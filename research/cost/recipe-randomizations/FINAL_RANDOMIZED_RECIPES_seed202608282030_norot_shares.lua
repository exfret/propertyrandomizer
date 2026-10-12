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
        {type="item", name="small-parts-01", amount=2},
        {type="item", name="stone-brick", amount=15},
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone", amount=123},
        {type="item", name="stone-brick", amount=59},
      },
      results = {
        {type="item", name="underground-belt", amount=2},
      },
    },
    ["lab"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=53},
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
        {type="item", name="bolts", amount=9},
        {type="item", name="burner-mining-drill", amount=1},
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
        {type="item", name="iron-stick", amount=2},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="small-electric-pole", amount=1},
      },
    },
    ["boiler"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=4},
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
        {type="item", name="copper-cable", amount=18},
        {type="item", name="pipe", amount=5},
        {type="item", name="small-parts-01", amount=8},
      },
      results = {
        {type="item", name="steam-engine", amount=1},
      },
    },
    ["burner-mining-drill"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=3},
        {type="item", name="stone-furnace", amount=2},
        {type="item", name="transport-belt", amount=8},
      },
      results = {
        {type="item", name="burner-mining-drill", amount=2},
      },
    },
    ["offshore-pump"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=6},
        {type="item", name="stone-brick", amount=17},
      },
      results = {
        {type="item", name="offshore-pump", amount=1},
      },
    },
    ["soil-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=72},
        {type="item", name="inductor1", amount=10},
        {type="item", name="lab", amount=1},
        {type="item", name="offshore-pump", amount=3},
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
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-ore", amount=247},
        {type="item", name="iron-stick", amount=77},
        {type="item", name="log", amount=5},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="transport-belt", amount=20},
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
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="copper-ore", amount=345},
        {type="item", name="iron-gear-wheel", amount=12},
        {type="item", name="iron-ore", amount=468},
        {type="item", name="iron-stick", amount=267},
        {type="item", name="stone", amount=247},
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
        {type="item", name="kerogen", amount=10},
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="soil", amount=5},
        {type="item", name="stone", amount=13},
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
        {type="item", name="copper-cable", amount=16},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-copper", amount=5},
      },
      results = {
        {type="item", name="copper-plate", amount=4},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="seaweed", amount=16},
      },
      results = {
        {type="item", name="raw-fiber", amount=2},
      },
    },
    ["glass-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-ore", amount=6},
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
        {type="fluid", name="steam", amount=236},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=27},
        {type="item", name="kerogen", amount=250},
        {type="item", name="lab", amount=2},
      },
      results = {
        {type="item", name="gun-turret", amount=3},
      },
    },
    ["muddy-sludge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="seaweed", amount=5},
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
        {type="item", name="limestone", amount=18},
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
        {type="item", name="raw-coal", amount=53},
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
        {type="item", name="iron-chest", amount=2},
        {type="item", name="iron-gear-wheel", amount=4},
        {type="item", name="saps", amount=2},
        {type="item", name="stone-furnace", amount=22},
      },
      results = {
        {type="item", name="shotgun", amount=1},
      },
    },
    ["submachine-gun"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=34},
        {type="item", name="pipe-to-ground", amount=1},
        {type="item", name="raw-coal", amount=514},
      },
      results = {
        {type="item", name="submachine-gun", amount=2},
      },
    },
    ["small-lamp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=9},
        {type="item", name="iron-stick", amount=2},
        {type="item", name="limestone", amount=9},
        {type="item", name="stone-brick", amount=5},
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
        {type="item", name="bolts", amount=16},
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="steam-engine", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2.94376152213681,
      ingredients = {
        {type="item", name="wood", amount=29},
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
        {type="fluid", name="vacuum", amount=1017},
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
        {type="item", name="ore-lead", amount=5},
      },
      results = {
        {type="item", name="aluminium-plate", amount=1},
      },
    },
    ["graphite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="log", amount=2},
      },
      results = {
        {type="item", name="graphite", amount=5},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=2},
        {type="item", name="pipe", amount=11},
      },
      results = {
        {type="item", name="duralumin", amount=1},
      },
    },
    ["tinned-cable"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=2},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="item", name="tinned-cable", amount=1},
      },
    },
    ["engine-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=4},
        {type="item", name="cellulose", amount=4},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="engine-unit", amount=1},
      },
    },
    ["iron-oxide-smelting"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=287},
      },
      results = {
        {type="item", name="iron-plate", amount=10},
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
        {type="item", name="burner-inserter", amount=9},
        {type="item", name="capacitor1", amount=47},
        {type="item", name="wooden-chest", amount=2},
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
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="tin-plate", amount=2},
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
        {type="fluid", name="steam", amount=537},
      },
      results = {
        {type="fluid", name="flue-gas", amount=150},
        {type="fluid", name="tailings", amount=500},
        {type="fluid", name="water-saline", amount=250},
        {type="item", name="soot", amount=2},
      },
    },
    ["chlorine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=2320},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1300},
      },
      results = {
        {type="fluid", name="acidgas", amount=15},
        {type="item", name="tailings-dust", amount=4},
      },
    },
    ["ash-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 9.94068558470902,
      ingredients = {
        {type="item", name="ash", amount=94},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="iron-oxide", amount=0.469004258293482},
        {type="item", name="soot", amount=2},
      },
    },
    ["soot-separation"] = {
      mode = "input-preserved-unmodified",
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
        {type="item", name="ore-aluminium", amount=47},
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
        {type="item", name="duralumin", amount=5},
        {type="item", name="ore-zinc", amount=34},
        {type="item", name="titanium-plate", amount=11},
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
        {type="item", name="iron-plate", amount=22},
        {type="item", name="small-parts-01", amount=77},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="bolts", amount=15},
        {type="item", name="raw-fiber", amount=11},
        {type="item", name="small-parts-01", amount=38},
      },
      results = {
        {type="item", name="py-tank-4000", amount=1},
      },
    },
    ["py-tank-8000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="concrete", amount=23},
        {type="item", name="copper-cable", amount=752},
        {type="item", name="glassworks-mk01", amount=2},
        {type="item", name="iron-gear-wheel", amount=30},
      },
      results = {
        {type="item", name="py-tank-8000", amount=3},
      },
    },
    ["py-tank-10000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=39},
        {type="item", name="moondrop-seeds", amount=196},
        {type="item", name="wood-seeds", amount=537},
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
        {type="item", name="aluminium-plate", amount=12},
        {type="item", name="glass", amount=12},
        {type="item", name="titanium-plate", amount=89},
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
        {type="item", name="empty-petri-dish", amount=23},
        {type="item", name="iron-plate", amount=17},
        {type="item", name="landfill", amount=1},
        {type="item", name="processed-iron-ore", amount=598},
      },
      results = {
        {type="item", name="py-tank-6500", amount=1},
      },
    },
    ["py-tank-7000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-chest", amount=40},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-parts-01", amount=103},
        {type="item", name="titanium-plate", amount=11},
      },
      results = {
        {type="item", name="py-tank-7000", amount=1},
      },
    },
    ["py-tank-5000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=6},
        {type="item", name="iron-plate", amount=9},
        {type="item", name="py-tank-1000", amount=3},
        {type="item", name="titanium-plate", amount=33},
      },
      results = {
        {type="item", name="py-tank-5000", amount=1},
      },
    },
    ["py-tank-9000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="light-oil-barrel", amount=56},
        {type="item", name="middle-oil-barrel", amount=4},
        {type="item", name="py-tank-4000", amount=8},
        {type="item", name="py-tank-8000", amount=2},
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
        {type="fluid", name="water", amount=2196},
        {type="item", name="cellulose", amount=2},
        {type="item", name="sand", amount=3},
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
        {type="fluid", name="water", amount=4131},
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
        {type="fluid", name="flue-gas", amount=414},
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
        {type="item", name="limestone", amount=7},
        {type="item", name="seaweed", amount=9},
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
        {type="fluid", name="carbon-dioxide", amount=523},
        {type="fluid", name="water", amount=3402},
        {type="item", name="iron-ore", amount=3},
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
        {type="fluid", name="water", amount=878},
        {type="item", name="gravel", amount=11},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="sand", amount=8},
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
        {type="fluid", name="pressured-water", amount=417},
        {type="item", name="gravel", amount=21},
        {type="item", name="wood-seeds", amount=26},
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
        {type="item", name="clay", amount=2},
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
        {type="item", name="iron-plate", amount=5},
        {type="item", name="pipe", amount=3},
        {type="item", name="saps", amount=1},
        {type="item", name="tin-plate", amount=2},
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
        {type="item", name="solder", amount=2},
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
        {type="item", name="ore-lead", amount=2},
        {type="item", name="raw-borax", amount=24},
        {type="item", name="zinc-plate", amount=1},
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
        {type="item", name="glass", amount=8},
        {type="item", name="lime", amount=27},
        {type="item", name="soil", amount=46},
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
        {type="item", name="boiler", amount=40},
        {type="item", name="log", amount=29},
        {type="item", name="shotgun", amount=1},
        {type="item", name="small-electric-pole", amount=10},
        {type="item", name="stone", amount=204},
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
        {type="item", name="iron-gear-wheel", amount=15},
        {type="item", name="ore-lead", amount=11},
        {type="item", name="pipe", amount=25},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-plate", amount=5},
        {type="item", name="stone", amount=203},
        {type="item", name="stone-wall", amount=9},
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
        {type="item", name="ash", amount=69},
        {type="item", name="bolts", amount=64},
        {type="item", name="limestone", amount=70},
        {type="item", name="pipe-to-ground", amount=2},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="soil", amount=103},
        {type="item", name="transport-belt", amount=11},
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
        {type="item", name="burner-inserter", amount=16},
        {type="item", name="kerogen", amount=45},
        {type="item", name="lab", amount=3},
        {type="item", name="sand", amount=43},
        {type="item", name="saps", amount=23},
        {type="item", name="small-parts-01", amount=10},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="distilator", amount=2},
        {type="item", name="iron-gear-wheel", amount=133},
        {type="item", name="processed-iron-ore", amount=207},
        {type="item", name="titanium-plate", amount=33},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk01", amount=3},
      },
    },
    ["iron-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="planter-box", amount=3},
      },
      results = {
        {type="item", name="iron-chest", amount=2},
      },
    },
    ["storage-tank"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=93},
        {type="item", name="concrete", amount=15},
        {type="item", name="copper-plate", amount=39},
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
        {type="item", name="burner-mining-drill", amount=5},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="planter-box", amount=2},
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
        {type="item", name="moss", amount=54},
        {type="item", name="moss-farm-mk01", amount=5},
        {type="item", name="py-check-valve", amount=18},
        {type="item", name="solder", amount=1},
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
        {type="item", name="seaweed", amount=7},
        {type="item", name="wooden-chest", amount=12},
      },
      results = {
        {type="item", name="small-electric-pole", amount=3},
      },
    },
    ["py-gas-vent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=38},
        {type="item", name="iron-gear-wheel", amount=15},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="py-gas-vent", amount=2},
      },
    },
    ["py-sinkhole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ash", amount=169},
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="kerogen", amount=384},
        {type="item", name="raw-coal", amount=1375},
        {type="item", name="small-parts-01", amount=15},
      },
      results = {
        {type="item", name="py-sinkhole", amount=2},
      },
    },
    ["retorter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=293},
        {type="item", name="copper-cable", amount=291},
        {type="item", name="iron-stick", amount=40},
        {type="item", name="stone-brick", amount=20},
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
        {type="item", name="pipe", amount=36},
      },
      results = {
        {type="item", name="steel-chest", amount=1},
      },
    },
    ["tree"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="agar", amount=4},
        {type="item", name="ceramic", amount=11},
      },
      results = {
        {type="item", name="tree-mk01", amount=3},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=14},
        {type="item", name="inductor1", amount=6},
        {type="item", name="iron-ore", amount=63},
        {type="item", name="iron-stick", amount=50},
        {type="item", name="stone", amount=290},
      },
      results = {
        {type="item", name="advanced-foundry-mk01", amount=1},
      },
    },
    ["borax-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=11},
        {type="item", name="ore-zinc", amount=377},
        {type="item", name="py-gas-vent", amount=1},
        {type="item", name="soil", amount=384},
        {type="item", name="soot", amount=42},
      },
      results = {
        {type="item", name="borax-mine", amount=1},
      },
    },
    ["distilator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=5},
        {type="item", name="copper-ore", amount=183},
        {type="item", name="copper-plate", amount=38},
        {type="item", name="inductor1", amount=6},
        {type="item", name="stone-furnace", amount=81},
        {type="item", name="wood-seeds", amount=41},
      },
      results = {
        {type="item", name="distilator", amount=2},
      },
    },
    ["fluid-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=5},
        {type="item", name="inductor1", amount=10},
        {type="item", name="iron-plate", amount=25},
        {type="item", name="poorman-wood-fence", amount=19},
        {type="item", name="transport-belt", amount=43},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=1},
      },
    },
    ["gasifier"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=69},
        {type="item", name="copper-cable", amount=103},
        {type="item", name="copper-plate", amount=23},
        {type="item", name="distilator", amount=1},
        {type="item", name="ore-aluminium", amount=68},
        {type="item", name="stone-furnace", amount=289},
      },
      results = {
        {type="item", name="gasifier", amount=2},
      },
    },
    ["glassworks-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=92},
        {type="item", name="copper-cable", amount=75},
        {type="item", name="copper-plate", amount=57},
        {type="item", name="distilator", amount=2},
        {type="item", name="planter-box", amount=3},
        {type="item", name="small-parts-01", amount=42},
      },
      results = {
        {type="item", name="glassworks-mk01", amount=3},
      },
    },
    ["hpf"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=97},
        {type="item", name="empty-planter-box", amount=11},
        {type="item", name="iron-gear-wheel", amount=7},
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="small-electric-pole", amount=3},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="hpf", amount=1},
      },
    },
    ["jaw-crusher"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=41},
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="burner-mining-drill", amount=13},
        {type="item", name="inductor1", amount=55},
      },
      results = {
        {type="item", name="jaw-crusher", amount=1},
      },
    },
    ["solid-separator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=61},
        {type="item", name="coal", amount=423},
        {type="item", name="light-armor", amount=3},
        {type="item", name="small-electric-pole", amount=97},
        {type="item", name="wooden-chest", amount=261},
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
        {type="item", name="burner-mining-drill", amount=18},
        {type="item", name="ore-aluminium", amount=136},
        {type="item", name="sand", amount=13},
        {type="item", name="small-electric-pole", amount=15},
        {type="item", name="steel-chest", amount=5},
        {type="item", name="stone-brick", amount=86},
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
        {type="item", name="lab", amount=3},
        {type="item", name="moss", amount=60},
        {type="item", name="planter-box", amount=3},
        {type="item", name="shotgun", amount=2},
        {type="item", name="stone-furnace", amount=55},
        {type="item", name="transport-belt", amount=40},
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
        {type="item", name="offshore-pump", amount=4},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="tin-plate", amount=40},
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
        {type="item", name="distilator", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=88},
        {type="item", name="iron-stick", amount=20},
        {type="item", name="tinned-cable", amount=8},
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
        {type="item", name="inductor1", amount=9},
        {type="item", name="iron-ore", amount=667},
        {type="item", name="soil", amount=299},
        {type="item", name="tailings-pond", amount=4},
        {type="item", name="underground-belt", amount=8},
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
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=32},
        {type="item", name="distilator", amount=1},
        {type="item", name="glassworks-mk01", amount=2},
        {type="item", name="iron-chest", amount=5},
        {type="item", name="transport-belt", amount=9},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=1},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=7},
        {type="item", name="bolts", amount=18},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=42},
        {type="item", name="iron-stick", amount=19},
        {type="item", name="wood-seeds", amount=298},
      },
      results = {
        {type="item", name="pulp-mill-mk01", amount=1},
      },
    },
    ["chipshooter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-aluminium", amount=1010},
        {type="item", name="repair-pack", amount=5},
        {type="item", name="rich-clay", amount=3},
        {type="item", name="sap-extractor-mk01", amount=1},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="vacuum-tube", amount=250},
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
        {type="item", name="clay-pit-mk01", amount=11},
        {type="item", name="coal-dust", amount=47},
        {type="item", name="lab", amount=2},
        {type="item", name="ore-titanium", amount=1042},
        {type="item", name="underground-belt", amount=4},
        {type="item", name="washer", amount=3},
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
        {type="fluid", name="pressured-water", amount=1356},
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
        {type="item", name="stone", amount=27},
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
        {type="item", name="coal-dust", amount=5},
        {type="item", name="copper-ore", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=50},
      },
    },
    ["saline-water"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="water", amount=106},
        {type="item", name="sand", amount=4},
      },
      results = {
        {type="fluid", name="water-saline", amount=53},
      },
    },
    ["biofactory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=39},
        {type="item", name="concrete", amount=652},
        {type="item", name="lead-plate", amount=202},
        {type="item", name="sand", amount=259},
        {type="item", name="stone-brick", amount=111},
        {type="item", name="tailings-dust", amount=82},
        {type="item", name="tin-plate", amount=16},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="bolts", amount=109},
        {type="item", name="capacitor1", amount=9},
        {type="item", name="empty-planter-box", amount=29},
        {type="item", name="glassworks-mk01", amount=2},
        {type="item", name="hpf", amount=3},
        {type="item", name="limestone", amount=291},
      },
      results = {
        {type="item", name="botanical-nursery", amount=2},
      },
    },
    ["creature-chamber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biofactory-mk01", amount=2},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="landfill", amount=36},
        {type="item", name="light-oil-barrel", amount=6},
        {type="item", name="lime", amount=317},
        {type="item", name="methane-barrel", amount=15},
        {type="item", name="petri-dish", amount=7},
        {type="item", name="pipe", amount=60},
      },
      results = {
        {type="item", name="creature-chamber-mk01", amount=1},
      },
    },
    ["incubator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=89},
        {type="item", name="distilator", amount=1},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="ore-aluminium", amount=858},
        {type="item", name="small-lamp", amount=24},
        {type="item", name="soil-extractor-mk01", amount=5},
      },
      results = {
        {type="item", name="incubator-mk01", amount=3},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="concrete", amount=49},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="pipe", amount=142},
        {type="item", name="poorman-wood-fence", amount=141},
        {type="item", name="titanium-plate", amount=19},
      },
      results = {
        {type="item", name="micro-mine-mk01", amount=3},
      },
    },
    ["rc-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="hazard-concrete", amount=341},
        {type="item", name="iron-stick", amount=357},
        {type="item", name="ore-lead", amount=315},
        {type="item", name="outpost-fluid", amount=4},
        {type="item", name="pipe-to-ground", amount=14},
        {type="item", name="py-gas-vent", amount=1},
        {type="item", name="soil", amount=4566},
        {type="item", name="stone", amount=1627},
        {type="item", name="tin-plate", amount=93},
      },
      results = {
        {type="item", name="rc-mk01", amount=1},
      },
    },
    ["genlab-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="capacitor1", amount=1128},
        {type="item", name="lead-plate", amount=249},
        {type="item", name="pipe", amount=186},
        {type="item", name="py-tank-9000", amount=2},
        {type="item", name="rc-mk01", amount=2},
        {type="item", name="steam-engine", amount=6},
        {type="item", name="tailings-dust", amount=677},
        {type="item", name="tin-plate", amount=42},
      },
      results = {
        {type="item", name="genlab-mk01", amount=3},
      },
    },
    ["research-center-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=340},
        {type="item", name="capacitor1", amount=1221},
        {type="item", name="concrete", amount=232},
        {type="item", name="copper-plate", amount=57},
        {type="item", name="empty-petri-dish", amount=8},
        {type="item", name="submachine-gun", amount=2},
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
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="concrete", amount=26},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="ore-chromium", amount=2183},
        {type="item", name="petri-dish-bacteria", amount=5},
        {type="item", name="py-tank-4000", amount=26},
        {type="item", name="transport-belt", amount=100},
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
        {type="item", name="coke", amount=8},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="gate", amount=1},
      },
    },
    ["poorman-wood-fence"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ash", amount=5},
      },
      results = {
        {type="item", name="poorman-wood-fence", amount=2},
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
        {type="item", name="calcium-carbide", amount=869},
        {type="item", name="concrete", amount=869},
        {type="item", name="pcb1", amount=2},
        {type="item", name="vacuum-tube", amount=11},
        {type="item", name="wpu-mk01", amount=1},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=1},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=86},
        {type="item", name="copper-cable", amount=41},
        {type="item", name="log", amount=55},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=2},
      },
    },
    ["bio-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=3},
        {type="item", name="seaweed", amount=7},
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
        {type="item", name="automation-science-pack", amount=15},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="tin-plate", amount=52},
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
        {type="item", name="refined-hazard-concrete", amount=1},
        {type="item", name="seaweed", amount=2},
        {type="item", name="sodium-hydroxide", amount=2},
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
        {type="item", name="pipe", amount=4},
        {type="item", name="resistor1", amount=204},
        {type="item", name="small-lamp", amount=8},
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
        {type="item", name="bio-sample", amount=47},
        {type="item", name="empty-petri-dish", amount=18},
        {type="item", name="moondrop-codex", amount=2},
        {type="item", name="seaweed", amount=5},
        {type="item", name="sodium-hydroxide", amount=38},
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
        {type="item", name="assembling-machine-1", amount=12},
        {type="item", name="copper-ore", amount=177},
        {type="item", name="ore-titanium", amount=69},
        {type="item", name="processed-iron-ore", amount=87},
        {type="item", name="seaweed", amount=570},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="vrauks-paddock-mk01", amount=1},
      },
    },
    ["vrauks-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cocoon", amount=10},
        {type="item", name="coke", amount=6},
        {type="item", name="moss", amount=5},
        {type="item", name="pressured-water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=2},
      },
    },
    ["fluidavan"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=5800},
        {type="item", name="acetylene-barrel", amount=57},
        {type="item", name="acetylene-canister", amount=16},
        {type="item", name="carbon-dioxide-barrel", amount=3},
        {type="item", name="guts", amount=18},
        {type="item", name="inserter", amount=2},
        {type="item", name="middle-oil-barrel", amount=25},
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
        {type="item", name="naphthalene-oil-canister", amount=31},
        {type="item", name="ore-aluminium", amount=1413},
        {type="item", name="ore-tin", amount=619},
        {type="item", name="pressured-air-barrel", amount=4},
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
        {type="fluid", name="water", amount=106},
        {type="item", name="coal-dust", amount=2},
        {type="item", name="graphite", amount=4},
        {type="item", name="stone", amount=19},
      },
      results = {
        {type="item", name="concrete", amount=5},
      },
    },
    ["stone-brick-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=50},
        {type="item", name="gravel", amount=3},
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
        {type="item", name="stone-furnace", amount=25},
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
        {type="fluid", name="vacuum", amount=200},
        {type="item", name="glass", amount=5},
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
        {type="item", name="copper-ore", amount=32},
        {type="item", name="sand", amount=19},
        {type="item", name="stone", amount=30},
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
        {type="item", name="stone-brick", amount=43},
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
        {type="item", name="coal", amount=14},
        {type="item", name="graphite", amount=6},
        {type="item", name="landfill", amount=2},
        {type="item", name="offshore-pump", amount=4},
        {type="item", name="transport-belt", amount=72},
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
        {type="item", name="inductor1", amount=51},
        {type="item", name="iron-ore", amount=243},
        {type="item", name="lead-plate", amount=38},
        {type="item", name="ore-lead", amount=9},
        {type="item", name="stone", amount=317},
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
        {type="item", name="distilator", amount=1},
        {type="item", name="lead-plate", amount=11},
        {type="item", name="log", amount=147},
        {type="item", name="moss-farm-mk01", amount=4},
        {type="item", name="pipe", amount=1909},
        {type="item", name="tailings-dust", amount=549},
      },
      results = {
        {type="item", name="data-array", amount=1},
      },
    },
    ["creamy-latex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="copper-ore", amount=14},
        {type="item", name="limestone", amount=2},
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
        {type="fluid", name="water", amount=100},
        {type="item", name="coal", amount=2},
        {type="item", name="sand", amount=4},
        {type="item", name="stone", amount=5},
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
        {type="fluid", name="water", amount=1365},
        {type="item", name="seaweed", amount=13},
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
        {type="item", name="copper-ore", amount=35},
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
        {type="fluid", name="muddy-sludge", amount=200},
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
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="ore-lead", amount=35},
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
        {type="item", name="copper-plate", amount=6},
        {type="item", name="iron-stick", amount=2},
        {type="item", name="sodium-alginate", amount=1},
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
        {type="item", name="capacitor1", amount=1},
        {type="item", name="gravel", amount=388},
        {type="item", name="pipe", amount=1},
        {type="item", name="small-electric-pole", amount=2},
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
        {type="item", name="iron-ore", amount=27},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="pipe-to-ground", amount=9},
      },
      results = {
        {type="item", name="py-overflow-valve", amount=1},
      },
    },
    ["py-local-radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=19},
        {type="item", name="concrete", amount=79},
        {type="item", name="pipe", amount=9},
        {type="item", name="stone-brick", amount=33},
      },
      results = {
        {type="item", name="py-local-radar", amount=1},
      },
    },
    ["radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="native-flora", amount=97},
        {type="item", name="ore-aluminium", amount=50},
        {type="item", name="soot", amount=68},
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
        {type="fluid", name="water", amount=5800},
        {type="item", name="ore-zinc", amount=117},
        {type="item", name="pipe", amount=8},
        {type="item", name="seaweed", amount=84},
      },
      results = {
        {type="item", name="battery-mk00", amount=1},
      },
    },
    ["electrolyzer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="fawogae-substrate", amount=35},
        {type="item", name="lead-plate", amount=25},
        {type="item", name="resistor1", amount=197},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="electrolyzer-mk01", amount=1},
      },
    },
    ["smelter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=579},
        {type="item", name="concrete", amount=30},
        {type="item", name="iron-stick", amount=71},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="moondrop", amount=37},
        {type="item", name="pipe", amount=126},
        {type="item", name="py-overflow-valve", amount=5},
        {type="item", name="resistor1", amount=204},
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
        {type="item", name="concrete", amount=87},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="stone-brick", amount=26},
      },
      results = {
        {type="item", name="inserter", amount=1},
      },
    },
    ["methane-co2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="seaweed", amount=4},
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
        {type="item", name="copper-cable", amount=9},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="graphite", amount=4},
        {type="item", name="iron-stick", amount=18},
      },
      results = {
        {type="item", name="inductor1", amount=5},
      },
    },
    ["resistor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clay", amount=1},
        {type="item", name="glass", amount=1},
        {type="item", name="limestone", amount=19},
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
        {type="fluid", name="water-saline", amount=220},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="lime", amount=10},
        {type="item", name="saps", amount=10},
      },
      results = {
        {type="item", name="formica", amount=1},
      },
    },
    ["vacuum-tube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=61},
        {type="item", name="coke", amount=6},
        {type="item", name="glass", amount=2},
        {type="item", name="pipe", amount=4},
        {type="item", name="soil", amount=16},
      },
      results = {
        {type="item", name="vacuum-tube", amount=2},
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
        {type="item", name="copper-cable", amount=83},
        {type="item", name="copper-plate", amount=16},
        {type="item", name="formica", amount=2},
        {type="item", name="pipe", amount=7},
        {type="item", name="refined-hazard-concrete", amount=6},
        {type="item", name="vacuum-tube", amount=3},
      },
      results = {
        {type="item", name="electronic-circuit", amount=3},
      },
    },
    ["olefin-plant"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="inductor1", amount=396},
        {type="item", name="offshore-pump", amount=438},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="reformer-mk01", amount=2},
        {type="item", name="small-electric-pole", amount=47},
      },
      results = {
        {type="item", name="olefin-plant", amount=3},
      },
    },
    ["reformer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="concrete", amount=2462},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="graphite", amount=471},
        {type="item", name="processed-iron-ore", amount=822},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="reformer-mk01", amount=2},
      },
    },
    ["splitter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="pipe", amount=8},
        {type="item", name="titanium-plate", amount=41},
        {type="item", name="underground-belt", amount=1},
      },
      results = {
        {type="item", name="splitter", amount=2},
      },
    },
    ["moondrop-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=200},
        {type="item", name="moondrop-seeds", amount=4},
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
        {type="fluid", name="pressured-water", amount=833},
        {type="item", name="coal-dust", amount=135},
        {type="item", name="empty-petri-dish", amount=4},
        {type="item", name="sand", amount=18},
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
        {type="item", name="fish", amount=10},
        {type="item", name="iron-ore", amount=1013},
        {type="item", name="pipe", amount=21},
        {type="item", name="py-check-valve", amount=4},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-wall", amount=8},
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
        {type="item", name="moss-gen", amount=2},
        {type="item", name="stopper", amount=7},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=3},
      },
    },
    ["agar"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="seaweed", amount=5},
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
        {type="item", name="coal", amount=7},
        {type="item", name="seaweed", amount=3},
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
        {type="item", name="stone-brick", amount=15},
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
        {type="item", name="guts", amount=10},
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
        {type="item", name="petri-dish", amount=2},
        {type="item", name="sand", amount=8},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="latex", amount=2},
        {type="item", name="wood", amount=5},
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
        {type="fluid", name="hydrogen", amount=1857},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="flask", amount=2},
      },
    },
    ["petri-dish"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=1},
        {type="item", name="empty-petri-dish", amount=1},
      },
      results = {
        {type="item", name="petri-dish", amount=1},
      },
    },
    ["scrude-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=196},
        {type="fluid", name="vacuum", amount=6624},
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
        {type="fluid", name="tar", amount=100},
        {type="fluid", name="water", amount=1100},
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
        {type="fluid", name="tar", amount=386},
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
        {type="fluid", name="pitch", amount=100},
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
        {type="fluid", name="pitch", amount=467},
        {type="fluid", name="steam", amount=100},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=50},
        {type="fluid", name="light-oil", amount=50},
        {type="fluid", name="naphthalene-oil", amount=100},
      },
    },
    ["anthracene-gasoline-cracking"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=156},
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
        {type="fluid", name="pitch", amount=538},
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
        {type="item", name="soil", amount=24},
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=29},
        {type="item", name="bolts", amount=32},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="petri-dish", amount=5},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="soil", amount=228},
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
        {type="fluid", name="water", amount=6071},
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
        {type="fluid", name="pitch", amount=467},
        {type="fluid", name="water", amount=77},
        {type="item", name="guts", amount=15},
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
        {type="item", name="copper-plate", amount=9},
        {type="item", name="duralumin", amount=5},
        {type="item", name="iron-plate", amount=141},
        {type="item", name="saps", amount=12},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="assembling-machine-2", amount=1},
      },
    },
    ["crushed-coal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3.09417350624166,
      ingredients = {
        {type="item", name="copper-ore", amount=9},
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
        {type="fluid", name="coal-gas", amount=7341},
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
        {type="fluid", name="chlorine", amount=947},
        {type="fluid", name="water", amount=90},
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
        {type="item", name="melamine-resin", amount=12},
      },
      results = {
        {type="fluid", name="molten-salt", amount=100},
      },
    },
    ["coal-molten-salt-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-salt", amount=500},
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
        {type="fluid", name="hydrogen", amount=154},
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
        {type="fluid", name="gasoline", amount=2811},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["borax-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.10153866243052,
      ingredients = {
        {type="fluid", name="steam", amount=108},
        {type="item", name="gunpowder", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=111},
        {type="item", name="borax", amount=11},
      },
    },
    ["diborane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=125},
        {type="item", name="sand-casting", amount=3},
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
        {type="fluid", name="hydrogen", amount=179},
        {type="fluid", name="oxygen", amount=251},
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
        {type="fluid", name="oxygen", amount=2741},
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
        {type="item", name="lime", amount=4},
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
        {type="item", name="soil", amount=150},
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
        {type="item", name="petri-dish", amount=1},
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
        {type="fluid", name="vacuum", amount=504},
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
        {type="fluid", name="pitch", amount=750},
        {type="item", name="aromatics-barrel", amount=487},
        {type="item", name="condensates-canister", amount=47},
        {type="item", name="log", amount=23},
        {type="item", name="tailings-dust", amount=143},
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
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="pipe", amount=8},
        {type="item", name="transport-belt", amount=8},
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
        {type="item", name="aluminium-plate", amount=26},
        {type="item", name="bio-sample", amount=4},
        {type="item", name="electric-mining-drill", amount=14},
        {type="item", name="gravel", amount=5},
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
        {type="item", name="coke", amount=356},
        {type="item", name="concrete", amount=815},
        {type="item", name="glass", amount=2},
        {type="item", name="heavy-oil-canister", amount=2},
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
        {type="item", name="coal-dust", amount=19},
        {type="item", name="ore-chromium", amount=42},
        {type="item", name="pipe-to-ground", amount=2},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="resistor1", amount=3},
        {type="item", name="syngas-canister", amount=2},
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
        {type="item", name="light-armor", amount=2},
        {type="item", name="pump", amount=9},
        {type="item", name="rich-clay", amount=105},
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-copper", amount=7},
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
        {type="item", name="grade-2-ti", amount=9},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-zinc", amount=6},
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
        {type="item", name="ceramic", amount=4},
        {type="item", name="rich-clay", amount=14},
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
        {type="fluid", name="steam", amount=326},
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
        {type="item", name="ore-lead", amount=3},
        {type="item", name="shotgun-shell", amount=6},
        {type="item", name="stone-wall", amount=2},
      },
      results = {
        {type="item", name="piercing-rounds-magazine", amount=2},
      },
    },
    ["py-asphalt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=202},
        {type="item", name="gravel", amount=9},
        {type="item", name="moondrop-seeds", amount=3},
      },
      results = {
        {type="item", name="py-asphalt", amount=2},
      },
    },
    ["py-iron-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=88},
        {type="item", name="gravel", amount=66},
        {type="item", name="pipe", amount=1},
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
        {type="item", name="gravel", amount=7},
        {type="item", name="seaweed", amount=9},
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
        {type="item", name="engine-unit", amount=2},
        {type="item", name="lead-plate", amount=35},
        {type="item", name="ore-quartz", amount=33},
        {type="item", name="small-parts-01", amount=4},
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
        {type="item", name="grade-2-ti", amount=4},
        {type="item", name="hydrogen-barrel", amount=11},
        {type="item", name="oxygen-barrel", amount=3},
        {type="item", name="pressured-water-barrel", amount=74},
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
        {type="item", name="duralumin", amount=17},
        {type="item", name="lead-plate", amount=4},
        {type="item", name="pipe", amount=30},
        {type="item", name="sodium-hydroxide", amount=5},
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
        {type="item", name="condensates-barrel", amount=1},
        {type="item", name="log", amount=5},
        {type="item", name="seaweed", amount=796},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="aluminium-plate", amount=49},
        {type="item", name="glass", amount=535},
        {type="item", name="small-parts-01", amount=7},
        {type="item", name="vrauks", amount=1},
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
        {type="item", name="grade-2-copper", amount=11},
        {type="item", name="kerogen", amount=12},
        {type="item", name="lead-plate", amount=35},
        {type="item", name="raw-coal", amount=1},
        {type="item", name="steel-plate", amount=1},
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
        {type="item", name="chlorine-barrel", amount=2},
        {type="item", name="py-asphalt", amount=1},
      },
      results = {
        {type="item", name="rail-signal", amount=1},
      },
    },
    ["rail-chain-signal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-copper", amount=5},
        {type="item", name="hydrogen-barrel", amount=7},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=2},
      },
    },
    ["train-stop"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=31},
        {type="item", name="coal-gas-barrel", amount=17},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="meat", amount=1},
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
        {type="item", name="grade-1-copper", amount=4},
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
      energy_required_multiplier = 1.04920100925147,
      ingredients = {
        {type="item", name="antimonium-ore", amount=13},
      },
      results = {
        {type="item", name="sb-grade-02", amount=10},
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
        {type="item", name="duralumin", amount=5},
        {type="item", name="small-parts-01", amount=7},
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
        {type="item", name="processed-iron-ore", amount=151},
        {type="item", name="solder", amount=7},
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
        {type="item", name="concrete", amount=27},
        {type="item", name="inductor1", amount=11},
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
        {type="item", name="ceramic", amount=7},
        {type="item", name="seaweed", amount=84},
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
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fenxsb-alloy", amount=8},
        {type="item", name="graphite", amount=9},
        {type="item", name="iron-plate", amount=25},
        {type="item", name="nickel-plate", amount=3},
        {type="item", name="pipe", amount=35},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="brake-mk01", amount=1},
      },
    },
    ["electronics-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=1},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="formica", amount=5},
        {type="item", name="glass", amount=4},
        {type="item", name="inductor1", amount=5},
        {type="item", name="pipe", amount=4},
        {type="item", name="small-lamp", amount=6},
        {type="item", name="stone-brick", amount=38},
      },
      results = {
        {type="item", name="electronics-mk01", amount=1},
      },
    },
    ["shaft-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="nexelit-plate", amount=48},
        {type="item", name="solder", amount=14},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="shaft-mk01", amount=3},
      },
    },
    ["utility-box-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="dried-meat", amount=59},
        {type="item", name="duralumin", amount=5},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="pipe", amount=8},
        {type="item", name="plastic-bar", amount=5},
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
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="seaweed", amount=69},
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
        {type="item", name="bolts", amount=6},
        {type="item", name="ceramic", amount=211},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="ore-nickel", amount=3},
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
        {type="item", name="pipe", amount=84},
        {type="item", name="tin-plate", amount=9},
      },
      results = {
        {type="item", name="gearbox-mk01", amount=2},
      },
    },
    ["nacelle-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=147},
        {type="item", name="acetylene-canister", amount=63},
        {type="item", name="anemometer-mk01", amount=9},
        {type="item", name="boiler", amount=13},
        {type="item", name="condensates-canister", amount=91},
        {type="item", name="melamine", amount=123},
        {type="item", name="pbsb-alloy", amount=17},
        {type="item", name="pipe", amount=543},
        {type="item", name="ralesia-codex", amount=4},
        {type="item", name="rhe", amount=12},
        {type="item", name="secondary-crusher-mk01", amount=4},
      },
      results = {
        {type="item", name="nacelle-mk01", amount=3},
      },
    },
    ["tower-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=142},
        {type="item", name="electronic-circuit", amount=13},
        {type="item", name="ore-chromium", amount=51},
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
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="belt", amount=30},
        {type="item", name="iron-plate", amount=355},
        {type="item", name="lead-plate", amount=84},
        {type="item", name="titanium-plate", amount=60},
      },
      results = {
        {type="item", name="yaw-drive-mk01", amount=1},
      },
    },
    ["rotor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=24},
        {type="item", name="iron-stick", amount=122},
        {type="item", name="treated-wood", amount=28},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="rotor-mk01", amount=3},
      },
    },
    ["animal-sample-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=298},
        {type="item", name="agar", amount=8},
        {type="item", name="condensates-canister", amount=1},
        {type="item", name="grade-1-zinc", amount=12},
        {type="item", name="grade-2-copper", amount=12},
        {type="item", name="landfill", amount=1},
        {type="item", name="retrovirus", amount=1},
        {type="item", name="syngas-canister", amount=1},
      },
      results = {
        {type="item", name="animal-sample-01", amount=1},
      },
    },
    ["bio-sample01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=21},
        {type="item", name="moss", amount=3},
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
        {type="item", name="titanium-plate", amount=8},
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
        {type="item", name="limestone", amount=5},
      },
      results = {
        {type="item", name="ground-sample01", amount=10},
      },
    },
    ["rich-clay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="steam", amount=258},
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="rich-clay", amount=8},
      },
    },
    ["sand-casting"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=250},
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
        {type="item", name="sand", amount=78},
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
        {type="item", name="pipe", amount=18},
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
        {type="item", name="ore-titanium", amount=4},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=1},
        {type="item", name="stone", amount=1},
      },
    },
    ["chromium-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="water", amount=687},
        {type="item", name="boron-trioxide", amount=4},
        {type="item", name="ground-sample01", amount=1},
        {type="item", name="sand", amount=6},
      },
      results = {
        {type="item", name="chromium", amount=6},
      },
    },
    ["tier-0-chromite-sand"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-ti", amount=1},
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
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="item", name="borax", amount=4},
        {type="item", name="ceramic", amount=4},
        {type="item", name="sb-grade-03", amount=2},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=13},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="item", name="coke", amount=5},
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
        {type="item", name="ore-nickel", amount=6},
      },
      results = {
        {type="item", name="crushed-quartz", amount=2},
        {type="item", name="stone", amount=1},
      },
    },
    ["sand-classification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.9984162235643,
      ingredients = {
        {type="item", name="limestone", amount=29},
      },
      results = {
        {type="item", name="crushed-quartz", amount=0.0944570973767676},
        {type="item", name="gravel", amount=8},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["glass-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sand", amount=9},
      },
      results = {
        {type="fluid", name="molten-glass", amount=30},
      },
    },
    ["hotair-molten-glass"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=124},
        {type="fluid", name="steam", amount=978},
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
        {type="item", name="iron-plate", amount=469},
        {type="item", name="ore-lead", amount=175},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="repair-pack", amount=39},
        {type="item", name="storage-tank", amount=1},
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
        {type="item", name="iron-plate", amount=467},
        {type="item", name="offshore-pump", amount=25},
        {type="item", name="pipe", amount=31},
        {type="item", name="plastic-bar", amount=35},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="tar-barrel", amount=46},
        {type="item", name="titanium-plate", amount=84},
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
        {type="item", name="bolts", amount=71},
        {type="item", name="condensates-barrel", amount=61},
        {type="item", name="lab", amount=2},
        {type="item", name="mechanical-parts-01", amount=11},
        {type="item", name="naphthalene-oil-barrel", amount=28},
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
        {type="item", name="biomass", amount=7222},
        {type="item", name="duralumin", amount=258},
        {type="item", name="fiberboard", amount=371},
        {type="item", name="firearm-magazine", amount=43},
        {type="item", name="iron-plate", amount=300},
        {type="item", name="lab", amount=8},
        {type="item", name="nexelit-plate", amount=1141},
        {type="item", name="sb-oxide", amount=21},
        {type="item", name="vacuum-barrel", amount=5},
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
        {type="item", name="anthracene-oil-canister", amount=40},
        {type="item", name="bolts", amount=326},
        {type="item", name="ceramic", amount=1028},
        {type="item", name="concrete", amount=1630},
        {type="item", name="cracker-mk01", amount=2},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="glass", amount=2357},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="nexelit-plate", amount=1951},
        {type="item", name="sap-extractor-mk01", amount=5},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=1},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-codex", amount=2},
        {type="item", name="clay-pit-mk01", amount=7},
        {type="item", name="grenade", amount=42},
        {type="item", name="lime", amount=1025},
        {type="item", name="py-tank-8000", amount=1},
        {type="item", name="rich-clay", amount=8},
        {type="item", name="small-parts-01", amount=201},
        {type="item", name="titanium-plate", amount=60},
        {type="item", name="tower-mk01", amount=2},
        {type="item", name="zogna-bacteria-barrel", amount=8},
      },
      results = {
        {type="item", name="steam-turbine-mk01", amount=1},
      },
    },
    ["tidal-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-paddock-mk01", amount=2},
        {type="item", name="belt", amount=367},
        {type="item", name="chromite-sand", amount=25},
        {type="item", name="clean-nexelit", amount=546},
        {type="item", name="cyanic-acid-barrel", amount=19},
        {type="item", name="gasoline-barrel", amount=42},
        {type="item", name="inductor1", amount=150},
        {type="item", name="naphthalene-oil-barrel", amount=9},
        {type="item", name="ralesia-seeds", amount=696},
        {type="item", name="vane-mk01", amount=8},
        {type="item", name="vrauks", amount=11},
        {type="item", name="yaw-drive-mk01", amount=1},
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
        {type="item", name="advanced-foundry-mk01", amount=1},
        {type="item", name="auog-codex", amount=4},
        {type="item", name="copper-ore", amount=250},
        {type="item", name="creamy-latex-barrel", amount=30},
        {type="item", name="fluid-wagon", amount=1},
        {type="item", name="geothermal-water-barrel", amount=29},
        {type="item", name="guts", amount=45},
        {type="item", name="kerosene-barrel", amount=40},
        {type="item", name="moondrop", amount=33},
        {type="item", name="naphthalene-oil-barrel", amount=2},
        {type="item", name="pitch-barrel", amount=5},
        {type="item", name="pressured-water-barrel", amount=61},
        {type="item", name="solder", amount=49},
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
        {type="item", name="concrete", amount=822},
        {type="item", name="cottongut-mk01", amount=21},
        {type="item", name="engine-unit", amount=20},
        {type="item", name="moondrop-seeds", amount=624},
        {type="item", name="resistor1", amount=2146},
        {type="item", name="secondary-crusher-mk01", amount=1},
        {type="item", name="steam-engine", amount=20},
        {type="item", name="vitreloy", amount=62},
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
        {type="item", name="cyanic-acid-barrel", amount=1},
        {type="item", name="hydrogen-barrel", amount=17},
        {type="item", name="pipe", amount=5},
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
        {type="item", name="molten-glass-barrel", amount=5},
        {type="item", name="saps", amount=4},
        {type="item", name="wood-fence", amount=8},
      },
      results = {
        {type="item", name="constant-combinator", amount=1},
      },
    },
    ["decider-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="melamine-resin", amount=36},
        {type="item", name="pipe", amount=16},
        {type="item", name="shaft-mk01", amount=4},
      },
      results = {
        {type="item", name="decider-combinator", amount=3},
      },
    },
    ["display-panel"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="iron-plate", amount=1},
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
        {type="item", name="crushed-quartz", amount=496},
        {type="item", name="fawogae-spore", amount=7},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="pipe-to-ground", amount=10},
      },
      results = {
        {type="item", name="power-switch", amount=1},
      },
    },
    ["programmable-speaker"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=1},
        {type="item", name="inductor1", amount=1},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="stone", amount=9},
      },
      results = {
        {type="item", name="programmable-speaker", amount=1},
      },
    },
    ["selector-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arithmetic-combinator", amount=1},
        {type="item", name="moondrop-seeds", amount=720},
        {type="item", name="workers-food", amount=3},
      },
      results = {
        {type="item", name="selector-combinator", amount=1},
      },
    },
    ["fiberboard"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=1533},
        {type="item", name="ceramic", amount=6},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="treated-wood", amount=3},
      },
      results = {
        {type="fluid", name="black-liquor", amount=10},
        {type="fluid", name="tall-oil", amount=15},
        {type="item", name="fiberboard", amount=4},
      },
    },
    ["urea-decomposition"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="urea", amount=20},
      },
      results = {
        {type="fluid", name="ammonia", amount=30},
        {type="fluid", name="cyanic-acid", amount=30},
      },
    },
    ["black-liquor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="black-liquor", amount=80},
        {type="fluid", name="steam", amount=365},
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
        {type="fluid", name="oxygen", amount=598},
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
        {type="fluid", name="syngas", amount=399},
        {type="fluid", name="vacuum", amount=400},
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
        {type="fluid", name="hydrogen", amount=219},
      },
      results = {
        {type="fluid", name="water", amount=400},
      },
    },
    ["flue-gas-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 0.973333333333333,
      ingredients = {
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=146},
      },
    },
    ["flue-gas-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=226},
        {type="item", name="limestone", amount=3},
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
        {type="item", name="automation-science-pack", amount=8},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="concrete", amount=16},
        {type="item", name="empty-planter-box", amount=13},
        {type="item", name="glass", amount=21},
        {type="item", name="inductor1", amount=150},
        {type="item", name="petri-dish", amount=5},
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
        {type="item", name="brain", amount=21},
        {type="item", name="fiberboard", amount=111},
        {type="item", name="formica", amount=5},
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="ore-tin", amount=78},
        {type="item", name="refined-hazard-concrete", amount=167},
        {type="item", name="sap-tree", amount=1},
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
        {type="item", name="advanced-foundry-mk01", amount=1},
        {type="item", name="burner-mining-drill", amount=15},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="gasifier", amount=1},
        {type="item", name="iron-plate", amount=355},
        {type="item", name="lead-plate", amount=7},
        {type="item", name="plastic-bar", amount=154},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="titanium-plate", amount=15},
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
        {type="item", name="capacitor1", amount=453},
        {type="item", name="gasoline-barrel", amount=19},
        {type="item", name="glass", amount=589},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="moondrop", amount=8},
        {type="item", name="tailings-barrel", amount=182},
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
        {type="item", name="cottongut-codex", amount=3},
        {type="item", name="py-science-pack-1", amount=110},
        {type="item", name="sodium-hydroxide", amount=774},
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
        {type="item", name="agar", amount=761},
        {type="item", name="bio-sample", amount=26},
        {type="item", name="cottongut-codex", amount=1},
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
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="vrauks-codex", amount=8},
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
        {type="item", name="auog-codex", amount=4},
        {type="item", name="iron-plate", amount=3390},
        {type="item", name="moss-gen", amount=19},
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
        {type="fluid", name="oxygen", amount=60},
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
        {type="item", name="limestone", amount=4},
        {type="item", name="processed-iron-ore", amount=3},
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
        {type="item", name="graphite", amount=1},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=60},
      },
    },
    ["mechanical-parts-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=4},
        {type="item", name="belt", amount=6},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="iron-plate", amount=178},
        {type="item", name="py-overflow-valve", amount=9},
        {type="item", name="rail", amount=5},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=3},
      },
    },
    ["sb-oxide-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="vacuum", amount=1080},
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
        {type="item", name="ceramic", amount=16},
        {type="item", name="lead-plate", amount=6},
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
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="ceramic", amount=3},
        {type="item", name="clay", amount=7},
        {type="item", name="glass", amount=1},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="pbsb-alloy", amount=1},
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
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="seaweed", amount=3},
        {type="item", name="tailings-barrel", amount=6},
      },
      results = {
        {type="item", name="accumulator", amount=1},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=9},
        {type="item", name="pipe", amount=2},
        {type="item", name="sb-oxide", amount=1},
      },
      results = {
        {type="item", name="fenxsb-alloy", amount=2},
      },
    },
    ["vitreloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=38},
        {type="item", name="copper-ore", amount=50},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="pbsb-alloy", amount=3},
        {type="item", name="tin-plate", amount=7},
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
        {type="item", name="antimonium-ore", amount=265},
        {type="item", name="duralumin", amount=3},
        {type="item", name="naphthalene-oil-barrel", amount=3},
        {type="item", name="pipe", amount=235},
        {type="item", name="raw-coal", amount=176},
        {type="item", name="seaweed", amount=91},
        {type="item", name="tinned-cable", amount=68},
        {type="item", name="water-saline-barrel", amount=33},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=1},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="concrete", amount=23},
        {type="item", name="distilator", amount=1},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="tinned-cable", amount=34},
        {type="item", name="titanium-plate", amount=11},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=1},
      },
    },
    ["classifier"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bonemeal", amount=7},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fiberboard", amount=37},
        {type="item", name="middle-oil-canister", amount=7},
        {type="item", name="soil", amount=397},
        {type="item", name="syngas-canister", amount=1},
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
        {type="item", name="acetylene-canister", amount=9},
        {type="item", name="agar", amount=6},
        {type="item", name="duralumin", amount=56},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="gasoline-canister", amount=4},
        {type="item", name="grade-3-ti", amount=81},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe-to-ground", amount=3},
        {type="item", name="repair-pack", amount=5},
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
        {type="item", name="dried-meat", amount=65},
        {type="item", name="duralumin", amount=7},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="pipe", amount=117},
        {type="item", name="refined-concrete", amount=74},
        {type="item", name="storage-chest", amount=2},
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
        {type="item", name="calcium-carbide", amount=656},
        {type="item", name="carbon-black", amount=121},
        {type="item", name="chlorine-barrel", amount=6},
        {type="item", name="condensates-barrel", amount=8},
        {type="item", name="crushed-coal", amount=165},
        {type="item", name="dried-meat", amount=7},
        {type="item", name="slacked-lime-barrel", amount=12},
      },
      results = {
        {type="item", name="fluid-drill-mk02", amount=1},
      },
    },
    ["bof-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="ceramic", amount=25},
        {type="item", name="pipe", amount=66},
        {type="item", name="resistor1", amount=405},
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="bof-mk01", amount=2},
      },
    },
    ["casting-unit-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=42},
        {type="item", name="diborane-barrel", amount=6},
        {type="item", name="grade-1-chromite", amount=40},
        {type="item", name="nexelit-plate", amount=863},
        {type="item", name="py-burner", amount=1},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="vacuum-pump-mk01", amount=2},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=2},
      },
    },
    ["eaf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain", amount=7},
        {type="item", name="clay", amount=78},
        {type="item", name="duralumin", amount=34},
        {type="item", name="pipe", amount=352},
        {type="item", name="py-limestone", amount=8},
        {type="item", name="solder", amount=19},
        {type="item", name="stone-wall", amount=51},
      },
      results = {
        {type="item", name="eaf-mk01", amount=1},
      },
    },
    ["hydroclassifier-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish-oil-barrel", amount=4},
        {type="item", name="flotation-cell-mk01", amount=1},
        {type="item", name="lab", amount=1},
        {type="item", name="radar", amount=2},
        {type="item", name="rich-clay", amount=4},
        {type="item", name="steam-engine", amount=17},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=1},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="evaporator", amount=1},
        {type="item", name="gasoline-canister", amount=3},
        {type="item", name="guts", amount=35},
        {type="item", name="intermetallics", amount=11},
        {type="item", name="iron-chest", amount=7},
        {type="item", name="resistor1", amount=203},
        {type="item", name="steam-engine", amount=11},
        {type="item", name="wooden-chest", amount=318},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=2},
      },
    },
    ["scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=12},
        {type="item", name="grade-2-ti", amount=3},
        {type="item", name="pipe", amount=529},
        {type="item", name="titanium-plate", amount=169},
        {type="item", name="warm-stone-brick", amount=36},
        {type="item", name="wpu-mk01", amount=1},
      },
      results = {
        {type="item", name="scrubber-mk01", amount=1},
      },
    },
    ["flotation-cell-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=3},
        {type="item", name="glass", amount=589},
        {type="item", name="inductor1", amount=22},
        {type="item", name="pipe", amount=89},
      },
      results = {
        {type="item", name="flotation-cell-mk01", amount=1},
      },
    },
    ["cargo-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=2},
        {type="item", name="capacitor1", amount=74},
        {type="item", name="crushed-coal", amount=167},
        {type="item", name="fenxsb-alloy", amount=26},
        {type="item", name="gasoline-canister", amount=1},
        {type="item", name="lead-plate", amount=50},
        {type="item", name="moondrop", amount=68},
        {type="item", name="zogna-bacteria-barrel", amount=11},
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
        {type="item", name="formic-acid-barrel", amount=8},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="grade-1-tin", amount=181},
        {type="item", name="inductor1", amount=7},
        {type="item", name="molten-glass-barrel", amount=7},
        {type="item", name="moss-gen", amount=26},
        {type="item", name="ore-titanium", amount=384},
        {type="item", name="shotgun-shell", amount=2},
        {type="item", name="storage-tank", amount=1},
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
        {type="item", name="cage", amount=1},
        {type="item", name="coal-gas-barrel", amount=2},
        {type="item", name="grade-2-ti", amount=66},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="py-science-pack-1", amount=35},
        {type="item", name="py-tank-4000", amount=6},
        {type="item", name="rail-chain-signal", amount=10},
        {type="item", name="raw-coal", amount=383},
        {type="item", name="shotgun", amount=5},
        {type="item", name="stone", amount=1253},
      },
      results = {
        {type="item", name="locomotive", amount=1},
      },
    },
    ["cooling-tower-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="engine-unit", amount=5},
        {type="item", name="moondrop-seeds", amount=37},
        {type="item", name="nexelit-plate", amount=158},
        {type="item", name="py-sinkhole", amount=4},
        {type="item", name="shaft-mk01", amount=4},
      },
      results = {
        {type="item", name="cooling-tower-mk01", amount=3},
      },
    },
    ["fawogae-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="biomass", amount=551},
        {type="item", name="concrete", amount=54},
        {type="item", name="grade-1-ti", amount=4},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="moondrop", amount=4},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="tinned-cable", amount=25},
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
        {type="item", name="engine-unit", amount=5},
        {type="item", name="guts", amount=9},
        {type="item", name="iron-gear-wheel", amount=35},
        {type="item", name="molten-iron-barrel", amount=2},
        {type="item", name="pipe", amount=105},
        {type="item", name="slacked-lime-barrel", amount=3},
        {type="item", name="titanium-plate", amount=152},
        {type="item", name="water-saline-barrel", amount=33},
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
        {type="item", name="hot-air-barrel", amount=5},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="moondrop-seeds", amount=13},
        {type="item", name="muddy-sludge-barrel", amount=5},
        {type="item", name="pipe", amount=41},
        {type="item", name="soot", amount=18},
        {type="item", name="steel-plate", amount=99},
        {type="item", name="tall-oil-barrel", amount=1},
        {type="item", name="tin-plate", amount=37},
        {type="item", name="titanium-plate", amount=29},
      },
      results = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
    },
    ["fish-farm-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=54},
        {type="item", name="equipment-chassi", amount=4},
        {type="item", name="fiberboard", amount=185},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="rich-clay", amount=17},
        {type="item", name="small-parts-01", amount=34},
        {type="item", name="treated-wood", amount=143},
        {type="item", name="warm-stone-brick", amount=452},
      },
      results = {
        {type="item", name="fish-farm-mk01", amount=1},
      },
    },
    ["heavy-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=91},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="latex", amount=4},
        {type="item", name="pbsb-alloy", amount=12},
        {type="item", name="pipe", amount=57},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="stone-brick", amount=85},
      },
      results = {
        {type="item", name="heavy-armor", amount=1},
      },
    },
    ["mixer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=3},
        {type="item", name="hpf", amount=2},
        {type="item", name="lead-plate", amount=22},
        {type="item", name="pipe", amount=174},
        {type="item", name="py-tank-1000", amount=3},
        {type="item", name="steel-plate", amount=12},
        {type="item", name="tinned-cable", amount=68},
      },
      results = {
        {type="item", name="mixer-mk01", amount=1},
      },
    },
    ["py-heat-exchanger"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="classifier", amount=2},
        {type="item", name="glass", amount=175},
        {type="item", name="iron-plate", amount=389},
        {type="item", name="lead-plate", amount=320},
        {type="item", name="nexelit-plate", amount=19},
        {type="item", name="py-tank-7000", amount=1},
        {type="item", name="steam-engine", amount=4},
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
        {type="item", name="aluminium-plate", amount=232},
        {type="item", name="concrete-wall", amount=145},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=175},
        {type="item", name="seaweed", amount=18},
        {type="item", name="stone-brick", amount=251},
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
        {type="item", name="crushed-quartz", amount=77},
        {type="item", name="flue-gas-barrel", amount=8},
        {type="item", name="iron-ore", amount=2759},
        {type="item", name="petri-dish-bacteria", amount=6},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="tailings-dust", amount=100},
        {type="item", name="tinned-cable", amount=25},
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
        {type="item", name="concrete", amount=45},
        {type="item", name="fluid-drill-mk01", amount=5},
        {type="item", name="gasoline-barrel", amount=25},
        {type="item", name="glass", amount=50},
        {type="item", name="sap-extractor-mk01", amount=1},
        {type="item", name="steam-engine", amount=7},
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
        {type="item", name="carbolic-oil-barrel", amount=1},
        {type="item", name="concrete", amount=190},
        {type="item", name="empty-fuel-canister", amount=2},
        {type="item", name="inductor1", amount=37},
        {type="item", name="methanal-barrel", amount=3},
        {type="item", name="py-tank-5000", amount=1},
        {type="item", name="small-electric-pole", amount=25},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="tree-mk01", amount=1},
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
        {type="item", name="copper-plate", amount=8},
        {type="item", name="fiberboard", amount=37},
        {type="item", name="glass", amount=42},
        {type="item", name="lab", amount=3},
        {type="item", name="pipe", amount=445},
        {type="item", name="pump", amount=3},
        {type="item", name="small-lamp", amount=9},
        {type="item", name="tar-processing-unit", amount=1},
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
        {type="item", name="acidgas-barrel", amount=11},
        {type="item", name="carbolic-oil-canister", amount=38},
        {type="item", name="carbon-dioxide-barrel", amount=17},
        {type="item", name="cellulose", amount=51},
        {type="item", name="clean-nexelit", amount=523},
        {type="item", name="hazard-concrete", amount=645},
        {type="item", name="vitreloy", amount=12},
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
        {type="item", name="anthracene-oil-canister", amount=29},
        {type="item", name="formic-acid-barrel", amount=4},
        {type="item", name="gasoline-barrel", amount=28},
        {type="item", name="nexelit-plate", amount=73},
        {type="item", name="scrude-canister", amount=17},
        {type="item", name="underground-belt", amount=3},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=1},
      },
    },
    ["py-electric-boiler"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="black-liquor-barrel", amount=6},
        {type="item", name="empty-petri-dish", amount=60},
        {type="item", name="fluid-drill-mk01", amount=4},
        {type="item", name="ore-lead", amount=165},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="py-electric-boiler", amount=3},
      },
    },
    ["rhe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=143},
        {type="item", name="concrete", amount=14},
        {type="item", name="iron-plate", amount=235},
        {type="item", name="slacked-lime-barrel", amount=3},
        {type="item", name="wooden-chest", amount=17},
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
        {type="item", name="concrete", amount=82},
        {type="item", name="duralumin", amount=68},
        {type="item", name="inductor1", amount=75},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="steam-engine", amount=4},
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
        {type="item", name="boric-acid-barrel", amount=1},
        {type="item", name="flask", amount=2},
        {type="item", name="ground-sample01", amount=264},
        {type="item", name="pressured-air-barrel", amount=1},
        {type="item", name="resistor1", amount=286},
        {type="item", name="stopper", amount=12},
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
        {type="item", name="acetylene-canister", amount=18},
        {type="item", name="assembling-machine-2", amount=1},
        {type="item", name="clay-pit-mk01", amount=2},
        {type="item", name="copper-ore", amount=74},
        {type="item", name="grade-1-copper", amount=19},
        {type="item", name="small-parts-01", amount=9},
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
        {type="item", name="ammonia-barrel", amount=5},
        {type="item", name="capacitor1", amount=28},
        {type="item", name="cottongut-mk01", amount=4},
        {type="item", name="fenxsb-alloy", amount=75},
        {type="item", name="muddy-sludge-barrel", amount=51},
        {type="item", name="vrauks-codex", amount=2},
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
        {type="item", name="concrete", amount=32},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="pipe", amount=11},
        {type="item", name="steel-plate", amount=20},
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
        {type="item", name="duralumin", amount=644},
        {type="item", name="inductor1", amount=299},
        {type="item", name="molten-iron-barrel", amount=1},
        {type="item", name="nexelit-plate", amount=1141},
        {type="item", name="polybutadiene-barrel", amount=81},
        {type="item", name="wpu-mk01", amount=2},
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
        {type="item", name="barrel-machine-mk01", amount=1},
        {type="item", name="grade-1-ti", amount=188},
        {type="item", name="iron-plate", amount=457},
        {type="item", name="lead-plate", amount=49},
        {type="item", name="pipe", amount=341},
        {type="item", name="stone-brick", amount=367},
      },
      results = {
        {type="item", name="dino-dig-site", amount=1},
      },
    },
    ["generator-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cocoon", amount=4},
        {type="item", name="copper-plate", amount=71},
        {type="item", name="inductor1", amount=30},
        {type="item", name="py-science-pack-1", amount=1},
        {type="item", name="sb-grade-01", amount=218},
        {type="item", name="sb-grade-02", amount=60},
        {type="item", name="slacked-lime-barrel", amount=4},
        {type="item", name="syngas-barrel", amount=4},
        {type="item", name="wood-seeds", amount=10},
      },
      results = {
        {type="item", name="generator-1", amount=1},
      },
    },
    ["pyphoon-bay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ash", amount=190},
        {type="item", name="condensates-canister", amount=6},
        {type="item", name="lime", amount=510},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="sb-grade-04", amount=46},
        {type="item", name="skin", amount=4},
        {type="item", name="tinned-cable", amount=68},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=1},
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
        {type="fluid", name="oxygen", amount=179},
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
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=1},
        {type="item", name="carbolic-oil-barrel", amount=1},
        {type="item", name="diborane-barrel", amount=4},
        {type="item", name="flask", amount=2},
        {type="item", name="pitch-canister", amount=1},
        {type="item", name="tar-canister", amount=7},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=3},
      },
    },
    ["carbon-black"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=2053},
        {type="fluid", name="vacuum", amount=100},
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
        {type="item", name="belt", amount=4},
        {type="item", name="copper-cable", amount=49},
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
        {type="item", name="nexelit-plate", amount=4},
        {type="item", name="pipe", amount=12},
        {type="item", name="rubber", amount=3},
      },
      results = {
        {type="item", name="transport-belt", amount=17},
      },
    },
    ["rubber-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=846},
        {type="item", name="carbon-black", amount=2},
        {type="item", name="concrete", amount=13},
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
        {type="fluid", name="flue-gas", amount=13026},
        {type="fluid", name="steam", amount=7594},
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
        {type="fluid", name="water", amount=240},
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
        {type="item", name="ceramic", amount=43},
        {type="item", name="fiberboard", amount=1},
        {type="item", name="formica", amount=1},
        {type="item", name="graphite", amount=19},
        {type="item", name="lead-plate", amount=14},
        {type="item", name="small-parts-01", amount=4},
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
        {type="item", name="capacitor1", amount=8},
        {type="item", name="melamine", amount=40},
      },
      results = {
        {type="item", name="formica", amount=5},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=124},
        {type="fluid", name="water", amount=1500},
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
        {type="item", name="petri-dish", amount=8},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=10},
      },
      results = {
        {type="item", name="ore-lead", amount=5},
      },
    },
    ["powdered-ralesia-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="latex-slab", amount=1},
      },
      results = {
        {type="item", name="powdered-ralesia-seeds", amount=1},
      },
    },
    ["water-saline"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=65},
        {type="item", name="kerogen", amount=10},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
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
        {type="fluid", name="pitch", amount=2599},
        {type="item", name="aluminium-plate", amount=200},
        {type="item", name="copper-ore", amount=500},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="gasifier", amount=18},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="meat", amount=166},
        {type="item", name="oxygen-barrel", amount=27},
        {type="item", name="petri-dish", amount=3},
        {type="item", name="polybutadiene-barrel", amount=25},
        {type="item", name="sb-oxide", amount=25},
        {type="item", name="vacuum-tube", amount=149},
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
        {type="fluid", name="pressured-water", amount=1989},
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
        {type="item", name="coal", amount=16},
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
      energy_required_multiplier = 1.125,
      ingredients = {
        {type="item", name="brain", amount=2},
      },
      results = {
        {type="item", name="kerogen", amount=9},
      },
    },
    ["breed-fish-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=219},
        {type="fluid", name="vacuum", amount=1600},
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
        {type="fluid", name="pressured-water", amount=5472},
        {type="fluid", name="steam", amount=522},
        {type="item", name="fish", amount=12},
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
        {type="fluid", name="flue-gas", amount=3904},
        {type="item", name="acidgas-barrel", amount=7},
        {type="item", name="boiler", amount=8},
        {type="item", name="moondrop-seeds", amount=72},
        {type="item", name="nexelit-plate", amount=173},
        {type="item", name="shotgun-shell", amount=119},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="solder", amount=5},
        {type="item", name="ti-rejects", amount=2},
        {type="item", name="used-auog", amount=4},
        {type="item", name="vitreloy", amount=4},
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
        {type="fluid", name="vacuum", amount=1000},
        {type="item", name="manure", amount=10},
      },
      results = {
        {type="fluid", name="liquid-manure", amount=100},
      },
    },
    ["zogna-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="fluid", name="pressured-air", amount=91},
        {type="item", name="agar", amount=2},
        {type="item", name="petri-dish-bacteria", amount=3},
        {type="item", name="small-lamp", amount=2},
      },
      results = {
        {type="fluid", name="zogna-bacteria", amount=36},
      },
    },
    ["plasmids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="empty-petri-dish", amount=7},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="plasmids", amount=1},
      },
    },
    ["retrovirus"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=347},
        {type="item", name="empty-petri-dish", amount=7},
        {type="item", name="iron-plate", amount=12},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="saps", amount=10},
      },
      results = {
        {type="item", name="retrovirus", amount=1},
      },
    },
    ["cdna"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=5},
        {type="item", name="fawogae-substrate", amount=4},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=6},
        {type="item", name="retrovirus", amount=1},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="sodium-hydroxide", amount=97},
        {type="item", name="stopper", amount=5},
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
        {type="fluid", name="steam", amount=652},
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
        {type="fluid", name="pressured-water", amount=238},
        {type="fluid", name="steam", amount=67},
        {type="item", name="lime", amount=3},
        {type="item", name="raw-fiber", amount=4},
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
        {type="item", name="copper-cable", amount=97},
        {type="item", name="glass", amount=2},
        {type="item", name="pipe", amount=1763},
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
        {type="item", name="ralesia", amount=3},
        {type="item", name="ralesia-seeds", amount=15},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=2359},
        {type="item", name="auog-codex", amount=11},
        {type="item", name="earth-shroom-sample", amount=2},
        {type="item", name="planter-box", amount=40},
        {type="item", name="py-tank-9000", amount=18},
        {type="item", name="sodium-hydroxide", amount=6146},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=3},
      },
    },
    ["cottongut-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=153},
        {type="item", name="cellulose", amount=8},
        {type="item", name="limestone", amount=6},
        {type="item", name="raw-fiber", amount=1},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood", amount=7},
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
        {type="fluid", name="naphthalene-oil", amount=762},
        {type="item", name="cellulose", amount=7},
        {type="item", name="cottongut", amount=20},
        {type="item", name="native-flora", amount=5},
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
        {type="item", name="fish", amount=2},
        {type="item", name="seaweed", amount=19},
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
        {type="item", name="coal", amount=1},
        {type="item", name="coarse", amount=13},
        {type="item", name="cottongut-pup-mk01", amount=1},
        {type="item", name="moondrop-seeds", amount=8},
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
        {type="item", name="animal-sample-01", amount=2},
        {type="item", name="battery-mk01", amount=3},
        {type="item", name="solidified-sarcorus", amount=1},
        {type="item", name="treated-wood", amount=26},
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
        {type="fluid", name="pressured-water", amount=3062},
        {type="fluid", name="steam", amount=100},
        {type="item", name="bonemeal", amount=1},
        {type="item", name="bones", amount=7},
        {type="item", name="cellulose", amount=3},
        {type="item", name="grade-1-tin", amount=5},
        {type="item", name="hazard-concrete", amount=2},
        {type="item", name="ore-nickel", amount=5},
        {type="item", name="pressured-water-barrel", amount=4},
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
        {type="item", name="glass", amount=2},
        {type="item", name="seaweed", amount=90},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="auog-codex", amount=1},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal-gas-canister", amount=3},
        {type="item", name="copper-cable", amount=38},
        {type="item", name="electronic-circuit", amount=16},
        {type="item", name="formic-acid-barrel", amount=6},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=2},
      },
    },
    ["auog-pooping-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.02883601600353,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="ralesia-seeds", amount=2},
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
      energy_required_multiplier = 1.4071390958736,
      ingredients = {
        {type="item", name="molten-iron-barrel", amount=2},
        {type="item", name="saps", amount=4},
        {type="item", name="seaweed", amount=24},
      },
      results = {
        {type="item", name="auog-pup", amount=5},
        {type="item", name="barrel", amount=7},
      },
    },
    ["auog"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=438},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="moss-gen", amount=4},
        {type="item", name="sodium-hydroxide", amount=722},
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
        {type="fluid", name="water", amount=153},
        {type="item", name="crushed-coal", amount=1},
        {type="item", name="limestone", amount=4},
        {type="item", name="moss", amount=5},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="soil", amount=80},
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
        {type="item", name="muddy-sludge-barrel", amount=5},
        {type="item", name="saps", amount=3},
      },
      results = {
        {type="item", name="auog", amount=3},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="guts", amount=4},
        {type="item", name="moss", amount=5},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["auog-maturing-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.05748304860864,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="hydrogen-barrel", amount=2},
        {type="item", name="manure", amount=9},
        {type="item", name="pipe-to-ground", amount=1},
        {type="item", name="pressured-water-barrel", amount=5},
        {type="item", name="seaweed", amount=17},
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
        {type="item", name="grade-1-chromite", amount=2},
        {type="item", name="seaweed", amount=17},
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
        {type="item", name="grade-2-copper", amount=6},
        {type="item", name="soil", amount=45},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="limestone", amount=10},
        {type="item", name="processed-iron-ore", amount=32},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["fertilizer-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=7467},
        {type="item", name="biomass", amount=10},
        {type="item", name="dried-meat", amount=9},
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
        {type="fluid", name="hydrogen", amount=4158},
        {type="fluid", name="water", amount=3733},
      },
      results = {
        {type="item", name="urea", amount=30},
      },
    },
    ["melamine-resin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="steam", amount=3488},
        {type="item", name="ceramic", amount=33},
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="item", name="melamine-resin", amount=11},
      },
    },
    ["fawogae-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 0.714285714285714,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=1},
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
        {type="fluid", name="muddy-sludge", amount=1771},
        {type="item", name="concrete-wall", amount=3},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="ground-sample01", amount=5},
        {type="item", name="ralesia-codex", amount=3},
        {type="item", name="wood", amount=127},
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
        {type="fluid", name="steam", amount=1957},
        {type="fluid", name="vacuum", amount=693},
        {type="item", name="limestone", amount=9},
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
        {type="fluid", name="hot-air", amount=433},
        {type="item", name="lime", amount=4},
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
        {type="item", name="coal-gas-barrel", amount=1},
        {type="item", name="limestone", amount=16},
        {type="item", name="native-flora", amount=336},
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
        {type="fluid", name="steam", amount=100},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="fawogae-spore", amount=9},
        {type="item", name="saps", amount=5},
        {type="item", name="soil", amount=35},
        {type="item", name="tin-plate", amount=1},
        {type="item", name="wood", amount=27},
      },
      results = {
        {type="item", name="vrauks-food-01", amount=4},
      },
    },
    ["vrauks-cocoon-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="geothermal-water-barrel", amount=1},
        {type="item", name="moss", amount=20},
        {type="item", name="ore-zinc", amount=4},
        {type="item", name="vrauks-food-01", amount=1},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=10},
      },
    },
    ["vrauks-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 0.79379692517239,
      ingredients = {
        {type="item", name="cocoon", amount=42},
        {type="item", name="iron-gear-wheel", amount=6},
        {type="item", name="moss", amount=31},
        {type="item", name="warm-stone-brick", amount=3},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="vrauks", amount=1},
        {type="item", name="vrauks-mk02", amount=0.00421735386896476},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      energy_required_multiplier = 1.04268128936639,
      ingredients = {
        {type="item", name="cocoon-mk02", amount=8},
        {type="item", name="moss", amount=4},
        {type="item", name="offshore-pump", amount=1},
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
        {type="item", name="grade-1-chromite", amount=2},
        {type="item", name="pressured-air-barrel", amount=1},
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
        {type="item", name="coke", amount=14},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=5},
      },
    },
    ["warm-air-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="warm-stone-brick", amount=20},
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
        {type="fluid", name="steam", amount=258},
        {type="fluid", name="waste-water", amount=50},
      },
      results = {
        {type="fluid", name="water", amount=50},
      },
    },
    ["barrel-milk"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sulfur", amount=4},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=1},
      },
    },
    ["empty-gas-canister"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-2-copper", amount=2},
        {type="item", name="pipe", amount=5},
      },
      results = {
        {type="item", name="empty-gas-canister", amount=2},
      },
    },
    ["active-provider-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fish-oil-barrel", amount=7},
        {type="item", name="steel-chest", amount=2},
      },
      results = {
        {type="item", name="active-provider-chest", amount=2},
      },
    },
    ["buffer-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=7},
        {type="item", name="steel-plate", amount=8},
      },
      results = {
        {type="item", name="buffer-chest", amount=1},
      },
    },
    ["passive-provider-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="steam-engine", amount=4},
        {type="item", name="ti-rejects", amount=3},
      },
      results = {
        {type="item", name="passive-provider-chest", amount=2},
      },
    },
    ["requester-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diborane-barrel", amount=2},
        {type="item", name="stopper", amount=21},
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
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="guts", amount=2},
      },
      results = {
        {type="item", name="ash", amount=5},
      },
    },
    ["ash3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-fiber", amount=5},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="tin-ore-rejects", amount=2},
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
        {type="fluid", name="pressured-air", amount=137},
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
        {type="item", name="syngas-canister", amount=4},
      },
      results = {
        {type="item", name="tin-dust", amount=3},
      },
    },
    ["tin-plate-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="latex-slab", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=10},
      },
    },
    ["molten-tin-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=12},
        {type="item", name="iron-ore", amount=157},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="fluid", name="molten-tin", amount=30},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="pressured-air", amount=18946},
        {type="item", name="coke", amount=5},
      },
      results = {
        {type="item", name="tin-plate", amount=63},
      },
    },
    ["tin-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=262},
        {type="item", name="coke", amount=5},
      },
      results = {
        {type="item", name="tin-plate", amount=50},
      },
    },
    ["carbon-filter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="distilator", amount=2},
        {type="item", name="iron-stick", amount=15},
        {type="item", name="lab", amount=5},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="vane-mk01", amount=5},
        {type="item", name="vitreloy", amount=8},
      },
      results = {
        {type="item", name="carbon-filter", amount=3},
      },
    },
    ["fts-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="bio-sample01", amount=3},
        {type="item", name="capacitor1", amount=300},
        {type="item", name="empty-barrel-milk", amount=15},
        {type="item", name="grade-1-copper", amount=3},
        {type="item", name="grade-1-zinc", amount=3},
        {type="item", name="sb-grade-02", amount=12},
        {type="item", name="stone-brick", amount=484},
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
        {type="item", name="aromatics-barrel", amount=5},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="iron-plate", amount=736},
        {type="item", name="long-handed-inserter", amount=1},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="antimonium-ore", amount=92},
        {type="item", name="empty-gas-canister", amount=176},
        {type="item", name="inductor1", amount=111},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="rail-chain-signal", amount=1},
        {type="item", name="soil-extractor-mk01", amount=13},
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
        {type="item", name="grade-4-chromite", amount=7},
      },
      results = {
        {type="item", name="grade-3-chromite", amount=1},
      },
    },
    ["grade-4-chromite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=67},
        {type="item", name="grade-1-chromite", amount=4},
      },
      results = {
        {type="item", name="chromite-rejects", amount=4},
        {type="item", name="grade-4-chromite", amount=4},
      },
    },
    ["grade-3-chromite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="grade-3-ti", amount=4},
      },
      results = {
        {type="item", name="grade-2-chromite", amount=2},
        {type="item", name="grade-3-chromite", amount=5},
      },
    },
    ["tier-2-chromite-sand"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.08333333333333,
      ingredients = {
        {type="item", name="acetylene-canister", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=13},
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
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=214},
        {type="item", name="aromatics-canister", amount=2},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=58},
        {type="fluid", name="iron-slime", amount=58},
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
        {type="fluid", name="geothermal-water", amount=2297},
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
        {type="fluid", name="hot-air", amount=3084},
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
      mode = "softmax-semantic-substitution",
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
        {type="fluid", name="water", amount=765},
        {type="item", name="chromium", amount=3},
        {type="item", name="processed-iron-ore", amount=27},
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
        {type="fluid", name="coke-oven-gas", amount=430},
        {type="fluid", name="water", amount=200},
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
        {type="item", name="grade-1-copper", amount=12},
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
        {type="item", name="grade-1-copper", amount=1},
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
        {type="item", name="copper-ore", amount=13},
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
        {type="fluid", name="cyanic-acid", amount=457},
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="limestone", amount=4},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=75},
      },
    },
    ["wash-coper-low-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=67},
        {type="item", name="copper-low-dust", amount=1},
      },
      results = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="low-grade-copper", amount=1},
      },
    },
    ["copper-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="petroleum-gas", amount=2070},
        {type="item", name="coke", amount=5},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=60},
      },
    },
    ["low-grade-smelting-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="low-grade-rejects", amount=7},
      },
      results = {
        {type="item", name="copper-plate", amount=1},
      },
    },
    ["molten-copper-04"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=437},
        {type="item", name="grade-3-copper", amount=6},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="molten-copper", amount=21},
      },
    },
    ["coalbed-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=2},
        {type="item", name="methanal-barrel", amount=8},
        {type="item", name="moondrop", amount=4},
        {type="item", name="passive-provider-chest", amount=6},
        {type="item", name="petri-dish", amount=7},
        {type="item", name="pressured-air-barrel", amount=8},
        {type="item", name="small-lamp", amount=12},
        {type="item", name="soil-extractor-mk01", amount=7},
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
        {type="item", name="aluminium-plate", amount=9},
        {type="item", name="barrel", amount=23},
        {type="item", name="boric-acid-barrel", amount=43},
        {type="item", name="burner-inserter", amount=4},
        {type="item", name="fiberboard", amount=111},
        {type="item", name="grade-3-ti", amount=8},
        {type="item", name="inductor1", amount=7},
        {type="item", name="light-armor", amount=1},
        {type="item", name="titanium-plate", amount=824},
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
        {type="item", name="brain", amount=1},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="grade-2-ti", amount=3},
        {type="item", name="nexelit-ore", amount=69258},
        {type="item", name="rail-chain-signal", amount=1},
        {type="item", name="tall-oil-barrel", amount=22},
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
        {type="item", name="dried-meat", amount=5},
        {type="item", name="empty-petri-dish", amount=5},
        {type="item", name="glass", amount=47},
        {type="item", name="muddy-sludge-barrel", amount=58},
        {type="item", name="steel-plate", amount=22},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="tinned-cable", amount=26},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=2},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=15},
        {type="item", name="boiler", amount=75},
        {type="item", name="grade-1-lead", amount=10},
        {type="item", name="grade-1-tin", amount=6},
        {type="item", name="pipe", amount=32},
        {type="item", name="py-recharge-station-mk01", amount=1},
        {type="item", name="py-science-pack-1", amount=34},
        {type="item", name="py-tank-1000", amount=6},
      },
      results = {
        {type="item", name="oil-sand-extractor-mk01", amount=2},
      },
    },
    ["pumpjack-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=29},
        {type="item", name="grade-2-chromite", amount=2},
        {type="item", name="inductor1", amount=15},
        {type="item", name="moondrop-seeds", amount=26},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="tall-oil-canister", amount=5},
      },
      results = {
        {type="item", name="pumpjack-mk01", amount=1},
      },
    },
    ["tar-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="antimonium-ore", amount=398},
        {type="item", name="auog-pup", amount=75},
        {type="item", name="barrel", amount=71},
        {type="item", name="coke", amount=18},
        {type="item", name="fts-reactor", amount=2},
        {type="item", name="iron-plate", amount=61},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="lead-plate", amount=28},
        {type="item", name="pressured-air-barrel", amount=22},
      },
      results = {
        {type="item", name="tar-extractor-mk01", amount=2},
      },
    },
    ["coarse-coal"] = {
      mode = "softmax-semantic-substitution",
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="guts", amount=71},
        {type="item", name="hydrogen-barrel", amount=20},
        {type="item", name="lead-plate", amount=417},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="molten-glass-barrel", amount=5},
        {type="item", name="py-science-pack-1", amount=19},
        {type="item", name="tin-plate", amount=48},
        {type="item", name="wooden-chest", amount=262},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=2},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=40},
        {type="item", name="lead-plate", amount=621},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="small-lamp", amount=15},
        {type="item", name="vitreloy", amount=15},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=2},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=38},
        {type="item", name="concrete", amount=28},
        {type="item", name="fiberboard", amount=37},
        {type="item", name="iron-stick", amount=39},
        {type="item", name="lab", amount=2},
        {type="item", name="lead-plate", amount=731},
        {type="item", name="steel-plate", amount=133},
        {type="item", name="tar-canister", amount=2},
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
        {type="item", name="aluminium-plate", amount=19},
        {type="item", name="fiberboard", amount=371},
        {type="item", name="lead-plate", amount=78},
        {type="item", name="petri-dish", amount=43},
        {type="item", name="pipe", amount=203},
        {type="item", name="py-tank-3000", amount=1},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="steel-plate", amount=133},
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
        {type="fluid", name="coal-gas", amount=291},
        {type="fluid", name="subcritical-water", amount=7499},
        {type="item", name="animal-sample-01", amount=36},
        {type="item", name="coarse", amount=94},
        {type="item", name="earth-generic-sample", amount=20},
        {type="item", name="fbreactor-mk01", amount=9},
        {type="item", name="gearbox-mk01", amount=5},
        {type="item", name="soot", amount=60},
        {type="item", name="titanium-plate", amount=86},
        {type="item", name="waste-water-barrel", amount=67},
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
        {type="item", name="carbolic-oil-canister", amount=2},
        {type="item", name="engine-unit", amount=8},
        {type="item", name="fawogae-substrate", amount=15},
        {type="item", name="inductor1", amount=111},
        {type="item", name="lens", amount=24},
        {type="item", name="methane-canister", amount=7},
        {type="item", name="pbsb-alloy", amount=29},
        {type="item", name="raw-fiber", amount=24},
        {type="item", name="syngas-barrel", amount=3},
        {type="item", name="tin-plate", amount=14},
      },
      results = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
    },
    ["crushing-molybdenite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.2285537604473,
      ingredients = {
        {type="item", name="btx-canister", amount=1},
      },
      results = {
        {type="item", name="crushed-molybdenite", amount=6},
        {type="item", name="stone", amount=3},
      },
    },
    ["duralumin-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="fluid", name="pressured-air", amount=30683},
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
        {type="item", name="gravel", amount=8},
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
        {type="fluid", name="water-saline", amount=97},
        {type="item", name="biomass", amount=45},
        {type="item", name="coke", amount=3},
        {type="item", name="ground-sample01", amount=18},
        {type="item", name="rich-clay", amount=1},
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
        {type="fluid", name="steam", amount=100},
        {type="item", name="brain", amount=1},
        {type="item", name="iron-plate", amount=74},
        {type="item", name="mukmoux-fat", amount=4},
        {type="item", name="pipe", amount=6},
        {type="item", name="ralesia", amount=9},
        {type="item", name="seaweed", amount=5},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="item", name="fish-food-01", amount=3},
      },
    },
    ["flask-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=120},
        {type="item", name="boron-trioxide", amount=5},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="flask", amount=4},
      },
    },
    ["hotair-flask-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="steam", amount=2795},
        {type="item", name="lens", amount=5},
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-lead", amount=4},
      },
      results = {
        {type="item", name="lead-dust", amount=1},
      },
    },
    ["molten-lead-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-3-lead", amount=4},
        {type="item", name="melamine-resin", amount=1},
        {type="item", name="pure-sand", amount=3},
      },
      results = {
        {type="fluid", name="molten-lead", amount=90},
      },
    },
    ["hotair-lead-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="purest-nitrogen-gas", amount=2774},
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
        {type="fluid", name="diborane", amount=895},
        {type="item", name="coke", amount=5},
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
        {type="fluid", name="water-saline", amount=266},
        {type="item", name="copper-ore", amount=46},
        {type="item", name="sb-grade-04", amount=1},
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
        {type="fluid", name="methanal", amount=1712},
        {type="item", name="coke", amount=5},
        {type="item", name="sand", amount=7},
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
        {type="fluid", name="geothermal-water", amount=14121},
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="sand", amount=7},
        {type="item", name="sand-casting", amount=1},
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
        {type="fluid", name="water-saline", amount=196},
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
        {type="fluid", name="boric-acid", amount=730},
        {type="fluid", name="molten-tin", amount=10},
        {type="fluid", name="steam", amount=205},
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
        {type="fluid", name="sulfuric-acid", amount=168},
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
        {type="fluid", name="refsyngas", amount=481},
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
        {type="fluid", name="ammonia", amount=241},
        {type="fluid", name="steam", amount=425},
        {type="item", name="flask", amount=1},
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
        {type="fluid", name="molten-steel", amount=100},
        {type="item", name="coke", amount=9},
      },
      results = {
        {type="item", name="steel-plate", amount=32},
      },
    },
    ["steel-20"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=7013},
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
        {type="item", name="coke", amount=67},
        {type="item", name="copper-cable", amount=58},
        {type="item", name="pipe", amount=2},
        {type="item", name="steel-plate", amount=518},
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
        {type="item", name="chromium", amount=35},
        {type="item", name="cottongut-food-01", amount=5},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="pipe", amount=2},
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
        {type="item", name="lead-plate", amount=2},
        {type="item", name="small-parts-01", amount=535},
        {type="item", name="tinned-cable", amount=18},
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
        {type="item", name="bolts", amount=72},
        {type="item", name="nickel-plate", amount=2},
        {type="item", name="sodium-hydroxide", amount=32},
        {type="item", name="steel-plate", amount=518},
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
        {type="item", name="bones", amount=50},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=10},
      },
    },
    ["leaching-station-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="petri-dish", amount=2},
        {type="item", name="resistor1", amount=74},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="tree-mk01", amount=35},
        {type="item", name="vitreloy", amount=6},
        {type="item", name="workers-food", amount=1},
      },
      results = {
        {type="item", name="leaching-station-mk01", amount=1},
      },
    },
    ["wet-scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog", amount=1},
        {type="item", name="gate", amount=5},
        {type="item", name="glass", amount=80},
        {type="item", name="methanal-barrel", amount=2},
        {type="item", name="methane-canister", amount=22},
        {type="item", name="tall-oil-barrel", amount=3},
        {type="item", name="vitreloy", amount=8},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.18,
      ingredients = {
        {type="fluid", name="flue-gas", amount=698},
        {type="item", name="grade-2-tin", amount=1},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=177},
      },
    },
    ["formamide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="hot-air", amount=1157},
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
        {type="item", name="boiler", amount=14},
        {type="item", name="electronics-mk01", amount=4},
        {type="item", name="gate", amount=8},
        {type="item", name="sodium-alginate", amount=7},
        {type="item", name="tall-oil-barrel", amount=3},
        {type="item", name="titanium-plate", amount=389},
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
        {type="item", name="pbsb-alloy", amount=7},
        {type="item", name="wood-fence", amount=1},
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
        {type="fluid", name="coal-gas", amount=695},
        {type="item", name="cellulose", amount=26},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=5},
      },
    },
    ["powdered-phosphate-rock"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=12},
      },
      results = {
        {type="item", name="powdered-phosphate-rock", amount=5},
        {type="item", name="stone", amount=5},
      },
    },
    ["stone-wool"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=227},
        {type="item", name="chromium", amount=3},
        {type="item", name="iron-stick", amount=13},
      },
      results = {
        {type="item", name="stone-wool", amount=2},
      },
    },
    ["stone-wool2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=1369},
        {type="item", name="boron-trioxide", amount=1},
        {type="item", name="coal-dust", amount=7},
      },
      results = {
        {type="item", name="stone-wool", amount=2},
      },
    },
    ["zipir-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="bolts", amount=29},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="sncr-alloy", amount=2},
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
        {type="fluid", name="methanal", amount=543},
        {type="fluid", name="water", amount=105},
        {type="item", name="fish", amount=5},
        {type="item", name="uranium-ore", amount=24},
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
        {type="item", name="fish", amount=707},
        {type="item", name="rail-signal", amount=17},
        {type="item", name="raw-coal", amount=60},
        {type="item", name="small-parts-01", amount=214},
        {type="item", name="spore-collector-mk01", amount=1},
        {type="item", name="train-stop", amount=2},
      },
      results = {
        {type="item", name="zipir-reef-mk01", amount=1},
      },
    },
    ["zipir-a-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.23866730524923,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=380},
        {type="fluid", name="water", amount=234},
        {type="item", name="cellulose", amount=23},
        {type="item", name="long-handed-inserter", amount=2},
        {type="item", name="small-parts-01", amount=6},
        {type="item", name="soil", amount=95},
      },
      results = {
        {type="fluid", name="waste-water", amount=117},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["zipir-a-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.41769021591528,
      ingredients = {
        {type="fluid", name="steam", amount=239},
        {type="fluid", name="water", amount=273},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="phytoplankton-barrel", amount=2},
        {type="item", name="ralesia-seeds", amount=86},
      },
      results = {
        {type="fluid", name="waste-water", amount=136},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["arthropod-blood-to-blood"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.79000433630682,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=2654},
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
        {type="item", name="fluid-drill-mk01", amount=4},
        {type="item", name="grade-2-lead", amount=143},
        {type="item", name="grade-3-iron", amount=267},
        {type="item", name="oxygen-barrel", amount=453},
        {type="item", name="py-science-pack-1", amount=19},
        {type="item", name="repair-pack", amount=97},
        {type="item", name="soil-extractor-mk01", amount=15},
        {type="item", name="steel-plate", amount=70},
        {type="item", name="water-barrel", amount=69},
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
        {type="item", name="constant-combinator", amount=1},
        {type="item", name="fish-egg", amount=15},
        {type="item", name="inductor1", amount=74},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="gravel", amount=12},
        {type="item", name="limestone", amount=3},
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
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="ceramic", amount=13},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.0409299364833,
      ingredients = {
        {type="item", name="tailings-dust", amount=40},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.00864222742116,
      ingredients = {
        {type="item", name="bolts", amount=199},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3.33333333333333,
      ingredients = {
        {type="item", name="tailings-dust", amount=128},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="silver-plate", amount=1},
      },
    },
    ["soot-to-zinc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.0509390350894,
      ingredients = {
        {type="item", name="tailings-dust", amount=40},
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
        {type="item", name="gravel", amount=49},
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
        {type="item", name="transport-belt", amount=6},
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
        {type="item", name="barrel", amount=7},
        {type="item", name="empty-petri-dish", amount=1},
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
        {type="fluid", name="methane", amount=228},
      },
      results = {
        {type="item", name="salt", amount=23},
      },
    },
    ["sand-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.125,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=139},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=90},
        {type="item", name="pure-sand", amount=9},
      },
    },
    ["acetic-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=80},
        {type="fluid", name="methanol", amount=50},
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
        {type="fluid", name="acetone", amount=100},
        {type="fluid", name="flue-gas", amount=393},
      },
      results = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="organic-solvent", amount=100},
      },
    },
    ["phosphorous-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="hot-air", amount=272},
        {type="item", name="gravel", amount=4},
        {type="item", name="melamine", amount=15},
        {type="item", name="tar-barrel", amount=2},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=52},
      },
    },
    ["tall-oil-separation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=157},
        {type="fluid", name="steam", amount=261},
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
      energy_required_multiplier = 0.792522190185053,
      ingredients = {
        {type="item", name="grade-3-copper", amount=1},
        {type="item", name="gravel", amount=5},
      },
      results = {
        {type="fluid", name="ammonia", amount=16},
        {type="fluid", name="tall-oil", amount=16},
        {type="fluid", name="tar", amount=23},
      },
    },
    ["methane-py-fertilizer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.3125,
      ingredients = {
        {type="fluid", name="water", amount=131},
        {type="item", name="ralesia-seeds", amount=2},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=105},
      },
    },
    ["phosphoric-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=4210},
        {type="fluid", name="water", amount=360},
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
        {type="fluid", name="hot-air", amount=154},
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
        {type="fluid", name="benzene", amount=1481},
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
        {type="fluid", name="phosphoric-acid", amount=30},
        {type="fluid", name="pressured-air", amount=67},
        {type="item", name="copper-rejects", amount=4},
        {type="item", name="gravel", amount=43},
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
        {type="fluid", name="hot-air", amount=231},
        {type="fluid", name="vacuum", amount=11341},
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
        {type="fluid", name="acetic-acid", amount=489},
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="pure-sand", amount=5},
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
        {type="fluid", name="acidgas", amount=500},
        {type="item", name="nichrome", amount=1},
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
        {type="fluid", name="chlorine", amount=3282},
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
        {type="fluid", name="ammonia", amount=189},
        {type="item", name="coke", amount=11},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=150},
      },
    },
    ["glass-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="item", name="concrete-wall", amount=1},
        {type="item", name="crushed-coal", amount=2},
      },
      results = {
        {type="fluid", name="molten-glass", amount=38},
      },
    },
    ["powdered-quartz"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1.00928472869687,
      ingredients = {
        {type="item", name="crushed-quartz", amount=5},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-quartz", amount=5},
      },
    },
    ["seaweed-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="oxygen", amount=114},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="item", name="seaweed", amount=20},
      },
    },
    ["silver-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-lead", amount=123},
      },
      results = {
        {type="item", name="silver-plate", amount=9},
      },
    },
    ["sulfur-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-vrauks", amount=10},
        {type="item", name="copper-rejects", amount=30},
        {type="item", name="electric-mining-drill", amount=5},
        {type="item", name="gate", amount=3},
        {type="item", name="grade-1-tin", amount=313},
        {type="item", name="iron-slime-barrel", amount=49},
      },
      results = {
        {type="item", name="sulfur-mine", amount=1},
      },
    },
    ["albumin-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=3062},
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
        {type="fluid", name="geothermal-water", amount=1544},
        {type="fluid", name="muddy-sludge", amount=2796},
        {type="fluid", name="pressured-air", amount=100},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="methanal", amount=50},
        {type="fluid", name="molten-salt", amount=30},
      },
    },
    ["powedered-biomass"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.15,
      ingredients = {
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="item", name="powdered-biomass", amount=23},
      },
    },
    ["sugar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=1831},
        {type="item", name="mukmoux-fat", amount=3},
      },
      results = {
        {type="item", name="sugar", amount=10},
      },
    },
    ["waste-water-urea"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=379},
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
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="item", name="fungal-substrate", amount=10},
      },
    },
    ["dried-biomass"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="powdered-biomass", amount=72},
      },
      results = {
        {type="item", name="dried-biomass", amount=30},
      },
    },
    ["fungal-substrate-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="water", amount=63},
        {type="item", name="biomass", amount=13},
        {type="item", name="coke", amount=5},
        {type="item", name="flask", amount=4},
        {type="item", name="guts", amount=2},
        {type="item", name="iron-ore", amount=2},
        {type="item", name="pipe", amount=9},
      },
      results = {
        {type="item", name="fungal-substrate-02", amount=13},
      },
    },
    ["fiber"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=10},
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
        {type="item", name="sodium-hydroxide", amount=3},
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
        {type="fluid", name="pressured-water", amount=2108},
        {type="fluid", name="propene", amount=50},
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
        {type="item", name="grade-1-ti", amount=5},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="soot", amount=4},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="sand", amount=2},
      },
    },
    ["grade-4-nickel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="fish-oil-barrel", amount=2},
      },
      results = {
        {type="item", name="grade-4-nickel", amount=3},
      },
    },
    ["nickel-rejects-recrush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-3-nickel", amount=3},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
      },
    },
    ["molten-nickel-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.98,
      ingredients = {
        {type="fluid", name="pressured-air", amount=502},
        {type="item", name="crushed-coal", amount=1},
        {type="item", name="grade-3-nickel", amount=3},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=49},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-slurry", amount=1309},
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="coke", amount=5},
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
        {type="fluid", name="creamy-latex", amount=938},
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
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="kerosene", amount=854},
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
        {type="fluid", name="hot-air", amount=931},
        {type="fluid", name="water", amount=250},
        {type="item", name="iron-oxide", amount=12},
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
        {type="fluid", name="anthracene-oil", amount=309},
        {type="fluid", name="pressured-steam", amount=4876},
        {type="fluid", name="syngas", amount=200},
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
        {type="fluid", name="carbon-dioxide", amount=4127},
        {type="fluid", name="heavy-oil", amount=2533},
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
        {type="fluid", name="coalbed-gas", amount=2144},
        {type="fluid", name="water", amount=100},
        {type="item", name="ground-sample01", amount=35},
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
        {type="fluid", name="coal-slurry", amount=1112},
        {type="fluid", name="water", amount=900},
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
        {type="item", name="grade-4-copper", amount=14},
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
        {type="fluid", name="coal-gas", amount=3034},
        {type="item", name="lime", amount=14},
      },
      results = {
        {type="fluid", name="vpulp2", amount=100},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.93,
      ingredients = {
        {type="fluid", name="hot-air", amount=72},
        {type="item", name="grade-3-tin", amount=2},
      },
      results = {
        {type="fluid", name="molybdenite-pulp", amount=93},
      },
    },
    ["vpulp3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methane", amount=308},
        {type="fluid", name="vpulp2", amount=100},
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
        {type="item", name="coal-dust", amount=2},
      },
      results = {
        {type="item", name="py-asphalt", amount=2},
      },
    },
    ["py-aluminium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=4},
        {type="item", name="graphite", amount=4},
        {type="item", name="small-lamp", amount=3},
      },
      results = {
        {type="item", name="py-aluminium", amount=4},
      },
    },
    ["py-coal-tile"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=4085},
        {type="item", name="oleochemicals-barrel", amount=2},
        {type="item", name="raw-coal", amount=6},
      },
      results = {
        {type="item", name="py-coal-tile", amount=3},
      },
    },
    ["py-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=12},
        {type="item", name="geothermal-water-barrel", amount=2},
        {type="item", name="iron-stick", amount=2},
      },
      results = {
        {type="item", name="py-iron", amount=5},
      },
    },
    ["py-nexelit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="tar", amount=38},
        {type="item", name="clean-nexelit", amount=3},
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="item", name="py-nexelit", amount=4},
      },
    },
    ["py-quartz"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=19},
        {type="item", name="acetylene-canister", amount=1},
        {type="item", name="iron-gear-wheel", amount=3},
      },
      results = {
        {type="item", name="py-quartz", amount=4},
      },
    },
    ["py-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=5},
        {type="fluid", name="molten-steel", amount=10},
        {type="item", name="iron-ore", amount=6},
      },
      results = {
        {type="item", name="py-steel", amount=2},
      },
    },
    ["hydrogen-chloride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1989},
        {type="fluid", name="steam", amount=212},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=150},
      },
      results = {
        {type="fluid", name="nitrogen", amount=20},
        {type="fluid", name="oxygen", amount=20},
        {type="fluid", name="purest-nitrogen-gas", amount=60},
      },
    },
    ["hcl-from-guts"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=10},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=50},
      },
    },
    ["nitrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=100},
        {type="item", name="low-grade-rejects", amount=1},
      },
      results = {
        {type="fluid", name="nitrogen", amount=200},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=50},
      },
    },
    ["zinc-chloride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=414},
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
        {type="item", name="calcium-carbide", amount=15},
        {type="item", name="rich-clay", amount=11},
        {type="item", name="tinned-cable", amount=3},
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
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="pure-sand", amount=9},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tar-barrel", amount=1},
      },
      results = {
        {type="item", name="drill-head", amount=5},
      },
    },
    ["drill-head-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromite-sand", amount=5},
        {type="item", name="nickel-plate", amount=5},
        {type="item", name="small-parts-01", amount=8},
      },
      results = {
        {type="item", name="drill-head", amount=4},
      },
    },
    ["drill-head-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=11},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="titanium-plate", amount=4},
      },
      results = {
        {type="item", name="drill-head", amount=6},
      },
    },
    ["nichrome"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=114},
        {type="item", name="gravel", amount=21},
        {type="item", name="titanium-plate", amount=16},
      },
      results = {
        {type="item", name="nichrome", amount=1},
      },
    },
    ["evaporate-nitrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=885},
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
        {type="fluid", name="carbon-dioxide", amount=449},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="water", amount=100},
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
        {type="fluid", name="methane", amount=395},
        {type="item", name="fish-egg", amount=2},
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
        {type="fluid", name="carbon-dioxide", amount=309},
        {type="item", name="coke", amount=7},
        {type="item", name="limestone", amount=2},
        {type="item", name="pure-sand", amount=2},
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
        {type="fluid", name="oxygen", amount=500},
        {type="fluid", name="pressured-air", amount=2917},
        {type="item", name="iron-oxide", amount=4},
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
        {type="fluid", name="carbon-dioxide", amount=371},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hydrogen", amount=500},
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
        {type="fluid", name="geothermal-water", amount=5907},
        {type="fluid", name="water", amount=638},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=300},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=200},
        {type="fluid", name="hot-air", amount=250},
      },
      results = {
        {type="fluid", name="acidgas", amount=150},
        {type="fluid", name="flue-gas", amount=900},
      },
    },
    ["coalbed-gas-to-co2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=804},
        {type="fluid", name="subcritical-water", amount=1179},
        {type="item", name="tailings-barrel", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=300},
      },
    },
    ["coalbed-gas-to-coalgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.3675,
      ingredients = {
        {type="fluid", name="tailings", amount=852},
        {type="item", name="bio-container", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=547},
      },
    },
    ["coalbed-gas-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=804},
        {type="fluid", name="nitrogen", amount=398},
        {type="item", name="coke", amount=12},
      },
      results = {
        {type="fluid", name="syngas", amount=200},
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
      energy_required_multiplier = 0.815909811342088,
      ingredients = {
        {type="fluid", name="flue-gas", amount=962},
        {type="fluid", name="geothermal-water", amount=673},
        {type="item", name="crude-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="light-oil", amount=245},
        {type="fluid", name="olefin", amount=122},
        {type="fluid", name="steam", amount=1632},
      },
    },
    ["petgas-from-refsyngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=241},
        {type="fluid", name="syngas", amount=461},
        {type="item", name="drilling-fluid-0-barrel", amount=2},
      },
      results = {
        {type="fluid", name="olefin", amount=150},
        {type="fluid", name="petroleum-gas", amount=400},
      },
    },
    ["bone-solvent"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="olefin", amount=100},
        {type="item", name="bonemeal", amount=10},
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
        {type="fluid", name="oxygen", amount=157},
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
        {type="item", name="lime", amount=9},
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
        {type="fluid", name="organic-solvent", amount=100},
        {type="fluid", name="syngas", amount=192},
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
        {type="fluid", name="ammonia", amount=310},
        {type="item", name="ash", amount=5},
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
        {type="fluid", name="olefin", amount=300},
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
      energy_required_multiplier = 1.05714285714286,
      ingredients = {
        {type="fluid", name="flue-gas", amount=418},
        {type="item", name="aromatics-barrel", amount=1},
      },
      results = {
        {type="fluid", name="refsyngas", amount=74},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=389},
        {type="item", name="chromium", amount=7},
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
        {type="fluid", name="anthraquinone", amount=100},
        {type="item", name="lead-plate", amount=6},
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
        {type="fluid", name="hot-air", amount=196},
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
        {type="fluid", name="nitrogen", amount=451},
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
        {type="fluid", name="syngas", amount=217},
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
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="syngas", amount=509},
        {type="fluid", name="water", amount=600},
      },
      results = {
        {type="fluid", name="acidgas", amount=30},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["pyrite-burn"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.913315917739701,
      ingredients = {
        {type="item", name="tin-ore-rejects", amount=1},
      },
      results = {
        {type="fluid", name="acidgas", amount=45},
        {type="item", name="iron-oxide", amount=11},
      },
    },
    ["log4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=124},
        {type="fluid", name="water", amount=500},
        {type="item", name="wood-seedling", amount=3},
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
        {type="fluid", name="hot-air", amount=123},
        {type="fluid", name="water", amount=2727},
        {type="item", name="cellulose", amount=4},
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
        {type="fluid", name="oxygen", amount=216},
        {type="item", name="biomass", amount=365},
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="item", name="log", amount=8},
      },
    },
    ["wood-seedling-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="water", amount=599},
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="iron-slime-barrel", amount=6},
        {type="item", name="lens", amount=2},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=3},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.96420773894801,
      ingredients = {
        {type="fluid", name="tailings", amount=371},
        {type="item", name="cellulose", amount=22},
        {type="item", name="retrovirus", amount=7},
      },
      results = {
        {type="item", name="wood-seeds", amount=1},
        {type="item", name="wood-seeds-mk02", amount=0.00927795997419715},
      },
    },
    ["wood-seeds-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chlorine-barrel", amount=12},
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
        {type="fluid", name="steam", amount=364},
        {type="item", name="aluminium-plate", amount=7},
        {type="item", name="wood-seeds-mk02", amount=4},
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
        {type="fluid", name="carbon-dioxide", amount=618},
        {type="item", name="anthracene-oil-canister", amount=286},
        {type="item", name="coal-dust", amount=274},
        {type="item", name="kerosene-canister", amount=48},
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
        {type="item", name="pipe", amount=1490},
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
        {type="item", name="aluminium-plate", amount=23},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="iron-stick", amount=63},
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
        {type="item", name="empty-comb", amount=12},
        {type="item", name="fish-egg", amount=15},
        {type="item", name="glass", amount=205},
        {type="item", name="nexelit-plate", amount=117},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="stopper", amount=6},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
    },
    ["ulric-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=115},
        {type="item", name="gravel", amount=11},
        {type="item", name="kerosene-canister", amount=1},
        {type="item", name="meat", amount=2},
        {type="item", name="nickel-plate", amount=2},
        {type="item", name="ralesia-seeds", amount=7},
        {type="item", name="seaweed", amount=17},
      },
      results = {
        {type="item", name="ulric-food-01", amount=7},
      },
    },
    ["ulric-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-iron", amount=3},
        {type="item", name="molten-iron-barrel", amount=2},
        {type="item", name="ralesia", amount=3},
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
        {type="item", name="hazard-concrete", amount=5},
        {type="item", name="ralesia", amount=15},
        {type="item", name="tall-oil-barrel", amount=2},
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
        {type="item", name="benzene-barrel", amount=4},
        {type="item", name="ralesia", amount=13},
        {type="item", name="sb-grade-04", amount=4},
        {type="item", name="tall-oil-barrel", amount=2},
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
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="pipe", amount=518},
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
        {type="item", name="crushed-coal", amount=35},
        {type="item", name="pipe", amount=518},
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
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="logistic-science-pack", amount=28},
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
        {type="item", name="py-science-pack-1", amount=174},
        {type="item", name="sodium-hydroxide", amount=586},
        {type="item", name="zipir-codex", amount=17},
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
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=55},
        {type="item", name="tuuphra-codex", amount=1},
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
        {type="item", name="aluminium-plate", amount=2070},
        {type="item", name="korlex-codex", amount=6},
        {type="item", name="tower-mk01", amount=3},
      },
      results = {
        {type="item", name="earth-bee-sample", amount=1},
      },
    },
    ["earth-horse-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cdna", amount=3},
        {type="item", name="kicalk-codex", amount=4},
        {type="item", name="logistic-science-pack", amount=25},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=3},
      },
    },
    ["kicalk-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=731},
        {type="item", name="bio-sample01", amount=13},
        {type="item", name="earth-bee-sample", amount=2},
        {type="item", name="empty-planter-box", amount=4},
        {type="item", name="moss-gen", amount=125},
        {type="item", name="py-shed-basic", amount=3},
        {type="item", name="sea-sponge-codex", amount=3},
      },
      results = {
        {type="item", name="kicalk", amount=3},
      },
    },
    ["kicalk-fiber"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=3},
      },
      results = {
        {type="item", name="raw-fiber", amount=5},
      },
    },
    ["kicalk-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="fertilizer", amount=2},
      },
      results = {
        {type="item", name="kicalk-seeds", amount=6},
      },
    },
    ["kicalk-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="melamine", amount=4},
        {type="item", name="residual-oil-canister", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=8},
      },
    },
    ["kicalk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=167},
        {type="item", name="coke", amount=6},
        {type="item", name="kicalk-seeds", amount=15},
        {type="item", name="limestone", amount=4},
        {type="item", name="tinned-cable", amount=4},
      },
      results = {
        {type="item", name="kicalk", amount=12},
      },
    },
    ["sea-sponge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=618},
        {type="item", name="cdna", amount=3},
        {type="item", name="coal-dust", amount=137},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="retrovirus", amount=5},
      },
      results = {
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="raw-gas-canister", amount=5},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=4},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-pup", amount=2},
      },
      results = {
        {type="item", name="ore-quartz", amount=7},
      },
    },
    ["arthropod-blood-to-organic-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cumene", amount=20},
        {type="fluid", name="waste-water", amount=383},
        {type="item", name="zinc-plate", amount=1},
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
        {type="fluid", name="steam", amount=1293},
        {type="fluid", name="water", amount=100},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=756},
        {type="fluid", name="water", amount=675},
        {type="item", name="tuuphra", amount=4},
      },
      results = {
        {type="fluid", name="tailings", amount=50},
        {type="item", name="cobalt-extract", amount=3},
      },
    },
    ["flue-gas-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=50},
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
        {type="fluid", name="hydrogen", amount=50},
        {type="fluid", name="water", amount=7815},
        {type="fluid", name="water-saline", amount=503},
        {type="item", name="lead-plate", amount=3},
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
        {type="fluid", name="carbon-dioxide", amount=200},
        {type="fluid", name="water", amount=2550},
        {type="item", name="pipe", amount=3},
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
        {type="fluid", name="carbon-dioxide", amount=340},
        {type="fluid", name="slacked-lime", amount=378},
        {type="item", name="cottongut-pup", amount=2},
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
        {type="fluid", name="olefin", amount=437},
        {type="item", name="sulfur", amount=5},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=50},
      },
    },
    ["wastewater-filtration"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=189},
        {type="item", name="limestone", amount=6},
      },
      results = {
        {type="fluid", name="methanol", amount=100},
      },
    },
    ["agitator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=72},
        {type="item", name="concrete", amount=434},
        {type="item", name="copper-plate", amount=80},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="melamine-resin", amount=11},
        {type="item", name="pipe", amount=129},
        {type="item", name="tinned-cable", amount=495},
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
        {type="item", name="cumene-barrel", amount=4},
        {type="item", name="fawogae-plantation-mk01", amount=2},
        {type="item", name="formic-acid-barrel", amount=2},
        {type="item", name="glass", amount=411},
        {type="item", name="inductor1", amount=186},
        {type="item", name="iron-slime-barrel", amount=9},
        {type="item", name="pipe", amount=85},
        {type="item", name="steam-engine", amount=7},
        {type="item", name="syngas-canister", amount=21},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=1},
      },
    },
    ["compressor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbolic-oil-barrel", amount=2},
        {type="item", name="concrete", amount=276},
        {type="item", name="drilling-fluid-0-barrel", amount=6},
        {type="item", name="molten-glass-barrel", amount=5},
        {type="item", name="scrude-canister", amount=13},
        {type="item", name="titanium-plate", amount=20},
        {type="item", name="washer", amount=4},
      },
      results = {
        {type="item", name="compressor-mk01", amount=1},
      },
    },
    ["gas-separator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=13},
        {type="item", name="active-carbon", amount=249},
        {type="item", name="grade-4-copper", amount=5},
        {type="item", name="inductor1", amount=224},
        {type="item", name="organic-solvent-barrel", amount=12},
        {type="item", name="pulp-mill-mk01", amount=1},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="tar-processing-unit", amount=3},
      },
      results = {
        {type="item", name="gas-separator-mk01", amount=1},
      },
    },
    ["hydrocyclone-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=15},
        {type="item", name="bolts", amount=103},
        {type="item", name="duralumin", amount=110},
        {type="item", name="nexelit-plate", amount=64},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="titanium-plate", amount=196},
      },
      results = {
        {type="item", name="hydrocyclone-mk01", amount=2},
      },
    },
    ["thickener-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=14},
        {type="item", name="carbon-dioxide-barrel", amount=30},
        {type="item", name="grade-2-nickel", amount=3},
        {type="item", name="hot-air-barrel", amount=5},
        {type="item", name="inductor1", amount=74},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="workers-food", amount=1},
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
        {type="fluid", name="flue-gas", amount=5326},
      },
      results = {
        {type="item", name="casein", amount=5},
      },
    },
    ["green-sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="gravel", amount=27},
        {type="item", name="melamine-resin", amount=3},
        {type="item", name="shotgun", amount=1},
      },
      results = {
        {type="item", name="green-sic", amount=6},
      },
    },
    ["mixed-ores"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.21108602577533,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
        {type="item", name="grade-2-copper", amount=3},
        {type="item", name="redhot-coke", amount=2},
      },
      results = {
        {type="item", name="mixed-ores", amount=6},
        {type="item", name="stone", amount=1},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="vacuum", amount=208},
        {type="item", name="diborane-barrel", amount=9},
        {type="item", name="small-electric-pole", amount=6},
      },
      results = {
        {type="item", name="cobalt-fluoride", amount=3},
      },
    },
    ["quartz-tube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="boric-acid", amount=1038},
        {type="item", name="equipment-chassi", amount=2},
        {type="item", name="kerosene-canister", amount=9},
      },
      results = {
        {type="item", name="quartz-tube", amount=4},
      },
    },
    ["sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="steel-furnace", amount=1},
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
        {type="fluid", name="diesel", amount=4556},
        {type="item", name="albumin", amount=10},
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
        {type="fluid", name="steam", amount=955},
        {type="fluid", name="water", amount=1275},
        {type="item", name="glass", amount=4},
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
        {type="item", name="empty-planter-box", amount=25},
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
        {type="fluid", name="hydrogen", amount=683},
        {type="item", name="grade-1-ti", amount=3},
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
      energy_required_multiplier = 1.125,
      ingredients = {
        {type="fluid", name="pressured-air", amount=75},
        {type="fluid", name="pressured-water", amount=411},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="limestone", amount=9},
      },
      results = {
        {type="item", name="moondrop", amount=9},
      },
    },
    ["moondrop-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="water", amount=1000},
        {type="item", name="limestone", amount=38},
        {type="item", name="moondrop", amount=2},
        {type="item", name="moondrop-seeds", amount=10},
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
        {type="fluid", name="steam", amount=850},
        {type="fluid", name="tailings", amount=444},
        {type="item", name="condensates-canister", amount=10},
        {type="item", name="gravel", amount=10},
        {type="item", name="kicalk", amount=6},
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
        {type="fluid", name="coke-oven-gas", amount=514},
        {type="fluid", name="methanol", amount=50},
      },
      results = {
        {type="item", name="plastic-bar", amount=10},
      },
    },
    ["plastic-from-casein"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=805},
        {type="fluid", name="steam", amount=127},
        {type="item", name="sap-seeds-mk02", amount=4},
      },
      results = {
        {type="item", name="plastic-bar", amount=20},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=858},
        {type="fluid", name="bitumen-froth", amount=1392},
        {type="item", name="artificial-blood-barrel", amount=1},
        {type="item", name="chromium", amount=153},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="fenxsb-alloy", amount=3},
        {type="item", name="middle-oil-barrel", amount=105},
        {type="item", name="sodium-hydroxide", amount=158},
      },
      results = {
        {type="item", name="zipir1", amount=1},
      },
    },
    ["alien-sample-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="formamide", amount=100},
        {type="fluid", name="outlet-gas-01", amount=1746},
        {type="fluid", name="purest-nitrogen-gas", amount=1545},
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="aluminium-plate", amount=117},
        {type="item", name="coal-gas-barrel", amount=25},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="moss-gen", amount=7},
        {type="item", name="ree-slurry-barrel", amount=1},
        {type="item", name="titanium-plate", amount=13},
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
        {type="fluid", name="boric-acid", amount=521},
        {type="item", name="agar", amount=129},
        {type="item", name="flask", amount=3},
        {type="item", name="sea-sponge-sprouts", amount=2},
        {type="item", name="small-parts-01", amount=7},
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
        {type="fluid", name="methane", amount=341},
        {type="item", name="cocoon-mk02", amount=2},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="py-science-pack-1", amount=1},
        {type="item", name="stopper", amount=18},
      },
      results = {
        {type="item", name="dna-polymerase", amount=1},
      },
    },
    ["manure-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.28,
      ingredients = {
        {type="item", name="ceramic", amount=7},
        {type="item", name="dried-meat", amount=6},
        {type="item", name="petri-dish-bacteria", amount=1},
      },
      results = {
        {type="fluid", name="manure-bacteria", amount=128},
      },
    },
    ["primers"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.42857142857143,
      ingredients = {
        {type="fluid", name="oxygen", amount=921},
        {type="item", name="empty-petri-dish", amount=17},
        {type="item", name="petri-dish", amount=18},
        {type="item", name="propene-barrel", amount=2},
        {type="item", name="raw-fiber", amount=8},
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
        {type="fluid", name="nitrogen", amount=366},
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="saps", amount=4},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="stopper", amount=4},
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
        {type="fluid", name="petroleum-gas", amount=4106},
        {type="fluid", name="subcritical-water", amount=200},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="black-liquor-barrel", amount=5},
        {type="item", name="cottongut-mk01", amount=23},
        {type="item", name="empty-petri-dish", amount=3},
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
        {type="fluid", name="hot-air", amount=256},
        {type="fluid", name="manure-bacteria", amount=50},
        {type="item", name="coal-dust", amount=28},
      },
      results = {
        {type="fluid", name="gasoline", amount=100},
      },
    },
    ["tuuphra-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=656},
        {type="item", name="bio-sample01", amount=23},
        {type="item", name="earth-generic-sample", amount=6},
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="retrovirus", amount=5},
        {type="item", name="xyhiphoe-pool-mk01", amount=5},
      },
      results = {
        {type="item", name="tuuphra", amount=4},
      },
    },
    ["tuuphra-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.125,
      ingredients = {
        {type="item", name="propene-canister", amount=3},
      },
      results = {
        {type="item", name="tuuphra-seeds", amount=9},
      },
    },
    ["tuuphra-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="nitrogen", amount=554},
        {type="fluid", name="pressured-air", amount=67},
        {type="item", name="coarse", amount=10},
        {type="item", name="kicalk", amount=3},
        {type="item", name="methanol-canister", amount=2},
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
        {type="fluid", name="molten-glass", amount=591},
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
        {type="item", name="carbon-black", amount=21},
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
        {type="item", name="aluminium-plate", amount=8},
        {type="item", name="dried-meat", amount=4},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="item", name="korlex-codex", amount=1},
      },
    },
    ["korlex-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=1410},
        {type="fluid", name="water", amount=378},
        {type="item", name="ammonia-barrel", amount=1},
        {type="item", name="bones", amount=6},
        {type="item", name="empty-barrel-milk", amount=8},
        {type="item", name="nickel-plate", amount=2},
        {type="item", name="phosphate-rock", amount=6},
        {type="item", name="ralesia-seeds", amount=14},
        {type="item", name="raw-gas-canister", amount=1},
        {type="item", name="syngas-canister", amount=1},
      },
      results = {
        {type="item", name="korlex-food-01", amount=4},
      },
    },
    ["korlex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="hot-syngas", amount=3905},
        {type="fluid", name="hydrofluoric-acid", amount=3447},
        {type="item", name="arqad-codex", amount=3},
        {type="item", name="cdna", amount=16},
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="hazard-concrete", amount=43},
        {type="item", name="planter-box", amount=41},
        {type="item", name="xyhiphoe-pool-mk01", amount=4},
      },
      results = {
        {type="item", name="korlex", amount=3},
      },
    },
    ["korlex-milk-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.67593903335266,
      ingredients = {
        {type="item", name="al-pulp-02-barrel", amount=3},
        {type="item", name="empty-barrel-milk", amount=5},
        {type="item", name="fish", amount=8},
        {type="item", name="middle-oil-canister", amount=3},
        {type="item", name="molten-iron-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=17},
        {type="item", name="barrel-milk", amount=5},
      },
    },
    ["korlex-pup-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=3},
        {type="item", name="creamy-latex-barrel", amount=7},
        {type="item", name="fertilizer", amount=13},
        {type="item", name="geothermal-water-barrel", amount=19},
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
        {type="item", name="arqad-honey-barrel", amount=2},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="purest-nitrogen-gas-barrel", amount=34},
        {type="item", name="tall-oil-barrel", amount=3},
        {type="item", name="yaedols", amount=5},
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
        {type="fluid", name="sulfuric-acid", amount=139},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=100},
        {type="item", name="sulfur", amount=20},
      },
    },
    ["quench-redcoke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.20441683222314,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=148},
        {type="fluid", name="pressured-air", amount=179},
        {type="item", name="py-aluminium", amount=2},
      },
      results = {
        {type="fluid", name="steam", amount=119},
        {type="item", name="coal-dust", amount=5},
        {type="item", name="coke", amount=36},
      },
    },
    ["redhot-coke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="item", name="coal-dust", amount=29},
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
        {type="fluid", name="flue-gas", amount=2594},
        {type="fluid", name="tar", amount=50},
        {type="item", name="chromium", amount=2},
        {type="item", name="ore-tin", amount=5},
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
        {type="fluid", name="petroleum-gas", amount=1981},
        {type="item", name="niobium-dust", amount=3},
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
        {type="item", name="grade-1-nickel", amount=5},
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
        {type="fluid", name="boric-acid", amount=1138},
        {type="fluid", name="nitrogen", amount=200},
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
        {type="fluid", name="pressured-water", amount=729},
        {type="item", name="light-oil-barrel", amount=15},
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
        {type="item", name="cellulose", amount=381},
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
      energy_required_multiplier = 2.33328115913059,
      ingredients = {
        {type="fluid", name="hydrogen", amount=224},
        {type="item", name="radar", amount=2},
      },
      results = {
        {type="fluid", name="water", amount=22},
        {type="item", name="molybdenum-plate", amount=7},
      },
    },
    ["seaweed-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=133},
        {type="item", name="fawogae", amount=2},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="molybdenum-ore", amount=103},
      },
      results = {
        {type="item", name="seaweed-mk02", amount=1},
      },
    },
    ["fertilizer-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="hot-air", amount=2584},
        {type="item", name="ash", amount=16},
        {type="item", name="auog", amount=1},
        {type="item", name="limestone", amount=1},
        {type="item", name="skin", amount=4},
      },
      results = {
        {type="item", name="fertilizer", amount=16},
      },
    },
    ["fertilizer-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3.6,
      ingredients = {
        {type="item", name="auog-pup", amount=3},
        {type="item", name="drill-head", amount=5},
        {type="item", name="limestone", amount=3},
        {type="item", name="polybutadiene-barrel", amount=2},
      },
      results = {
        {type="item", name="fertilizer", amount=36},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetone", amount=1363},
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
        {type="fluid", name="pressured-air", amount=3515},
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="fluid", name="water", amount=100},
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
        {type="fluid", name="hydrogen", amount=173},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="moss", amount=5},
        {type="item", name="sap-seeds", amount=34},
        {type="item", name="saps", amount=2},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=1},
      },
    },
    ["sap-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="agar", amount=5},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=3},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=86},
        {type="item", name="brain", amount=2},
        {type="item", name="fawogae", amount=9},
        {type="item", name="saps-mk02", amount=16},
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
        {type="fluid", name="carbon-dioxide", amount=309},
        {type="fluid", name="subcritical-water", amount=2193},
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
        {type="fluid", name="sulfuric-acid", amount=10},
        {type="fluid", name="water", amount=100},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="tinned-cable", amount=3},
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
        {type="fluid", name="boric-acid", amount=660},
        {type="fluid", name="steam", amount=333},
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
        {type="fluid", name="flue-gas", amount=1034},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="chitin", amount=2},
      },
      results = {
        {type="item", name="wax-barrel", amount=3},
      },
    },
    ["sugar-wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="empty-fuel-canister", amount=1},
        {type="item", name="ulric-cub", amount=7},
      },
      results = {
        {type="item", name="wax-barrel", amount=2},
      },
    },
    ["phosphate-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-codex", amount=9},
        {type="item", name="automated-factory-mk01", amount=2},
        {type="item", name="engine-unit", amount=28},
        {type="item", name="grade-3-chromite", amount=85},
        {type="item", name="pipe", amount=105},
        {type="item", name="tar-processing-unit", amount=3},
      },
      results = {
        {type="item", name="phosphate-mine", amount=3},
      },
    },
    ["rare-earth-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="decider-combinator", amount=1},
        {type="item", name="empty-barrel-milk", amount=45},
        {type="item", name="pbsb-alloy", amount=29},
        {type="item", name="powdered-aluminium", amount=173},
        {type="item", name="residual-oil-barrel", amount=43},
        {type="item", name="rich-clay", amount=420},
        {type="item", name="stopper", amount=65},
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
        {type="fluid", name="carbon-dioxide", amount=724},
        {type="fluid", name="water", amount=350},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=200},
      },
    },
    ["wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.22,
      ingredients = {
        {type="fluid", name="vacuum", amount=64},
        {type="item", name="lab-instrument", amount=1},
      },
      results = {
        {type="fluid", name="wax", amount=61},
      },
    },
    ["wax-honeycomb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.78,
      ingredients = {
        {type="fluid", name="water", amount=76},
        {type="item", name="middle-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="wax", amount=39},
      },
    },
    ["empty-comb-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=545},
      },
      results = {
        {type="item", name="empty-comb", amount=8},
      },
    },
    ["empty-honeycomb-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="wax", amount=100},
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
        {type="item", name="carbon-dioxide-barrel", amount=4},
        {type="item", name="concrete", amount=4},
        {type="item", name="kicalk-seeds", amount=14},
        {type="item", name="small-parts-01", amount=16},
      },
      results = {
        {type="item", name="big-electric-pole", amount=1},
      },
    },
    ["breed-fish-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.04558804720555,
      ingredients = {
        {type="fluid", name="hydrogen", amount=124},
        {type="fluid", name="water-saline", amount=103},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="biomass", amount=10},
        {type="item", name="fertilizer", amount=15},
        {type="item", name="tailings-barrel", amount=1},
        {type="item", name="tinned-cable", amount=11},
      },
      results = {
        {type="fluid", name="waste-water", amount=103},
        {type="item", name="fish", amount=21},
      },
    },
    ["breed-fish-egg-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1393},
        {type="fluid", name="water", amount=1452},
        {type="item", name="fish", amount=12},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="lime", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=30},
      },
    },
    ["fish-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.999470898598342,
      ingredients = {
        {type="fluid", name="hot-air", amount=1671},
        {type="item", name="bio-sample", amount=3},
        {type="item", name="fish", amount=20},
        {type="item", name="lime", amount=14},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="fish", amount=5},
        {type="item", name="fish-mk02", amount=0.00499735449299171},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1393},
        {type="fluid", name="steam", amount=484},
        {type="item", name="refsyngas-barrel", amount=20},
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
        {type="fluid", name="oxygen", amount=114},
        {type="item", name="lime", amount=4},
        {type="item", name="medium-distillate-canister", amount=2},
        {type="item", name="propene-canister", amount=19},
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
        {type="item", name="display-panel", amount=1},
        {type="item", name="pitch-canister", amount=14},
        {type="item", name="processed-iron-ore", amount=3},
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
        {type="item", name="bitumen-barrel", amount=2},
        {type="item", name="chromium", amount=3},
        {type="item", name="fenxsb-alloy", amount=3},
        {type="item", name="long-handed-inserter", amount=2},
        {type="item", name="nexelit-plate", amount=11},
        {type="item", name="steel-plate", amount=41},
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
        {type="fluid", name="water", amount=9776},
        {type="item", name="niobium-dust", amount=41},
        {type="item", name="steam-engine", amount=6},
        {type="item", name="stripped-distillate-canister", amount=26},
        {type="item", name="tinned-cable", amount=65},
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
        {type="item", name="micro-fiber", amount=7},
        {type="item", name="soil", amount=53},
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
        {type="item", name="acetic-acid-barrel", amount=35},
        {type="item", name="auog", amount=10},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="duralumin", amount=24},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="uranium-ore", amount=407},
        {type="item", name="vanabins-barrel", amount=1},
      },
      results = {
        {type="item", name="mo-mine", amount=1},
      },
    },
    ["niobium-pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-dust", amount=5},
      },
      results = {
        {type="item", name="niobium-pipe", amount=2},
      },
    },
    ["niobium-pipe-to-ground"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-plate", amount=1},
        {type="item", name="pipe", amount=29},
      },
      results = {
        {type="item", name="niobium-pipe-to-ground", amount=2},
      },
    },
    ["py-logistic-robot-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="benzene-barrel", amount=3},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="cyanic-acid-barrel", amount=5},
        {type="item", name="grade-2-lead", amount=3},
        {type="item", name="niobium-powder", amount=10},
        {type="item", name="poorman-wood-fence", amount=140},
        {type="item", name="py-asphalt", amount=38},
        {type="item", name="scrude-canister", amount=38},
        {type="item", name="slacked-lime-barrel", amount=1},
        {type="item", name="stopper", amount=3},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=1},
      },
    },
    ["yaedols-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=53},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="log", amount=2},
        {type="item", name="raw-fiber", amount=13},
        {type="item", name="sncr-alloy", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=3},
      },
    },
    ["yaedols-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=268},
        {type="item", name="aluminium-plate", amount=61},
        {type="item", name="animal-sample-01", amount=11},
        {type="item", name="chromium", amount=160},
        {type="item", name="depolymerized-organics-barrel", amount=2},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="navens-spore", amount=10},
        {type="item", name="plasmids", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=1},
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
        {type="item", name="sodium-hydroxide", amount=82},
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
        {type="fluid", name="carbon-dioxide", amount=124},
        {type="fluid", name="syngas", amount=290},
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
        {type="fluid", name="carbon-dioxide", amount=186},
        {type="fluid", name="geothermal-water", amount=4108},
        {type="fluid", name="hydrogen", amount=141},
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
        {type="fluid", name="pitch", amount=363},
        {type="fluid", name="vacuum", amount=2274},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=30},
      },
    },
    ["natural-gas-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=50},
        {type="item", name="small-parts-01", amount=2},
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
        {type="fluid", name="drilling-fluid-0", amount=50},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="fluid", name="crude-oil", amount=40},
      },
    },
    ["rubber-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=50},
        {type="fluid", name="polybutadiene", amount=50},
        {type="item", name="carbon-black", amount=2},
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
        {type="fluid", name="muddy-sludge", amount=7834},
        {type="fluid", name="polybutadiene", amount=20},
        {type="item", name="belt", amount=16},
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
        {type="fluid", name="boric-acid", amount=358},
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
        {type="fluid", name="water-saline", amount=214},
        {type="item", name="rich-clay", amount=4},
        {type="item", name="titanium-plate", amount=3},
      },
      results = {
        {type="item", name="ticl4", amount=4},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=241},
        {type="fluid", name="geothermal-water", amount=603},
        {type="item", name="bolts", amount=9},
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
        {type="fluid", name="methanal", amount=293},
        {type="item", name="copper-plate", amount=2},
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
        {type="fluid", name="naphtha", amount=150},
        {type="item", name="gravel", amount=3},
      },
      results = {
        {type="fluid", name="syngas", amount=400},
      },
    },
    ["reheat-coke-gas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="fluid", name="creosote", amount=544},
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
      energy_required_multiplier = 1.00104441649661,
      ingredients = {
        {type="fluid", name="pressured-air", amount=151},
        {type="item", name="carbon-black", amount=6},
      },
      results = {
        {type="fluid", name="hot-air", amount=303},
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["aromatics-2-diesel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=520},
        {type="fluid", name="syngas", amount=1126},
        {type="item", name="shotgun-shell", amount=2},
      },
      results = {
        {type="fluid", name="diesel", amount=350},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=735},
        {type="fluid", name="steam", amount=637},
        {type="item", name="kerogen", amount=7},
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
        {type="fluid", name="lubricant", amount=379},
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
        {type="fluid", name="methane", amount=608},
        {type="item", name="carbon-black", amount=1},
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
        {type="fluid", name="tailings", amount=585},
        {type="fluid", name="water", amount=900},
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
        {type="fluid", name="olefin", amount=446},
        {type="item", name="rail", amount=2},
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
        {type="fluid", name="oxygen", amount=698},
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
        {type="fluid", name="ammonia", amount=275},
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
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="ground-sample01", amount=4},
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
        {type="fluid", name="coalbed-gas", amount=430},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="gasoline", amount=200},
      },
    },
    ["stripped-distillate-to-methanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="kerosene", amount=1242},
        {type="item", name="methanol-canister", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=180},
      },
    },
    ["fluorine-to-olefins"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=731},
        {type="fluid", name="molten-glass", amount=605},
        {type="item", name="chromium", amount=2},
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
        {type="fluid", name="high-distillate", amount=200},
        {type="fluid", name="hydrogen", amount=197},
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
        {type="fluid", name="molten-glass", amount=488},
        {type="fluid", name="steam", amount=1045},
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
        {type="fluid", name="geothermal-water", amount=2316},
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
        {type="fluid", name="phytoplankton", amount=264},
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
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hot-air", amount=154},
        {type="fluid", name="kerosene", amount=741},
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
        {type="fluid", name="carbon-dioxide", amount=4578},
      },
      results = {
        {type="fluid", name="tall-oil", amount=100},
      },
    },
    ["bitumen-comb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.993604497567458,
      ingredients = {
        {type="item", name="bio-container", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=49},
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
        {type="fluid", name="water", amount=600},
        {type="item", name="rich-clay", amount=3},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=100},
      },
    },
    ["bio-oil-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bio-oil", amount=200},
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
        {type="fluid", name="anthracene-oil", amount=309},
        {type="fluid", name="oxygen", amount=94},
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
      energy_required_multiplier = 1.11,
      ingredients = {
        {type="fluid", name="residual-mixture", amount=111},
        {type="item", name="boron-trioxide", amount=1},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=111},
      },
    },
    ["oil-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=686},
        {type="fluid", name="purest-nitrogen-gas", amount=1135},
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
        {type="fluid", name="residual-mixture", amount=200},
        {type="fluid", name="water", amount=375},
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
      energy_required_multiplier = 1.29542278604344,
      ingredients = {
        {type="fluid", name="water", amount=13},
        {type="item", name="stripped-distillate-canister", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=32},
        {type="fluid", name="residual-oil", amount=65},
      },
    },
    ["used-comb-to-residual-mixture"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=10},
        {type="item", name="coke", amount=4},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=60},
      },
    },
    ["arqad-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=16},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="pipe", amount=24},
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
        {type="item", name="flask", amount=19},
        {type="item", name="ralesia", amount=6},
        {type="item", name="raw-borax", amount=74},
        {type="item", name="warmer-stone-brick", amount=345},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-comb", amount=5},
        {type="item", name="hot-air-barrel", amount=5},
        {type="item", name="moss", amount=6},
        {type="item", name="sb-grade-01", amount=11},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="filled-comb", amount=5},
      },
    },
    ["arqad-filled-honeycomb-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=3},
        {type="item", name="empty-comb", amount=5},
      },
      results = {
        {type="item", name="honeycomb", amount=4},
      },
    },
    ["arqad"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.75728348636999,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=40482},
        {type="item", name="bio-sample", amount=13},
        {type="item", name="cdna", amount=8},
        {type="item", name="earth-potato-sample", amount=2},
        {type="item", name="moondrop-mk02", amount=28},
      },
      results = {
        {type="item", name="arqad", amount=3},
        {type="item", name="arqad-egg", amount=27},
      },
    },
    ["arqad-egg-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="hydrogen-barrel", amount=158},
        {type="item", name="ore-zinc", amount=199},
        {type="item", name="ralesia-seeds", amount=18},
        {type="item", name="reo", amount=6},
        {type="item", name="yaedols", amount=1},
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
        {type="item", name="cocoon", amount=23},
        {type="item", name="electric-mining-drill", amount=2},
        {type="item", name="inductor1", amount=36},
        {type="item", name="light-oil-canister", amount=11},
        {type="item", name="molten-aluminium-barrel", amount=1},
        {type="item", name="personal-roboport-equipment", amount=1},
        {type="item", name="rich-dust", amount=62},
        {type="item", name="vitreloy", amount=7},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=1},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="empty-comb", amount=2},
        {type="item", name="petroleum-gas-canister", amount=78},
        {type="item", name="repair-pack", amount=3},
      },
      results = {
        {type="item", name="arqad-egg-nest", amount=2},
        {type="item", name="barrel", amount=2},
      },
    },
    ["arqad-maggots-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-vrauks", amount=10},
        {type="item", name="fish-hydrolysate-barrel", amount=25},
        {type="item", name="py-limestone", amount=13},
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
        {type="item", name="bonemeal", amount=20},
        {type="item", name="firearm-magazine", amount=93},
        {type="item", name="naphtha-barrel", amount=4},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood", amount=172},
      },
      results = {
        {type="fluid", name="arqad-honey", amount=250},
        {type="item", name="empty-honeycomb", amount=5},
      },
    },
    ["hotair-empty-honeycomb-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=121},
        {type="fluid", name="gasoline", amount=301},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=10},
      },
    },
    ["bitumen-to-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
      },
      results = {
        {type="fluid", name="nitrogen", amount=200},
      },
    },
    ["bitumen-to-sulfur"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
        {type="fluid", name="steam", amount=67},
      },
      results = {
        {type="item", name="sulfur", amount=10},
      },
    },
    ["crush-oil-sand"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="resistor1", amount=2},
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
        {type="fluid", name="bitumen", amount=100},
        {type="fluid", name="hydrogen", amount=141},
        {type="fluid", name="pressured-water", amount=364},
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
        {type="fluid", name="hot-air", amount=77},
        {type="fluid", name="hot-syngas", amount=100},
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
        {type="fluid", name="carbon-dioxide", amount=989},
        {type="fluid", name="water-saline", amount=1463},
        {type="item", name="vacuum-barrel", amount=1},
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
        {type="fluid", name="carbon-dioxide", amount=247},
        {type="fluid", name="pressured-water", amount=3728},
      },
      results = {
        {type="fluid", name="hot-syngas", amount=100},
        {type="item", name="soot", amount=2},
      },
    },
    ["oil-sand-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=183},
        {type="fluid", name="water", amount=288},
        {type="item", name="plastic-bar", amount=3},
      },
      results = {
        {type="fluid", name="oil-sand-slurry", amount=96},
      },
    },
    ["bitumen-froth"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="oil-sand-slurry", amount=116},
        {type="fluid", name="pressured-air", amount=233},
        {type="item", name="benzene-canister", amount=1},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=116},
        {type="fluid", name="tailings", amount=116},
      },
    },
    ["btx-to-benzene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1502},
        {type="fluid", name="water", amount=600},
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
        {type="fluid", name="coal-gas", amount=469},
        {type="fluid", name="steam", amount=450},
        {type="item", name="limestone", amount=3},
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
        {type="fluid", name="water", amount=638},
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
        {type="fluid", name="slacked-lime", amount=291},
        {type="fluid", name="syngas", amount=935},
      },
      results = {
        {type="item", name="explosives", amount=5},
      },
    },
    ["filtration-media"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="chromium", amount=12},
        {type="item", name="iron-chest", amount=2},
        {type="item", name="nichrome", amount=1},
        {type="item", name="stone", amount=21},
      },
      results = {
        {type="item", name="filtration-media", amount=4},
      },
    },
    ["niobium-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="vacuum-barrel", amount=3},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="niobium-dust", amount=10},
      },
    },
    ["stone-distilation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=133},
        {type="item", name="gravel", amount=50},
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
      energy_required_multiplier = 1.65515072758747,
      ingredients = {
        {type="item", name="polybutadiene-barrel", amount=1},
      },
      results = {
        {type="item", name="gravel", amount=3},
        {type="item", name="rare-earth-dust", amount=5},
      },
    },
    ["rare-earth-beneficiation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.01921935535628,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1264},
        {type="fluid", name="gasoline", amount=258},
        {type="item", name="drilling-fluid-0-barrel", amount=3},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=255},
        {type="fluid", name="steam", amount=2044},
        {type="item", name="rich-dust", amount=5},
        {type="item", name="sand", amount=10},
      },
    },
    ["milling-molybdenite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.19153766060868,
      ingredients = {
        {type="item", name="aromatics-canister", amount=1},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="molybdenite-dust", amount=12},
      },
    },
    ["ree-float"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 0.838604015922124,
      ingredients = {
        {type="fluid", name="tar", amount=230},
        {type="item", name="grade-3-tin", amount=1},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=85},
        {type="item", name="zinc-plate", amount=4},
      },
    },
    ["ree-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=4900},
        {type="fluid", name="muddy-sludge", amount=1778},
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
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="hot-air", amount=6348},
      },
      results = {
        {type="fluid", name="ree-solution", amount=100},
        {type="item", name="uranium-ore", amount=0.1},
      },
    },
    ["crusher-ree"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="acetone-barrel", amount=1},
      },
      results = {
        {type="item", name="rare-earth-powder", amount=7},
        {type="item", name="stone", amount=7},
      },
    },
    ["ree-concentrate2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=1292},
        {type="fluid", name="sulfuric-acid", amount=325},
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
        {type="fluid", name="sulfuric-acid", amount=325},
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
        {type="item", name="moondrop", amount=14},
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
        {type="fluid", name="acidgas", amount=356},
        {type="fluid", name="ree-solution", amount=100},
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
        {type="item", name="chromium", amount=35},
        {type="item", name="pipe", amount=2},
        {type="item", name="shaft-mk01", amount=5},
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
        {type="fluid", name="subcritical-water", amount=3327},
        {type="fluid", name="water", amount=1750},
        {type="item", name="auog-food-01", amount=4},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="guts", amount=11},
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
        {type="item", name="auog-paddock-mk01", amount=7},
        {type="item", name="bolts", amount=57},
        {type="item", name="dried-meat", amount=199},
        {type="item", name="empty-barrel-milk", amount=58},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="grade-1-copper", amount=73},
        {type="item", name="grade-3-copper", amount=60},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="titanium-plate", amount=463},
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
        {type="fluid", name="hot-air", amount=256},
        {type="fluid", name="sulfuric-acid", amount=1165},
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="lens", amount=9},
        {type="item", name="moss-gen", amount=6},
        {type="item", name="soil-extractor-mk01", amount=15},
        {type="item", name="solidified-sarcorus", amount=3},
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
        {type="fluid", name="hydrogen", amount=824},
        {type="fluid", name="vacuum", amount=2898},
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="fish-egg", amount=18},
        {type="item", name="ore-lead", amount=7},
      },
      results = {
        {type="fluid", name="waste-water", amount=200},
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["niobium-concentrate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="residual-mixture-canister", amount=1},
      },
      results = {
        {type="item", name="niobium-concentrate", amount=10},
        {type="item", name="sand", amount=2},
      },
    },
    ["nbfe-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pitch-barrel", amount=4},
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
        {type="fluid", name="oxygen", amount=285},
        {type="fluid", name="water-saline", amount=557},
      },
      results = {
        {type="item", name="niobium-oxide", amount=10},
      },
    },
    ["niobium-plate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="hot-air-barrel", amount=3},
        {type="item", name="methanol-canister", amount=4},
      },
      results = {
        {type="item", name="niobium-plate", amount=6},
      },
    },
    ["niobium-complex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="fluid", name="organic-solvent", amount=50},
        {type="item", name="moondrop", amount=7},
      },
      results = {
        {type="fluid", name="niobium-complex", amount=100},
      },
    },
    ["niobium-powder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="antimonium-ore", amount=17},
      },
      results = {
        {type="item", name="niobium-powder", amount=5},
        {type="item", name="stone", amount=2},
      },
    },
    ["fill-methanol-gas-canister"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="pressured-air", amount=4964},
        {type="item", name="bio-container", amount=2},
      },
      results = {
        {type="item", name="methanol-gas-canister", amount=3},
      },
    },
    ["empty-methanol-gas-canister"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 2.09415820538197,
      ingredients = {
        {type="item", name="naphtha-barrel", amount=3},
      },
      results = {
        {type="fluid", name="methanol", amount=217},
        {type="item", name="empty-gas-canister", amount=2},
      },
    },
    ["hydrogen-chloride-void"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=461},
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
        {type="fluid", name="flue-gas", amount=928},
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
        {type="item", name="refined-concrete", amount=8},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=50},
        {type="fluid", name="hot-residual-mixture", amount=2582},
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
        {type="item", name="methanal-barrel", amount=8},
        {type="item", name="pipe", amount=9},
        {type="item", name="shotgun-shell", amount=9},
      },
      results = {
        {type="item", name="defender-capsule", amount=1},
      },
    },
    ["flamethrower"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="unslimed-iron", amount=2},
        {type="item", name="vane-mk01", amount=2},
      },
      results = {
        {type="item", name="flamethrower", amount=3},
      },
    },
    ["rocket-launcher"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=3},
        {type="item", name="inductor1", amount=38},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="rocket-launcher", amount=1},
      },
    },
    ["flamethrower-ammo"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="light-oil", amount=189},
        {type="item", name="tailings-barrel", amount=5},
      },
      results = {
        {type="item", name="flamethrower-ammo", amount=2},
      },
    },
    ["rocket"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gunpowder", amount=27},
        {type="item", name="hazard-concrete", amount=1},
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
        {type="item", name="ammonia-barrel", amount=4},
        {type="item", name="inductor1", amount=14},
        {type="item", name="shotgun-shell", amount=6},
        {type="item", name="stopper", amount=36},
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
        {type="item", name="glycerol-barrel", amount=1},
        {type="item", name="grade-1-copper", amount=1},
      },
      results = {
        {type="item", name="land-mine", amount=4},
      },
    },
    ["py-science-pack-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      energy_required_multiplier = 1.05555555555556,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=619},
        {type="fluid", name="formamide", amount=792},
        {type="item", name="arqad-maggot", amount=2},
        {type="item", name="casein", amount=31},
        {type="item", name="cdna", amount=4},
        {type="item", name="concrete", amount=25},
        {type="item", name="engine-unit", amount=12},
        {type="item", name="lab-instrument", amount=2},
        {type="item", name="moondrop", amount=160},
        {type="item", name="natural-gas-derrick-mk01", amount=2},
        {type="item", name="saps", amount=192},
      },
      results = {
        {type="item", name="py-science-pack-2", amount=19},
      },
    },
    ["arthropod-blood-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=50},
      },
      results = {
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["guts-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=6},
      },
      results = {
        {type="item", name="copper-ore", amount=15},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=5},
        {type="item", name="meat", amount=5},
      },
      results = {
        {type="item", name="copper-ore", amount=35},
      },
    },
    ["tuuphra-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tuuphra-seeds", amount=15},
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
        {type="fluid", name="water", amount=600},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="fluid", name="ethylene", amount=100},
      },
    },
    ["ceramic-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="item", name="coke", amount=1},
        {type="item", name="rail", amount=2},
        {type="item", name="seaweed", amount=4},
      },
      results = {
        {type="item", name="ceramic", amount=13},
      },
    },
    ["crude-cermet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="melamine-resin", amount=3},
        {type="item", name="ore-lead", amount=4},
        {type="item", name="poorman-wood-fence", amount=1},
      },
      results = {
        {type="item", name="crude-cermet", amount=9},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=203},
        {type="fluid", name="water", amount=100},
        {type="item", name="cellulose", amount=4},
        {type="item", name="stone-furnace", amount=2},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="iron-ore", amount=13},
      },
    },
    ["p2s5"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-oxide", amount=12},
        {type="item", name="wood", amount=5},
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
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=2},
        {type="item", name="pipe", amount=34},
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
        {type="item", name="benzene-canister", amount=27},
        {type="item", name="carbon-dioxide-barrel", amount=182},
        {type="item", name="copper-ore", amount=280},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="korlex-pup", amount=2},
        {type="item", name="navens-spore", amount=43},
        {type="item", name="outlet-gas-01-barrel", amount=18},
        {type="item", name="sic", amount=58},
      },
      results = {
        {type="item", name="trits-reef-mk01", amount=1},
      },
    },
    ["trits"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=885},
        {type="fluid", name="fetal-serum", amount=190},
        {type="item", name="alien-sample-02", amount=4},
        {type="item", name="cocoon", amount=9},
        {type="item", name="cytostatics", amount=3},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="earth-palmtree-sample", amount=1},
        {type="item", name="mukmoux-codex", amount=1},
        {type="item", name="titanium-plate", amount=259},
      },
      results = {
        {type="item", name="trits", amount=2},
      },
    },
    ["trits-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.9647959196282,
      ingredients = {
        {type="fluid", name="water-saline", amount=847},
        {type="item", name="aromatics-canister", amount=3},
        {type="item", name="moondrop-mk02", amount=2},
        {type="item", name="nichrome", amount=2},
        {type="item", name="trits", amount=3},
        {type="item", name="vane-mk01", amount=4},
        {type="item", name="wood", amount=73},
      },
      results = {
        {type="fluid", name="waste-water", amount=847},
        {type="item", name="trits-pup", amount=6},
      },
    },
    ["trits-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=130},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="moondrop-seeds", amount=36},
        {type="item", name="photophore", amount=2},
        {type="item", name="salt", amount=73},
        {type="item", name="sodium-alginate", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=250},
        {type="item", name="trits", amount=2},
      },
    },
    ["glass-core"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=3750},
        {type="item", name="coke", amount=4},
        {type="item", name="zinc-plate", amount=75},
      },
      results = {
        {type="item", name="glass-core", amount=1},
      },
    },
    ["hotair-glass-core"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="oxygen", amount=117},
        {type="fluid", name="steam", amount=5346},
        {type="item", name="gold-plate", amount=4},
        {type="item", name="sand", amount=7},
      },
      results = {
        {type="item", name="glass-core", amount=3},
      },
    },
    ["guar-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="water", amount=293},
        {type="item", name="casein", amount=3},
        {type="item", name="earth-bear-sample", amount=5},
        {type="item", name="earth-bee-sample", amount=3},
        {type="item", name="glass", amount=145},
        {type="item", name="retrovirus", amount=112},
        {type="item", name="trits-codex", amount=24},
        {type="item", name="vrauks-codex", amount=22},
      },
      results = {
        {type="item", name="guar", amount=3},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=67},
        {type="item", name="coarse", amount=2},
        {type="item", name="guar-seeds", amount=5},
        {type="item", name="pure-sand", amount=3},
      },
      results = {
        {type="item", name="guar", amount=10},
      },
    },
    ["acid-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=16},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="item", name="acid-refined-concrete", amount=5},
      },
    },
    ["black-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="condensates-barrel", amount=1},
        {type="item", name="powdered-aluminium", amount=1},
      },
      results = {
        {type="item", name="black-refined-concrete", amount=5},
      },
    },
    ["blue-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="niobium-powder", amount=3},
        {type="item", name="refined-hazard-concrete", amount=4},
      },
      results = {
        {type="item", name="blue-refined-concrete", amount=6},
      },
    },
    ["cyan-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=562},
        {type="item", name="niobium-ore", amount=3},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=3},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop-seeds", amount=3},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="orange-refined-concrete", amount=3},
      },
    },
    ["purple-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vpulp3", amount=5},
        {type="item", name="fungal-substrate-02", amount=1},
      },
      results = {
        {type="item", name="purple-refined-concrete", amount=3},
      },
    },
    ["brown-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-honeycomb", amount=3},
        {type="item", name="grade-1-nickel", amount=1},
      },
      results = {
        {type="item", name="brown-refined-concrete", amount=3},
      },
    },
    ["green-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="pipe", amount=5},
        {type="item", name="rail", amount=2},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=6},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=3},
        {type="item", name="tar-barrel", amount=3},
      },
      results = {
        {type="item", name="pink-refined-concrete", amount=3},
      },
    },
    ["red-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=15},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="red-refined-concrete", amount=3},
      },
    },
    ["yellow-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="pipe", amount=5},
        {type="item", name="ralesia", amount=2},
      },
      results = {
        {type="item", name="yellow-refined-concrete", amount=6},
      },
    },
    ["ipod"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="atomizer-mk01", amount=1},
        {type="item", name="crude-oil-canister", amount=7},
        {type="item", name="duralumin", amount=94},
        {type="item", name="iron-plate", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=20},
        {type="item", name="retorter", amount=2},
        {type="item", name="steel-chest", amount=12},
      },
      results = {
        {type="item", name="ipod", amount=2},
      },
    },
    ["kicalk-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=150},
        {type="fluid", name="steam", amount=167},
        {type="item", name="biomass", amount=10},
        {type="item", name="glass", amount=5},
        {type="item", name="limestone", amount=8},
        {type="item", name="pure-sand", amount=6},
        {type="item", name="ralesia-seeds", amount=7},
        {type="item", name="raw-fiber", amount=23},
        {type="item", name="soil", amount=11},
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
        {type="fluid", name="oxygen", amount=78},
        {type="item", name="glass", amount=25},
        {type="item", name="kicalk", amount=2},
        {type="item", name="melamine", amount=6},
        {type="item", name="raw-fiber", amount=15},
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
        {type="fluid", name="flutec-pp6", amount=50},
        {type="fluid", name="water", amount=859},
        {type="item", name="glass", amount=25},
        {type="item", name="kicalk-seeds-mk02", amount=5},
        {type="item", name="rich-clay", amount=10},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="wood", amount=34},
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
        {type="fluid", name="formic-acid", amount=4540},
        {type="fluid", name="tailings", amount=15325},
        {type="item", name="empty-petri-dish", amount=4908},
        {type="item", name="ez-ranch-mk01", amount=3},
        {type="item", name="fawogae-spore", amount=9},
        {type="item", name="py-science-pack-1", amount=38},
        {type="item", name="rc-mk01", amount=10},
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
        {type="fluid", name="flue-gas", amount=200},
        {type="item", name="grade-3-nickel", amount=3},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="poorman-wood-fence", amount=75},
      },
      results = {
        {type="item", name="py-logo-15tiles", amount=1},
      },
    },
    ["rail-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="brown-refined-concrete", amount=5},
        {type="item", name="grade-1-lead", amount=3},
        {type="item", name="iron-stick", amount=7},
        {type="item", name="refined-natural-gas-barrel", amount=1},
      },
      results = {
        {type="item", name="rail", amount=16},
      },
    },
    ["resorcinol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=6},
        {type="item", name="starch", amount=2},
      },
      results = {
        {type="item", name="resorcinol", amount=2},
      },
    },
    ["sample-cup"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="plastic-bar", amount=2},
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
      mode = "input-preserved-unmodified",
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="slacked-lime", amount=50},
        {type="fluid", name="water", amount=2725},
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
        {type="fluid", name="tailings", amount=72},
        {type="fluid", name="water", amount=5265},
        {type="item", name="capacitor1", amount=1},
        {type="item", name="lubricant-barrel", amount=7},
        {type="item", name="py-tank-1000", amount=3},
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
        {type="fluid", name="hot-air", amount=472},
        {type="fluid", name="water", amount=100},
        {type="item", name="empty-honeycomb", amount=3},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="fine-powdered-biomass", amount=2},
        {type="item", name="gravel", amount=3},
        {type="item", name="lime", amount=3},
        {type="item", name="tuuphra-seeds", amount=10},
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
        {type="fluid", name="oxygen", amount=78},
        {type="item", name="dried-meat", amount=13},
        {type="item", name="oil-sand-slurry-barrel", amount=4},
        {type="item", name="planter-box", amount=2},
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
        {type="fluid", name="acetic-acid", amount=1755},
        {type="fluid", name="manure-bacteria", amount=381},
        {type="item", name="green-sic", amount=7},
        {type="item", name="powdered-biomass", amount=49},
        {type="item", name="ralesia", amount=32},
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
        {type="fluid", name="water", amount=1436},
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
        {type="item", name="mukmoux-fat", amount=9},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=45},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="steam", amount=201},
        {type="item", name="chitin", amount=3},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=19},
      },
    },
    ["xenogenic-from-chitin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=364},
        {type="item", name="mukmoux-fat", amount=33},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=70},
      },
    },
    ["xenogenic-from-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="water", amount=1209},
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=25},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=211},
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=40},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="mukmoux-fat", amount=11},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=60},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="pressured-air", amount=554},
        {type="item", name="skin", amount=2},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=39},
      },
    },
    ["Moss-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="pure-sand", amount=12},
        {type="item", name="stone-brick", amount=8},
      },
      results = {
        {type="item", name="moss", amount=24},
      },
    },
    ["moss-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.9085850004672,
      ingredients = {
        {type="fluid", name="oxygen", amount=165},
        {type="item", name="hydrogen-chloride-barrel", amount=1},
        {type="item", name="moondrop", amount=1},
        {type="item", name="sodium-alginate", amount=2},
        {type="item", name="soil", amount=30},
      },
      results = {
        {type="item", name="moss-mk02", amount=0.038171700009344},
      },
    },
    ["moss-mk02r"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=6462},
        {type="fluid", name="xenogenic-cells", amount=158},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="moss-mk02", amount=3},
        {type="item", name="raw-gas-canister", amount=7},
        {type="item", name="sodium-chlorate", amount=6},
        {type="item", name="used-auog", amount=16},
      },
      results = {
        {type="item", name="moss-mk02", amount=8},
      },
    },
    ["biomass-molten-salt-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="soda-ash", amount=3098},
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
        {type="fluid", name="molten-glass", amount=3110},
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
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="organic-solvent", amount=70},
        {type="item", name="niobium-plate", amount=8},
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
        {type="fluid", name="flue-gas", amount=477},
        {type="item", name="pipe", amount=2},
        {type="item", name="pyrite", amount=9},
        {type="item", name="yaedols", amount=4},
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
        {type="fluid", name="muddy-sludge", amount=264},
        {type="fluid", name="pressured-water", amount=75},
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
        {type="fluid", name="water-saline", amount=12839},
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
        {type="fluid", name="phosphoric-acid", amount=100},
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
        {type="fluid", name="acetic-acid", amount=100},
        {type="fluid", name="geothermal-water", amount=10462},
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
        {type="fluid", name="water", amount=500},
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
        {type="fluid", name="chlorine", amount=297},
        {type="fluid", name="middle-processed-lard", amount=50},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=70},
      },
    },
    ["carbon-sulfide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="propene", amount=30},
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="wood", amount=5},
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
        {type="fluid", name="oxygen", amount=195},
        {type="fluid", name="sulfuric-acid", amount=110},
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
        {type="fluid", name="hydrogen-peroxide", amount=50},
        {type="fluid", name="phosphoric-acid", amount=100},
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="bones", amount=6},
      },
      results = {
        {type="fluid", name="etching", amount=150},
      },
    },
    ["ethylene"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methane", amount=50},
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
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="methane", amount=29},
        {type="fluid", name="pressured-water", amount=348},
        {type="item", name="crushed-molybdenite", amount=1},
      },
      results = {
        {type="fluid", name="methanal", amount=96},
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
        {type="item", name="chromite-sand", amount=5},
        {type="item", name="copper-rejects", amount=1},
      },
      results = {
        {type="fluid", name="acetone", amount=50},
      },
    },
    ["ethylene-from-fruit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stone-brick", amount=45},
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
        {type="item", name="graphite", amount=19},
        {type="item", name="molybdenum-concentrate", amount=272},
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
      energy_required_multiplier = 1.03922537298686,
      ingredients = {
        {type="item", name="uranium-ore", amount=8},
      },
      results = {
        {type="item", name="powdered-u", amount=1},
        {type="item", name="sand", amount=1},
      },
    },
    ["u-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=249},
        {type="fluid", name="muddy-sludge", amount=164},
        {type="item", name="uranium-ore", amount=104},
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
        {type="fluid", name="vacuum", amount=23885},
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
        {type="fluid", name="chlorine", amount=692},
        {type="fluid", name="steam", amount=3484},
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
        {type="fluid", name="nitrobenzene", amount=701},
        {type="fluid", name="water", amount=600},
        {type="item", name="iron-ore-dust", amount=3},
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
        {type="item", name="active-carbon", amount=19},
        {type="item", name="aramid", amount=1},
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
        {type="fluid", name="nitrobenzene", amount=50},
        {type="fluid", name="sulfuric-acid", amount=161},
        {type="item", name="tin-plate", amount=3},
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
        {type="fluid", name="water", amount=2725},
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
        {type="item", name="active-carbon", amount=3},
        {type="item", name="chromium", amount=7},
        {type="item", name="stone", amount=44},
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
        {type="fluid", name="organic-solvent", amount=102},
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
        {type="item", name="boron-trioxide", amount=5},
        {type="item", name="cladding", amount=2},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="inductor1", amount=8},
        {type="item", name="rubber", amount=12},
        {type="item", name="transport-belt", amount=9},
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
        {type="fluid", name="acetic-acid", amount=1041},
        {type="fluid", name="chlorine", amount=400},
        {type="fluid", name="nitrobenzene", amount=50},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="niobium-plate", amount=3},
      },
      results = {
        {type="item", name="nbfe-coating", amount=1},
      },
    },
    ["py-sodium-hydroxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=50},
        {type="item", name="coke", amount=11},
      },
      results = {
        {type="item", name="limestone", amount=5},
        {type="item", name="sodium-hydroxide", amount=10},
      },
    },
    ["sodium-bisulfate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="sodium-hydroxide", amount=4},
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
        {type="item", name="molybdenum-oxide", amount=17},
        {type="item", name="p2s5", amount=2},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=50},
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
        {type="item", name="chromite-sand", amount=5},
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
        {type="fluid", name="boric-acid", amount=300},
        {type="item", name="lignin", amount=90},
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
        {type="item", name="ground-sample01", amount=13},
        {type="item", name="iron-oxide", amount=9},
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
        {type="fluid", name="syngas", amount=1498},
        {type="item", name="sand-casting", amount=16},
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
        {type="fluid", name="hydrogen", amount=601},
        {type="item", name="ceramic", amount=38},
      },
      results = {
        {type="item", name="bisphenol-a", amount=3},
      },
    },
    ["melamine-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=40},
        {type="item", name="phenol", amount=10},
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
        {type="item", name="melamine-resin", amount=17},
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
        {type="item", name="bisphenol-a", amount=3},
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
        {type="item", name="iron-plate", amount=1},
        {type="item", name="salt", amount=12},
        {type="item", name="sodium-silicate", amount=2},
      },
      results = {
        {type="item", name="epoxy", amount=4},
      },
    },
    ["nylon2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="benzene", amount=100},
        {type="fluid", name="chlorine", amount=50},
        {type="item", name="nichrome", amount=2},
      },
      results = {
        {type="item", name="nylon", amount=6},
      },
    },
    ["blood-meal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=100},
        {type="item", name="resistor1", amount=3},
      },
      results = {
        {type="item", name="blood-meal", amount=1},
      },
    },
    ["nylon-parts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rich-dust", amount=2},
      },
      results = {
        {type="item", name="nylon-parts", amount=5},
      },
    },
    ["nylon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="steam", amount=300},
        {type="item", name="bisphenol-a", amount=1},
        {type="item", name="blood-meal", amount=3},
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
        {type="fluid", name="water-saline", amount=106},
        {type="item", name="gunpowder", amount=3},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=75},
        {type="fluid", name="tailings", amount=200},
      },
    },
    ["manure-to-nitrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="item", name="albumin", amount=2},
      },
      results = {
        {type="fluid", name="nitrogen", amount=53},
      },
    },
    ["mibc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acetone", amount=50},
        {type="fluid", name="petroleum-gas", amount=150},
        {type="item", name="copper-rejects", amount=2},
      },
      results = {
        {type="fluid", name="mibc", amount=200},
      },
    },
    ["trichlorosilane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.05957251141654,
      ingredients = {
        {type="fluid", name="water-saline", amount=296},
        {type="item", name="silica-powder", amount=3},
      },
      results = {
        {type="fluid", name="hydrogen", amount=105},
        {type="fluid", name="trichlorosilane", amount=53},
      },
    },
    ["eg-si"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pure-trichlorosilane", amount=50},
        {type="fluid", name="water", amount=638},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="purified-ti-pulp", amount=100},
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
        {type="item", name="coarse", amount=1},
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=510},
      },
    },
    ["powdered-ti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="mibc", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="grade-1-ti", amount=12},
      },
      results = {
        {type="fluid", name="tailings", amount=40},
        {type="fluid", name="ti-pulp-03", amount=60},
        {type="item", name="powdered-ti", amount=2},
      },
    },
    ["titanium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=100},
        {type="item", name="sand", amount=6},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=350},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-3-ti", amount=5},
      },
      results = {
        {type="item", name="ti-enriched-dust", amount=2},
        {type="item", name="ti-rejects", amount=1},
      },
    },
    ["molten-stainless-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="molten-steel", amount=116},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="fecr-alloy", amount=6},
        {type="item", name="low-grade-rejects", amount=1},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="niobium-oxide", amount=5},
        {type="item", name="ore-nickel", amount=1},
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
        {type="item", name="aramid", amount=1},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="item", name="stainless-steel", amount=13},
      },
    },
    ["stainless-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=100},
        {type="item", name="aramid", amount=1},
        {type="item", name="sand", amount=12},
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
        {type="item", name="plastic-bar", amount=1},
      },
      results = {
        {type="item", name="guar-gum", amount=3},
      },
    },
    ["long-handed-inserter-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="pitch", amount=1726},
        {type="item", name="big-electric-pole", amount=1},
        {type="item", name="brain", amount=2},
        {type="item", name="glycerol-barrel", amount=1},
        {type="item", name="pink-refined-concrete", amount=19},
        {type="item", name="refined-natural-gas-barrel", amount=96},
        {type="item", name="submachine-gun", amount=1},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=21},
      },
    },
    ["small-parts-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="belt", amount=2},
        {type="item", name="chromium", amount=1},
        {type="item", name="duralumin", amount=1},
        {type="item", name="glass", amount=1},
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="kerogen", amount=22},
        {type="item", name="niobium-pipe", amount=6},
        {type="item", name="nylon-parts", amount=5},
        {type="item", name="pipe", amount=3},
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
      energy_required_multiplier = 0.866666666666667,
      ingredients = {
        {type="fluid", name="vacuum", amount=12268},
        {type="item", name="anemometer-mk01", amount=6},
        {type="item", name="burner-inserter", amount=32},
        {type="item", name="nexelit-plate", amount=193},
        {type="item", name="niobium-oxide", amount=82},
        {type="item", name="rubber", amount=2},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="utility-box-mk01", amount=1},
      },
      results = {
        {type="item", name="fast-inserter", amount=13},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=130},
        {type="item", name="concrete", amount=138},
        {type="item", name="lead-plate", amount=268},
        {type="item", name="pipe", amount=30},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=15},
      },
    },
    ["rotor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete", amount=76},
        {type="item", name="nxsb-alloy", amount=5},
      },
      results = {
        {type="item", name="rotor", amount=2},
      },
    },
    ["stator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=6},
        {type="item", name="pipe", amount=4},
        {type="item", name="titanium-plate", amount=46},
      },
      results = {
        {type="item", name="stator", amount=1},
      },
    },
    ["electric-engine-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="oxygen", amount=794},
        {type="item", name="eg-si", amount=23},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="inductor1", amount=32},
        {type="item", name="niobium-pipe", amount=117},
        {type="item", name="sncr-alloy", amount=3},
        {type="item", name="tin-plate", amount=11},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=5},
      },
    },
    ["nexelit-power-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=6},
        {type="item", name="pure-sand", amount=8},
        {type="item", name="rare-earth-dust", amount=12},
      },
      results = {
        {type="item", name="nexelit-power-pole", amount=1},
      },
    },
    ["anemometer-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="ceramic", amount=554},
        {type="item", name="iron-plate", amount=14},
        {type="item", name="small-parts-01", amount=116},
      },
      results = {
        {type="item", name="anemometer-mk02", amount=1},
      },
    },
    ["blade-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="glass", amount=359},
        {type="item", name="pipe", amount=49},
        {type="item", name="processed-ash", amount=4},
      },
      results = {
        {type="item", name="blade-mk02", amount=3},
      },
    },
    ["brake-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=349},
        {type="item", name="ceramic", amount=30},
        {type="item", name="cermet", amount=14},
        {type="item", name="duralumin", amount=22},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="sugar", amount=5},
      },
      results = {
        {type="item", name="brake-mk02", amount=1},
      },
    },
    ["controler-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="active-provider-chest", amount=3},
        {type="item", name="chromium", amount=40},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=4},
        {type="item", name="nexelit-battery", amount=5},
        {type="item", name="small-parts-01", amount=6},
        {type="item", name="zinc-acetate", amount=5},
      },
      results = {
        {type="item", name="controler-mk02", amount=1},
      },
    },
    ["electronics-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diode", amount=2},
        {type="item", name="inductor2", amount=2},
        {type="item", name="lignin", amount=106},
        {type="item", name="melamine-resin", amount=131},
        {type="item", name="nexelit-plate", amount=15},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="phenolicboard", amount=32},
        {type="item", name="sic", amount=1},
        {type="item", name="transistor", amount=47},
        {type="item", name="transport-belt", amount=2},
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
        {type="fluid", name="hot-air", amount=1224},
        {type="item", name="duralumin", amount=4},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="lead-plate", amount=17},
        {type="item", name="niobium-oxide", amount=21},
        {type="item", name="niobium-pipe", amount=252},
        {type="item", name="pipe", amount=1845},
        {type="item", name="rubber", amount=5},
        {type="item", name="wax-barrel", amount=22},
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
        {type="item", name="lime", amount=3},
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
        {type="item", name="sand-casting", amount=2},
        {type="item", name="zinc-chloride", amount=164},
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
        {type="item", name="limestone", amount=8},
        {type="item", name="nxsb-alloy", amount=2},
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
        {type="item", name="bisphenol-a", amount=89},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="engine-unit", amount=9},
        {type="item", name="korlex-codex", amount=3},
        {type="item", name="lead-plate", amount=389},
        {type="item", name="sic", amount=8},
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
        {type="item", name="sand", amount=12},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["nacelle-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=49},
        {type="item", name="borax-mine", amount=2},
        {type="item", name="display-panel", amount=67},
        {type="item", name="duralumin", amount=21},
        {type="item", name="fish-hydrolysate-barrel", amount=3},
        {type="item", name="grod-seeds", amount=1444},
        {type="item", name="mechanical-parts-01", amount=10},
        {type="item", name="naphtha-canister", amount=403},
        {type="item", name="py-burner", amount=43},
        {type="item", name="py-construction-robot-mk01", amount=4},
        {type="item", name="sap-tree-mk02", amount=2},
      },
      results = {
        {type="item", name="nacelle-mk02", amount=1},
      },
    },
    ["rotor-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=67},
        {type="item", name="korlex", amount=9},
        {type="item", name="power-switch", amount=1},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="ticl4", amount=49},
        {type="item", name="titanium-plate", amount=11},
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
        {type="item", name="concrete", amount=394},
        {type="item", name="copper-plate", amount=124},
        {type="item", name="intermetallics", amount=14},
        {type="item", name="nexelit-plate", amount=548},
        {type="item", name="niobium-dust", amount=686},
        {type="item", name="vane-mk01", amount=5},
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
        {type="fluid", name="heavy-oil", amount=200},
        {type="item", name="cadaveric-arum-seeds", amount=9},
        {type="item", name="carbon-black", amount=131},
        {type="item", name="empty-honeycomb", amount=375},
        {type="item", name="explosives", amount=36},
        {type="item", name="fluid-drill-mk01", amount=3},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="pipe", amount=362},
        {type="item", name="vrauks-mk02", amount=4},
        {type="item", name="water-saline-barrel", amount=115},
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
        {type="item", name="brake-mk02", amount=2},
        {type="item", name="fluorine-gas-barrel", amount=16},
        {type="item", name="nexelit-matrix", amount=258},
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
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="scrude-canister", amount=452},
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
        {type="item", name="depleted-uranium-fuel-cell", amount=5},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="py-roboport-mk01", amount=5},
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
        {type="item", name="anthraquinone-barrel", amount=1},
        {type="item", name="bio-sample", amount=3},
        {type="item", name="glass", amount=2},
        {type="item", name="small-parts-01", amount=141},
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
        {type="item", name="inductor1", amount=341},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="pipe", amount=3},
        {type="item", name="transport-belt", amount=17},
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
        {type="item", name="glass", amount=2},
        {type="item", name="neuroprocessor", amount=63},
        {type="item", name="trichlorosilane-barrel", amount=2},
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
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="filtration-media", amount=3},
        {type="item", name="pipe", amount=3},
        {type="item", name="sodium-hydroxide", amount=112},
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
        {type="item", name="pipe", amount=3},
        {type="item", name="sodium-hydroxide", amount=47},
        {type="item", name="steam-engine", amount=29},
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
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="sic", amount=1},
        {type="item", name="transport-belt", amount=17},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cdna", amount=1},
        {type="item", name="korlex-codex", amount=4},
        {type="item", name="py-science-pack-1", amount=80},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=1},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cdna", amount=2},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="py-science-pack-1", amount=323},
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
        {type="item", name="yaedols-codex", amount=1},
      },
      results = {
        {type="item", name="earth-tropical-tree-sample", amount=1},
      },
    },
    ["cadaveric-arum-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=630},
        {type="item", name="cytostatics", amount=3},
        {type="item", name="dna-polymerase", amount=39},
        {type="item", name="earth-bear-sample", amount=3},
        {type="item", name="earth-crustacean-sample", amount=5},
        {type="item", name="moss-gen", amount=6},
        {type="item", name="stone-furnace", amount=7},
        {type="item", name="yotoi-codex", amount=4},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=4},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cadaveric-arum", amount=4},
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
        {type="fluid", name="flue-gas", amount=863},
        {type="fluid", name="vacuum", amount=267},
        {type="item", name="cadaveric-arum-seeds", amount=5},
        {type="item", name="coarse", amount=1},
        {type="item", name="stone-wool", amount=1},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=571},
        {type="item", name="aluminium-plate", amount=40},
        {type="item", name="casein", amount=1},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-cow-sample", amount=4},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="nichrome", amount=3},
      },
      results = {
        {type="item", name="grod", amount=1},
      },
    },
    ["dried-grods"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rennea", amount=2},
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
        {type="fluid", name="steam", amount=149},
        {type="item", name="rennea", amount=1},
      },
      results = {
        {type="item", name="dried-grods", amount=5},
      },
    },
    ["grod-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grod", amount=2},
      },
      results = {
        {type="item", name="grod-seeds", amount=4},
      },
    },
    ["grod-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=233},
        {type="item", name="clean-nexelit", amount=2},
        {type="item", name="coarse", amount=1},
        {type="item", name="dried-grods", amount=3},
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
        {type="fluid", name="oxygen", amount=78},
        {type="item", name="alien-sample01", amount=299},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="fawogae", amount=57},
        {type="item", name="moss-gen", amount=9},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="retrovirus", amount=465},
      },
      results = {
        {type="item", name="rennea", amount=2},
      },
    },
    ["rennea-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="rennea", amount=4},
      },
      results = {
        {type="item", name="rennea-seeds", amount=7},
      },
    },
    ["rennea-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="nitrogen", amount=593},
        {type="fluid", name="pressured-air", amount=98},
        {type="item", name="coal-gas-canister", amount=2},
        {type="item", name="niobium-concentrate", amount=1},
        {type="item", name="rennea-seeds", amount=6},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="rennea", amount=6},
      },
    },
    ["bhoddos-to-ti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bhoddos-spore", amount=5},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=50},
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
        {type="item", name="dried-grods", amount=6},
      },
      results = {
        {type="item", name="ore-zinc", amount=5},
      },
    },
    ["meat-to-chromium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bonemeal", amount=4},
      },
      results = {
        {type="item", name="ore-chromium", amount=15},
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
        {type="item", name="yotoi-fruit", amount=4},
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
        {type="fluid", name="flue-gas", amount=935},
        {type="item", name="cadaveric-arum", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="s-biomass", amount=10},
      },
    },
    ["cool-pressured-steam-3000-to-2000"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="pressured-water", amount=110},
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
        {type="fluid", name="tailings", amount=200},
        {type="item", name="bhoddos", amount=12},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="cu-biomass", amount=10},
      },
    },
    ["tuuphra-nacl"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.09342339980914,
      ingredients = {
        {type="fluid", name="tailings", amount=216},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=54},
        {type="item", name="nacl-biomass", amount=11},
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
        {type="fluid", name="water-saline", amount=147},
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
        {type="item", name="fawogae", amount=8},
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
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="limestone", amount=8},
        {type="item", name="moondrop-seeds-mk02", amount=1},
        {type="item", name="ralesia", amount=10},
        {type="item", name="raw-fiber", amount=4},
      },
      results = {
        {type="item", name="moondrop", amount=16},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.13333333333333,
      ingredients = {
        {type="fluid", name="methane", amount=110},
        {type="item", name="moondrop-seeds-mk02", amount=1},
        {type="item", name="nacl-biomass", amount=4},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=17},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.07,
      ingredients = {
        {type="fluid", name="flue-gas", amount=809},
        {type="fluid", name="purest-nitrogen-gas", amount=855},
        {type="fluid", name="steam", amount=107},
        {type="item", name="gold-plate", amount=3},
      },
      results = {
        {type="fluid", name="ethylene-chlorohydrin", amount=107},
      },
    },
    ["moonshine-fueloil-pressing-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="moondrop-fueloil", amount=5},
      },
      results = {
        {type="fluid", name="fuel-oil", amount=400},
        {type="item", name="ash", amount=10},
      },
    },
    ["chloroethanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=140},
        {type="fluid", name="ethylene", amount=50},
        {type="fluid", name="refined-natural-gas", amount=3607},
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
        {type="fluid", name="chloroethanol", amount=100},
        {type="fluid", name="steam", amount=509},
        {type="fluid", name="water", amount=100},
        {type="item", name="boron-trioxide", amount=1},
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
        {type="item", name="lime", amount=22},
        {type="item", name="nichrome", amount=3},
        {type="item", name="pipe", amount=23},
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
        {type="item", name="niobium-oxide", amount=61},
        {type="item", name="silver-plate", amount=1},
        {type="item", name="sodium-hydroxide", amount=122},
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
        {type="fluid", name="boric-acid", amount=150},
        {type="fluid", name="vacuum", amount=100},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="niobium-pipe", amount=24},
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
        {type="item", name="sodium-hydroxide", amount=4},
      },
      results = {
        {type="item", name="sodium-chlorate", amount=5},
      },
    },
    ["steam-heating"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1000},
        {type="fluid", name="water", amount=100},
        {type="item", name="fuelrod-mk01", amount=1},
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
        {type="item", name="niobium-pipe", amount=14},
        {type="item", name="pu-241", amount=4},
        {type="item", name="pu-242", amount=2},
        {type="item", name="ti-enriched-dust", amount=6},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=100},
        {type="fluid", name="perylene", amount=100},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="melamine", amount=2},
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
        {type="item", name="eva", amount=5},
        {type="item", name="lead-plate", amount=4},
        {type="item", name="nbalti", amount=1},
        {type="item", name="ptcda", amount=1},
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
        {type="item", name="bonemeal", amount=89},
        {type="item", name="fenxsb-alloy", amount=1},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chitin", amount=10},
        {type="item", name="landfill", amount=146},
        {type="item", name="lead-plate", amount=35},
        {type="item", name="moondrop", amount=24},
        {type="item", name="ore-tin", amount=1273},
        {type="item", name="polybutadiene-barrel", amount=2},
        {type="item", name="refined-natural-gas-canister", amount=31},
        {type="item", name="rennea-seeds", amount=2},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="vat-brain", amount=1},
      },
    },
    ["mk02-locomotive"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=4},
        {type="item", name="blood-barrel", amount=31},
        {type="item", name="capacitor1", amount=296},
        {type="item", name="coal-gas-barrel", amount=88},
        {type="item", name="cumene-barrel", amount=43},
        {type="item", name="filled-comb", amount=84},
        {type="item", name="kicalk-mk02", amount=64},
        {type="item", name="long-handed-inserter", amount=61},
        {type="item", name="powdered-quartz", amount=103},
        {type="item", name="rail-signal", amount=27},
        {type="item", name="residual-mixture-barrel", amount=48},
        {type="item", name="rocket-launcher", amount=9},
        {type="item", name="tall-oil-barrel", amount=18},
        {type="item", name="tin-ore-rejects", amount=28},
        {type="item", name="tower-mk02", amount=1},
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
        {type="item", name="bolts", amount=1916},
        {type="item", name="controler-mk02", amount=1},
        {type="item", name="eg-si", amount=408},
        {type="item", name="fatty-acids-canister", amount=6},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="light-oil-barrel", amount=41},
        {type="item", name="mibc-barrel", amount=5},
        {type="item", name="oleochemicals-barrel", amount=6},
        {type="item", name="pipe", amount=170},
        {type="item", name="plastic-bar", amount=189},
        {type="item", name="rail", amount=34},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="transport-belt", amount=283},
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
        {type="item", name="condensed-distillate-canister", amount=2},
        {type="item", name="cracker-mk01", amount=1},
        {type="item", name="etching-barrel", amount=17},
        {type="item", name="kicalk-seeds-mk02", amount=2},
        {type="item", name="niobium-oxide", amount=21},
        {type="item", name="nitrogen-barrel", amount=5},
        {type="item", name="scrude-canister", amount=34},
        {type="item", name="seaweed-mk02", amount=3},
        {type="item", name="sic", amount=29},
        {type="item", name="steam-engine", amount=8},
        {type="item", name="steel-chest", amount=6},
        {type="item", name="stone-wool", amount=67},
        {type="item", name="stripped-distillate-barrel", amount=79},
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
        {type="fluid", name="pressured-water", amount=585},
        {type="item", name="chitin", amount=2},
        {type="item", name="chromium", amount=2},
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
        {type="fluid", name="syngas", amount=353},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="sporopollenin", amount=5},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=200},
      },
    },
    ["sea-sponge-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=409},
        {type="fluid", name="phytoplankton", amount=40},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="casein-mixture-barrel", amount=8},
        {type="item", name="geothermal-water-barrel", amount=5},
        {type="item", name="grade-1-iron", amount=14},
      },
      results = {
        {type="item", name="heat-exchanger", amount=1},
      },
    },
    ["heat-pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="low-grade-rejects", amount=81},
        {type="item", name="pipe", amount=18},
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
        {type="item", name="advanced-circuit", amount=500},
        {type="item", name="pipe", amount=585},
        {type="item", name="small-parts-02", amount=423},
        {type="item", name="tin-plate", amount=314},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=1},
      },
    },
    ["steam-turbine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-u", amount=9},
        {type="item", name="nexelit-power-pole", amount=5},
        {type="item", name="niobium-pipe-to-ground", amount=21},
        {type="item", name="nitrogen-barrel", amount=12},
      },
      results = {
        {type="item", name="steam-turbine", amount=1},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="phosphine-gas", amount=20},
        {type="item", name="silicon-wafer", amount=5},
      },
      results = {
        {type="item", name="light-n", amount=10},
      },
    },
    ["p-dope"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="diborane", amount=20},
        {type="fluid", name="etching", amount=20},
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
        {type="fluid", name="steam", amount=143},
        {type="fluid", name="water", amount=4924},
        {type="item", name="limestone", amount=17},
      },
      results = {
        {type="item", name="ammonium-chloride", amount=2},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["p2s5-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sulfur", amount=5},
        {type="item", name="wood", amount=5},
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
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="coal-gas-canister", amount=138},
        {type="item", name="rocket-launcher", amount=5},
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
        {type="fluid", name="steam", amount=83},
        {type="fluid", name="sulfuric-acid", amount=250},
        {type="item", name="flask", amount=736},
        {type="item", name="sodium-carbonate", amount=1},
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
        {type="item", name="coalbed-gas-canister", amount=243},
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
        {type="fluid", name="sb-phosphate-1", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=250},
        {type="item", name="nxsb-alloy", amount=8},
      },
      results = {
        {type="fluid", name="plutonium-peroxide", amount=100},
        {type="fluid", name="sb-phosphate-2", amount=100},
      },
    },
    ["plutonium-shuffle-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=34},
        {type="item", name="plutonium-oxide", amount=1},
        {type="item", name="sb-hpo-pu", amount=1},
      },
      results = {
        {type="item", name="pu-238", amount=1},
        {type="item", name="pu-242", amount=1},
      },
    },
    ["plutonium-shuffle-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ree-solution", amount=716},
        {type="item", name="plutonium-oxide", amount=2},
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
        {type="fluid", name="sulfuric-acid", amount=2862},
        {type="item", name="sb-hpo-pu", amount=3},
        {type="item", name="u-238", amount=2},
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
        {type="item", name="raw-fiber", amount=33},
        {type="item", name="tinned-cable", amount=21},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="rayon", amount=5},
      },
    },
    ["battery-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=79},
        {type="item", name="nxsb-alloy", amount=4},
        {type="item", name="rayon", amount=3},
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="battery-mk01", amount=5},
      },
    },
    ["battery-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=90},
        {type="item", name="lime", amount=3},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="p2s5", amount=5},
        {type="item", name="rayon", amount=4},
      },
      results = {
        {type="item", name="battery-mk01", amount=7},
      },
    },
    ["nas-battery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="item", name="chromium", amount=1},
        {type="item", name="coke", amount=184},
        {type="item", name="lime", amount=8},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="rayon", amount=2},
        {type="item", name="steel-plate", amount=1},
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
        {type="fluid", name="methanol", amount=557},
        {type="fluid", name="pressured-water", amount=711},
        {type="item", name="chromium", amount=15},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="pipe", amount=7},
        {type="item", name="silica-powder", amount=10},
      },
      results = {
        {type="item", name="used-nexelit-battery", amount=1},
      },
    },
    ["nexelit-battery-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="distilator", amount=2},
        {type="item", name="nexelit-plate", amount=9},
      },
      results = {
        {type="item", name="nexelit-battery", amount=3},
      },
    },
    ["casein-mixture-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=5702},
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
        {type="fluid", name="fish-hydrolysate", amount=100},
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
        {type="fluid", name="subcritical-water", amount=794},
        {type="fluid", name="water", amount=281},
        {type="item", name="soil", amount=84},
      },
      results = {
        {type="fluid", name="b-molasse", amount=100},
      },
    },
    ["ethanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="b-molasse", amount=65},
        {type="fluid", name="zogna-bacteria", amount=26},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="ethanol", amount=130},
      },
    },
    ["syrup-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=333},
        {type="item", name="fawogae-substrate", amount=24},
        {type="item", name="sporopollenin", amount=1},
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
        {type="item", name="raw-fiber", amount=28},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="fertilizer", amount=15},
      },
    },
    ["fertilizer-fish-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=4865},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="solder", amount=53},
      },
      results = {
        {type="item", name="u-235", amount=1},
        {type="item", name="u-238", amount=9},
      },
    },
    ["plutonium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=539},
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
        {type="item", name="carbon-dioxide-barrel", amount=3},
        {type="item", name="grade-2-lead", amount=1},
        {type="item", name="refsyngas-canister", amount=16},
        {type="item", name="tall-oil-canister", amount=5},
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
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="belt-immunity-equipment", amount=10},
        {type="item", name="cumene-barrel", amount=3},
        {type="item", name="fungal-substrate-03", amount=29},
        {type="item", name="heavy-oil-canister", amount=6},
        {type="item", name="korlex-pup", amount=26},
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
        {type="item", name="grade-1-zinc", amount=64},
        {type="item", name="phosphoric-acid-barrel", amount=7},
        {type="item", name="warm-stone-brick", amount=105},
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
        {type="item", name="saps", amount=3},
        {type="item", name="skin", amount=60},
      },
      results = {
        {type="item", name="bio-scafold", amount=1},
      },
    },
    ["bone-fat"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=2},
      },
    },
    ["print-bonemeal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=622},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="bonemeal", amount=4},
      },
    },
    ["print-bones"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=622},
        {type="item", name="bonemeal", amount=182},
      },
      results = {
        {type="item", name="bones", amount=3},
      },
    },
    ["print-brain"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=778},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="brain", amount=2},
      },
    },
    ["print-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="chitin", amount=20},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=5},
      },
    },
    ["print-guts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=622},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=622},
        {type="item", name="bonemeal", amount=182},
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
        {type="fluid", name="steam", amount=100},
        {type="fluid", name="vacuum", amount=204},
        {type="item", name="dried-biomass", amount=86},
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
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="aromatics", amount=115},
        {type="fluid", name="manure-bacteria", amount=23},
        {type="fluid", name="vacuum", amount=11210},
        {type="item", name="nisi", amount=2},
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="fluid", name="tpa", amount=58},
      },
    },
    ["oleo-gasification"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=200},
        {type="fluid", name="oxygen", amount=250},
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
        {type="item", name="barrel", amount=1},
        {type="item", name="cobalt-extract", amount=4},
        {type="item", name="phenol", amount=11},
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
        {type="fluid", name="heavy-oil", amount=200},
        {type="item", name="anemometer-mk01", amount=49},
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="cladded-core", amount=1},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="duralumin", amount=66},
        {type="item", name="engine-unit", amount=33},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="stainless-steel", amount=8},
        {type="item", name="tower-mk01", amount=16},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="utility-box-mk01", amount=5},
        {type="item", name="vane-mk02", amount=6},
      },
      results = {
        {type="item", name="mechanical-parts-02", amount=6},
      },
    },
    ["sb-oxide-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="fluid", name="sb-pulp-02", amount=100},
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
        {type="fluid", name="water", amount=1275},
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
        {type="fluid", name="acetic-acid", amount=50},
        {type="fluid", name="low-distillate", amount=931},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="lead-acetate", amount=1},
      },
    },
    ["dowfroth-250"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=522},
        {type="fluid", name="medium-distillate", amount=558},
        {type="item", name="coke", amount=13},
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
        {type="item", name="coal-dust", amount=18},
        {type="item", name="sb-grade-03", amount=2},
      },
      results = {
        {type="item", name="sb-crushed", amount=3},
      },
    },
    ["sb-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="sb-grade-03", amount=5},
      },
      results = {
        {type="item", name="sb-dust", amount=2},
        {type="item", name="sb-grade-04", amount=1},
      },
    },
    ["sb-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.985,
      ingredients = {
        {type="fluid", name="fish-oil", amount=25},
        {type="item", name="sb-crushed", amount=4},
        {type="item", name="shaft-mk02", amount=1},
      },
      results = {
        {type="fluid", name="sb-pulp-01", amount=197},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="battery-mk01", amount=30},
        {type="item", name="iron-ore", amount=6},
        {type="item", name="iron-ore-dust", amount=35},
        {type="item", name="micro-fiber", amount=7},
        {type="item", name="niobium-oxide", amount=6},
        {type="item", name="small-parts-02", amount=6},
      },
      results = {
        {type="item", name="fast-splitter", amount=1},
      },
    },
    ["fast-transport-belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="lubricant", amount=10},
        {type="item", name="duralumin", amount=4},
        {type="item", name="nexelit-plate", amount=43},
        {type="item", name="niobium-oxide", amount=6},
        {type="item", name="transport-belt", amount=2},
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
        {type="item", name="grade-3-tin", amount=18},
        {type="item", name="hot-residual-mixture-canister", amount=2},
        {type="item", name="hydrogen-peroxide-barrel", amount=2},
        {type="item", name="sap-seeds", amount=42},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="stone-furnace", amount=1},
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
        {type="item", name="bitumen-froth-barrel", amount=12},
        {type="item", name="flutec-pp6-barrel", amount=5},
        {type="item", name="grade-1-zinc", amount=6},
        {type="item", name="grade-4-tin", amount=162},
        {type="item", name="nxsb-alloy", amount=22},
        {type="item", name="petroleum-gas-canister", amount=10},
        {type="item", name="pipe", amount=179},
        {type="item", name="pressured-hydrogen-barrel", amount=7},
        {type="item", name="py-tank-1000", amount=7},
        {type="item", name="resistor1", amount=269},
      },
      results = {
        {type="item", name="neutron-absorber-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=189},
        {type="item", name="coalbed-gas-canister", amount=340},
        {type="item", name="creamy-latex-barrel", amount=2947},
        {type="item", name="duralumin", amount=70},
        {type="item", name="fish-egg-mk03", amount=10},
        {type="item", name="low-grade-copper", amount=292},
        {type="item", name="meat", amount=2538},
        {type="item", name="moondrop-seeds", amount=256},
        {type="item", name="nacelle-mk02", amount=1},
        {type="item", name="organic-acid-anhydride-barrel", amount=446},
        {type="item", name="rare-earth-mine", amount=39},
        {type="item", name="vrauks-codex", amount=11},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk02", amount=2},
      },
    },
    ["py-coal-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="efficiency-module", amount=1},
        {type="item", name="electric-engine-unit", amount=8},
        {type="item", name="fetal-serum-barrel", amount=11},
        {type="item", name="flora-collector-mk01", amount=8},
        {type="item", name="hazard-concrete", amount=78},
        {type="item", name="naphthalene-oil-canister", amount=18},
        {type="item", name="organic-acid-anhydride-barrel", amount=177},
        {type="item", name="processed-fatty-acids-barrel", amount=606},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="steam-turbine-mk01", amount=2},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk02", amount=1},
      },
    },
    ["py-oil-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="duralumin", amount=540},
        {type="item", name="efficiency-module", amount=3},
        {type="item", name="engine-unit", amount=41},
        {type="item", name="ethylene-chlorohydrin-barrel", amount=19},
        {type="item", name="kicalk-seeds-mk02", amount=738},
        {type="item", name="mechanical-parts-01", amount=40},
        {type="item", name="poorman-wood-fence", amount=355},
        {type="item", name="powdered-aluminium", amount=461},
        {type="item", name="py-gas-powerplant-mk01", amount=2},
        {type="item", name="saps-mk02", amount=617},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk02", amount=2},
      },
    },
    ["tidal-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=14},
        {type="item", name="coal-slurry-barrel", amount=6129},
        {type="item", name="controler-mk02", amount=2},
        {type="item", name="empty-fuel-canister", amount=13},
        {type="item", name="intermetallics", amount=132},
        {type="item", name="methanol-gas-canister", amount=15},
        {type="item", name="nacelle-mk02", amount=1},
        {type="item", name="propene-canister", amount=54},
        {type="item", name="pump", amount=43},
        {type="item", name="py-tank-1000", amount=126},
        {type="item", name="redhot-coke", amount=1061},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="zipir1", amount=31},
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
        {type="item", name="auog-mk02", amount=1},
        {type="item", name="brake-mk02", amount=2},
        {type="item", name="caged-auog", amount=134},
        {type="item", name="earth-horse-sample", amount=3},
        {type="item", name="eva", amount=40},
        {type="item", name="heat-pipe", amount=44},
        {type="item", name="neuroprocessor", amount=13},
        {type="item", name="nexelit-matrix", amount=129},
        {type="item", name="powdered-u", amount=318},
        {type="item", name="py-sinkhole", amount=5},
        {type="item", name="resistor2", amount=46},
        {type="item", name="wood-seedling-mk02", amount=230},
        {type="item", name="yaedols-spores", amount=79},
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
        {type="item", name="auog-mk02", amount=4},
        {type="item", name="cottongut-codex", amount=2},
        {type="item", name="ethylene-barrel", amount=383},
        {type="item", name="fawogae-plantation-mk01", amount=47},
        {type="item", name="photophore", amount=118},
        {type="item", name="rotor-mk01", amount=1},
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
        {type="item", name="belt-immunity-equipment", amount=7},
        {type="item", name="caged-mukmoux", amount=1},
        {type="item", name="carbon-sulfide-barrel", amount=33},
        {type="item", name="electronics-mk02", amount=10},
        {type="item", name="grade-2-chromite", amount=783},
        {type="item", name="molten-aluminium-barrel", amount=12},
        {type="item", name="mosfet", amount=10},
        {type="item", name="navens-codex", amount=1},
        {type="item", name="niobium-concentrate", amount=1108},
        {type="item", name="organic-acid-anhydride-barrel", amount=590},
        {type="item", name="phytoplankton-barrel", amount=460},
        {type="item", name="rail-chain-signal", amount=1503},
        {type="item", name="rocket", amount=1090},
        {type="item", name="stone-furnace", amount=438},
        {type="item", name="yaw-drive-mk02", amount=3},
      },
      results = {
        {type="item", name="steam-turbine-mk02", amount=1},
      },
    },
    ["jig-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete-wall", amount=75},
        {type="item", name="filled-comb", amount=101},
        {type="item", name="molten-iron-barrel", amount=23},
        {type="item", name="molten-stainless-steel-barrel", amount=6},
        {type="item", name="mukmoux-pasture-mk01", amount=1},
        {type="item", name="organic-acid-anhydride-barrel", amount=6},
        {type="item", name="py-science-pack-1", amount=7},
        {type="item", name="ree-solution-barrel", amount=3},
        {type="item", name="sweet-syrup-barrel", amount=3},
      },
      results = {
        {type="item", name="jig-mk01", amount=2},
      },
    },
    ["nmf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=186},
        {type="item", name="duralumin", amount=8},
        {type="item", name="empty-petri-dish", amount=15},
        {type="item", name="lab", amount=4},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="niobium-pipe-to-ground", amount=3},
        {type="item", name="pipe", amount=241},
        {type="item", name="py-coal-tile", amount=8},
        {type="item", name="resistor1", amount=505},
      },
      results = {
        {type="item", name="nmf-mk01", amount=1},
      },
    },
    ["py-heat-exchanger-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=7},
        {type="item", name="barrel-machine-mk01", amount=95},
        {type="item", name="brain-cartridge-01", amount=1},
        {type="item", name="hydrocyclone-mk01", amount=3},
        {type="item", name="iron-pulp-01-barrel", amount=2},
        {type="item", name="py-tank-8000", amount=1},
        {type="item", name="sb-grade-02", amount=6056},
        {type="item", name="ulric-cub", amount=174},
      },
      results = {
        {type="item", name="py-heat-exchanger-mk02", amount=1},
      },
    },
    ["bio-printer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=30},
        {type="item", name="concrete", amount=23},
        {type="item", name="grade-3-copper", amount=35},
        {type="item", name="molten-aluminium-barrel", amount=8},
        {type="item", name="niobium-pipe", amount=19},
        {type="item", name="pipe", amount=241},
        {type="item", name="polybutadiene-barrel", amount=103},
        {type="item", name="stone-brick", amount=255},
        {type="item", name="transport-belt", amount=300},
      },
      results = {
        {type="item", name="bio-printer-mk01", amount=1},
      },
    },
    ["botanical-nursery-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blood-barrel", amount=34},
        {type="item", name="electronic-circuit", amount=128},
        {type="item", name="formamide-barrel", amount=32},
        {type="item", name="grade-2-tin", amount=51},
        {type="item", name="organic-acid-anhydride-barrel", amount=1},
        {type="item", name="saps-mk02", amount=33},
        {type="item", name="small-parts-01", amount=11},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="steam-turbine", amount=4},
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
        {type="item", name="aromatics-barrel", amount=78},
        {type="item", name="arqad-egg", amount=3},
        {type="item", name="botanical-nursery", amount=2},
        {type="item", name="electronics-mk02", amount=4},
        {type="item", name="flora-collector-mk01", amount=54},
        {type="item", name="hazard-concrete", amount=509},
        {type="item", name="kerosene-canister", amount=8},
        {type="item", name="middle-oil-canister", amount=38},
        {type="item", name="resorcinol", amount=370},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.70148106564745,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1185},
        {type="fluid", name="water", amount=7386},
        {type="item", name="albumin", amount=3},
        {type="item", name="filtration-media", amount=3},
        {type="item", name="fish-egg-mk02", amount=5},
        {type="item", name="fish-food-02", amount=3},
        {type="item", name="powdered-biomass", amount=13},
        {type="item", name="small-lamp", amount=8},
        {type="item", name="sodium-alginate", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=271},
        {type="item", name="fish", amount=81},
      },
    },
    ["breed-fish-egg-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=9173},
        {type="fluid", name="water", amount=2725},
        {type="item", name="dried-meat", amount=5},
        {type="item", name="fish", amount=12},
        {type="item", name="salt", amount=15},
        {type="item", name="stopper", amount=3},
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
        {type="fluid", name="oxygen", amount=214},
        {type="fluid", name="water", amount=17200},
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
        {type="fluid", name="sulfuric-acid", amount=197},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="casein", amount=1},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish-mk02", amount=20},
        {type="item", name="fishmeal", amount=11},
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
        {type="item", name="glass", amount=26},
        {type="item", name="lime", amount=68},
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
        {type="fluid", name="pressured-air", amount=143},
        {type="fluid", name="steam", amount=167},
        {type="fluid", name="subcritical-water", amount=1352},
        {type="item", name="tin-plate", amount=5},
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
        {type="item", name="agar", amount=3},
        {type="item", name="fiberboard", amount=7},
        {type="item", name="glass", amount=4},
        {type="item", name="molybdenum-sulfide", amount=13},
        {type="item", name="p-dope", amount=2},
        {type="item", name="pcb1", amount=1},
        {type="item", name="pcb2", amount=1},
        {type="item", name="planter-box", amount=6},
        {type="item", name="ppd", amount=36},
        {type="item", name="skin", amount=10},
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
        {type="fluid", name="boric-acid", amount=200},
        {type="item", name="copper-cable", amount=118},
        {type="item", name="inductor1", amount=3},
        {type="item", name="titanium-plate", amount=11},
      },
      results = {
        {type="item", name="capacitor2", amount=5},
      },
    },
    ["microchip"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="cermet", amount=5},
        {type="item", name="glass", amount=9},
        {type="item", name="light-n", amount=10},
        {type="item", name="nexelit-plate", amount=8},
        {type="item", name="p-dope", amount=10},
        {type="item", name="tinned-cable", amount=10},
      },
      results = {
        {type="item", name="microchip", amount=3},
      },
    },
    ["mosfet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=15},
        {type="fluid", name="water", amount=10453},
        {type="item", name="aluminium-plate", amount=1},
        {type="item", name="cermet", amount=12},
        {type="item", name="heavy-n", amount=4},
        {type="item", name="light-n", amount=4},
        {type="item", name="nexelit-plate", amount=4},
        {type="item", name="planter-box", amount=8},
        {type="item", name="py-quartz", amount=7},
        {type="item", name="rare-earth-powder", amount=46},
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
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="item", name="phenolicboard", amount=5},
      },
    },
    ["resistor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=161},
        {type="item", name="cermet", amount=3},
        {type="item", name="fecr-alloy", amount=4},
        {type="item", name="resistor1", amount=4},
      },
      results = {
        {type="item", name="resistor2", amount=4},
      },
    },
    ["inductor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ferrite", amount=10},
        {type="item", name="melamine-resin", amount=5},
        {type="item", name="resistor1", amount=9},
        {type="item", name="tin-plate", amount=34},
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
        {type="item", name="inductor2", amount=2},
        {type="item", name="low-grade-copper", amount=1},
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
        {type="fluid", name="vacuum", amount=100},
        {type="item", name="cermet", amount=13},
        {type="item", name="heavy-n", amount=5},
        {type="item", name="melamine-resin", amount=5},
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
        {type="fluid", name="water", amount=94},
        {type="item", name="bio-sample", amount=3},
        {type="item", name="ceramic", amount=53},
        {type="item", name="heavy-n", amount=1},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="melamine-resin", amount=45},
        {type="item", name="ree-concentrate", amount=8},
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
        {type="item", name="bakelite", amount=5},
        {type="item", name="capacitor2", amount=5},
        {type="item", name="formica", amount=146},
        {type="item", name="heavy-n", amount=2},
        {type="item", name="inductor1", amount=53},
        {type="item", name="iron-plate", amount=38},
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="molybdenum-concentrate", amount=10},
        {type="item", name="pcb1", amount=20},
        {type="item", name="phenolicboard", amount=19},
        {type="item", name="used-nexelit-battery", amount=2},
        {type="item", name="vacuum-tube", amount=96},
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
        {type="item", name="grade-3-tin", amount=1934},
        {type="item", name="land-mine", amount=510},
        {type="item", name="methanol-reactor", amount=2},
        {type="item", name="nbfe-coating", amount=6},
        {type="item", name="phosphorous-acid-barrel", amount=294},
        {type="item", name="pitch-barrel", amount=232},
        {type="item", name="polybutadiene-barrel", amount=232},
        {type="item", name="zipir1", amount=7},
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
        {type="item", name="chromite-sand", amount=7798},
        {type="item", name="cobalt-fluoride", amount=530},
        {type="item", name="empty-petri-dish", amount=313},
        {type="item", name="green-refined-concrete", amount=48},
        {type="item", name="methane-canister", amount=214},
        {type="item", name="nacelle-mk01", amount=1},
        {type="item", name="refsyngas-canister", amount=104},
        {type="item", name="titanium-plate", amount=46},
        {type="item", name="tuuphra-plantation-mk01", amount=6},
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
        {type="item", name="bitumen-froth-barrel", amount=145},
        {type="item", name="controler-mk02", amount=2},
        {type="item", name="diode", amount=82},
        {type="item", name="drilling-fluid-0-barrel", amount=670},
        {type="item", name="fast-transport-belt", amount=54},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="jaw-crusher", amount=12},
        {type="item", name="lead-acetate", amount=57},
        {type="item", name="mechanical-parts-01", amount=6},
        {type="item", name="military-science-pack", amount=781},
        {type="item", name="py-roboport-mk01", amount=11},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="stripped-distillate-canister", amount=236},
        {type="item", name="vinyl-acetate-barrel", amount=16},
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
        {type="item", name="accumulator", amount=253},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="glass", amount=30},
        {type="item", name="inductor1", amount=102},
        {type="item", name="skin", amount=13},
        {type="item", name="small-lamp", amount=3},
        {type="item", name="stainless-steel", amount=16},
        {type="item", name="steel-chest", amount=6},
      },
      results = {
        {type="item", name="bhoddos-culture-mk01", amount=1},
      },
    },
    ["cadaveric-arum-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=11},
        {type="item", name="flora-collector-mk01", amount=2},
        {type="item", name="glass", amount=105},
        {type="item", name="hydrocyclone-mk01", amount=1},
        {type="item", name="nexelit-plate", amount=492},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=1},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="blade-mk01", amount=5},
        {type="item", name="carbon-dioxide-barrel", amount=34},
        {type="item", name="duralumin", amount=8},
        {type="item", name="fawogae", amount=50},
        {type="item", name="fenxsb-alloy", amount=23},
        {type="item", name="inductor1", amount=137},
        {type="item", name="kicalk", amount=67},
        {type="item", name="medium-electric-pole", amount=40},
        {type="item", name="nexelit-plate", amount=50},
        {type="item", name="phytoplankton-barrel", amount=7},
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
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="ethylene-barrel", amount=14},
        {type="item", name="glass", amount=162},
        {type="item", name="incubator-mk01", amount=1},
        {type="item", name="nexelit-plate", amount=420},
        {type="item", name="pipe-to-ground", amount=3},
        {type="item", name="rare-earth-dust", amount=45},
        {type="item", name="shotgun-shell", amount=302},
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
        {type="item", name="acidgas-barrel", amount=17},
        {type="item", name="al-pulp-02-barrel", amount=12},
        {type="item", name="aluminium-plate", amount=70},
        {type="item", name="depolymerized-organics-barrel", amount=2},
        {type="item", name="fertilizer", amount=14},
        {type="item", name="lead-plate", amount=28},
        {type="item", name="neuroprocessor", amount=19},
        {type="item", name="processed-fatty-acids-barrel", amount=1},
        {type="item", name="titanium-plate", amount=164},
        {type="item", name="vitreloy", amount=10},
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
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="cottongut-pup", amount=8},
        {type="item", name="ethylene-canister", amount=237},
        {type="item", name="grade-1-nickel", amount=2503},
        {type="item", name="grade-2-lead", amount=15},
        {type="item", name="guar-seeds", amount=492},
        {type="item", name="lead-plate", amount=50},
        {type="item", name="molten-steel-barrel", amount=14},
        {type="item", name="moondrop", amount=125},
        {type="item", name="oil-sand-slurry-barrel", amount=426},
        {type="item", name="tpa-barrel", amount=108},
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
        {type="item", name="big-electric-pole", amount=4},
        {type="item", name="distilator", amount=1},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="glass", amount=87},
        {type="item", name="inductor1", amount=341},
        {type="item", name="iron-chest", amount=5},
        {type="item", name="iron-plate", amount=137},
        {type="item", name="latex", amount=6},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="soil", amount=900},
      },
      results = {
        {type="item", name="rennea-plantation-mk01", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=137},
        {type="item", name="lab", amount=1},
        {type="item", name="middle-oil-canister", amount=1},
        {type="item", name="sample-cup", amount=68},
        {type="item", name="silver-plate", amount=7},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="tin-plate", amount=20},
        {type="item", name="titanium-plate", amount=164},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=1},
      },
    },
    ["sponge-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acid-refined-concrete", amount=329},
        {type="item", name="advanced-circuit", amount=30},
        {type="item", name="bio-container", amount=203},
        {type="item", name="brain-cartridge-01", amount=22},
        {type="item", name="distilator", amount=2},
        {type="item", name="empty-planter-box", amount=168},
        {type="item", name="honeycomb", amount=38},
        {type="item", name="hot-air-barrel", amount=178},
        {type="item", name="powdered-u", amount=9},
        {type="item", name="rail-signal", amount=172},
        {type="item", name="ralesia-mk02", amount=1},
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
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="carbolic-oil-canister", amount=33},
        {type="item", name="grade-4-nickel", amount=1107},
        {type="item", name="lead-plate", amount=50},
        {type="item", name="perylene-barrel", amount=13},
        {type="item", name="ralesia-seeds", amount=4146},
        {type="item", name="sample-cup", amount=170},
        {type="item", name="stripped-distillate-barrel", amount=33},
        {type="item", name="unslimed-iron", amount=19},
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
        {type="item", name="black-refined-concrete", amount=936},
        {type="item", name="condensates-canister", amount=59},
        {type="item", name="condensed-distillate-barrel", amount=9},
        {type="item", name="empty-comb", amount=570},
        {type="item", name="grade-1-copper", amount=5184},
        {type="item", name="low-distillate-barrel", amount=4},
        {type="item", name="niobium-pipe-to-ground", amount=3},
        {type="item", name="organic-solvent-barrel", amount=12},
        {type="item", name="p-dope", amount=28},
        {type="item", name="pipe-to-ground", amount=310},
        {type="item", name="stripped-distillate-barrel", amount=3},
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
        {type="item", name="battery-mk00", amount=74},
        {type="item", name="empty-honeycomb", amount=375},
        {type="item", name="mechanical-parts-01", amount=6},
        {type="item", name="molten-zinc-barrel", amount=118},
        {type="item", name="navens", amount=77},
        {type="item", name="propene-canister", amount=36},
        {type="item", name="purified-ti-pulp-barrel", amount=19},
        {type="item", name="py-steel", amount=20},
        {type="item", name="salt", amount=210},
        {type="item", name="shaft-mk02", amount=2},
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
        {type="item", name="advanced-circuit", amount=40},
        {type="item", name="duralumin", amount=6},
        {type="item", name="fast-splitter", amount=1},
        {type="item", name="middle-processed-lard-barrel", amount=38},
        {type="item", name="nexelit-power-pole", amount=29},
        {type="item", name="sea-sponge-sprouts-mk02", amount=6},
        {type="item", name="seaweed-mk03", amount=1},
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
        {type="item", name="advanced-circuit", amount=10},
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
        {type="item", name="perylene-barrel", amount=19},
        {type="item", name="propene-barrel", amount=45},
        {type="item", name="sap-tree-mk03", amount=1},
        {type="item", name="vrauks", amount=3},
        {type="item", name="water-saline-barrel", amount=9},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk02", amount=1},
      },
    },
    ["moss-farm-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=114},
        {type="item", name="empty-gas-canister", amount=148},
        {type="item", name="fatty-acids-barrel", amount=84},
        {type="item", name="hot-syngas-canister", amount=25},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="medium-electric-pole", amount=44},
        {type="item", name="neuroprocessor", amount=19},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="vrauks", amount=8},
      },
      results = {
        {type="item", name="moss-farm-mk02", amount=1},
      },
    },
    ["navens-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arithmetic-combinator", amount=56},
        {type="item", name="arqad-hive-mk01", amount=5},
        {type="item", name="chromite-rejects", amount=90},
        {type="item", name="crude-oil-barrel", amount=121},
        {type="item", name="fawogae-spore-mk02", amount=140},
        {type="item", name="guar-seeds", amount=33},
        {type="item", name="portable-gasoline-generator", amount=17},
        {type="item", name="power-switch", amount=1},
        {type="item", name="silver-plate", amount=1},
        {type="item", name="vrauks-mk02", amount=4},
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
        {type="item", name="caged-auog", amount=1},
        {type="item", name="eva", amount=117},
        {type="item", name="heat-pipe", amount=4},
        {type="item", name="high-grade-ti-powder", amount=17},
        {type="item", name="lead-plate", amount=30},
        {type="item", name="liquid-nitrogen-barrel", amount=16},
        {type="item", name="p-dope", amount=31},
        {type="item", name="phosphoric-acid-barrel", amount=2},
        {type="item", name="tin-dust", amount=4579},
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
        {type="item", name="chloroethanol-barrel", amount=4},
        {type="item", name="display-panel", amount=16},
        {type="item", name="duralumin", amount=12},
        {type="item", name="ech-barrel", amount=3},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="landfill", amount=2},
        {type="item", name="molten-copper-barrel", amount=6},
        {type="item", name="ptcda", amount=7},
        {type="item", name="rare-earth-mud-barrel", amount=693},
        {type="item", name="wpu-mk01", amount=2},
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
        {type="item", name="cdna", amount=3},
        {type="item", name="chitin", amount=406},
        {type="item", name="grade-1-chromite", amount=27},
        {type="item", name="heavy-oil-canister", amount=12},
        {type="item", name="low-grade-rejects", amount=141},
        {type="item", name="moondrop-seeds", amount=334},
        {type="item", name="powdered-ti", amount=21},
        {type="item", name="seaweed-crop-mk01", amount=1},
        {type="item", name="syngas-canister", amount=124},
      },
      results = {
        {type="item", name="seaweed-crop-mk02", amount=1},
      },
    },
    ["tuuphra-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=714},
        {type="item", name="eg-si", amount=360},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="high-distillate-canister", amount=1442},
        {type="item", name="methanol-gas-canister", amount=41},
        {type="item", name="niobium-pipe", amount=2767},
        {type="item", name="sb-pulp-01-barrel", amount=8},
        {type="item", name="sponge-culture-mk01", amount=1},
        {type="item", name="syngas-canister", amount=4},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acid-refined-concrete", amount=88},
        {type="item", name="bhoddos-culture-mk01", amount=1},
        {type="item", name="brain-cartridge-01", amount=22},
        {type="item", name="coal-slurry-barrel", amount=255},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="glass", amount=44},
        {type="item", name="intermetallics", amount=9},
        {type="item", name="purified-syngas-canister", amount=12},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="transport-belt", amount=77},
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
        {type="item", name="bee-venom-barrel", amount=5},
        {type="item", name="grade-3-lead", amount=22},
        {type="item", name="intermetallics", amount=17},
        {type="item", name="meat", amount=29},
        {type="item", name="methanol-gas-canister", amount=3},
        {type="item", name="nickel-rejects", amount=4},
        {type="item", name="purified-ti-pulp-barrel", amount=5},
        {type="item", name="wood-fence", amount=14},
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
        {type="item", name="aromatics-barrel", amount=1923},
        {type="item", name="ash", amount=3055},
        {type="item", name="auog-food-02", amount=35},
        {type="item", name="eg-si", amount=288},
        {type="item", name="molten-titanium-barrel", amount=2},
        {type="item", name="niobium-complex-barrel", amount=21},
        {type="item", name="offshore-pump", amount=41},
        {type="item", name="petri-dish", amount=29},
        {type="item", name="plastic-bar", amount=50},
        {type="item", name="py-gas-vent", amount=10},
      },
      results = {
        {type="item", name="fwf-mk02", amount=1},
      },
    },
    ["bulk-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="engine-unit", amount=7},
        {type="item", name="fast-transport-belt", amount=2},
        {type="item", name="fenxsb-alloy", amount=21},
        {type="item", name="inserter", amount=5},
        {type="item", name="mechanical-parts-01", amount=4},
      },
      results = {
        {type="item", name="bulk-inserter", amount=3},
      },
    },
    ["assembling-machine-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="dried-biomass", amount=1497},
        {type="item", name="grade-1-iron", amount=85},
        {type="item", name="solder", amount=291},
        {type="item", name="vpulp2-barrel", amount=152},
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
        {type="item", name="carbon-black", amount=66},
        {type="item", name="concrete", amount=59},
        {type="item", name="copper-coating", amount=8},
        {type="item", name="duralumin", amount=45},
        {type="item", name="glass", amount=16},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nuclear-sample", amount=1},
        {type="item", name="self-assembly-monolayer", amount=2},
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
        {type="item", name="empty-honeycomb", amount=139},
        {type="item", name="fawogae-spore", amount=7},
        {type="item", name="grade-3-lead", amount=1},
        {type="item", name="sodium-bisulfate", amount=155},
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
        {type="item", name="electric-engine-unit", amount=3},
        {type="item", name="electronic-circuit", amount=510},
        {type="item", name="niobium-powder", amount=32},
        {type="item", name="raw-gas-barrel", amount=1},
        {type="item", name="steam-engine", amount=3},
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
        {type="fluid", name="mibc", amount=1123},
        {type="item", name="chloroethanol-barrel", amount=26},
        {type="item", name="coalbed-mk01", amount=19},
        {type="item", name="dried-grods", amount=42},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="ethylene-glycol-barrel", amount=63},
        {type="item", name="grenade", amount=8},
        {type="item", name="py-local-radar", amount=253},
        {type="item", name="stone-furnace", amount=12},
        {type="item", name="tin-ore-rejects", amount=327},
        {type="item", name="vrauks-mk03", amount=9},
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
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="brake-mk02", amount=1},
        {type="item", name="cobalt-fluoride", amount=21},
        {type="item", name="duralumin", amount=3086},
        {type="item", name="fast-transport-belt", amount=8},
        {type="item", name="niobium-powder", amount=48},
        {type="item", name="py-electric-boiler", amount=2},
        {type="item", name="rail-chain-signal", amount=147},
        {type="item", name="steel-chest", amount=61},
        {type="item", name="zogna-bacteria-barrel", amount=2},
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
        {type="item", name="chitin", amount=53},
        {type="item", name="cyanic-acid-barrel", amount=1478},
        {type="item", name="glycerol-barrel", amount=137},
        {type="item", name="iron-pulp-01-barrel", amount=3},
        {type="item", name="molten-iron-barrel", amount=867},
        {type="item", name="molten-zinc-barrel", amount=6},
        {type="item", name="retorter", amount=2},
        {type="item", name="stone-brick", amount=74},
        {type="item", name="trits-pup", amount=16},
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
        {type="item", name="b-molasse-barrel", amount=51},
        {type="item", name="bio-oil-canister", amount=68},
        {type="item", name="cottongut", amount=62},
        {type="item", name="diesel-canister", amount=21},
        {type="item", name="duralumin", amount=5},
        {type="item", name="empty-comb", amount=21},
        {type="item", name="grade-3-iron", amount=1384},
        {type="item", name="organic-acid-anhydride-barrel", amount=29},
        {type="item", name="steam-engine", amount=4},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
    },
    ["kicalk-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kicalk", amount=158},
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
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="fertilizer", amount=4},
        {type="item", name="kicalk", amount=2},
        {type="item", name="poorman-wood-fence", amount=2},
        {type="item", name="yotoi", amount=3},
      },
      results = {
        {type="item", name="bedding", amount=3},
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
        {type="item", name="s-biomass", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="iron-ore", amount=20},
      },
    },
    ["fungal-substrate-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="water-saline", amount=770},
        {type="item", name="brain", amount=1},
        {type="item", name="fine-powdered-biomass", amount=4},
        {type="item", name="fungal-substrate-02", amount=1},
        {type="item", name="powdered-biomass", amount=59},
        {type="item", name="stopper", amount=2},
        {type="item", name="ticl4", amount=1},
        {type="item", name="tuuphra-seeds", amount=14},
      },
      results = {
        {type="item", name="fungal-substrate-03", amount=12},
      },
    },
    ["nacl-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=140},
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
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="xenogenic-cells", amount=150},
        {type="item", name="quartz-tube", amount=2},
        {type="item", name="sugar", amount=3},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="fluid", name="psc", amount=50},
      },
    },
    ["s-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=140},
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
        {type="item", name="sn-biomass", amount=10},
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
        {type="item", name="calcium-carbide", amount=12},
        {type="item", name="lime", amount=5},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="flue-gas-barrel", amount=4},
        {type="item", name="fungal-substrate-02", amount=2},
        {type="item", name="rennea-seeds", amount=14},
      },
      results = {
        {type="item", name="sporopollenin", amount=5},
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
        {type="fluid", name="steam", amount=100},
        {type="item", name="chromium", amount=1},
        {type="item", name="dried-biomass", amount=69},
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
        {type="item", name="kicalk-seeds", amount=113},
        {type="item", name="soil", amount=54},
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
      energy_required_multiplier = 1.68133161223073,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="cocoon-mk02", amount=5},
        {type="item", name="molten-iron-barrel", amount=1},
        {type="item", name="ore-nickel", amount=6},
        {type="item", name="pyrite", amount=4},
        {type="item", name="ralesia", amount=18},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="ulric", amount=10},
      },
    },
    ["ulric-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=2},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="moss", amount=17},
        {type="item", name="ralesia", amount=10},
        {type="item", name="refined-natural-gas-barrel", amount=8},
        {type="item", name="sample-cup", amount=12},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="ulric-cub", amount=6},
      },
    },
    ["ulric-manure-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.52822341784697,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=8},
        {type="item", name="raw-fiber", amount=34},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="ulric-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="manure", amount=9},
      },
    },
    ["ulric-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="kicalk", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=4},
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
        {type="item", name="chitin", amount=2},
        {type="item", name="sand-casting", amount=1},
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
        {type="item", name="latex-slab", amount=2},
        {type="item", name="melamine", amount=9},
        {type="item", name="moss", amount=14},
        {type="item", name="ulric", amount=89},
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
        {type="item", name="bedding", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="sample-cup", amount=24},
        {type="item", name="ulric-mk02", amount=1},
        {type="item", name="ulric-mk02-dna-sample", amount=12},
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
        {type="item", name="bedding", amount=2},
        {type="item", name="used-auog", amount=72},
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
        {type="item", name="kicalk-seeds", amount=5},
        {type="item", name="mixed-ores", amount=27},
        {type="item", name="ralesia-seeds-mk02", amount=1},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="ulric-cub-mk02", amount=4},
        {type="item", name="vinyl-acetate-barrel", amount=1},
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
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="mukmoux-codex", amount=1},
      },
      results = {
        {type="item", name="korlex-codex-mk02", amount=1},
      },
    },
    ["korlex-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bhoddos-spore", amount=2},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="fawogae", amount=46},
        {type="item", name="fishmeal", amount=3},
        {type="item", name="korlex-pup", amount=4},
        {type="item", name="olefin-barrel", amount=5},
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="saps", amount=12},
        {type="item", name="silicon", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=4},
      },
    },
    ["korlex-milk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bhoddos", amount=4},
        {type="item", name="ethanol-barrel", amount=2},
        {type="item", name="fish", amount=10},
        {type="item", name="fishmeal", amount=7},
        {type="item", name="iron-oxide", amount=6},
        {type="item", name="mixed-ores", amount=18},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=20},
        {type="item", name="barrel-milk", amount=12},
      },
    },
    ["korlex-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="korlex", amount=2},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="py-quartz", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="rennea-seeds", amount=17},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="korlex", amount=1},
        {type="item", name="korlex-mk02", amount=0.005},
      },
    },
    ["korlex-pup-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="ethanol-barrel", amount=2},
        {type="item", name="fish", amount=15},
        {type="item", name="fish-hydrolysate-barrel", amount=12},
        {type="item", name="gravel", amount=10},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=119628},
        {type="fluid", name="xenogenic-cells", amount=100},
        {type="item", name="bio-sample", amount=95},
        {type="item", name="chitin", amount=102},
        {type="item", name="korlex-food-01", amount=22},
        {type="item", name="korlex-mk02", amount=4},
        {type="item", name="nichrome", amount=7},
      },
      results = {
        {type="item", name="korlex-mk02", amount=5},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=629},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="gunpowder", amount=6},
        {type="item", name="sap-tree", amount=9},
        {type="item", name="stone-furnace", amount=2},
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
        {type="item", name="acetylene-barrel", amount=2},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=2},
      },
    },
    ["sap-tree-mk03-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="steam", amount=693},
        {type="item", name="arqad-honey-barrel", amount=6},
        {type="item", name="guts", amount=10},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="sap-tree-mk03", amount=2},
      },
    },
    ["xyhiphoe-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.45878008331969,
      ingredients = {
        {type="fluid", name="hydrogen", amount=1914},
        {type="fluid", name="phytoplankton", amount=116},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="fishmeal", amount=6},
        {type="item", name="native-flora", amount=32},
        {type="item", name="py-logo-15tiles", amount=2},
        {type="item", name="xyhiphoe-cub", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=465},
        {type="item", name="xyhiphoe", amount=3},
      },
    },
    ["xyhiphoe-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=1167},
        {type="fluid", name="water-saline", amount=1894},
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="dried-meat", amount=4},
        {type="item", name="nylon-parts", amount=38},
        {type="item", name="seaweed", amount=51},
        {type="item", name="small-lamp", amount=7},
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
        {type="fluid", name="water", amount=5250},
        {type="item", name="calcinates", amount=16},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="ralesia-seeds", amount=68},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="advanced-circuit", amount=29},
        {type="item", name="al-pulp-02-barrel", amount=15},
        {type="item", name="cottongut-mk02", amount=13},
        {type="item", name="efficiency-module", amount=4},
        {type="item", name="empty-fuel-canister", amount=10},
        {type="item", name="empty-honeycomb", amount=2712},
        {type="item", name="flutec-pp6-barrel", amount=27},
        {type="item", name="native-flora", amount=143},
        {type="item", name="niobium-dust", amount=346},
        {type="item", name="ptcda", amount=31},
        {type="item", name="steam-engine", amount=31},
        {type="item", name="vanabins-barrel", amount=28},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=3},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.873810086551692,
      ingredients = {
        {type="fluid", name="steam", amount=1610},
        {type="item", name="bio-oil-canister", amount=22},
        {type="item", name="fawogae-spore", amount=20},
        {type="item", name="fish-egg-mk02", amount=2},
        {type="item", name="nichrome", amount=2},
        {type="item", name="xyhiphoe", amount=20},
      },
      results = {
        {type="item", name="xyhiphoe-cub", amount=1},
        {type="item", name="xyhiphoe-cub-mk02", amount=2},
      },
    },
    ["xyhiphoe-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="residual-oil", amount=1633},
        {type="item", name="xyhiphoe-cub-mk02", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
    },
    ["bhoddos-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="pressured-air", amount=57},
        {type="item", name="empty-fuel-canister", amount=2},
        {type="item", name="fungal-substrate", amount=4},
        {type="item", name="powdered-biomass", amount=4},
      },
      results = {
        {type="item", name="bhoddos", amount=4},
      },
    },
    ["bhoddos-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=485},
        {type="item", name="acetone-barrel", amount=2},
        {type="item", name="aluminium-plate", amount=42},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="fungal-substrate-02", amount=43},
        {type="item", name="plasmids", amount=1},
        {type="item", name="primers", amount=6},
        {type="item", name="trits-codex", amount=4},
      },
      results = {
        {type="item", name="bhoddos", amount=1},
      },
    },
    ["fish-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="acidgas-barrel", amount=1},
        {type="item", name="chromium", amount=9},
        {type="item", name="fawogae-spore", amount=7},
        {type="item", name="fish", amount=2},
        {type="item", name="fish-food-01", amount=5},
        {type="item", name="guts", amount=8},
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="meat", amount=13},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="sodium-carbonate", amount=1},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="yotoi", amount=2},
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
      energy_required_multiplier = 1.14285714285714,
      ingredients = {
        {type="fluid", name="pressured-air", amount=78},
        {type="item", name="aromatics-canister", amount=1},
        {type="item", name="fungal-substrate-03", amount=1},
        {type="item", name="guts", amount=6},
        {type="item", name="ralesia", amount=6},
      },
      results = {
        {type="item", name="navens", amount=8},
      },
    },
    ["navens-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="planter-box", amount=19},
        {type="item", name="rennea-codex", amount=36},
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
        {type="item", name="filled-comb", amount=5},
        {type="item", name="inductor1", amount=68},
        {type="item", name="lead-plate", amount=2},
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
        {type="fluid", name="water", amount=382},
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="clean-nexelit", amount=5},
        {type="item", name="fawogae", amount=59},
        {type="item", name="mixed-ores", amount=3},
        {type="item", name="pipe", amount=6},
        {type="item", name="vrauks-food-01", amount=1},
        {type="item", name="water-saline-barrel", amount=1},
      },
      results = {
        {type="item", name="mukmoux-food-01", amount=4},
      },
    },
    ["mukmoux-manure-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.96836141439634,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="mukmoux-food-01", amount=4},
        {type="item", name="ralesia-mk02", amount=3},
        {type="item", name="raw-fiber", amount=65},
        {type="item", name="refined-natural-gas-barrel", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=27},
        {type="item", name="manure", amount=10},
        {type="item", name="manure-bacteria-barrel", amount=2},
      },
    },
    ["mukmoux"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=1699},
        {type="fluid", name="wax", amount=2745},
        {type="item", name="cytostatics", amount=9},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="grade-1-tin", amount=62},
        {type="item", name="retrovirus", amount=123},
        {type="item", name="ulric-codex", amount=2},
      },
      results = {
        {type="item", name="mukmoux", amount=2},
      },
    },
    ["mukmoux-calf-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="fertilizer", amount=20},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="naphtha-barrel", amount=6},
        {type="item", name="yaedols", amount=3},
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
        {type="item", name="mukmoux-food-01", amount=3},
        {type="item", name="ralesia", amount=16},
        {type="item", name="refined-natural-gas-barrel", amount=5},
        {type="item", name="tuuphra", amount=3},
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
        {type="item", name="empty-gas-canister", amount=14},
        {type="item", name="lens", amount=42},
        {type="item", name="methanol-gas-canister", amount=19},
        {type="item", name="pipe", amount=179},
        {type="item", name="stone-wall", amount=229},
        {type="item", name="wood-seeds", amount=360},
      },
      results = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
    },
    ["cottongut-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="steam", amount=134},
        {type="item", name="coal-dust", amount=9},
        {type="item", name="fawogae", amount=9},
        {type="item", name="fish", amount=1},
        {type="item", name="moondrop-seeds-mk02", amount=3},
        {type="item", name="nexelit-plate", amount=6},
        {type="item", name="ore-tin", amount=18},
        {type="item", name="rennea", amount=8},
        {type="item", name="wood-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=8},
      },
    },
    ["cottongut-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.99623676885853,
      ingredients = {
        {type="fluid", name="bio-oil", amount=1090},
        {type="fluid", name="oxygen", amount=22737},
        {type="item", name="cottongut-pup", amount=2},
        {type="item", name="primers", amount=1},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="cottongut-mk02", amount=0.00942156105910033},
      },
    },
    ["cottongut-pup-mk02-raising"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.55844155844156,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="cottongut-food-01", amount=7},
        {type="item", name="cottongut-mk02", amount=3},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="flue-gas-barrel", amount=2},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="cottongut-pup-mk02", amount=6},
      },
    },
    ["cottongut-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.3768219928262,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="barrel-milk", amount=3},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut", amount=6},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="urea", amount=4},
        {type="item", name="water-barrel", amount=4},
        {type="item", name="yotoi-fruit", amount=38},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cottongut-pup", amount=22},
        {type="item", name="empty-barrel-milk", amount=3},
      },
    },
    ["cottongut-mature-basic-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cadaveric-arum-seeds", amount=2},
        {type="item", name="cottongut-pup-mk02", amount=3},
        {type="item", name="fishmeal", amount=3},
        {type="item", name="grade-1-chromite", amount=19},
        {type="item", name="raw-fiber", amount=19},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
      },
    },
    ["auog-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="water", amount=340},
        {type="item", name="cellulose", amount=4},
        {type="item", name="cobalt-extract", amount=3},
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="kicalk", amount=1},
        {type="item", name="ralesia", amount=6},
        {type="item", name="sand", amount=12},
        {type="item", name="saps", amount=2},
        {type="item", name="stone", amount=29},
        {type="item", name="warm-stone-brick", amount=2},
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="auog-food-02", amount=6},
      },
    },
    ["auog-maturing-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.13058491446036,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=6},
        {type="item", name="caged-auog", amount=3},
        {type="item", name="fawogae-mk02", amount=2},
        {type="item", name="kicalk", amount=10},
        {type="item", name="stone-furnace", amount=9},
        {type="item", name="tin-ore-rejects", amount=1},
        {type="item", name="wax-barrel", amount=2},
      },
      results = {
        {type="item", name="auog", amount=17},
        {type="item", name="barrel", amount=11},
      },
    },
    ["auog-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.40439080988389,
      ingredients = {
        {type="item", name="casein", amount=3},
        {type="item", name="dried-meat", amount=52},
        {type="item", name="energy-drink", amount=1},
        {type="item", name="moss", amount=9},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="dirty-syngas-barrel", amount=3},
        {type="item", name="pressured-water-barrel", amount=12},
      },
      results = {
        {type="item", name="charged-auog", amount=2},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="charged-auog", amount=12},
        {type="item", name="lignin", amount=24},
        {type="item", name="methane-barrel", amount=4},
        {type="item", name="native-flora", amount=25},
        {type="item", name="water-barrel", amount=3},
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
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="saps", amount=3},
        {type="item", name="ulric-food-01", amount=5},
        {type="item", name="wood-seeds-mk02", amount=33},
      },
      results = {
        {type="item", name="auog-mk02", amount=4},
      },
    },
    ["auog-pooping-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.30887085674253,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=4},
        {type="item", name="diesel-barrel", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sodium-hydroxide", amount=14},
        {type="item", name="vrauks-food-01", amount=1},
        {type="item", name="yotoi-leaves", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="manure", amount=14},
      },
    },
    ["auog-pup-breeding-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=6},
        {type="item", name="cage", amount=2},
        {type="item", name="kicalk", amount=9},
        {type="item", name="manure", amount=3},
        {type="item", name="refined-natural-gas-barrel", amount=5},
        {type="item", name="sodium-hydroxide", amount=21},
      },
      results = {
        {type="item", name="auog-pup", amount=24},
        {type="item", name="barrel", amount=10},
      },
    },
    ["auog-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2.75,
      ingredients = {
        {type="item", name="auog-food-01", amount=10},
        {type="item", name="bedding", amount=3},
        {type="item", name="lab-instrument", amount=2},
      },
      results = {
        {type="item", name="auog", amount=11},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="auog-pup-mk02", amount=4},
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="fish", amount=1},
        {type="item", name="moss", amount=66},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="vrauks-food-02", amount=1},
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
        {type="fluid", name="steam", amount=212},
        {type="fluid", name="water", amount=100},
        {type="item", name="fine-powdered-biomass", amount=2},
        {type="item", name="log", amount=1},
        {type="item", name="raw-fiber", amount=19},
        {type="item", name="sand", amount=8},
        {type="item", name="urea", amount=4},
      },
      results = {
        {type="item", name="ralesia", amount=25},
      },
    },
    ["ralesia-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.08397547218965,
      ingredients = {
        {type="fluid", name="hydrogen", amount=325},
        {type="fluid", name="water", amount=1084},
        {type="item", name="ralesia", amount=2},
        {type="item", name="ralesia-seeds", amount=11},
        {type="item", name="raw-fiber", amount=23},
        {type="item", name="residual-oil-barrel", amount=2},
      },
      results = {
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-mk02", amount=0.00541987736094827},
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
        {type="item", name="fawogae", amount=60},
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
        {type="item", name="moss", amount=6},
        {type="item", name="olefin-barrel", amount=3},
        {type="item", name="ralesia", amount=3},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="vrauks-food-02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=20},
      },
    },
    ["vrauks-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="fish-oil", amount=45},
        {type="fluid", name="water", amount=449},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="formica", amount=3},
        {type="item", name="guts", amount=3},
        {type="item", name="ore-zinc", amount=4},
        {type="item", name="ralesia-seeds", amount=11},
        {type="item", name="saps", amount=6},
        {type="item", name="sic", amount=4},
        {type="item", name="starch", amount=6},
        {type="item", name="stripped-distillate-canister", amount=3},
        {type="item", name="tuuphra", amount=1},
        {type="item", name="urea", amount=4},
      },
      results = {
        {type="item", name="vrauks-food-02", amount=9},
      },
    },
    ["vrauks-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.9557076811718,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=2},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=8},
        {type="item", name="cocoon", amount=421},
        {type="item", name="refined-natural-gas-barrel", amount=5},
        {type="item", name="vrauks-food-02", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="vrauks-mk02", amount=5},
        {type="item", name="vrauks-mk03", amount=0.00753724884728026},
      },
    },
    ["vrauks-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="caged-vrauks", amount=2},
        {type="item", name="carbon-dioxide-barrel", amount=3},
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="fishmeal", amount=2},
        {type="item", name="moss", amount=8},
        {type="item", name="salt", amount=42},
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
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="cocoon-mk02", amount=4},
        {type="item", name="cottongut-food-01", amount=7},
        {type="item", name="nickel-plate", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sea-sponge-mk02", amount=1},
        {type="item", name="splitter", amount=1},
        {type="item", name="ulric-food-01", amount=10},
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
        {type="item", name="energy-drink", amount=2},
        {type="item", name="native-flora", amount=15},
        {type="item", name="olefin-barrel", amount=3},
        {type="item", name="residual-mixture-canister", amount=1},
        {type="item", name="sea-sponge-mk02", amount=1},
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
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="moss-gen", amount=61},
        {type="item", name="plasmids", amount=1},
        {type="item", name="sap-extractor-mk01", amount=8},
        {type="item", name="sodium-hydroxide", amount=16},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=8},
      },
      results = {
        {type="item", name="yotoi-seeds", amount=3},
      },
    },
    ["yotoi-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=192},
        {type="item", name="lime", amount=5},
        {type="item", name="yotoi-fruit", amount=1},
        {type="item", name="yotoi-seeds", amount=2},
      },
      results = {
        {type="item", name="yotoi", amount=8},
      },
    },
    ["yotoi-fruit-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="clean-nexelit", amount=2},
        {type="item", name="gravel", amount=10},
        {type="item", name="sand", amount=2},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=5},
      },
    },
    ["fawogae-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="water", amount=142},
        {type="item", name="condensates-barrel", amount=1},
        {type="item", name="fungal-substrate", amount=1},
      },
      results = {
        {type="item", name="fawogae", amount=21},
      },
    },
    ["fawogae-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.07293284507195,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=500},
        {type="fluid", name="oxygen", amount=161},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fertilizer", amount=11},
        {type="item", name="refsyngas-barrel", amount=2},
        {type="item", name="soil", amount=107},
      },
      results = {
        {type="item", name="fawogae", amount=1},
        {type="item", name="fawogae-mk02", amount=0.00536466422535974},
      },
    },
    ["fawogae-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1652},
        {type="fluid", name="steam", amount=378},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="fawogae-spore", amount=69},
        {type="item", name="fine-powdered-biomass", amount=7},
      },
      results = {
        {type="item", name="fawogae-mk02", amount=4},
      },
    },
    ["fawogae-spore-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fawogae", amount=30},
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
        {type="item", name="fine-powdered-biomass", amount=7},
        {type="item", name="fungal-substrate-02", amount=5},
        {type="item", name="iron-oxide", amount=5},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="tuuphra", amount=2},
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
      energy_required_multiplier = 1.00384715641074,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=468},
        {type="item", name="chromium", amount=4},
        {type="item", name="scrude-barrel", amount=3},
        {type="item", name="tin-ore-rejects", amount=4},
        {type="item", name="yaedols", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=1},
        {type="item", name="yaedols-mk02", amount=0.00501923578205369},
      },
    },
    ["yaedols-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 0.888888888888889,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=176},
        {type="fluid", name="oxygen", amount=729},
        {type="item", name="hot-residual-mixture-barrel", amount=1},
        {type="item", name="kerogen", amount=3},
        {type="item", name="nisi", amount=6},
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
        {type="item", name="brain", amount=22},
      },
      results = {
      },
    },
    ["purex-antimony-void"] = {
      mode = "input-preserved-unmodified",
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

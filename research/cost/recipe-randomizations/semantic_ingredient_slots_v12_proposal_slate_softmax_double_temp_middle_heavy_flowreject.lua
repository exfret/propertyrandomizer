-- Semantic ingredient-slot substitutions v12: diverse proposal slate + softmax at 0.20/0.40/0.80, middle-heavy 25/60/15 classes, original always proposed, 12-attempt post-scale flow rejection.
return {
  metadata = {
    format = "semantic-ingredient-slot-proposal-slate-v12-double-temp-middle-heavy-flowreject",
    seed = 202608211528,
  },
  recipes = {
    ["recipe-unknown"] = {
      mode = "frozen-preserved",
      science_level = 0,
      ingredients = {
      },
      results = {
      },
    },
    ["copper-plate"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="copper-ore", amount=8},
      },
      results = {
        {type="item", name="copper-plate", amount=1},
      },
    },
    ["iron-plate"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-ore", amount=8},
      },
      results = {
        {type="item", name="iron-plate", amount=1},
      },
    },
    ["copper-cable"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="copper-plate", amount=1},
      },
      results = {
        {type="item", name="copper-cable", amount=2},
      },
    },
    ["iron-stick"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="iron-stick", amount=2},
      },
    },
    ["iron-gear-wheel"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=2},
      },
      results = {
        {type="item", name="iron-gear-wheel", amount=1},
      },
    },
    ["bolts"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-stick", amount=2},
      },
      results = {
        {type="item", name="bolts", amount=2},
      },
    },
    ["small-parts-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="bolts", amount=3},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="iron-gear-wheel", amount=1},
      },
      results = {
        {type="item", name="small-parts-01", amount=2},
      },
    },
    ["burner-inserter"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
        {type="item", name="small-parts-01", amount=2},
      },
      results = {
        {type="item", name="burner-inserter", amount=1},
      },
    },
    ["inductor1-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="copper-cable", amount=8},
        {type="item", name="stone", amount=6.75},
      },
      results = {
        {type="item", name="inductor1", amount=1},
      },
    },
    ["soil"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="fluid", name="water", amount=800},
      },
      results = {
        {type="item", name="soil", amount=16},
      },
    },
    ["stone-brick"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="stone", amount=2},
      },
      results = {
        {type="item", name="stone-brick", amount=1},
      },
    },
    ["stone-furnace"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="stone", amount=5},
      },
      results = {
        {type="item", name="stone-furnace", amount=1},
      },
    },
    ["transport-belt"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="transport-belt", amount=2},
      },
    },
    ["underground-belt"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="transport-belt", amount=10},
      },
      results = {
        {type="item", name="underground-belt", amount=2},
      },
    },
    ["lab"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="lab", amount=1},
      },
    },
    ["pipe"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="pipe", amount=1},
      },
    },
    ["pipe-to-ground"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
        {type="item", name="pipe", amount=10},
      },
      results = {
        {type="item", name="pipe-to-ground", amount=2},
      },
    },
    ["small-electric-pole"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="copper-cable", amount=2},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="small-electric-pole", amount=1},
      },
    },
    ["boiler"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
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
      ingredients = {
        {type="item", name="copper-plate", amount=10},
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
      ingredients = {
        {type="item", name="iron-plate", amount=3},
        {type="item", name="stone-brick", amount=25.4508196721},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="burner-mining-drill", amount=1},
      },
    },
    ["offshore-pump"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="copper-plate", amount=5.59459459459},
        {type="item", name="pipe", amount=3},
      },
      results = {
        {type="item", name="offshore-pump", amount=1},
      },
    },
    ["soil-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="inductor1", amount=10},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="pipe", amount=38.3333333333},
      },
      results = {
        {type="item", name="soil-extractor-mk01", amount=1},
      },
    },
    ["wpu-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="copper-cable", amount=50},
        {type="item", name="copper-plate", amount=20},
        {type="item", name="log", amount=5},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="wpu-mk01", amount=1},
      },
    },
    ["flora-collector-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="flora-collector-mk01", amount=1},
      },
    },
    ["automation-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="native-flora", amount=10},
        {type="item", name="pipe", amount=5.11111111111},
        {type="item", name="planter-box", amount=2},
      },
      results = {
        {type="item", name="automation-science-pack", amount=1},
      },
    },
    ["empty-planter-box"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
        {type="item", name="stone-brick", amount=4},
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="empty-planter-box", amount=1},
      },
    },
    ["planter-box"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="ash", amount=3},
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
      ingredients = {
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="wooden-chest", amount=1},
      },
    },
    ["water-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=20000},
      },
      results = {
      },
    },
    ["assembling-machine-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-plate", amount=9},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="assembling-machine-1", amount=1},
      },
    },
    ["bricks-to-stone"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="stone-brick", amount=4},
      },
      results = {
        {type="item", name="stone", amount=8},
      },
    },
    ["grade-2-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=1.84494097092},
      },
      results = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="grade-2-copper", amount=2},
      },
    },
    ["copper-plate-4"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="iron-plate", amount=3.54465976708},
      },
      results = {
        {type="item", name="raw-fiber", amount=2},
      },
    },
    ["glass-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-quartz", amount=6},
      },
      results = {
        {type="fluid", name="molten-glass", amount=10},
      },
    },
    ["molten-glass"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=50},
      },
      results = {
        {type="item", name="glass", amount=5},
      },
    },
    ["grade-1-iron-crush"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="iron-ore", amount=6.66666666667},
      },
      results = {
        {type="item", name="iron-plate", amount=1},
      },
    },
    ["gravel-to-sand"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="gravel", amount=4},
      },
      results = {
        {type="item", name="sand", amount=3},
      },
    },
    ["stone-to-gravel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=2.23255813953},
      },
      results = {
        {type="item", name="gravel", amount=3},
      },
    },
    ["gun-turret"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=10},
        {type="item", name="moss", amount=42.725430623},
        {type="item", name="pipe", amount=25.1153846154},
      },
      results = {
        {type="item", name="gun-turret", amount=1},
      },
    },
    ["muddy-sludge"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="soil", amount=10},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
      },
    },
    ["soil-washing"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=600},
        {type="item", name="soil", amount=30},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="sand", amount=10},
      },
    },
    ["pressured-water"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=500},
      },
      results = {
        {type="fluid", name="pressured-water", amount=500},
      },
    },
    ["repair-pack"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=2},
        {type="item", name="small-parts-01", amount=2},
      },
      results = {
        {type="item", name="repair-pack", amount=1},
      },
    },
    ["seaweed-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=400},
      },
      results = {
        {type="item", name="seaweed", amount=10},
      },
    },
    ["shotgun"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=15},
        {type="item", name="pipe", amount=12.5576923077},
        {type="item", name="stone", amount=88.3333333333},
        {type="item", name="wood", amount=5},
      },
      results = {
        {type="item", name="shotgun", amount=1},
      },
    },
    ["submachine-gun"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=5},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=25.1153846154},
      },
      results = {
        {type="item", name="submachine-gun", amount=1},
      },
    },
    ["small-lamp"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=3},
        {type="item", name="copper-plate", amount=1},
        {type="item", name="glass", amount=2},
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="small-lamp", amount=1},
      },
    },
    ["tailings-pond"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="soil", amount=101.960784314},
        {type="item", name="stone-brick", amount=100},
      },
      results = {
        {type="item", name="tailings-pond", amount=1},
      },
    },
    ["tin-plate-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-tin", amount=40},
      },
      results = {
        {type="item", name="tin-plate", amount=4},
      },
    },
    ["acetylene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=750},
        {type="item", name="calcium-carbide", amount=10},
      },
      results = {
        {type="fluid", name="acetylene", amount=100},
        {type="fluid", name="slacked-lime", amount=25},
      },
    },
    ["coal-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="coal", amount=10},
      },
      results = {
        {type="fluid", name="coal-gas", amount=40},
        {type="fluid", name="tar", amount=50},
        {type="item", name="coke", amount=6},
        {type="item", name="iron-oxide", amount=0.3},
      },
    },
    ["coal-gas-from-wood"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="fluid", name="coal-gas", amount=10},
        {type="fluid", name="tar", amount=30},
        {type="item", name="coal", amount=10},
        {type="item", name="iron-oxide", amount=0.3},
      },
    },
    ["syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=50},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="syngas", amount=70},
        {type="fluid", name="tar", amount=30},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-gas-from-coke"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=20},
      },
      results = {
        {type="fluid", name="coal-gas", amount=20},
        {type="fluid", name="tar", amount=20},
        {type="item", name="ash", amount=1},
      },
    },
    ["distilled-raw-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="raw-coal", amount=10},
      },
      results = {
        {type="fluid", name="coal-gas", amount=60},
        {type="fluid", name="tar", amount=30},
        {type="item", name="coal", amount=3},
        {type="item", name="iron-oxide", amount=0.2},
      },
    },
    ["aluminium-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=8.53704326962},
      },
      results = {
        {type="item", name="aluminium-plate", amount=1},
      },
    },
    ["graphite"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=5},
      },
      results = {
        {type="item", name="graphite", amount=2},
      },
    },
    ["clay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=1100},
      },
      results = {
        {type="item", name="clay", amount=3},
      },
    },
    ["ceramic"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="clay", amount=10},
        {type="item", name="coke", amount=1},
      },
      results = {
        {type="item", name="ceramic", amount=5},
      },
    },
    ["duralumin-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="copper-plate", amount=2},
      },
      results = {
        {type="item", name="duralumin", amount=1},
      },
    },
    ["tinned-cable"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=6.2},
        {type="item", name="wood", amount=2.91842610179},
      },
      results = {
        {type="item", name="tinned-cable", amount=1},
      },
    },
    ["engine-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="small-electric-pole", amount=0.815444022833},
        {type="item", name="stone-brick", amount=267.62295082},
        {type="item", name="tin-plate", amount=4.45856617375},
      },
      results = {
        {type="item", name="engine-unit", amount=1},
      },
    },
    ["iron-oxide-smelting"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="log", amount=47.0548006823},
      },
      results = {
        {type="item", name="iron-plate", amount=10},
      },
    },
    ["lead-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="small-electric-pole", amount=1.13602805494},
      },
      results = {
        {type="item", name="lead-plate", amount=1},
      },
    },
    ["moondrop-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=179},
        {type="item", name="glass", amount=2},
        {type="item", name="steam-engine", amount=3.58075182685},
      },
      results = {
        {type="item", name="moondrop-codex", amount=1},
      },
    },
    ["solder-0"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="lead-plate", amount=4},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="solder", amount=1},
      },
    },
    ["tar-quenching"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tar", amount=500},
        {type="fluid", name="water", amount=500},
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
      ingredients = {
        {type="fluid", name="pressured-air", amount=750},
      },
      results = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="oxygen", amount=100},
      },
    },
    ["muddy-sludge-void-electrolyzer"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=100},
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
      ingredients = {
        {type="item", name="poorman-wood-fence", amount=3.78583364639},
      },
      results = {
        {type="item", name="coal-dust", amount=0.5},
        {type="item", name="iron-oxide", amount=0.05},
        {type="item", name="soot", amount=0.2},
      },
    },
    ["soot-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="soot", amount=2},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="copper-ore", amount=0.2},
        {type="item", name="iron-ore", amount=0.2},
        {type="item", name="ore-aluminium", amount=0.1},
        {type="item", name="ore-lead", amount=0.1},
        {type="item", name="ore-zinc", amount=0.1},
      },
    },
    ["tailings-classification"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="tailings-dust", amount=15},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="ore-tin", amount=1},
        {type="item", name="ore-titanium", amount=1},
      },
    },
    ["extract-sulfur"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=419.65885744},
      },
      results = {
        {type="item", name="sulfur", amount=2},
      },
    },
    ["titanium-plate-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-titanium", amount=40},
      },
      results = {
        {type="item", name="titanium-plate", amount=4},
      },
    },
    ["water-from-oxygen-and-hydrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="oxygen", amount=100},
      },
      results = {
        {type="fluid", name="water", amount=300},
      },
    },
    ["zinc-plate-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-zinc", amount=40},
      },
      results = {
        {type="item", name="zinc-plate", amount=4},
      },
    },
    ["py-tank-1000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="lead-plate", amount=10},
        {type="item", name="small-parts-01", amount=3.98162327718},
        {type="item", name="steel-plate", amount=14.4083667496},
      },
      results = {
        {type="item", name="py-tank-1000", amount=1},
      },
    },
    ["py-tank-3000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=77.0647044908},
        {type="item", name="titanium-plate", amount=11.0024190378},
      },
      results = {
        {type="item", name="py-tank-3000", amount=1},
      },
    },
    ["py-tank-4000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-chest", amount=1.10403397028},
        {type="item", name="iron-stick", amount=40},
        {type="item", name="lead-plate", amount=30},
      },
      results = {
        {type="item", name="py-tank-4000", amount=1},
      },
    },
    ["py-tank-8000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=43.3333333333},
        {type="item", name="lead-plate", amount=40},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="small-parts-01", amount=4.77794793262},
      },
      results = {
        {type="item", name="py-tank-8000", amount=1},
      },
    },
    ["py-tank-10000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="lead-plate", amount=45},
        {type="item", name="py-tank-8000", amount=0.873419523},
        {type="item", name="titanium-plate", amount=89.1124138573},
      },
      results = {
        {type="item", name="py-tank-10000", amount=1},
      },
    },
    ["py-tank-1500"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="lead-plate", amount=10},
        {type="item", name="small-parts-01", amount=3.98162327718},
        {type="item", name="titanium-plate", amount=89.1124138573},
      },
      results = {
        {type="item", name="py-tank-1500", amount=1},
      },
    },
    ["py-tank-6500"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=27.3109243697},
        {type="item", name="lead-plate", amount=30},
        {type="item", name="pipe", amount=8},
        {type="item", name="py-tank-4000", amount=1},
      },
      results = {
        {type="item", name="py-tank-6500", amount=1},
      },
    },
    ["py-tank-7000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="lead-plate", amount=10},
        {type="item", name="pipe", amount=10},
        {type="item", name="steel-plate", amount=57.6334669985},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="py-tank-7000", amount=1},
      },
    },
    ["py-tank-5000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=65.2643071678},
        {type="item", name="iron-plate", amount=8.96551724138},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="small-parts-01", amount=7.96324655436},
      },
      results = {
        {type="item", name="py-tank-5000", amount=1},
      },
    },
    ["py-tank-9000"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=15},
        {type="item", name="py-tank-3000", amount=1},
        {type="item", name="py-tank-5000", amount=1},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="py-tank-9000", amount=1},
      },
    },
    ["chloride-void-iron-oxide"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=60},
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["extract-limestone-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=400},
      },
      results = {
        {type="item", name="limestone", amount=8},
      },
    },
    ["gun-powder"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="coke", amount=3},
        {type="item", name="sulfur", amount=1},
      },
      results = {
        {type="item", name="gunpowder", amount=5},
      },
    },
    ["tar-distilation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=470.819929757},
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
      ingredients = {
        {type="fluid", name="syngas", amount=337.171977771},
        {type="item", name="wood", amount=1},
      },
      results = {
        {type="item", name="treated-wood", amount=2},
      },
    },
    ["calcium-carbide"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=7},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="item", name="calcium-carbide", amount=10},
      },
    },
    ["sand-brick"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="fluid", name="tar", amount=100},
        {type="item", name="iron-ore", amount=1},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=10},
        {type="fluid", name="coal-gas", amount=35},
        {type="item", name="ash", amount=1},
        {type="item", name="rich-clay", amount=0.3},
      },
    },
    ["Moss-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="moss", amount=16},
      },
    },
    ["Moss-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="fluid", name="pressured-water", amount=505.430892651},
      },
      results = {
        {type="item", name="moss", amount=8},
      },
    },
    ["aromatics-to-plastic"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="syngas", amount=100},
      },
      results = {
        {type="item", name="plastic-bar", amount=1},
      },
    },
    ["log1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=3},
      },
    },
    ["wood-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="wood", amount=5},
      },
      results = {
        {type="item", name="wood-seeds", amount=4},
      },
    },
    ["wood-seedling"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="native-flora", amount=22.6250889124},
        {type="item", name="seaweed", amount=2.35704629455},
      },
      results = {
        {type="item", name="wood-seedling", amount=3},
      },
    },
    ["log2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="cellulose", amount=1.03882965904},
      },
      results = {
        {type="item", name="log", amount=4},
      },
    },
    ["log3"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=500},
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
      ingredients = {
        {type="item", name="ash", amount=3.1270543937},
        {type="item", name="iron-ore", amount=20},
        {type="item", name="limestone", amount=5},
      },
      results = {
        {type="item", name="steel-plate", amount=1},
      },
    },
    ["bio-container"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=1},
        {type="item", name="iron-plate", amount=5.01816231442},
        {type="item", name="lead-plate", amount=1},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="item", name="bio-container", amount=1},
      },
    },
    ["cage"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=15},
        {type="item", name="solder", amount=2},
        {type="item", name="titanium-plate", amount=5},
      },
      results = {
        {type="item", name="cage", amount=1},
      },
    },
    ["empty-jerry-can"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=5.01816231442},
        {type="item", name="offshore-pump", amount=0.742065142892},
      },
      results = {
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["shotgun-shell"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=10.0065725279},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="lead-plate", amount=1},
      },
      results = {
        {type="item", name="shotgun-shell", amount=3},
      },
    },
    ["firearm-magazine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="gunpowder", amount=10},
        {type="item", name="ore-nickel", amount=40.7601475504},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="firearm-magazine", amount=5},
      },
    },
    ["fwf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=1.25410795144},
        {type="item", name="inductor1", amount=10},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="stone-brick", amount=50},
      },
      results = {
        {type="item", name="fwf-mk01", amount=1},
      },
    },
    ["moss-farm-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=0.501643180574},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="pipe", amount=25.1153846154},
        {type="item", name="soil", amount=50},
        {type="item", name="steel-plate", amount=5.45749141806},
        {type="item", name="stone-brick", amount=50},
        {type="item", name="titanium-plate", amount=9.54533174722},
      },
      results = {
        {type="item", name="moss-farm-mk01", amount=1},
      },
    },
    ["sap-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=34.9299719888},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="small-parts-01", amount=5.97243491577},
        {type="item", name="soil", amount=100},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-brick", amount=30},
      },
      results = {
        {type="item", name="sap-extractor-mk01", amount=1},
      },
    },
    ["seaweed-crop-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=25},
        {type="item", name="pipe", amount=15},
        {type="item", name="small-parts-01", amount=9.72999393808},
        {type="item", name="soot", amount=33.302084308},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-brick", amount=30},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=40},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="pipe", amount=15},
        {type="item", name="small-parts-01", amount=40},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
      },
    },
    ["iron-chest"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=8},
      },
      results = {
        {type="item", name="iron-chest", amount=1},
      },
    },
    ["storage-tank"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="duralumin", amount=20},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="storage-tank", amount=1},
      },
    },
    ["light-armor"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=4},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="light-armor", amount=1},
      },
    },
    ["car"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=8},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="light-armor", amount=1},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="car", amount=1},
      },
    },
    ["pump"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=3.23434551406},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="pump", amount=1},
      },
    },
    ["small-electric-pole-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=10.2765825209},
        {type="item", name="iron-stick", amount=2.76923076923},
      },
      results = {
        {type="item", name="small-electric-pole", amount=3},
      },
    },
    ["py-gas-vent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=5.97243491577},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="py-gas-vent", amount=1},
      },
    },
    ["py-sinkhole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=40.6666666667},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="lime", amount=35.431802406},
        {type="item", name="offshore-pump", amount=5},
        {type="item", name="steel-plate", amount=15},
      },
      results = {
        {type="item", name="py-sinkhole", amount=1},
      },
    },
    ["retorter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=10},
        {type="item", name="soil", amount=203.921568627},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="retorter", amount=1},
      },
    },
    ["steel-chest"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="steel-plate", amount=8},
      },
      results = {
        {type="item", name="steel-chest", amount=1},
      },
    },
    ["tree"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="small-lamp", amount=0.946422081905},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="tree-mk01", amount=1},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=30},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="stone-furnace", amount=10},
      },
      results = {
        {type="item", name="advanced-foundry-mk01", amount=1},
      },
    },
    ["borax-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=68.5924369748},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="inductor1", amount=20},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="transport-belt", amount=20},
      },
      results = {
        {type="item", name="borax-mine", amount=1},
      },
    },
    ["distilator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=20},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=10},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="transport-belt", amount=14.30449069},
      },
      results = {
        {type="item", name="distilator", amount=1},
      },
    },
    ["fluid-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="inductor1", amount=10},
        {type="item", name="iron-plate", amount=25.0908115721},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=1},
      },
    },
    ["gasifier"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=4},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="gasifier", amount=1},
      },
    },
    ["glassworks-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=20},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-brick", amount=15},
      },
      results = {
        {type="item", name="glassworks-mk01", amount=1},
      },
    },
    ["hpf"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=20},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="hpf", amount=1},
      },
    },
    ["jaw-crusher"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=1.00328636115},
        {type="item", name="iron-stick", amount=44.6153846154},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="jaw-crusher", amount=1},
      },
    },
    ["solid-separator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=0.752464770862},
        {type="item", name="inductor1", amount=30},
        {type="item", name="repair-pack", amount=22.3500091623},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="transport-belt", amount=10.1642935378},
      },
      results = {
        {type="item", name="solid-separator", amount=1},
      },
    },
    ["tar-processing-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=5.8548978989},
        {type="item", name="inductor1", amount=7},
        {type="item", name="small-parts-01", amount=7.96324655436},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="stone-furnace", amount=3},
      },
      results = {
        {type="item", name="tar-processing-unit", amount=1},
      },
    },
    ["washer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="boiler", amount=7.89323843416},
        {type="item", name="burner-inserter", amount=2.60625501203},
        {type="item", name="copper-cable", amount=24.4},
        {type="item", name="copper-plate", amount=10.9433962264},
        {type="item", name="inductor1", amount=2},
        {type="item", name="small-parts-01", amount=10},
      },
      results = {
        {type="item", name="washer", amount=1},
      },
    },
    ["evaporator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="pipe", amount=37.6730769231},
        {type="item", name="soil-extractor-mk01", amount=4.07741328166},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="tin-plate", amount=40},
      },
      results = {
        {type="item", name="evaporator", amount=1},
      },
    },
    ["quenching-tower"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=150.045955882},
        {type="item", name="iron-plate", amount=11.2068965517},
        {type="item", name="pump", amount=2},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-brick", amount=195.084658737},
      },
      results = {
        {type="item", name="quenching-tower", amount=1},
      },
    },
    ["clay-pit-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="seaweed", amount=184.126984127},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="transport-belt", amount=5.69550930997},
      },
      results = {
        {type="item", name="clay-pit-mk01", amount=1},
      },
    },
    ["electronics-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="pipe", amount=15},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="soil-extractor-mk01", amount=3.58671473569},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="steel-plate", amount=7.97104547318},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=1},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=24.4},
        {type="item", name="distilator", amount=1},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="wood", amount=30},
      },
      results = {
        {type="item", name="pulp-mill-mk01", amount=1},
      },
    },
    ["chipshooter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=456.14658633},
        {type="item", name="ceramic", amount=183.182441945},
        {type="item", name="distilator", amount=2},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="offshore-pump", amount=2.35950804163},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="chipshooter-mk01", amount=1},
      },
    },
    ["pcb-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=60},
        {type="item", name="electronics-factory-mk01", amount=2},
        {type="item", name="iron-plate", amount=80},
        {type="item", name="jaw-crusher", amount=0.857317611879},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="pcb-factory-mk01", amount=1},
      },
    },
    ["anthracene-oil-creosote"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=50},
      },
      results = {
        {type="fluid", name="creosote", amount=20},
      },
    },
    ["gravel-saline-water"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="gravel", amount=15},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
      },
    },
    ["sulfur-void-tar"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="duralumin", amount=50},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=50},
        {type="item", name="lead-plate", amount=13.6333654885},
        {type="item", name="pipe", amount=50.2307692308},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="steel-plate", amount=15},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=10},
        {type="item", name="inductor1", amount=5},
        {type="item", name="planter-box", amount=10},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=6.97466478903},
        {type="item", name="tar-processing-unit", amount=0.799447710598},
        {type="item", name="washer", amount=1.05855635613},
      },
      results = {
        {type="item", name="botanical-nursery", amount=1},
      },
    },
    ["creature-chamber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=41.9053009987},
        {type="item", name="ceramic", amount=282.338015128},
        {type="item", name="genlab-mk01", amount=1},
        {type="item", name="inductor1", amount=780.98030663},
        {type="item", name="lead-plate", amount=15},
        {type="item", name="pipe", amount=60.3356043105},
        {type="item", name="small-parts-01", amount=16.6615620214},
        {type="item", name="steel-plate", amount=40},
      },
      results = {
        {type="item", name="creature-chamber-mk01", amount=1},
      },
    },
    ["incubator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="boiler", amount=15.7864768683},
        {type="item", name="concrete", amount=28.57103438},
        {type="item", name="lead-plate", amount=27.2667309771},
        {type="item", name="pipe", amount=75.3461538462},
        {type="item", name="steel-plate", amount=43.2251002489},
        {type="item", name="washer", amount=2.12790374021},
      },
      results = {
        {type="item", name="incubator-mk01", amount=1},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=9.37824874975},
        {type="item", name="cellulose", amount=14.6421179947},
        {type="item", name="lead-plate", amount=15.7647020865},
        {type="item", name="soil-extractor-mk01", amount=1.79335736785},
        {type="item", name="stone-brick", amount=50},
        {type="item", name="treated-wood", amount=3.50311009781},
      },
      results = {
        {type="item", name="micro-mine-mk01", amount=1},
      },
    },
    ["rc-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=100},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="glass", amount=50},
        {type="item", name="iron-plate", amount=200},
        {type="item", name="iron-stick", amount=300.307692308},
        {type="item", name="pipe", amount=502.307692308},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="titanium-plate", amount=100},
      },
      results = {
        {type="item", name="rc-mk01", amount=1},
      },
    },
    ["genlab-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=50},
        {type="item", name="incubator-mk01", amount=2.73044375705},
        {type="item", name="kerogen", amount=727.63353559},
        {type="item", name="lead-plate", amount=36.3556413028},
        {type="item", name="pipe", amount=258.067959141},
        {type="item", name="plastic-bar", amount=20},
        {type="item", name="py-tank-3000", amount=2},
      },
      results = {
        {type="item", name="genlab-mk01", amount=1},
      },
    },
    ["research-center-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=100},
        {type="item", name="distilator", amount=1},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="titanium-plate", amount=11.5597822908},
      },
      results = {
        {type="item", name="research-center-mk01", amount=1},
      },
    },
    ["slaughterhouse-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=2.50821590287},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=50},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=70},
        {type="item", name="stone-brick", amount=100},
        {type="item", name="titanium-plate", amount=40},
      },
      results = {
        {type="item", name="slaughterhouse-mk01", amount=1},
      },
    },
    ["gate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="iron-plate", amount=10.0363246288},
        {type="item", name="stone-wall", amount=1},
      },
      results = {
        {type="item", name="gate", amount=1},
      },
    },
    ["poorman-wood-fence"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="wood", amount=3},
      },
      results = {
        {type="item", name="poorman-wood-fence", amount=1},
      },
    },
    ["stone-wall"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=3.75384615385},
      },
      results = {
        {type="item", name="stone-wall", amount=1},
      },
    },
    ["automated-screener-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=329.494431211},
        {type="item", name="inductor1", amount=520.653537753},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="soil-extractor-mk01", amount=1.79335736785},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=1},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=54.4166666667},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="iron-stick", amount=20},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
    },
    ["bio-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bio-container", amount=1},
        {type="item", name="seaweed", amount=7.14285714286},
      },
      results = {
        {type="item", name="bio-sample", amount=1},
      },
    },
    ["moss-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="petri-dish-bacteria", amount=1.8240917782},
        {type="item", name="sodium-hydroxide", amount=4.4876209413},
      },
      results = {
        {type="item", name="moss-gen", amount=1},
      },
    },
    ["earth-generic-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=15},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="iron-chest", amount=1},
      },
      results = {
        {type="item", name="earth-generic-sample", amount=1},
      },
    },
    ["vrauks-cocoon-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=5},
        {type="item", name="saps", amount=3},
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
      ingredients = {
        {type="item", name="glass", amount=5},
        {type="item", name="inductor1", amount=130.163384438},
        {type="item", name="tinned-cable", amount=10},
      },
      results = {
        {type="item", name="vrauks-codex", amount=1},
      },
    },
    ["vrauks"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="moss-gen", amount=3},
        {type="item", name="native-flora", amount=10},
        {type="item", name="petri-dish", amount=10},
        {type="item", name="vrauks-codex", amount=1},
      },
      results = {
        {type="item", name="vrauks", amount=1},
      },
    },
    ["vrauks-paddock-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=40},
        {type="item", name="copper-plate", amount=20},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="ore-quartz", amount=181.333333333},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="vrauks-paddock-mk01", amount=1},
      },
    },
    ["caged-vrauks"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="cage", amount=1},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="caged-vrauks", amount=1},
      },
    },
    ["full-render-vrauks"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
      },
      results = {
        {type="fluid", name="formic-acid", amount=200},
        {type="item", name="brain", amount=1},
        {type="item", name="cage", amount=1},
        {type="item", name="chitin", amount=1},
        {type="item", name="guts", amount=2},
        {type="item", name="meat", amount=2},
      },
    },
    ["uncaged-vrauks"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="vrauks", amount=1},
      },
    },
    ["vrauks-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="cocoon", amount=10},
        {type="item", name="flue-gas-barrel", amount=2.77986377132},
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=3.27109719215},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=2},
      },
    },
    ["fluidavan"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="aluminium-plate", amount=127.142722861},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="pump", amount=2},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="vrauks", amount=1.31111352354},
      },
      results = {
        {type="item", name="fluidavan", amount=1},
      },
    },
    ["caravan"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=382.511904485},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="moss-gen", amount=15},
        {type="item", name="vrauks", amount=1.31111352354},
      },
      results = {
        {type="item", name="caravan", amount=1},
      },
    },
    ["concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="gravel", amount=10},
        {type="item", name="lime", amount=5},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="item", name="concrete", amount=5},
      },
    },
    ["stone-brick-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=50},
        {type="item", name="coke", amount=1.84494097092},
      },
      results = {
        {type="item", name="stone-brick", amount=4},
      },
    },
    ["hazard-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=10},
      },
      results = {
        {type="item", name="hazard-concrete", amount=10},
      },
    },
    ["refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="iron-stick", amount=8},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="stone-brick", amount=19.5084658737},
      },
      results = {
        {type="item", name="refined-concrete", amount=10},
      },
    },
    ["landfill"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="gravel", amount=30},
        {type="item", name="soil", amount=30},
        {type="item", name="stone", amount=30},
      },
      results = {
        {type="item", name="landfill", amount=1},
      },
    },
    ["refined-hazard-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="cellulose", amount=4.90725444836},
      },
      results = {
        {type="item", name="refined-hazard-concrete", amount=10},
      },
    },
    ["outpost"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=8.0870677812},
        {type="item", name="glass", amount=5},
        {type="item", name="iron-plate", amount=32.8280391255},
        {type="item", name="soil-extractor-mk01", amount=1.14186715674},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="outpost", amount=1},
      },
    },
    ["outpost-fluid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=20},
        {type="item", name="copper-plate", amount=27.4578692676},
        {type="item", name="glass", amount=5},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="small-parts-01", amount=50},
      },
      results = {
        {type="item", name="outpost-fluid", amount=1},
      },
    },
    ["data-array"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=12.1104039094},
        {type="item", name="distilator", amount=4.74231969613},
        {type="item", name="inductor1", amount=780.98030663},
        {type="item", name="iron-plate", amount=250.908115721},
        {type="item", name="pipe", amount=125.576923077},
        {type="item", name="titanium-plate", amount=100},
      },
      results = {
        {type="item", name="data-array", amount=1},
      },
    },
    ["creamy-latex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="coal", amount=3.89813223728},
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="fluid", name="creamy-latex", amount=100},
      },
    },
    ["sodium-alginate"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="limestone", amount=4},
        {type="item", name="seaweed", amount=5},
        {type="item", name="stone", amount=5},
      },
      results = {
        {type="item", name="sodium-alginate", amount=1},
      },
    },
    ["latex-slab"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=100},
        {type="fluid", name="formic-acid", amount=100},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="latex-slab", amount=1},
      },
    },
    ["sap-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="native-flora", amount=34.5833333333},
      },
      results = {
        {type="item", name="sap-seeds", amount=2},
      },
    },
    ["latex"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=150},
        {type="item", name="latex-slab", amount=1},
      },
      results = {
        {type="item", name="latex", amount=1},
      },
    },
    ["sap-tree"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="planter-box", amount=1},
        {type="item", name="sap-seeds", amount=5},
      },
      results = {
        {type="item", name="sap-tree", amount=1},
      },
    },
    ["py-check-valve"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="lime", amount=1.7715901203},
        {type="item", name="small-parts-01", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="py-check-valve", amount=1},
      },
    },
    ["py-underflow-valve"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="pipe", amount=1},
        {type="item", name="small-parts-01", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="py-underflow-valve", amount=1},
      },
    },
    ["py-overflow-valve"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="pipe", amount=1},
        {type="item", name="small-parts-01", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="py-overflow-valve", amount=1},
      },
    },
    ["py-local-radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=1},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="ore-zinc", amount=21.7111658502},
        {type="item", name="pipe", amount=12.5576923077},
      },
      results = {
        {type="item", name="py-local-radar", amount=1},
      },
    },
    ["radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=10.9433962264},
        {type="item", name="pcb1", amount=5.35224699232},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="radar", amount=1},
      },
    },
    ["battery-mk00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=250},
        {type="item", name="cellulose", amount=5},
        {type="item", name="iron-plate", amount=9.13793103448},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="battery-mk00", amount=1},
      },
    },
    ["electrolyzer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=30},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="lab", amount=2},
        {type="item", name="pipe", amount=25.1153846154},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="electrolyzer-mk01", amount=1},
      },
    },
    ["smelter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="ceramic", amount=50},
        {type="item", name="copper-plate", amount=43.7735849057},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=8.97058823529},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="tin-plate", amount=40.5086848635},
        {type="item", name="treated-wood", amount=15.1521456446},
      },
      results = {
        {type="item", name="smelter-mk01", amount=1},
      },
    },
    ["inserter"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="duralumin", amount=1},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="small-parts-01", amount=3},
      },
      results = {
        {type="item", name="inserter", amount=1},
      },
    },
    ["methane-co2"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="fluid", name="steam", amount=210.192366573},
        {type="item", name="iron-plate", amount=4.56896551724},
      },
      results = {
        {type="fluid", name="methanal", amount=50},
      },
    },
    ["capacitor1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="ceramic", amount=1},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="capacitor1", amount=3},
      },
    },
    ["inductor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="ceramic", amount=2},
        {type="item", name="coke", amount=36.8988194184},
      },
      results = {
        {type="item", name="inductor1", amount=5},
      },
    },
    ["resistor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=1},
        {type="item", name="sand", amount=1.92560717928},
        {type="item", name="tin-plate", amount=1},
      },
      results = {
        {type="item", name="resistor1", amount=3},
      },
    },
    ["formica"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=50},
        {type="item", name="native-flora", amount=69.1666666667},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="treated-wood", amount=2},
      },
      results = {
        {type="item", name="formica", amount=1},
      },
    },
    ["vacuum-tube"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="glass", amount=2},
        {type="item", name="graphite", amount=2},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="vacuum-tube", amount=2},
      },
    },
    ["pcb1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="copper-plate", amount=5},
        {type="item", name="vacuum-tube", amount=11.6726644341},
      },
      results = {
        {type="item", name="pcb1", amount=1},
      },
    },
    ["electronic-circuit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="capacitor1", amount=5},
        {type="item", name="formica", amount=0.514021458758},
        {type="item", name="inductor1", amount=3},
        {type="item", name="pcb1", amount=1},
        {type="item", name="resistor1", amount=6},
        {type="item", name="solder", amount=2},
      },
      results = {
        {type="item", name="electronic-circuit", amount=3},
      },
    },
    ["olefin-plant"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electrolyzer-mk01", amount=2},
        {type="item", name="inductor1", amount=130.163384438},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="stone-brick", amount=100.358606557},
        {type="item", name="storage-tank", amount=4},
      },
      results = {
        {type="item", name="olefin-plant", amount=1},
      },
    },
    ["reformer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=356.688587711},
        {type="item", name="distilator", amount=1},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="pipe", amount=25.1153846154},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="steel-plate", amount=40},
      },
      results = {
        {type="item", name="reformer-mk01", amount=1},
      },
    },
    ["splitter"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="splitter", amount=1},
      },
    },
    ["moondrop-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="moondrop-seeds", amount=4},
      },
      results = {
        {type="item", name="moondrop", amount=4},
      },
    },
    ["moondrop-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=357.142857143},
        {type="item", name="empty-petri-dish", amount=3.50735294118},
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
      ingredients = {
        {type="item", name="moondrop", amount=5},
      },
      results = {
        {type="item", name="moondrop", amount=2.2},
        {type="item", name="moondrop-seeds", amount=7.5},
      },
    },
    ["multiblade-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="fish", amount=5},
        {type="item", name="inductor1", amount=18},
        {type="item", name="iron-plate", amount=50.1816231442},
        {type="item", name="pipe", amount=7.50769230769},
        {type="item", name="small-electric-pole", amount=6},
        {type="item", name="small-parts-01", amount=4},
      },
      results = {
        {type="item", name="multiblade-turbine-mk01", amount=1},
      },
    },
    ["py-science-pack-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18.3648395771},
        {type="item", name="petri-dish", amount=7.99898988494},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=3},
      },
    },
    ["agar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=1100},
        {type="item", name="copper-ore", amount=10.5},
      },
      results = {
        {type="item", name="agar", amount=1},
      },
    },
    ["cellulose-00"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="agar", amount=0.761445431447},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="item", name="cellulose", amount=1},
      },
    },
    ["cellulose-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=6.67279411765},
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="item", name="cellulose", amount=2},
      },
    },
    ["coke-co2"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=2},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=80},
      },
    },
    ["lime"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=7.50493054488},
        {type="item", name="soil", amount=16.862745098},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="item", name="lime", amount=10},
      },
    },
    ["dried-meat-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="meat", amount=10},
      },
      results = {
        {type="item", name="dried-meat", amount=5},
      },
    },
    ["petri-dish-bacteria"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="cellulose", amount=3},
        {type="item", name="native-flora", amount=22.6250889124},
        {type="item", name="petri-dish-bacteria", amount=2},
      },
      results = {
        {type="item", name="fawogae-substrate", amount=10},
      },
    },
    ["empty-petri-dish"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=50},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=1},
      },
    },
    ["sand-void-glass"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-chromium", amount=2.36167197476},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="fluid", name="molten-glass", amount=10},
      },
    },
    ["stopper"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="fluid", name="syngas", amount=499.724681896},
        {type="item", name="petri-dish-bacteria", amount=3.84642214802},
      },
      results = {
        {type="item", name="flask", amount=2},
      },
    },
    ["petri-dish"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="agar", amount=1},
        {type="item", name="empty-petri-dish", amount=1},
      },
      results = {
        {type="item", name="petri-dish", amount=1},
      },
    },
    ["scrude-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="fluid", name="syngas", amount=318.286182008},
      },
      results = {
        {type="fluid", name="condensates", amount=250},
        {type="fluid", name="heavy-oil", amount=100},
        {type="fluid", name="light-oil", amount=150},
      },
    },
    ["tar-refining"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="fluid", name="tar", amount=100},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=75},
        {type="fluid", name="creosote", amount=24},
        {type="fluid", name="middle-oil", amount=30},
        {type="fluid", name="pitch", amount=140},
      },
    },
    ["heavy-oil-to-kerosene"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
      },
      results = {
        {type="fluid", name="kerosene", amount=40},
      },
    },
    ["pitch-refining"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=100},
        {type="fluid", name="steam", amount=100},
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
      ingredients = {
        {type="fluid", name="pitch", amount=466.666666667},
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
      ingredients = {
        {type="fluid", name="hydrogen", amount=581.050672355},
      },
      results = {
        {type="fluid", name="gasoline", amount=20},
        {type="item", name="coke", amount=5},
      },
    },
    ["carbolic-oil-creosote"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=288.108306549},
      },
      results = {
        {type="fluid", name="creosote", amount=50},
      },
    },
    ["kerogen-extraction"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="kerogen", amount=25},
      },
      results = {
        {type="fluid", name="scrude", amount=250},
      },
    },
    ["light-oil-aromatics"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=250.17157891},
      },
      results = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="gasoline", amount=25},
      },
    },
    ["naphthalene-oil-creosote"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=50},
      },
      results = {
        {type="fluid", name="creosote", amount=30},
      },
    },
    ["acetylene-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="acetylene", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="acetylene-barrel", amount=1},
      },
    },
    ["acetylene-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="acetylene", amount=20000},
      },
      results = {
      },
    },
    ["acidgas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="acidgas-barrel", amount=1},
      },
    },
    ["acidgas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=20000},
      },
      results = {
      },
    },
    ["anthracene-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="anthracene-oil-barrel", amount=1},
      },
    },
    ["anthracene-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=20000},
      },
      results = {
      },
    },
    ["aromatics-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="aromatics-barrel", amount=1},
      },
    },
    ["aromatics-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=20000},
      },
      results = {
      },
    },
    ["barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=1},
      },
    },
    ["barrel-machine-mk01"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="barrel-machine-mk01", amount=1},
      },
    },
    ["carbolic-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="carbolic-oil-barrel", amount=1},
      },
    },
    ["carbolic-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=20000},
      },
      results = {
      },
    },
    ["carbon-dioxide-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="carbon-dioxide-barrel", amount=1},
      },
    },
    ["carbon-dioxide-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=20000},
      },
      results = {
      },
    },
    ["chlorine-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="chlorine-barrel", amount=1},
      },
    },
    ["chlorine-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="chlorine", amount=20000},
      },
      results = {
      },
    },
    ["coal-gas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="coal-gas-barrel", amount=1},
      },
    },
    ["coal-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=20000},
      },
      results = {
      },
    },
    ["coal-gas-void"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=50},
      },
      results = {
        {type="item", name="ash", amount=1},
      },
    },
    ["condensates-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="condensates-barrel", amount=1},
      },
    },
    ["condensates-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=20000},
      },
      results = {
      },
    },
    ["creamy-latex-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="creamy-latex-barrel", amount=1},
      },
    },
    ["creamy-latex-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=20000},
      },
      results = {
      },
    },
    ["creosote-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="creosote", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="creosote-barrel", amount=1},
      },
    },
    ["creosote-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="creosote", amount=20000},
      },
      results = {
      },
    },
    ["empty-acetylene-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=1},
      },
      results = {
        {type="fluid", name="acetylene", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-acidgas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="acidgas", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-anthracene-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-aromatics-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="aromatics-barrel", amount=1},
      },
      results = {
        {type="fluid", name="aromatics", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-carbolic-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="carbolic-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-carbon-dioxide-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-chlorine-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="chlorine-barrel", amount=1},
      },
      results = {
        {type="fluid", name="chlorine", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-coal-gas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="coal-gas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-condensates-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="condensates-barrel", amount=1},
      },
      results = {
        {type="fluid", name="condensates", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-creamy-latex-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=1},
      },
      results = {
        {type="fluid", name="creamy-latex", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["empty-creosote-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="creosote-barrel", amount=1},
      },
      results = {
        {type="fluid", name="creosote", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["fill-acetylene-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="acetylene", amount=10},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="acetylene-canister", amount=1},
      },
    },
    ["empty-acetylene-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="acetylene-canister", amount=1},
      },
      results = {
        {type="fluid", name="acetylene", amount=10},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-anthracene-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=40},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="anthracene-oil-canister", amount=1},
      },
    },
    ["empty-anthracene-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=40},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-aromatics-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=29},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="aromatics-canister", amount=1},
      },
    },
    ["empty-aromatics-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="aromatics-canister", amount=1},
      },
      results = {
        {type="fluid", name="aromatics", amount=29},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-carbolic-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbolic-oil", amount=29},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="carbolic-oil-canister", amount=1},
      },
    },
    ["empty-carbolic-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="carbolic-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=29},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-coal-gas-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="coal-gas-canister", amount=1},
      },
    },
    ["empty-coal-gas-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="coal-gas-canister", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-condensates-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="condensates", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="condensates-canister", amount=1},
      },
    },
    ["empty-condensates-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="condensates-canister", amount=1},
      },
      results = {
        {type="fluid", name="condensates", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-gasoline-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=9},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="gasoline-canister", amount=1},
      },
    },
    ["empty-gasoline-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="gasoline-canister", amount=1},
      },
      results = {
        {type="fluid", name="gasoline", amount=9},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-heavy-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=13},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="heavy-oil-canister", amount=1},
      },
    },
    ["empty-heavy-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="heavy-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=13},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-kerosene-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="kerosene", amount=7},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="kerosene-canister", amount=1},
      },
    },
    ["empty-kerosene-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="kerosene-canister", amount=1},
      },
      results = {
        {type="fluid", name="kerosene", amount=7},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-light-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="light-oil", amount=12},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="light-oil-canister", amount=1},
      },
    },
    ["empty-light-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="light-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="light-oil", amount=12},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-methane-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methane", amount=13},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="methane-canister", amount=1},
      },
    },
    ["empty-methane-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="methane-canister", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=13},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-middle-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="middle-oil", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="middle-oil-canister", amount=1},
      },
    },
    ["empty-middle-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="middle-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="middle-oil", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-naphthalene-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=34},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="naphthalene-oil-canister", amount=1},
      },
    },
    ["empty-naphthalene-oil-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="naphthalene-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="naphthalene-oil", amount=34},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-pitch-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=100},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="pitch-canister", amount=1},
      },
    },
    ["empty-pitch-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="pitch-canister", amount=1},
      },
      results = {
        {type="fluid", name="pitch", amount=100},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-scrude-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=20},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="scrude-canister", amount=1},
      },
    },
    ["empty-scrude-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="scrude-canister", amount=1},
      },
      results = {
        {type="fluid", name="scrude", amount=20},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-syngas-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=25},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="syngas-canister", amount=1},
      },
    },
    ["empty-syngas-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="syngas-canister", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=25},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["fill-tar-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tar", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="tar-canister", amount=1},
      },
    },
    ["empty-tar-canister"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="tar-canister", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=50},
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["flue-gas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="flue-gas-barrel", amount=1},
      },
    },
    ["empty-flue-gas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="flue-gas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="flue-gas", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["flue-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=20000},
      },
      results = {
      },
    },
    ["formic-acid-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="formic-acid", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="formic-acid-barrel", amount=1},
      },
    },
    ["empty-formic-acid-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="formic-acid-barrel", amount=1},
      },
      results = {
        {type="fluid", name="formic-acid", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["formic-acid-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="formic-acid", amount=20000},
      },
      results = {
      },
    },
    ["gasoline-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="gasoline-barrel", amount=1},
      },
    },
    ["empty-gasoline-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="gasoline-barrel", amount=1},
      },
      results = {
        {type="fluid", name="gasoline", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["gasoline-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=20000},
      },
      results = {
      },
    },
    ["heavy-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="heavy-oil-barrel", amount=1},
      },
    },
    ["empty-heavy-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="heavy-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["heavy-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=20000},
      },
      results = {
      },
    },
    ["hydrogen-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="hydrogen-barrel", amount=1},
      },
    },
    ["empty-hydrogen-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="hydrogen-barrel", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["hydrogen-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=20000},
      },
      results = {
      },
    },
    ["kerosene-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="kerosene", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="kerosene-barrel", amount=1},
      },
    },
    ["empty-kerosene-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="kerosene-barrel", amount=1},
      },
      results = {
        {type="fluid", name="kerosene", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["kerosene-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="kerosene", amount=20000},
      },
      results = {
      },
    },
    ["light-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="light-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="light-oil-barrel", amount=1},
      },
    },
    ["empty-light-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="light-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="light-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["light-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="light-oil", amount=20000},
      },
      results = {
      },
    },
    ["methanal-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="methanal-barrel", amount=1},
      },
    },
    ["empty-methanal-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="methanal-barrel", amount=1},
      },
      results = {
        {type="fluid", name="methanal", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["methanal-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=20000},
      },
      results = {
      },
    },
    ["methane-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methane", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="methane-barrel", amount=1},
      },
    },
    ["empty-methane-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="methane-barrel", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["methane-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methane", amount=20000},
      },
      results = {
      },
    },
    ["middle-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="middle-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="middle-oil-barrel", amount=1},
      },
    },
    ["empty-middle-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="middle-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="middle-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["middle-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="middle-oil", amount=20000},
      },
      results = {
      },
    },
    ["molten-glass-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="molten-glass-barrel", amount=1},
      },
    },
    ["empty-molten-glass-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="molten-glass-barrel", amount=1},
      },
      results = {
        {type="fluid", name="molten-glass", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["molten-glass-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="molten-glass", amount=20000},
      },
      results = {
      },
    },
    ["muddy-sludge-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="muddy-sludge-barrel", amount=1},
      },
    },
    ["empty-muddy-sludge-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="muddy-sludge-barrel", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["muddy-sludge-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=20000},
      },
      results = {
      },
    },
    ["naphthalene-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="naphthalene-oil-barrel", amount=1},
      },
    },
    ["empty-naphthalene-oil-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="naphthalene-oil-barrel", amount=1},
      },
      results = {
        {type="fluid", name="naphthalene-oil", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["naphthalene-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=20000},
      },
      results = {
      },
    },
    ["oxygen-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="oxygen-barrel", amount=1},
      },
    },
    ["empty-oxygen-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="oxygen-barrel", amount=1},
      },
      results = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["oxygen-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=20000},
      },
      results = {
      },
    },
    ["pitch-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="pitch-barrel", amount=1},
      },
    },
    ["empty-pitch-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="pitch-barrel", amount=1},
      },
      results = {
        {type="fluid", name="pitch", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["pitch-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=20000},
      },
      results = {
      },
    },
    ["pressured-water-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="pressured-water-barrel", amount=1},
      },
    },
    ["empty-pressured-water-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="pressured-water-barrel", amount=1},
      },
      results = {
        {type="fluid", name="pressured-water", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["pressured-water-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=20000},
      },
      results = {
      },
    },
    ["scrude-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="scrude-barrel", amount=1},
      },
    },
    ["empty-scrude-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="scrude-barrel", amount=1},
      },
      results = {
        {type="fluid", name="scrude", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["scrude-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=20000},
      },
      results = {
      },
    },
    ["slacked-lime-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="slacked-lime-barrel", amount=1},
      },
    },
    ["empty-slacked-lime-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="slacked-lime-barrel", amount=1},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["slacked-lime-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=20000},
      },
      results = {
      },
    },
    ["slacked-lime-void"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=60},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="lime", amount=1},
      },
    },
    ["sodium-hydroxide-void"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="sodium-hydroxide", amount=10},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
      },
    },
    ["steel-from-barrels"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="steel-plate", amount=0.65},
      },
    },
    ["syngas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="syngas-barrel", amount=1},
      },
    },
    ["empty-syngas-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="syngas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["syngas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=20000},
      },
      results = {
      },
    },
    ["tailings-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="tailings-barrel", amount=1},
      },
    },
    ["empty-tailings-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="tailings-barrel", amount=1},
      },
      results = {
        {type="fluid", name="tailings", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["tailings-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tailings", amount=20000},
      },
      results = {
      },
    },
    ["tar-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tar", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="tar-barrel", amount=1},
      },
    },
    ["empty-tar-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="tar-barrel", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["tar-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tar", amount=20000},
      },
      results = {
      },
    },
    ["water-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="water-barrel", amount=1},
      },
    },
    ["empty-water-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="water-barrel", amount=1},
      },
      results = {
        {type="fluid", name="water", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["water-saline-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="water-saline-barrel", amount=1},
      },
    },
    ["empty-water-saline-barrel"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="item", name="water-saline-barrel", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="barrel", amount=1},
      },
    },
    ["water-saline-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=20000},
      },
      results = {
      },
    },
    ["advanced-foundry-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["agar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["aluminium-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ash-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ash", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["assembling-machine-1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["automated-screener-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="automated-screener-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["automation-science-pack-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["barrel-machine-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="barrel-machine-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["barrel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="barrel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["battery-mk00-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-container-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-container", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["biofactory-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="biofactory-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["biomass-agar"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-brain"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-caged-vrauks"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-cellulose"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cellulose", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=4},
      },
    },
    ["biomass-chitin"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cocoon"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-creamy-latex"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=200},
      },
      results = {
        {type="item", name="biomass", amount=21},
      },
    },
    ["biomass-dried-meat"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="dried-meat", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-fawogae-substrate"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-guts"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="guts", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-log"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=30},
      },
    },
    ["biomass-meat"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="meat", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-moondrop"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moondrop", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=35},
      },
    },
    ["biomass-moondrop-seeds"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moondrop-seeds", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=12},
      },
    },
    ["biomass-moss"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moss", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=13},
      },
    },
    ["biomass-petri-dish"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="petri-dish", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-petri-dish-bacteria"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="petri-dish-bacteria", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-raw-fiber"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="raw-fiber", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-sap-seeds"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sap-seeds", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-sap-tree"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sap-tree", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-seaweed"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="seaweed", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-tree-mk01"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-vrauks"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-wood"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wood", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=30},
      },
    },
    ["biomass-wood-seedling"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wood-seedling", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-wood-seeds"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wood-seeds", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=30},
      },
    },
    ["boiler-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="boiler", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bolts-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bolts", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["borax-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="borax-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["botanical-nursery-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="botanical-nursery", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["brain-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["burner-inserter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["burner-mining-drill-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cage-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cage", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["caged-vrauks-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["calcium-carbide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["capacitor1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["car-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="car", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["caravan-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="caravan", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ceramic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ceramic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chipshooter-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="chipshooter-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chitin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chitin-void"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="middle-oil", amount=100},
        {type="fluid", name="steam", amount=50},
        {type="item", name="chitin", amount=3},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=100},
        {type="fluid", name="naphthalene-oil", amount=50},
      },
    },
    ["clay-pit-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="clay-pit-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["clay-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="clay", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cocoon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["copper-cable-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["copper-ore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["copper-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["creature-chamber-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="creature-chamber-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["data-array-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="data-array", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["distilator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="distilator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["dried-meat-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="dried-meat", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["duralumin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-generic-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electrolyzer-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="electrolyzer-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electronic-circuit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electronics-factory-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="electronics-factory-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-fuel-canister-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="empty-fuel-canister", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-petri-dish-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-planter-box-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="empty-planter-box", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["engine-unit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="engine-unit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["evaporator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="evaporator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fawogae-substrate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["firearm-magazine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="firearm-magazine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flask-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="flask", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flora-collector-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="flora-collector-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fluid-drill-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fluidavan-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fluidavan", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["formica-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="formica", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fwf-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fwf-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gasifier-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="gasifier", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="gate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["genlab-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="genlab-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["geothermal-water-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=20000},
      },
      results = {
      },
    },
    ["glass-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="glass", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["glassworks-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="glassworks-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-copper-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-copper-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-copper", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["graphite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gravel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="gravel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gun-turret-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="gun-turret", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["guts-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="guts", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hazard-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="hazard-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hpf-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="hpf", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["incubator-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="incubator-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["inductor1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="inductor1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["inserter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="inserter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-gear-wheel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-ore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-ore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-stick-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["jaw-crusher-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="jaw-crusher", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lab-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="lab", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["landfill-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="landfill", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["latex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="latex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["latex-slab-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="latex-slab", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lead-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="lead-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["light-armor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="light-armor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lime-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="lime", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["limestone-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="limestone", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["limestone-void"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="limestone", amount=3},
        {type="item", name="soil", amount=2},
      },
      results = {
        {type="item", name="limestone", amount=2},
        {type="item", name="soil", amount=3},
      },
    },
    ["meat-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="meat", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["micro-mine-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="micro-mine-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moondrop-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-greenhouse-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moondrop", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moss-farm-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moss-farm-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moss-gen-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moss-gen", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moss-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="moss", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["multiblade-turbine-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="multiblade-turbine-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["offshore-pump-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="offshore-pump", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["olefin-plant-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="olefin-plant", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-aluminium-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-aluminium", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-lead-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-lead", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-tin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-tin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-titanium-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-titanium", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-zinc-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-zinc", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["outpost-fluid-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="outpost-fluid", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["outpost-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="outpost", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pcb-factory-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pcb-factory-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pcb1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pcb1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["petri-dish-bacteria-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="petri-dish-bacteria", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["petri-dish-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="petri-dish", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pipe-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pipe-to-ground-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pipe-to-ground", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["planter-box-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["plastic-bar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="plastic-bar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["poorman-wood-fence-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="poorman-wood-fence", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["processed-iron-ore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pulp-mill-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pulp-mill-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pump-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pump", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-check-valve-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-check-valve", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-gas-vent-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-gas-vent", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-local-radar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-local-radar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-overflow-valve-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-overflow-valve", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-science-pack-1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-science-pack-1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-sinkhole-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-sinkhole", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-1000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-1000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-10000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-10000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-1500-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-1500", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-3000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-3000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-4000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-4000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-5000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-5000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-6500-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-6500", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-7000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-7000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-8000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-8000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-tank-9000-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-tank-9000", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-underflow-valve-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-underflow-valve", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["quenching-tower-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="quenching-tower", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["radar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="radar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rc-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rc-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["refined-hazard-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="refined-hazard-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["reformer-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="reformer-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["repair-pack-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="repair-pack", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["research-center-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="research-center-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["resistor1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="resistor1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["retorter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="retorter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rich-clay-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rich-clay", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sand-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sand", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-extractor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sap-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sap-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-tree-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sap-tree", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["seaweed-crop-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["seaweed-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="seaweed", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["shotgun-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="shotgun", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["shotgun-shell-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="shotgun-shell", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["slaughterhouse-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="slaughterhouse-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["small-electric-pole-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="small-electric-pole", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["small-lamp-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["small-parts-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["smelter-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="smelter-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-alginate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-hydroxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sodium-hydroxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["soil-extractor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="soil-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["soil-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="soil", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["solder-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="solder", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["solid-separator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="solid-separator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["soot-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="soot", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["splitter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="splitter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steam-engine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steam-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=20000},
      },
      results = {
      },
    },
    ["steel-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steel-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stone-brick-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="stone-brick", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stone-furnace-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stone-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="stone", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stone-wall-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="stone-wall", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stopper-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["storage-tank-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["submachine-gun-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="submachine-gun", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sulfur-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sulfur", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tailings-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tailings-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tailings-pond-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tailings-pond", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tar-processing-unit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tin-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tin-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tinned-cable-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tinned-cable", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["titanium-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="titanium-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["transport-belt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="transport-belt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tree-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["underground-belt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="underground-belt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vacuum-pump-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vacuum-tube-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vacuum-tube", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vrauks-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vrauks-paddock-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks-paddock-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vrauks-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["washer-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wood-seedling-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wood-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wood-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wooden-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wooden-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wpu-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wpu-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zinc-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["assembling-machine-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="concrete", amount=24.0203117127},
        {type="item", name="inductor1", amount=22.426785888},
        {type="item", name="lead-plate", amount=8.42548048213},
        {type="item", name="steel-plate", amount=2},
      },
      results = {
        {type="item", name="assembling-machine-2", amount=1},
      },
    },
    ["crushed-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="raw-coal", amount=3},
      },
      results = {
        {type="item", name="coal", amount=2},
        {type="item", name="coal-dust", amount=0.3},
        {type="item", name="crushed-coal", amount=1},
      },
    },
    ["biomass-cooking"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="fluid", name="ammonia", amount=212.382544981},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=400},
      },
    },
    ["chitin-to-geothermal-water"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="chitin", amount=2},
      },
      results = {
        {type="fluid", name="geothermal-water", amount=50},
      },
    },
    ["he-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="diborane", amount=2665.98014861},
        {type="fluid", name="pressured-water", amount=75},
      },
      results = {
        {type="fluid", name="molten-salt", amount=200},
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["molten-salt"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="salt", amount=300},
      },
      results = {
        {type="fluid", name="molten-salt", amount=100},
      },
    },
    ["coal-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="ammonia", amount=265.478181226},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["geo-he-00"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=600},
      },
      results = {
        {type="fluid", name="steam", amount=300},
      },
    },
    ["oil-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="ammonia", amount=265.478181226},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["borax-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=97.8260869565},
        {type="item", name="raw-borax", amount=10},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="borax", amount=10},
      },
    },
    ["diborane"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=250},
        {type="item", name="borax", amount=10},
      },
      results = {
        {type="fluid", name="diborane", amount=150},
      },
    },
    ["boric-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="diborane", amount=100},
        {type="fluid", name="water", amount=500},
      },
      results = {
        {type="fluid", name="boric-acid", amount=500},
      },
    },
    ["clean-nexelit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=65.2173913043},
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
      ingredients = {
        {type="fluid", name="hydrogen", amount=2322.16575695},
      },
      results = {
        {type="item", name="nexelit-ore", amount=1},
        {type="item", name="tailings-dust", amount=0.4},
      },
    },
    ["nexelit-plate-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="clean-nexelit", amount=18},
      },
      results = {
        {type="item", name="nexelit-plate", amount=18},
      },
    },
    ["soil-separation-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="soil", amount=20},
      },
      results = {
        {type="item", name="biomass", amount=3},
        {type="item", name="coarse", amount=3},
        {type="item", name="limestone", amount=2},
        {type="item", name="sand", amount=13},
      },
    },
    ["coarse-classification"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="coarse", amount=20},
      },
      results = {
        {type="item", name="gravel", amount=4},
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="stone", amount=5},
      },
    },
    ["concrete-wall"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=2},
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="concrete-wall", amount=1},
      },
    },
    ["wood-fence"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="treated-wood", amount=2},
      },
      results = {
        {type="item", name="wood-fence", amount=1},
      },
    },
    ["cool-pressured-steam-2000-to-1000"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="pressured-water", amount=210},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=400},
      },
    },
    ["jerky-to-phytoplankton"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="dried-meat", amount=3},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["cool-steam-250-to-150"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="water", amount=150},
      },
      results = {
        {type="fluid", name="steam", amount=340},
      },
    },
    ["electric-boiler-water-to-steam"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="vacuum", amount=600},
      },
      results = {
        {type="fluid", name="steam", amount=300},
      },
    },
    ["digosaurus"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water-saline", amount=1000},
        {type="item", name="duralumin", amount=88.9644769879},
        {type="item", name="earth-generic-sample", amount=10},
        {type="item", name="petri-dish-bacteria", amount=8.19371727749},
        {type="item", name="titanium-plate", amount=50},
      },
      results = {
        {type="item", name="digosaurus", amount=1},
      },
    },
    ["electric-mining-drill"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="stone-brick", amount=9.0756722263},
      },
      results = {
        {type="item", name="electric-mining-drill", amount=1},
      },
    },
    ["fawogae-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="sodium-hydroxide", amount=25.2633766606},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="fawogae-codex", amount=1},
      },
    },
    ["ralesia-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=373.779764801},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="ralesia-codex", amount=1},
      },
    },
    ["fbreactor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="boiler", amount=2},
        {type="item", name="copper-cable", amount=49.4074245357},
        {type="item", name="duralumin", amount=3.92557152293},
        {type="item", name="hydrogen-barrel", amount=1.51853638019},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="stone-furnace", amount=4},
      },
      results = {
        {type="item", name="fbreactor-mk01", amount=1},
      },
    },
    ["geothermal-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=95.2708004622},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="steam-engine", amount=12.7695890092},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="geothermal-plant-mk01", amount=1},
      },
    },
    ["grade-1-lead"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="item", name="ore-nickel", amount=5},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["nickel-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=4.71085946574},
      },
      results = {
        {type="item", name="nickel-plate", amount=1},
      },
    },
    ["grade-1-ti"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-titanium", amount=5},
      },
      results = {
        {type="item", name="grade-1-ti", amount=1},
        {type="item", name="grade-2-ti", amount=0.5},
      },
    },
    ["grade-2-ti-crush"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-ti", amount=1},
      },
      results = {
        {type="item", name="grade-1-ti", amount=0.5},
        {type="item", name="stone", amount=1},
      },
    },
    ["grade-3-ti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-ti", amount=1.29368855989},
      },
      results = {
        {type="item", name="grade-3-ti", amount=1},
        {type="item", name="ti-rejects", amount=0.5},
      },
    },
    ["ti-rejects-recrush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-ti", amount=6.3698462231},
      },
      results = {
        {type="item", name="grade-3-ti", amount=0.3},
        {type="item", name="gravel", amount=1},
      },
    },
    ["titanium-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-ti", amount=14.2494985536},
      },
      results = {
        {type="item", name="titanium-plate", amount=10},
      },
    },
    ["grade-1-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-tin", amount=5},
      },
      results = {
        {type="item", name="grade-1-tin", amount=1},
        {type="item", name="grade-2-tin", amount=0.5},
      },
    },
    ["tin-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-tin", amount=6.84563758389},
      },
      results = {
        {type="item", name="tin-plate", amount=10},
      },
    },
    ["grade-2-crush-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="item", name="grade-1-tin", amount=0.5},
        {type="item", name="stone", amount=1},
      },
    },
    ["grade-1-zinc"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=3},
        {type="item", name="ore-zinc", amount=5},
      },
      results = {
        {type="item", name="grade-1-zinc", amount=1},
        {type="item", name="soil", amount=0.7},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["grade-2-zinc"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=2},
      },
      results = {
        {type="item", name="grade-2-zinc", amount=2},
        {type="item", name="sand", amount=0.5},
      },
    },
    ["zinc-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=20.8101086021},
      },
      results = {
        {type="item", name="zinc-plate", amount=30},
      },
    },
    ["grenade"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="gunpowder", amount=10},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="grenade", amount=1},
      },
    },
    ["guts-to-chlorine"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="guts", amount=5},
      },
      results = {
        {type="fluid", name="chlorine", amount=100},
      },
    },
    ["phytoplankton"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["piercing-rounds-magazine"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="firearm-magazine", amount=2},
        {type="item", name="lead-plate", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="piercing-rounds-magazine", amount=2},
      },
    },
    ["py-asphalt"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pitch", amount=10},
        {type="item", name="ash", amount=3},
        {type="item", name="gravel", amount=5},
      },
      results = {
        {type="item", name="py-asphalt", amount=1},
      },
    },
    ["py-iron-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=20},
        {type="item", name="limestone", amount=65.8052299953},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="py-iron-oxide", amount=2},
      },
    },
    ["py-limestone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="creosote", amount=35},
        {type="item", name="ash", amount=3},
        {type="item", name="soil", amount=22.3902357744},
      },
      results = {
        {type="item", name="py-limestone", amount=2},
      },
    },
    ["py-burner"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="boiler", amount=1.24743047883},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="titanium-plate", amount=20},
      },
      results = {
        {type="item", name="py-burner", amount=1},
      },
    },
    ["py-deposit-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=9.56570430815},
        {type="item", name="copper-plate", amount=59.9431521371},
        {type="item", name="steel-plate", amount=80},
        {type="item", name="wooden-chest", amount=20},
      },
      results = {
        {type="item", name="py-deposit-basic", amount=1},
      },
    },
    ["py-shed-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=94.5860990164},
        {type="item", name="iron-chest", amount=1.28220932672},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="stone-brick", amount=10},
      },
      results = {
        {type="item", name="py-shed-basic", amount=1},
      },
    },
    ["py-storehouse-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-chest", amount=2.56441865344},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="tin-plate", amount=4.45362962995},
      },
      results = {
        {type="item", name="py-storehouse-basic", amount=1},
      },
    },
    ["py-warehouse-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-chest", amount=3.84662798016},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="small-parts-01", amount=152.195645543},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="py-warehouse-basic", amount=1},
      },
    },
    ["rail"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ceramic", amount=2.83538574194},
        {type="item", name="coal-gas-barrel", amount=7.03160556721},
        {type="item", name="sodium-hydroxide", amount=4.72533078965},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="stone", amount=1},
      },
      results = {
        {type="item", name="rail", amount=3},
      },
    },
    ["rail-signal"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="rail-signal", amount=1},
      },
    },
    ["rail-chain-signal"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=1},
      },
    },
    ["train-stop"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="iron-plate", amount=6},
        {type="item", name="iron-stick", amount=6},
        {type="item", name="steel-plate", amount=3},
      },
      results = {
        {type="item", name="train-stop", amount=1},
      },
    },
    ["sb-grade-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="antimonium-ore", amount=10},
      },
      results = {
        {type="item", name="iron-oxide", amount=0.3},
        {type="item", name="sb-grade-01", amount=5},
        {type="item", name="sb-grade-02", amount=3},
        {type="item", name="stone", amount=2},
      },
    },
    ["sb-grade-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-01", amount=4.65587044534},
      },
      results = {
        {type="item", name="gravel", amount=3},
        {type="item", name="sb-grade-03", amount=0.8},
        {type="item", name="sb-grade-04", amount=5},
      },
    },
    ["sb-grade-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-01", amount=5},
      },
      results = {
        {type="item", name="sb-grade-02", amount=10},
        {type="item", name="stone", amount=0.4},
      },
    },
    ["sb-grade-04"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-01", amount=39.7899797571},
      },
      results = {
        {type="item", name="sb-grade-04", amount=4},
      },
    },
    ["steel-furnace"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="refined-concrete", amount=10},
        {type="item", name="steam-engine", amount=1.30750834151},
      },
      results = {
        {type="item", name="steel-furnace", amount=1},
      },
    },
    ["storage-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="inductor1", amount=22.426785888},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="storage-chest", amount=1},
      },
    },
    ["anemometer-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="small-parts-01", amount=15},
      },
      results = {
        {type="item", name="anemometer-mk01", amount=1},
      },
    },
    ["blade-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ceramic", amount=7.44247387033},
        {type="item", name="lens", amount=9.61020643407},
      },
      results = {
        {type="item", name="blade-mk01", amount=1},
      },
    },
    ["brake-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ceramic", amount=10},
        {type="item", name="copper-plate", amount=10},
        {type="item", name="fenxsb-alloy", amount=8.46354808009},
        {type="item", name="glass", amount=10},
        {type="item", name="iron-plate", amount=59.1723756036},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="titanium-plate", amount=59.7559943937},
      },
      results = {
        {type="item", name="brake-mk01", amount=1},
      },
    },
    ["electronics-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=10},
        {type="item", name="formica", amount=5.28569381717},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="pipe", amount=3.98798070702},
        {type="item", name="resistor1", amount=20},
        {type="item", name="small-lamp", amount=6.40364825142},
        {type="item", name="solder", amount=5},
        {type="item", name="vacuum-tube", amount=5},
      },
      results = {
        {type="item", name="electronics-mk01", amount=1},
      },
    },
    ["shaft-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cellulose", amount=11.9585257856},
        {type="item", name="fenxsb-alloy", amount=5},
        {type="item", name="nexelit-plate", amount=17.0335187671},
      },
      results = {
        {type="item", name="shaft-mk01", amount=1},
      },
    },
    ["utility-box-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="steel-plate", amount=5.28618904045},
        {type="item", name="tinned-cable", amount=50},
        {type="item", name="vacuum-tube", amount=17.7201116508},
      },
      results = {
        {type="item", name="utility-box-mk01", amount=1},
      },
    },
    ["vane-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="bolts", amount=50},
        {type="item", name="stone-brick", amount=13.6135083394},
      },
      results = {
        {type="item", name="vane-mk01", amount=1},
      },
    },
    ["controler-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=3},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="glass", amount=4},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="ore-aluminium", amount=1.85551458263},
      },
      results = {
        {type="item", name="controler-mk01", amount=1},
      },
    },
    ["gearbox-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=20},
        {type="item", name="brake-mk01", amount=0.69120454166},
        {type="item", name="duralumin", amount=4},
        {type="item", name="nickel-plate", amount=4.41688994076},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="gearbox-mk01", amount=1},
      },
    },
    ["nacelle-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=114.232607411},
        {type="item", name="anemometer-mk01", amount=3.75871821722},
        {type="item", name="blade-mk01", amount=43.6410963608},
        {type="item", name="engine-unit", amount=5.93013903653},
        {type="item", name="inserter", amount=3.30408476158},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="melamine-resin", amount=10},
        {type="item", name="rotor-mk01", amount=5.75629695091},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="tower-mk01", amount=0.847661814754},
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="nacelle-mk01", amount=1},
      },
    },
    ["tower-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=591.723756036},
        {type="item", name="kerogen", amount=86.4497843878},
        {type="item", name="solder", amount=15},
      },
      results = {
        {type="item", name="tower-mk01", amount=1},
      },
    },
    ["yaw-drive-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="rubber", amount=15},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="titanium-plate", amount=59.7559943937},
      },
      results = {
        {type="item", name="yaw-drive-mk01", amount=1},
      },
    },
    ["rotor-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="blade-mk01", amount=7},
        {type="item", name="bolts", amount=35},
        {type="item", name="melamine", amount=10},
        {type="item", name="treated-wood", amount=10},
      },
      results = {
        {type="item", name="rotor-mk01", amount=1},
      },
    },
    ["animal-sample-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="tar", amount=202.205082122},
        {type="item", name="bones", amount=5},
        {type="item", name="brain", amount=3},
        {type="item", name="guts", amount=3},
        {type="item", name="meat", amount=7},
        {type="item", name="mukmoux-fat", amount=1},
        {type="item", name="plasmids", amount=1},
        {type="item", name="skin", amount=3},
      },
      results = {
        {type="item", name="animal-sample-01", amount=1},
      },
    },
    ["bio-sample01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="bonemeal", amount=10},
        {type="item", name="native-flora", amount=12},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="ralesia-seeds", amount=18},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="bio-sample01", amount=4},
      },
    },
    ["equipment-chassi"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="inductor1", amount=7.47559529602},
        {type="item", name="nexelit-plate", amount=27.0978418258},
      },
      results = {
        {type="item", name="equipment-chassi", amount=2},
      },
    },
    ["ground-sample01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="rich-clay", amount=5},
        {type="item", name="soil", amount=10},
      },
      results = {
        {type="item", name="ground-sample01", amount=10},
      },
    },
    ["rich-clay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=326.086956522},
        {type="item", name="ash", amount=25},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["sand-casting"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="creosote", amount=20},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="item", name="sand-casting", amount=2},
      },
    },
    ["alien-sample01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-sample01", amount=4},
        {type="item", name="ground-sample01", amount=15},
      },
      results = {
        {type="item", name="alien-sample01", amount=4},
      },
    },
    ["lab-instrument"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=27.593613346},
        {type="item", name="nexelit-plate", amount=17.0335187671},
        {type="item", name="ore-quartz", amount=1699.71928998},
        {type="item", name="treated-wood", amount=19.6561867252},
      },
      results = {
        {type="item", name="lab-instrument", amount=2},
      },
    },
    ["grade-1-chromite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-nickel", amount=5},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=1},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["chromium-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=150},
        {type="item", name="lens", amount=3.10991670061},
        {type="item", name="limestone", amount=3},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="chromium", amount=5},
      },
    },
    ["tier-0-chromite-sand"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=3},
      },
    },
    ["medium-electric-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="chromium", amount=1},
        {type="item", name="iron-stick", amount=4.25835228038},
      },
      results = {
        {type="item", name="medium-electric-pole", amount=1},
      },
    },
    ["powdered-aluminium"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-aluminium", amount=5},
      },
      results = {
        {type="item", name="gravel", amount=0.5},
        {type="item", name="powdered-aluminium", amount=1},
      },
    },
    ["molten-aluminium-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="borax", amount=3},
        {type="item", name="graphite", amount=3},
        {type="item", name="powdered-aluminium", amount=2},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=10},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="aluminium-plate", amount=50},
      },
    },
    ["hotair-aluminium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="fluid", name="steam", amount=226.086956522},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="aluminium-plate", amount=63},
      },
    },
    ["crushing-quartz"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-quartz", amount=5},
      },
      results = {
        {type="item", name="crushed-quartz", amount=1},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["sand-classification"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="sand", amount=20},
      },
      results = {
        {type="item", name="crushed-quartz", amount=0.05},
        {type="item", name="gravel", amount=4},
        {type="item", name="iron-oxide", amount=0.5},
      },
    },
    ["glass-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="crushed-quartz", amount=2},
      },
      results = {
        {type="fluid", name="molten-glass", amount=30},
      },
    },
    ["hotair-molten-glass"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="boric-acid", amount=373.73636691},
        {type="fluid", name="hot-air", amount=50},
      },
      results = {
        {type="item", name="glass", amount=7},
      },
    },
    ["antimony-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="bolts", amount=228.606351702},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="steam-engine", amount=15.9619862615},
      },
      results = {
        {type="item", name="antimony-drill-mk01", amount=1},
      },
    },
    ["centrifuge-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=2},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=30.7892709051},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="titanium-plate", amount=149.389985984},
      },
      results = {
        {type="item", name="centrifuge-mk01", amount=1},
      },
    },
    ["hawt-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="rotor-mk01", amount=1},
        {type="item", name="utility-box-mk01", amount=17.198188986},
        {type="item", name="vane-mk01", amount=1},
        {type="item", name="yaw-drive-mk01", amount=0.54901596489},
      },
      results = {
        {type="item", name="hawt-turbine-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=33.7244701919},
        {type="item", name="electronic-circuit", amount=100},
        {type="item", name="intermetallics", amount=20},
        {type="item", name="iron-plate", amount=300},
        {type="item", name="mechanical-parts-01", amount=4},
        {type="item", name="pipe", amount=50},
        {type="item", name="plastic-bar", amount=50},
        {type="item", name="soil-extractor-mk01", amount=2.73551342017},
        {type="item", name="steel-plate", amount=100},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
      },
    },
    ["py-oil-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=1.68668005523},
        {type="item", name="gas-refinery-mk01", amount=1},
        {type="item", name="inductor1", amount=747.559529602},
        {type="item", name="intermetallics", amount=40},
        {type="item", name="iron-plate", amount=1183.44751207},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="pipe", amount=200},
        {type="item", name="small-parts-01", amount=200},
        {type="item", name="steam-engine", amount=20},
        {type="item", name="titanium-plate", amount=149.389985984},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=1},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=10.7499752432},
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="concrete", amount=324.028914542},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="engine-unit", amount=5.93013903653},
        {type="item", name="pipe", amount=20},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="titanium-plate", amount=59.7559943937},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="steam-turbine-mk01", amount=1},
      },
    },
    ["tidal-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=10.7499752432},
        {type="item", name="brake-mk01", amount=3},
        {type="item", name="concrete", amount=162.014457271},
        {type="item", name="distilator", amount=3.78831699018},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="mechanical-parts-01", amount=10},
        {type="item", name="pipe", amount=20},
        {type="item", name="shaft-mk01", amount=3},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="stone-brick", amount=145.999187263},
        {type="item", name="titanium-plate", amount=89.6339915906},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="tidal-mk01", amount=1},
      },
    },
    ["vawt-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="bones", amount=45},
        {type="item", name="carbon-black", amount=10.4850057599},
        {type="item", name="ceramic", amount=61.4963739215},
        {type="item", name="gearbox-mk01", amount=5},
        {type="item", name="glass", amount=351.713869576},
        {type="item", name="inductor1", amount=149.51190592},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="rubber", amount=7.55883324417},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="storage-tank", amount=2.19908519927},
        {type="item", name="titanium-plate", amount=239.023977575},
        {type="item", name="utility-box-mk01", amount=5},
        {type="item", name="vane-mk01", amount=2.51212534112},
      },
      results = {
        {type="item", name="vawt-turbine-mk01", amount=1},
      },
    },
    ["py-coal-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=0.689652903906},
        {type="item", name="electronic-circuit", amount=100},
        {type="item", name="engine-unit", amount=20.2744626655},
        {type="item", name="intermetallics", amount=50},
        {type="item", name="jaw-crusher", amount=2.11630590157},
        {type="item", name="small-parts-01", amount=300},
        {type="item", name="steam-engine", amount=20},
        {type="item", name="steel-plate", amount=200},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk01", amount=1},
      },
    },
    ["arithmetic-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="copper-cable", amount=5},
        {type="item", name="inductor1", amount=37.3779764801},
      },
      results = {
        {type="item", name="arithmetic-combinator", amount=1},
      },
    },
    ["constant-combinator"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="copper-cable", amount=5},
        {type="item", name="electronic-circuit", amount=2},
      },
      results = {
        {type="item", name="constant-combinator", amount=1},
      },
    },
    ["decider-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="inductor1", amount=37.3779764801},
        {type="item", name="pipe", amount=5.32294035048},
      },
      results = {
        {type="item", name="decider-combinator", amount=1},
      },
    },
    ["display-panel"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="item", name="copper-cable", amount=5},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="glass", amount=3.76930668523},
        {type="item", name="mechanical-parts-01", amount=1},
      },
      results = {
        {type="item", name="power-switch", amount=1},
      },
    },
    ["programmable-speaker"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=5},
        {type="item", name="engine-unit", amount=1.4241688415},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="programmable-speaker", amount=1},
      },
    },
    ["selector-combinator"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="decider-combinator", amount=5},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="solder", amount=5},
      },
      results = {
        {type="item", name="selector-combinator", amount=1},
      },
    },
    ["fiberboard"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=500},
        {type="item", name="plastic-bar", amount=3.35983948903},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="urea", amount=20},
      },
      results = {
        {type="fluid", name="ammonia", amount=30},
        {type="fluid", name="cyanic-acid", amount=30},
      },
    },
    ["black-liquor"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="hot-air", amount=482.960130645},
        {type="item", name="wood", amount=15.6877404269},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=100},
        {type="fluid", name="hydrogen", amount=50},
      },
    },
    ["melamine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="ammonia", amount=20},
        {type="fluid", name="cyanic-acid", amount=20},
        {type="fluid", name="steam", amount=130.434782609},
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
      ingredients = {
        {type="fluid", name="oxygen", amount=109.523809524},
      },
      results = {
        {type="fluid", name="water", amount=400},
      },
    },
    ["flue-gas-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="biomass", amount=10},
      },
      results = {
        {type="fluid", name="flue-gas", amount=150},
      },
    },
    ["flue-gas-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="stone", amount=5.78422580373},
      },
      results = {
        {type="fluid", name="flue-gas", amount=200},
      },
    },
    ["cracker-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1.14911247739},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="pipe", amount=34.8005360919},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="cracker-mk01", amount=1},
      },
    },
    ["heavy-oil-refinery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=39.9621014247},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="glass", amount=20.872036338},
        {type="item", name="pipe", amount=35.0657031566},
        {type="item", name="soil-extractor-mk01", amount=2.73551342017},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
      },
    },
    ["gas-refinery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=3.28611071672},
        {type="item", name="duralumin", amount=5},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=15},
        {type="item", name="intermetallics", amount=15},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="titanium-plate", amount=8.62055685602},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="gas-refinery-mk01", amount=1},
      },
    },
    ["upgrader-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=3.37244701919},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="gas-refinery-mk01", amount=0.919512469458},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="pipe", amount=30},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="upgrader-mk01", amount=1},
      },
    },
    ["earth-bear-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-codex", amount=5},
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="earth-generic-sample", amount=1},
      },
      results = {
        {type="item", name="earth-bear-sample", amount=1},
      },
    },
    ["earth-flower-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="ralesia-codex", amount=1},
      },
      results = {
        {type="item", name="earth-flower-sample", amount=1},
      },
    },
    ["earth-shroom-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="wooden-chest", amount=1},
      },
      results = {
        {type="item", name="earth-shroom-sample", amount=1},
      },
    },
    ["earth-mouse-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-codex", amount=3.82898582479},
        {type="item", name="moss-gen", amount=82.6413113131},
        {type="item", name="utility-box-mk01", amount=1.34317038219},
      },
      results = {
        {type="item", name="earth-mouse-sample", amount=1},
      },
    },
    ["molten-iron-05"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=120},
        {type="item", name="borax", amount=3},
        {type="item", name="processed-iron-ore", amount=5},
      },
      results = {
        {type="fluid", name="molten-iron", amount=10},
      },
    },
    ["hotair-iron-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-iron", amount=100},
        {type="fluid", name="water", amount=346.666666667},
        {type="item", name="coke", amount=5.29569086556},
        {type="item", name="lime", amount=1.47656155365},
      },
      results = {
        {type="item", name="iron-plate", amount=75},
      },
    },
    ["iron-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-iron", amount=100},
        {type="item", name="limestone", amount=3.37714393755},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="iron-plate", amount=60},
      },
    },
    ["mechanical-parts-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=4.06866557702},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="electronic-circuit", amount=3.78291051962},
        {type="item", name="rubber", amount=3},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="small-parts-01", amount=25},
        {type="item", name="tower-mk01", amount=0.576811573681},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=3},
      },
    },
    ["sb-oxide-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=280},
        {type="item", name="plastic-bar", amount=1},
        {type="item", name="sb-grade-02", amount=24.8859081098},
      },
      results = {
        {type="item", name="sb-oxide", amount=1},
      },
    },
    ["pbsb-alloy"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="lead-plate", amount=6},
        {type="item", name="sb-oxide", amount=1},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=1},
      },
    },
    ["battery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=30},
        {type="item", name="carbon-black", amount=0.629100345596},
        {type="item", name="chromium", amount=0.878996391669},
        {type="item", name="glass", amount=1},
        {type="item", name="melamine", amount=2},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="zinc-plate", amount=3},
      },
      results = {
        {type="item", name="battery-mk01", amount=1},
      },
    },
    ["accumulator"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=30},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="iron-plate", amount=2},
      },
      results = {
        {type="item", name="accumulator", amount=1},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=7},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="pbsb-alloy", amount=0.548884369373},
      },
      results = {
        {type="item", name="fenxsb-alloy", amount=2},
      },
    },
    ["vitreloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6.16010530011},
        {type="item", name="cellulose", amount=6.86822295601},
        {type="item", name="copper-plate", amount=3},
        {type="item", name="glass", amount=10.4716262134},
        {type="item", name="small-parts-01", amount=8.89561787903},
      },
      results = {
        {type="item", name="vitreloy", amount=2},
      },
    },
    ["intermetallics"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2.84258300194},
        {type="item", name="copper-plate", amount=30},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="pipe", amount=37.5798058489},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-brick", amount=429.623268663},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=1},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=9.2406221856},
        {type="item", name="copper-plate", amount=20},
        {type="item", name="fluid-drill-mk01", amount=0.665429564715},
        {type="item", name="glass", amount=50},
        {type="item", name="inductor1", amount=37.3779764801},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=15},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=1},
      },
    },
    ["classifier"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=16.9490727859},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="transport-belt", amount=30},
      },
      results = {
        {type="item", name="classifier", amount=1},
      },
    },
    ["rectisol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=115.904702846},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="electric-mining-drill", amount=0.626488448001},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=25},
        {type="item", name="pipe", amount=20},
        {type="item", name="pump", amount=2},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="storage-tank", amount=2},
      },
      results = {
        {type="item", name="rectisol", amount=1},
      },
    },
    ["automated-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="burner-inserter", amount=27.4491150014},
        {type="item", name="duralumin", amount=6.74489403838},
        {type="item", name="engine-unit", amount=1.18602780731},
        {type="item", name="inductor1", amount=37.3779764801},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="tower-mk01", amount=1.15362314736},
      },
      results = {
        {type="item", name="automated-factory-mk01", amount=1},
      },
    },
    ["fluid-drill-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="electric-mining-drill", amount=2},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="fluid-drill-mk02", amount=1},
      },
    },
    ["bof-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=1.9074804544},
      },
      results = {
        {type="item", name="bof-mk01", amount=1},
      },
    },
    ["casting-unit-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=20},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=35.0657031566},
        {type="item", name="radar", amount=0.674420754671},
        {type="item", name="steel-furnace", amount=2},
        {type="item", name="steel-plate", amount=15},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=1},
      },
    },
    ["eaf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="distilator", amount=0.657626283772},
        {type="item", name="inductor1", amount=74.7559529602},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="soil-extractor-mk01", amount=1.87533495813},
        {type="item", name="steel-plate", amount=25},
        {type="item", name="stone-furnace", amount=20.041197024},
        {type="item", name="tin-plate", amount=12.5718637495},
      },
      results = {
        {type="item", name="eaf-mk01", amount=1},
      },
    },
    ["hydroclassifier-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electrolyzer-mk01", amount=1.24024960031},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="engine-unit", amount=4.74411122922},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=1},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="py-local-radar", amount=2},
        {type="item", name="soil-extractor-mk01", amount=3.75066991627},
        {type="item", name="steam-engine", amount=6},
        {type="item", name="tin-plate", amount=12.5718637495},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=1},
      },
    },
    ["scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=16.2014457271},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="fluid-drill-mk01", amount=0.533238073371},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="lead-plate", amount=7.95935437404},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="scrubber-mk01", amount=1},
      },
    },
    ["flotation-cell-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-stick", amount=326.535420624},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=35.0657031566},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="flotation-cell-mk01", amount=1},
      },
    },
    ["cargo-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="duralumin", amount=10},
        {type="item", name="gearbox-mk01", amount=0.725036954164},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="titanium-plate", amount=50},
      },
      results = {
        {type="item", name="cargo-wagon", amount=1},
      },
    },
    ["fluid-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="duralumin", amount=10},
        {type="item", name="engine-unit", amount=2.96506951826},
        {type="item", name="pipe", amount=8},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=16},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="titanium-plate", amount=50},
      },
      results = {
        {type="item", name="fluid-wagon", amount=1},
      },
    },
    ["locomotive"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="concrete", amount=9.2406221856},
        {type="item", name="duralumin", amount=25},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="shaft-mk01", amount=4},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="utility-box-mk01", amount=0.880712610373},
      },
      results = {
        {type="item", name="locomotive", amount=1},
      },
    },
    ["cooling-tower-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=9.2406221856},
        {type="item", name="duralumin", amount=30},
        {type="item", name="inductor1", amount=37.3779764801},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="nexelit-plate", amount=51.1005563012},
      },
      results = {
        {type="item", name="cooling-tower-mk01", amount=1},
      },
    },
    ["fawogae-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="intermetallics", amount=2},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="nexelit-plate", amount=9.71520159798},
        {type="item", name="nickel-plate", amount=40.9857018309},
        {type="item", name="soil", amount=100},
        {type="item", name="steel-plate", amount=39.6520084791},
        {type="item", name="wood", amount=100},
      },
      results = {
        {type="item", name="fawogae-plantation-mk01", amount=1},
      },
    },
    ["prandium-lab-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="lead-plate", amount=23.9554968142},
        {type="item", name="small-lamp", amount=8},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="titanium-plate", amount=17.6415412149},
      },
      results = {
        {type="item", name="prandium-lab-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=3.00056793622},
        {type="item", name="formica", amount=62.8392137481},
        {type="item", name="glass", amount=100},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="limestone", amount=133.986976744},
        {type="item", name="plastic-bar", amount=18.1272339185},
        {type="item", name="small-lamp", amount=20},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="treated-wood", amount=50},
      },
      results = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
    },
    ["fish-farm-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=90.9407698751},
        {type="item", name="duralumin", amount=30},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="engine-unit", amount=1.18602780731},
        {type="item", name="iron-plate", amount=591.723756036},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=40},
        {type="item", name="pump", amount=5},
      },
      results = {
        {type="item", name="fish-farm-mk01", amount=1},
      },
    },
    ["heavy-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=20},
        {type="item", name="glass", amount=139.621682845},
        {type="item", name="inductor1", amount=186.8898824},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="latex-slab", amount=4},
        {type="item", name="pipe", amount=70.1314063132},
        {type="item", name="plastic-bar", amount=10},
      },
      results = {
        {type="item", name="heavy-armor", amount=1},
      },
    },
    ["mixer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=30},
        {type="item", name="duralumin", amount=16.7347227696},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="py-tank-3000", amount=1.05477268766},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="mixer-mk01", amount=1},
      },
    },
    ["py-heat-exchanger"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="distilator", amount=3.59536449819},
        {type="item", name="duralumin", amount=16.8622350959},
        {type="item", name="inductor1", amount=37.3779764801},
        {type="item", name="pipe", amount=20},
        {type="item", name="py-tank-1500", amount=2.13463776505},
        {type="item", name="vitreloy", amount=6.23960205002},
      },
      results = {
        {type="item", name="py-heat-exchanger", amount=1},
      },
    },
    ["secondary-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1.05557794941},
        {type="item", name="duralumin", amount=20},
        {type="item", name="electronic-circuit", amount=25},
        {type="item", name="iron-plate", amount=473.379004828},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="small-parts-01", amount=50},
      },
      results = {
        {type="item", name="secondary-crusher-mk01", amount=1},
      },
    },
    ["atomizer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="distilator", amount=1.09604380629},
        {type="item", name="duralumin", amount=10},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=50},
        {type="item", name="methanal-barrel", amount=4.96779902347},
        {type="item", name="nickel-plate", amount=25},
        {type="item", name="small-parts-01", amount=167.524972119},
        {type="item", name="treated-wood", amount=32.2833730025},
      },
      results = {
        {type="item", name="atomizer-mk01", amount=1},
      },
    },
    ["bio-reactor-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="glass", amount=50},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="mixer-mk01", amount=1},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="tailings-pond", amount=1},
      },
      results = {
        {type="item", name="bio-reactor-mk01", amount=1},
      },
    },
    ["plankton-farm"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=30},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="iron-plate", amount=591.723756036},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=25},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="plankton-farm", amount=1},
      },
    },
    ["spore-collector-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=236.465247541},
        {type="item", name="fluid-drill-mk01", amount=1.19907746605},
        {type="item", name="inductor1", amount=74.7559529602},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="treated-wood", amount=10.9749020991},
      },
      results = {
        {type="item", name="spore-collector-mk01", amount=1},
      },
    },
    ["compost-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=128.631442353},
        {type="item", name="electronic-circuit", amount=40},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="lab", amount=9.18602808846},
        {type="item", name="pipe", amount=175.328515783},
        {type="item", name="pump", amount=2.88424303559},
        {type="item", name="steel-plate", amount=100},
      },
      results = {
        {type="item", name="compost-plant-mk01", amount=1},
      },
    },
    ["oil-boiler-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="lab", amount=1},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="washer", amount=2.55687871883},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=1},
      },
    },
    ["py-electric-boiler"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="gasifier", amount=1},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=70.1314063132},
      },
      results = {
        {type="item", name="py-electric-boiler", amount=1},
      },
    },
    ["rhe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="boiler", amount=5},
        {type="item", name="concrete", amount=13.8609332784},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=41.5319834305},
        {type="item", name="small-parts-01", amount=20},
      },
      results = {
        {type="item", name="rhe", amount=1},
      },
    },
    ["personal-roboport-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=10},
        {type="item", name="inductor1", amount=74.7559529602},
        {type="item", name="intermetallics", amount=12},
        {type="item", name="pipe", amount=157.795664205},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="personal-roboport-equipment", amount=1},
      },
    },
    ["portable-gasoline-generator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="boiler", amount=1},
        {type="item", name="duralumin", amount=45.197527429},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="small-electric-pole", amount=1},
        {type="item", name="small-parts-01", amount=14},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="portable-gasoline-generator", amount=1},
      },
    },
    ["py-recharge-station-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=15},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-stick", amount=63.8752842057},
        {type="item", name="nexelit-plate", amount=14.9112579614},
        {type="item", name="pipe", amount=177.894910944},
      },
      results = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
    },
    ["py-roboport-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="distilator", amount=0.655072410744},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=11.0635842161},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="titanium-plate", amount=20.1523925172},
      },
      results = {
        {type="item", name="py-roboport-mk01", amount=1},
      },
    },
    ["py-ze"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=94.5860990164},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="pipe", amount=70.1314063132},
      },
      results = {
        {type="item", name="py-ze", amount=1},
      },
    },
    ["salt-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=40},
        {type="item", name="engine-unit", amount=67.5815422183},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="plastic-bar", amount=204.82653806},
        {type="item", name="solid-separator", amount=0.535423140087},
        {type="item", name="tar-processing-unit", amount=3.8567228385},
      },
      results = {
        {type="item", name="salt-mine", amount=1},
      },
    },
    ["dino-dig-site"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="duralumin", amount=30},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=104.36018169},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="titanium-plate", amount=100},
      },
      results = {
        {type="item", name="dino-dig-site", amount=1},
      },
    },
    ["generator-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=50},
        {type="item", name="duralumin", amount=6.00401429867},
        {type="item", name="engine-unit", amount=1.18602780731},
        {type="item", name="glass", amount=10.0301387942},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="iron-stick", amount=30},
        {type="item", name="small-parts-01", amount=40},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="tailings-dust", amount=11.8034276884},
      },
      results = {
        {type="item", name="generator-1", amount=1},
      },
    },
    ["pyphoon-bay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="coke", amount=116.881017105},
        {type="item", name="copper-plate", amount=236.465247541},
        {type="item", name="duralumin", amount=50},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="sand", amount=100},
        {type="item", name="small-parts-01", amount=50},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=1},
      },
    },
    ["belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="small-parts-01", amount=10.3206307915},
      },
      results = {
        {type="item", name="belt", amount=2},
      },
    },
    ["polybutadiene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="aromatics", amount=200},
        {type="fluid", name="water", amount=1000},
        {type="item", name="ore-titanium", amount=7.75354692503},
      },
      results = {
        {type="fluid", name="polybutadiene", amount=100},
        {type="fluid", name="steam", amount=1000},
      },
    },
    ["long-handed-inserter"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="belt", amount=1},
        {type="item", name="chromium", amount=10},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="inserter", amount=1},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=2},
      },
    },
    ["carbon-black"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=200},
        {type="fluid", name="vacuum", amount=100},
      },
      results = {
        {type="item", name="carbon-black", amount=4},
      },
    },
    ["engine-unit-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="carbon-black", amount=24.9319765222},
        {type="item", name="duralumin", amount=5},
        {type="item", name="nexelit-plate", amount=9.71520159798},
        {type="item", name="small-parts-01", amount=50},
      },
      results = {
        {type="item", name="engine-unit", amount=3},
      },
    },
    ["transport-belt-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="belt", amount=5},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="small-parts-01", amount=3},
      },
      results = {
        {type="item", name="transport-belt", amount=15},
      },
    },
    ["rubber-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="liquid-manure", amount=100},
        {type="fluid", name="subcritical-water", amount=1000},
      },
      results = {
        {type="fluid", name="depolymerized-organics", amount=100},
      },
    },
    ["subcritical-water-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-water", amount=200},
        {type="item", name="biomass", amount=30},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=50},
      },
    },
    ["electronic-circuit-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
        {type="item", name="fiberboard", amount=1.03581256888},
        {type="item", name="formica", amount=0.832799111712},
        {type="item", name="inductor1", amount=3},
        {type="item", name="pcb1", amount=1},
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
      ingredients = {
        {type="item", name="capacitor1", amount=8.14578079768},
        {type="item", name="melamine-resin", amount=10},
      },
      results = {
        {type="item", name="formica", amount=5},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="fluid", name="hydrogen", amount=1071.42857143},
        {type="fluid", name="water", amount=346.666666667},
        {type="item", name="petri-dish-bacteria", amount=6.40822330205},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["stopper-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="small-parts-01", amount=10.3206307915},
      },
      results = {
        {type="item", name="stopper", amount=2},
      },
    },
    ["meat-to-tin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="guts", amount=1.875},
      },
      results = {
        {type="item", name="ore-tin", amount=15},
      },
    },
    ["skin-to-lead"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="skin", amount=7},
      },
      results = {
        {type="item", name="ore-lead", amount=5},
      },
    },
    ["powdered-ralesia-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=15},
      },
      results = {
        {type="item", name="powdered-ralesia-seeds", amount=1},
      },
    },
    ["water-saline"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
      },
    },
    ["starch"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=4.07289039884},
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
      ingredients = {
        {type="fluid", name="hot-air", amount=4000},
        {type="item", name="aluminium-plate", amount=200},
        {type="item", name="battery-mk01", amount=100},
        {type="item", name="carbon-black", amount=8.38800460795},
        {type="item", name="concrete", amount=162.014457271},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="gearbox-mk01", amount=1.11628164051},
        {type="item", name="geothermal-water-barrel", amount=61.6183136954},
        {type="item", name="iron-stick", amount=212.917614019},
        {type="item", name="plastic-bar", amount=60},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="aerial-blimp-mk01", amount=1},
      },
    },
    ["blood-to-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=344.257892298},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["fawogae-to-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae", amount=6},
      },
      results = {
        {type="item", name="iron-ore", amount=5},
      },
    },
    ["bone-to-bonemeal-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="item", name="bones", amount=10},
      },
      results = {
        {type="item", name="bonemeal", amount=5},
      },
    },
    ["bones-to-kerogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="skin", amount=3.33333333333},
      },
      results = {
        {type="item", name="kerogen", amount=8},
      },
    },
    ["breed-fish-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="fluid", name="vacuum", amount=1600},
        {type="item", name="biomass", amount=10},
        {type="item", name="chromium", amount=7.5556070107},
        {type="item", name="fish-egg", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=10},
      },
    },
    ["breed-fish-egg-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="bio-sample", amount=5.24142606199},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=25},
      },
    },
    ["full-render-fish"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="fish", amount=8},
      },
      results = {
        {type="fluid", name="fish-oil", amount=100},
        {type="item", name="bones", amount=2},
        {type="item", name="guts", amount=5},
        {type="item", name="meat", amount=2},
        {type="item", name="skin", amount=3},
      },
    },
    ["py-construction-robot-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=50},
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="battery-mk01", amount=2},
        {type="item", name="carbon-black", amount=18.6989823916},
        {type="item", name="chromium", amount=21.8910406227},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="engine-unit", amount=1.77904171096},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="iron-plate", amount=236.689502414},
        {type="item", name="solder", amount=5},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="py-construction-robot-mk01", amount=1},
      },
    },
    ["liquid-manure"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="manure", amount=10},
      },
      results = {
        {type="fluid", name="liquid-manure", amount=100},
      },
    },
    ["zogna-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-air", amount=50},
        {type="item", name="coke", amount=11.6881017105},
        {type="item", name="flask", amount=0.639223118282},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="zogna-bacteria", amount=20},
      },
    },
    ["plasmids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="petri-dish", amount=3.12879797805},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=15.6735877108},
      },
      results = {
        {type="item", name="plasmids", amount=1},
      },
    },
    ["retrovirus"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-water", amount=288.888888889},
        {type="item", name="flask", amount=1},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish-bacteria", amount=0.819371727749},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="vrauks", amount=0.514541837564},
      },
      results = {
        {type="item", name="retrovirus", amount=1},
      },
    },
    ["cdna"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=4.8095057321},
        {type="item", name="anemometer-mk01", amount=2.57962483791},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="moss-gen", amount=5},
        {type="item", name="petri-dish", amount=9.38639393414},
        {type="item", name="petri-dish-bacteria", amount=5},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="cdna", amount=1},
      },
    },
    ["ralesia-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="ralesia", amount=2},
      },
    },
    ["ralesia-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia", amount=5},
      },
      results = {
        {type="item", name="ralesia-seeds", amount=8},
      },
    },
    ["ralesia-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="ralesia-seeds", amount=8},
        {type="item", name="soil", amount=15},
      },
      results = {
        {type="item", name="ralesia", amount=10},
      },
    },
    ["cottongut-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=373.779764801},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="cottongut-codex", amount=1},
      },
    },
    ["cottongut-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-mk01", amount=1.71297928852},
        {type="item", name="moondrop", amount=2},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut-pup", amount=10},
      },
    },
    ["caged-cottongut-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-pup", amount=7},
        {type="item", name="moondrop", amount=4},
        {type="item", name="ralesia-seeds", amount=3},
        {type="item", name="water-barrel", amount=2},
        {type="item", name="wood-seeds", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="cottongut", amount=6},
      },
    },
    ["cottongut"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=652.173913043},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-bear-sample", amount=0.900468280929},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="moss-gen", amount=3.78033285133},
        {type="item", name="retrovirus", amount=12.5416257136},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
      },
    },
    ["cottongut-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="moss", amount=2.89274808296},
        {type="item", name="ralesia-seeds", amount=2},
        {type="item", name="sodium-hydroxide", amount=30.8193493051},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood-seeds", amount=5},
      },
      results = {
        {type="item", name="cottongut-food-01", amount=4},
      },
    },
    ["cottongut-science-red-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="depolymerized-organics", amount=50},
        {type="item", name="agar", amount=12.0237643302},
        {type="item", name="native-flora", amount=5},
        {type="item", name="plasmids", amount=1},
        {type="item", name="vrauks", amount=14.580066022},
      },
      results = {
        {type="item", name="solidified-sarcorus", amount=3},
      },
    },
    ["full-render-cottongut"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut", amount=5},
      },
      results = {
        {type="fluid", name="blood", amount=60},
        {type="item", name="bones", amount=5},
        {type="item", name="brain", amount=2},
        {type="item", name="guts", amount=5},
        {type="item", name="meat", amount=4},
        {type="item", name="mukmoux-fat", amount=5},
        {type="item", name="skin", amount=4},
      },
    },
    ["cottongut-pup-mk01-raising"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="fish-egg", amount=2},
        {type="item", name="seaweed", amount=10},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1.5},
        {type="item", name="cottongut-pup", amount=0.5},
        {type="item", name="cottongut-pup-mk01", amount=4.4},
      },
    },
    ["cottongut-mature-basic-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-pup", amount=1.11843921527},
        {type="item", name="moondrop", amount=3},
        {type="item", name="wood", amount=1},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
      },
    },
    ["logistic-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=3},
        {type="item", name="bio-sample01", amount=13.6383862227},
        {type="item", name="clay", amount=284.323678306},
        {type="item", name="solidified-sarcorus", amount=1},
      },
      results = {
        {type="item", name="logistic-science-pack", amount=12},
      },
    },
    ["workers-food"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="blood", amount=50},
        {type="fluid", name="water", amount=100},
        {type="item", name="aluminium-plate", amount=3.63454805704},
        {type="item", name="bones", amount=4.5},
        {type="item", name="guts", amount=4},
        {type="item", name="mukmoux-fat", amount=1},
        {type="item", name="native-flora", amount=5},
        {type="item", name="starch", amount=1},
        {type="item", name="wood", amount=3.29442548964},
      },
      results = {
        {type="item", name="workers-food", amount=2},
      },
    },
    ["auog-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=74.7559529602},
        {type="item", name="lead-plate", amount=19.3868107952},
        {type="item", name="sodium-hydroxide", amount=64.7111111111},
      },
      results = {
        {type="item", name="auog-codex", amount=1},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=19.9876524096},
        {type="item", name="copper-cable", amount=20},
        {type="item", name="engine-unit", amount=2.96506951826},
        {type="item", name="iron-plate", amount=80},
        {type="item", name="soil", amount=300},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=1},
      },
    },
    ["auog-pooping-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="native-flora", amount=20},
        {type="item", name="saps", amount=5.24785513851},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=5.5},
      },
    },
    ["auog-pup-breeding-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="native-flora", amount=20},
        {type="item", name="nexelit-plate", amount=7.50830822064},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog-pup", amount=3.5},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="auog-codex", amount=1},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="earth-mouse-sample", amount=1.11053328716},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["auog-food-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="moss", amount=5},
        {type="item", name="native-flora", amount=5},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="ralesia", amount=5},
        {type="item", name="seaweed", amount=3},
      },
      results = {
        {type="item", name="auog-food-01", amount=3},
      },
    },
    ["auog-maturing-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-pup", amount=4},
        {type="item", name="moss", amount=10},
        {type="item", name="saps", amount=2.89156626506},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog", amount=3},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge-00"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="meat", amount=10},
        {type="item", name="moss", amount=5},
        {type="item", name="used-auog", amount=1},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["auog-maturing-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="auog-pup", amount=8},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
        {type="item", name="saps", amount=12},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog", amount=5.5},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-pooping-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
        {type="item", name="tar-barrel", amount=4.27036747898},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=8.5},
      },
    },
    ["auog-pup-breeding-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
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
      ingredients = {
        {type="item", name="moss", amount=5},
        {type="item", name="used-auog", amount=1},
        {type="item", name="vacuum-tube", amount=1.73175640995},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["caged-auog"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="auog", amount=1},
        {type="item", name="cage", amount=1},
      },
      results = {
        {type="item", name="caged-auog", amount=1},
      },
    },
    ["uncaged-auog"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="caged-auog", amount=1},
      },
      results = {
        {type="item", name="auog", amount=1},
        {type="item", name="cage", amount=1},
      },
    },
    ["ex-used-auog"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="used-auog", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=50},
        {type="item", name="bones", amount=3},
        {type="item", name="brain", amount=1},
        {type="item", name="guts", amount=3},
        {type="item", name="meat", amount=4},
        {type="item", name="skin", amount=2},
      },
    },
    ["fertilizer-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="biomass", amount=10},
        {type="item", name="small-lamp", amount=4.80422345545},
      },
      results = {
        {type="item", name="fertilizer", amount=5},
      },
    },
    ["urea-from-liquid-manure"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="liquid-manure", amount=100},
        {type="fluid", name="zogna-bacteria", amount=10},
      },
      results = {
        {type="item", name="urea", amount=30},
      },
    },
    ["full-render-auogs"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="caged-auog", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=100},
        {type="item", name="bones", amount=3},
        {type="item", name="brain", amount=1},
        {type="item", name="cage", amount=1},
        {type="item", name="guts", amount=3},
        {type="item", name="meat", amount=8},
        {type="item", name="mukmoux-fat", amount=2},
        {type="item", name="skin", amount=2},
      },
    },
    ["melamine-resin"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="methanal", amount=50},
        {type="item", name="melamine", amount=20},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="melamine-resin", amount=10},
      },
    },
    ["fawogae-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae-spore", amount=3},
      },
      results = {
        {type="item", name="fawogae", amount=7},
      },
    },
    ["fawogae-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=1533.33333333},
        {type="item", name="earth-shroom-sample", amount=1},
        {type="item", name="fawogae-spore", amount=10},
        {type="item", name="ground-sample01", amount=2},
        {type="item", name="moondrop-codex", amount=5.58625023707},
        {type="item", name="wood", amount=50},
      },
      results = {
        {type="item", name="fawogae", amount=2},
      },
    },
    ["boron-trioxide"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="boric-acid", amount=200},
        {type="item", name="coke", amount=1},
      },
      results = {
        {type="item", name="boron-trioxide", amount=1},
      },
    },
    ["coke-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="raw-coal", amount=10},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=20},
        {type="item", name="coke", amount=4},
      },
    },
    ["coal-fawogae"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae", amount=2},
      },
      results = {
        {type="item", name="raw-coal", amount=3},
      },
    },
    ["hotair-lens"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="boron-trioxide", amount=1},
      },
      results = {
        {type="item", name="lens", amount=4},
      },
    },
    ["lens"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=535.714285714},
        {type="item", name="tailings-dust", amount=2.79819164256},
      },
      results = {
        {type="item", name="lens", amount=3},
      },
    },
    ["vrauks-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon", amount=20},
        {type="item", name="saps", amount=10},
        {type="item", name="seaweed", amount=13.8276817935},
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
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="cellulose", amount=3},
        {type="item", name="dried-meat", amount=3.07919788362},
        {type="item", name="fawogae", amount=5},
        {type="item", name="moss", amount=10},
        {type="item", name="nexelit-plate", amount=2.70978418258},
        {type="item", name="wood-seeds", amount=6},
      },
      results = {
        {type="item", name="vrauks-food-01", amount=4},
      },
    },
    ["vrauks-cocoon-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="moss", amount=20},
        {type="item", name="native-flora", amount=10},
        {type="item", name="saps", amount=6},
        {type="item", name="vrauks-food-01", amount=1},
        {type="item", name="water-barrel", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=10},
      },
    },
    ["vrauks-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon", amount=50},
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=8},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks", amount=1.275},
        {type="item", name="vrauks-mk02", amount=0.005},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon-mk02", amount=8},
        {type="item", name="moss", amount=15.2443232308},
        {type="item", name="native-flora", amount=15},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="vrauks-mk02", amount=1},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk02", amount=1.95},
      },
    },
    ["vrauks-mk02-cocoon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="glass", amount=3.20338983051},
        {type="item", name="moss", amount=15.2443232308},
        {type="item", name="vrauks-food-01", amount=4},
        {type="item", name="vrauks-mk02", amount=2},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="cocoon-mk02", amount=5.5},
        {type="item", name="vrauks-mk02", amount=1.98},
      },
    },
    ["warm-stone-brick-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warm-stone-brick", amount=5},
      },
    },
    ["warm-air-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="warm-stone-brick", amount=20},
      },
      results = {
        {type="fluid", name="hot-air", amount=150},
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["accumulator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="accumulator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["acetone-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="acetone", amount=20000},
      },
      results = {
      },
    },
    ["aerial-blimp-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="aerial-blimp-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["alien-sample01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="alien-sample01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ammonia-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="ammonia", amount=20000},
      },
      results = {
      },
    },
    ["anemometer-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["animal-sample-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="animal-sample-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["antimony-drill-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="antimony-drill-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arithmetic-combinator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="arithmetic-combinator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["assembling-machine-2-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["atomizer-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="atomizer-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-paddock-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-paddock-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-pup-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-pup", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["automated-factory-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ball-mill-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ball-mill-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["battery-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["belt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="belt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-reactor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-reactor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-sample01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-sample01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["biomass-auog"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-auog-food-01"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-auog-pup"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-pup", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-blood"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="blood", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-bonemeal"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bonemeal", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-bones"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bones", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-caged-auog"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="caged-auog", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-cottongut"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cottongut-food-01"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cottongut-mk01"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-mk01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cottongut-pup"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-pup", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-fawogae"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae", amount=20},
      },
      results = {
        {type="item", name="biomass", amount=60},
      },
    },
    ["biomass-fertilizer"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-fish"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fish", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-fish-egg"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fish-egg", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=4},
      },
    },
    ["biomass-manure"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="manure", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=80},
      },
    },
    ["biomass-mukmoux-fat"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-phytoplankton"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
      },
      results = {
        {type="item", name="biomass", amount=45},
      },
    },
    ["biomass-ralesia"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=2},
      },
    },
    ["biomass-ralesia-seeds"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=4},
      },
    },
    ["biomass-skin"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="skin", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-urea"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-vrauks-food-01"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-vrauks-mk02"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["black-liquor-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="black-liquor", amount=20000},
      },
      results = {
      },
    },
    ["blade-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="blade-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["blood-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="blood", amount=20000},
      },
      results = {
      },
    },
    ["bof-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bof-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bonemeal-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bonemeal", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bones-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="bones", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["borax-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="borax", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["boric-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="boric-acid", amount=20000},
      },
      results = {
      },
    },
    ["boron-trioxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="boron-trioxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["brake-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["caged-auog-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="caged-auog", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cargo-wagon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cargo-wagon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["casting-unit-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="casting-unit-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cdna-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cdna", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["centrifuge-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="centrifuge-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chemical-plant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="chemical-plant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chromite-sand-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="chromite-sand", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chromium-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["classifier-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="classifier", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["clean-nexelit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="clean-nexelit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["coarse-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="coarse", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cocoon-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["coke-oven-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=20000},
      },
      results = {
      },
    },
    ["compost-plant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="compost-plant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["concrete-wall-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete-wall", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["constant-combinator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="constant-combinator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["controler-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="controler-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cooling-tower-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cooling-tower-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-pup-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-pup-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-pup-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut-pup", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cracker-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="cracker-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crushed-quartz-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="crushed-quartz", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cyanic-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=20000},
      },
      results = {
      },
    },
    ["decider-combinator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="decider-combinator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["depolymerized-organics-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="depolymerized-organics", amount=20000},
      },
      results = {
      },
    },
    ["diborane-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="diborane", amount=20000},
      },
      results = {
      },
    },
    ["digosaurus-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="digosaurus", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["dino-dig-site-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="dino-dig-site", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["display-panel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="display-panel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["eaf-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="eaf-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-bear-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="earth-bear-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-flower-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="earth-flower-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-mouse-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="earth-mouse-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-shroom-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="earth-shroom-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electric-mining-drill-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electronics-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="electronics-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["equipment-chassi-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="equipment-chassi", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fawogae-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fawogae-plantation-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae-plantation-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fawogae-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fawogae", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fbreactor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fbreactor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fenxsb-alloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fertilizer-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fiberboard-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-egg-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fish-egg", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-farm-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fish-farm-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="fish-oil", amount=20000},
      },
      results = {
      },
    },
    ["fish-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fish", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flotation-cell-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="flotation-cell-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fluid-drill-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fluid-drill-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fluid-wagon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="fluid-wagon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gas-refinery-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="gas-refinery-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gearbox-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="gearbox-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["generator-1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="generator-1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["geothermal-plant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="geothermal-plant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-chromite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-lead-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-lead", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-nickel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-nickel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-ti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-ti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-tin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-zinc-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-ti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-ti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-tin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-zinc-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-zinc", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-ti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-3-ti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grenade-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="grenade", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ground-sample01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ground-sample01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hawt-turbine-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="hawt-turbine-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["heavy-armor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="heavy-armor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["heavy-oil-refinery-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hot-air-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=20000},
      },
      results = {
      },
    },
    ["hot-molten-salt-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=20000},
      },
      results = {
      },
    },
    ["hydroclassifier-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="hydroclassifier-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["impact-crusher-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="impact-crusher-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["intermetallics-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="intermetallics", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lab-instrument-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="lab-instrument", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lens-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="lens", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["liquid-manure-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="liquid-manure", amount=20000},
      },
      results = {
      },
    },
    ["locomotive-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="locomotive", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["long-handed-inserter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="long-handed-inserter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["manure-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="manure", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mechanical-parts-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="mechanical-parts-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["medium-electric-pole-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="medium-electric-pole", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["melamine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="melamine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["melamine-resin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="melamine-resin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mixer-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="mixer-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molten-aluminium-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=20000},
      },
      results = {
      },
    },
    ["molten-iron-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-iron", amount=20000},
      },
      results = {
      },
    },
    ["molten-salt-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-salt", amount=20000},
      },
      results = {
      },
    },
    ["mukmoux-fat-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nacelle-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="nacelle-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nexelit-ore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="nexelit-ore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nexelit-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nickel-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="nickel-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["oil-boiler-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="oil-boiler-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pbsb-alloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pbsb-alloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["personal-roboport-equipment-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="personal-roboport-equipment", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["phytoplankton-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=20000},
      },
      results = {
      },
    },
    ["piercing-rounds-magazine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="piercing-rounds-magazine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["plankton-farm-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="plankton-farm", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["plasmids-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="plasmids", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["polybutadiene-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=20000},
      },
      results = {
      },
    },
    ["portable-gasoline-generator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="portable-gasoline-generator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["powdered-aluminium-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="powdered-aluminium", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["powdered-ralesia-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="powdered-ralesia-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["power-switch-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="power-switch", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["prandium-lab-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="prandium-lab-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pressured-steam-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=20000},
      },
      results = {
      },
    },
    ["programmable-speaker-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="programmable-speaker", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-asphalt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-asphalt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-biomass-powerplant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-burner-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-burner", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-coal-powerplant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-coal-powerplant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-construction-robot-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-construction-robot-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-deposit-basic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-deposit-basic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-electric-boiler-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-electric-boiler", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-heat-exchanger-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-heat-exchanger", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-iron-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-iron-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-limestone-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-limestone", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-oil-powerplant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-oil-powerplant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-recharge-station-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-roboport-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-roboport-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-shed-basic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-shed-basic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-storehouse-basic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-storehouse-basic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-warehouse-basic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-warehouse-basic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-ze-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="py-ze", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pyphoon-bay-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="pyphoon-bay", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rail-chain-signal-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rail-chain-signal", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rail-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rail", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rail-signal-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rail-signal", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-plantation-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rectisol-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rectisol", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["retrovirus-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rhe-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rhe", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rotor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rotor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rubber-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="rubber", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["salt-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="salt-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sand-casting-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-grade-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-grade-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-grade-03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-grade-04-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-04", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["scrubber-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="scrubber-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["secondary-crusher-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="secondary-crusher-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["selector-combinator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="selector-combinator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["shaft-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="shaft-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["skin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="skin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["solidified-sarcorus-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="solidified-sarcorus", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["spore-collector-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="spore-collector-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["starch-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steam-turbine-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="steam-turbine-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steel-furnace-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="steel-furnace", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["storage-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="storage-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["subcritical-water-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=20000},
      },
      results = {
      },
    },
    ["tall-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="tall-oil", amount=20000},
      },
      results = {
      },
    },
    ["ti-rejects-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="ti-rejects", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tidal-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tidal-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tower-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="tower-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["train-stop-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="train-stop", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["upgrader-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="upgrader-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["urea-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["utility-box-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="utility-box-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vane-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vawt-turbine-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vawt-turbine-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vitreloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vrauks-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vrauks-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="vrauks-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["warm-stone-brick-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="warm-stone-brick", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["waste-water-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="waste-water", amount=20000},
      },
      results = {
      },
    },
    ["waste-water-void"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="chlorine", amount=10},
        {type="fluid", name="waste-water", amount=50},
      },
      results = {
        {type="fluid", name="water", amount=50},
      },
    },
    ["wood-fence-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="wood-fence", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["workers-food-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="workers-food", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaw-drive-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="item", name="yaw-drive-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zogna-bacteria-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 2,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=20000},
      },
      results = {
      },
    },
    ["barrel-milk"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=1},
      },
    },
    ["empty-gas-canister"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="copper-plate", amount=1},
      },
      results = {
        {type="item", name="empty-gas-canister", amount=1},
      },
    },
    ["ore-nickel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="ore-nickel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-quartz-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="ore-quartz", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["salt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="salt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["active-provider-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fiberboard", amount=11.1264968438},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="active-provider-chest", amount=1},
      },
    },
    ["buffer-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="inductor1", amount=22.2670891621},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="buffer-chest", amount=1},
      },
    },
    ["passive-provider-chest"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="inductor1", amount=22.2670891621},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="passive-provider-chest", amount=1},
      },
    },
    ["requester-chest"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="requester-chest", amount=1},
      },
    },
    ["aromatic-organic"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="fawogae", amount=20},
        {type="item", name="ralesia", amount=5},
      },
      results = {
        {type="fluid", name="aromatics", amount=200},
      },
    },
    ["ash-bone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="mukmoux-fat", amount=2.06316313417},
      },
      results = {
        {type="item", name="ash", amount=4},
      },
    },
    ["ash3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="flue-gas", amount=100},
      },
      results = {
        {type="item", name="ash", amount=2},
      },
    },
    ["grade-3-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-1-tin", amount=2},
      },
      results = {
        {type="item", name="grade-3-tin", amount=1},
        {type="item", name="tin-ore-rejects", amount=0.5},
      },
    },
    ["tin-ore-rejects"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-tin", amount=2.05477002135},
      },
      results = {
        {type="item", name="grade-1-tin", amount=0.5},
      },
    },
    ["wash-grade-3-tin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="grade-2-tin", amount=1.11266578519},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="item", name="grade-4-tin", amount=1},
      },
    },
    ["ball-grade-4-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-4-tin", amount=1},
      },
      results = {
        {type="item", name="tin-dust", amount=1},
      },
    },
    ["tin-plate-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-1-tin", amount=11.0393276689},
      },
      results = {
        {type="item", name="tin-plate", amount=8},
      },
    },
    ["molten-tin-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="borax", amount=4},
        {type="item", name="graphite", amount=6},
        {type="item", name="tin-dust", amount=6},
      },
      results = {
        {type="fluid", name="molten-tin", amount=30},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-tin", amount=100},
        {type="fluid", name="water", amount=195},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=63},
      },
    },
    ["tin-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="distilator", amount=0.653117925465},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="lead-plate", amount=1.82349395995},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="steel-plate", amount=7.04129714426},
      },
      results = {
        {type="item", name="carbon-filter", amount=1},
      },
    },
    ["fts-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="concrete", amount=20},
        {type="item", name="copper-plate", amount=28.4009416978},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="glass", amount=10},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="fts-reactor", amount=1},
      },
    },
    ["methanol-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="copper-cable", amount=53.0828076487},
        {type="item", name="electronic-circuit", amount=25},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="iron-plate", amount=56.807714801},
        {type="item", name="steam-engine", amount=0.501013242105},
      },
      results = {
        {type="item", name="methanol-reactor", amount=1},
      },
    },
    ["fluid-separator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bolts", amount=75.3548258846},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="evaporator", amount=2.79375195981},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="pipe", amount=40},
        {type="item", name="storage-tank", amount=4},
      },
      results = {
        {type="item", name="fluid-separator", amount=1},
      },
    },
    ["chromite-rejects-processing"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="chromite-rejects", amount=3},
      },
      results = {
        {type="item", name="grade-3-chromite", amount=0.6},
      },
    },
    ["grade-4-chromite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=66.6666666667},
        {type="item", name="grade-2-chromite", amount=0.759238095238},
      },
      results = {
        {type="item", name="chromite-rejects", amount=4},
        {type="item", name="grade-4-chromite", amount=4},
      },
    },
    ["grade-3-chromite"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=2},
      },
      results = {
        {type="item", name="grade-2-chromite", amount=0.4},
        {type="item", name="grade-3-chromite", amount=1},
      },
    },
    ["tier-2-chromite-sand"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-4-chromite", amount=2},
      },
      results = {
        {type="item", name="chromite-sand", amount=12},
      },
    },
    ["grade-2-chromite-beneficiation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-chromite", amount=2.63421976919},
      },
      results = {
        {type="item", name="grade-1-chromite", amount=0.65},
        {type="item", name="gravel", amount=0.5},
      },
    },
    ["classify-iron-ore-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="iron-ore-dust", amount=3},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=50},
        {type="fluid", name="iron-slime", amount=50},
      },
    },
    ["grade-2-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="iron-ore", amount=12.6362268137},
      },
      results = {
        {type="item", name="grade-1-iron", amount=1},
        {type="item", name="grade-2-iron", amount=0.5},
        {type="item", name="grade-3-iron", amount=0.5},
      },
    },
    ["iron-slime"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=300},
        {type="item", name="chromium", amount=212.739083705},
      },
      results = {
        {type="fluid", name="iron-slime", amount=50},
      },
    },
    ["unslimed-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="iron-slime", amount=100},
        {type="fluid", name="steam", amount=66.6666666667},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["grade-2-crush"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-iron", amount=1},
      },
      results = {
        {type="item", name="grade-1-iron", amount=1},
        {type="item", name="gravel", amount=0.5},
      },
    },
    ["grade-3-iron-processing"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="grade-2-iron", amount=0.561441579252},
      },
      results = {
        {type="item", name="iron-ore-dust", amount=1},
      },
    },
    ["molten-iron-06"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="borax", amount=3},
        {type="item", name="unslimed-iron", amount=1},
      },
      results = {
        {type="fluid", name="molten-iron", amount=40},
      },
    },
    ["unslimed-iron-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="iron-pulp-01", amount=300},
        {type="fluid", name="steam", amount=66.6666666667},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["classify-low-grade"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="copper-rejects", amount=3.54385964912},
      },
      results = {
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="grade-4-copper", amount=0.3},
      },
    },
    ["copper-rejects-recrush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-copper", amount=2.57291666667},
      },
      results = {
        {type="item", name="grade-3-copper", amount=0.5},
        {type="item", name="gravel", amount=1},
      },
    },
    ["grade-3-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-copper", amount=2},
      },
      results = {
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="grade-3-copper", amount=1},
      },
    },
    ["grade-4-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-copper", amount=2},
      },
      results = {
        {type="item", name="grade-4-copper", amount=1},
        {type="item", name="low-grade-rejects", amount=2},
      },
    },
    ["hotair-copper-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-copper", amount=100},
        {type="item", name="sand", amount=10.3893307659},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=75},
      },
    },
    ["wash-coper-low-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="copper-rejects", amount=3.74628879892},
      },
      results = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="low-grade-copper", amount=1},
      },
    },
    ["copper-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-copper", amount=100},
        {type="item", name="chromium", amount=2.86158116127},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=60},
      },
    },
    ["low-grade-smelting-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="copper-rejects", amount=4.05668016194},
      },
      results = {
        {type="item", name="copper-plate", amount=0.6},
      },
    },
    ["molten-copper-04"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="borax", amount=3},
        {type="item", name="grade-2-copper", amount=12.5724637681},
      },
      results = {
        {type="fluid", name="molten-copper", amount=21},
      },
    },
    ["coalbed-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6.52896987186},
        {type="item", name="assembling-machine-1", amount=1.03927066356},
        {type="item", name="concrete", amount=55.9307299611},
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="evaporator", amount=1.39687597991},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="small-parts-01", amount=20},
      },
      results = {
        {type="item", name="coalbed-mk01", amount=1},
      },
    },
    ["lor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bolts", amount=50.2365505897},
        {type="item", name="distilator", amount=1.30623585093},
        {type="item", name="duralumin", amount=10},
        {type="item", name="inductor1", amount=222.670891621},
        {type="item", name="intermetallics", amount=15},
        {type="item", name="iron-plate", amount=85.2115722014},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="pipe", amount=30},
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
      results = {
        {type="item", name="lor-mk01", amount=1},
      },
    },
    ["natural-gas-derrick-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="inductor1", amount=37.1118152701},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="pipe", amount=10},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="titanium-plate", amount=20.0814673858},
      },
      results = {
        {type="item", name="natural-gas-derrick-mk01", amount=1},
      },
    },
    ["oil-derrick-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="concrete", amount=9.82857854644},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="pbsb-alloy", amount=14.6662672684},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="vacuum-tube", amount=1.59684077577},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=1},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=9.85965758678},
        {type="item", name="evaporator", amount=0.678940681448},
        {type="item", name="lead-plate", amount=15},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="oil-sand-extractor-mk01", amount=1},
      },
    },
    ["pumpjack-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="duralumin", amount=29.1624221026},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="offshore-pump", amount=1.36712009321},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="pumpjack-mk01", amount=1},
      },
    },
    ["tar-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="chromium", amount=5},
        {type="item", name="concrete", amount=19.6571570929},
        {type="item", name="fluid-drill-mk01", amount=0.795498186383},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="py-check-valve", amount=17.8972928119},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="titanium-plate", amount=19.3367319619},
      },
      results = {
        {type="item", name="tar-extractor-mk01", amount=1},
      },
    },
    ["coarse-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="crushed-coal", amount=2},
      },
      results = {
        {type="item", name="coal", amount=4},
        {type="item", name="coal-dust", amount=0.3},
        {type="item", name="coarse-coal", amount=1},
      },
    },
    ["coarse-coal-to-coal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="crushed-coal", amount=7.33999716061},
      },
      results = {
        {type="item", name="coal", amount=4},
      },
    },
    ["cog-void-soot"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="duralumin", amount=30},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=31.0290281306},
        {type="item", name="ore-tin", amount=567.094184744},
        {type="item", name="plastic-bar", amount=20},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="tin-plate", amount=25.1911459317},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=1},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="engine-unit", amount=4.92982879339},
        {type="item", name="formica", amount=51.9629308586},
        {type="item", name="glass", amount=30},
        {type="item", name="iron-plate", amount=71.0096435012},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=1},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=37.705283998},
        {type="item", name="duralumin", amount=100},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="small-parts-01", amount=8.77934198242},
        {type="item", name="soil", amount=65.3846153846},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=30},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="duralumin", amount=50},
        {type="item", name="engine-unit", amount=4.92982879339},
        {type="item", name="glass", amount=20},
        {type="item", name="pipe", amount=85.0812473529},
        {type="item", name="pump", amount=5},
        {type="item", name="sand", amount=9474.43330163},
        {type="item", name="small-parts-01", amount=119.099514285},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="yaedols-culture-mk01", amount=1},
      },
    },
    ["crawdad"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="fish-oil", amount=262.854646379},
        {type="fluid", name="oxygen", amount=569.43462161},
        {type="item", name="bio-sample", amount=50},
        {type="item", name="earth-bear-sample", amount=2.49502397762},
        {type="item", name="heavy-armor", amount=1},
        {type="item", name="py-shed-basic", amount=1},
        {type="item", name="treated-wood", amount=42.2736993803},
        {type="item", name="utility-box-mk01", amount=29.8773085543},
        {type="item", name="vacuum-barrel", amount=342.40941619},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="crawdad", amount=1},
      },
    },
    ["sponge-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=12.5184808337},
        {type="item", name="copper-cable", amount=70.7770768649},
        {type="item", name="duralumin", amount=50},
        {type="item", name="gasoline-barrel", amount=6.15528469115},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="tin-plate", amount=125.955729659},
        {type="item", name="titanium-plate", amount=15},
        {type="item", name="vacuum-tube", amount=48.417311037},
      },
      results = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
    },
    ["crushing-molybdenite"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="molybdenum-ore", amount=10},
      },
      results = {
        {type="item", name="crushed-molybdenite", amount=5},
        {type="item", name="stone", amount=2},
      },
    },
    ["duralumin-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="fluid", name="molten-copper", amount=100},
        {type="item", name="sand-casting", amount=4},
      },
      results = {
        {type="item", name="duralumin", amount=20},
      },
    },
    ["sncr-alloy"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="chromium", amount=3},
        {type="item", name="tin-plate", amount=4},
      },
      results = {
        {type="item", name="sncr-alloy", amount=2},
      },
    },
    ["empty-comb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="creosote", amount=30},
        {type="item", name="ash", amount=5},
        {type="item", name="chromium", amount=1.78668346576},
        {type="item", name="gravel", amount=49.4439907013},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="item", name="empty-comb", amount=7},
      },
    },
    ["fish-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="brain", amount=0.773080551602},
        {type="item", name="chitin", amount=0.984222215523},
        {type="item", name="fawogae", amount=10},
        {type="item", name="fish", amount=2},
        {type="item", name="guts", amount=9.97215056975},
        {type="item", name="limestone", amount=5.04523268963},
        {type="item", name="moss", amount=6.01504337538},
        {type="item", name="plastic-bar", amount=6},
      },
      results = {
        {type="item", name="fish-food-01", amount=3},
      },
    },
    ["flask-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-glass", amount=120},
        {type="item", name="boron-trioxide", amount=5},
        {type="item", name="petri-dish", amount=1.12494116169},
      },
      results = {
        {type="item", name="flask", amount=4},
      },
    },
    ["hotair-flask-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-glass", amount=120},
        {type="fluid", name="water", amount=195},
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
      ingredients = {
        {type="item", name="grade-2-lead", amount=2},
      },
      results = {
        {type="item", name="grade-1-lead", amount=0.5},
        {type="item", name="grade-3-lead", amount=1},
      },
    },
    ["grade-2-crush-lead"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-lead", amount=1.90625},
      },
      results = {
        {type="item", name="lead-dust", amount=1},
      },
    },
    ["molten-lead-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="borax", amount=2},
        {type="item", name="graphite", amount=2},
        {type="item", name="lead-dust", amount=4},
      },
      results = {
        {type="fluid", name="molten-lead", amount=90},
      },
    },
    ["hotair-lead-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-lead", amount=100},
        {type="fluid", name="water", amount=195},
        {type="item", name="lime", amount=1.45067308702},
      },
      results = {
        {type="item", name="lead-plate", amount=63},
      },
    },
    ["lead-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-lead", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="lead-plate", amount=50},
      },
    },
    ["grade-3-zinc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="grade-1-zinc", amount=5.41582840305},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=50},
        {type="item", name="grade-3-zinc", amount=5},
      },
    },
    ["molten-zinc-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
        {type="item", name="coke", amount=4.17609975054},
        {type="item", name="grade-2-zinc", amount=4.2390832729},
      },
      results = {
        {type="fluid", name="molten-zinc", amount=20},
      },
    },
    ["zinc-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-zinc", amount=100},
        {type="item", name="borax", amount=2},
        {type="item", name="lime", amount=1.45067308702},
      },
      results = {
        {type="item", name="zinc-plate", amount=50},
      },
    },
    ["hotair-zinc-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-zinc", amount=100},
        {type="item", name="lime", amount=1.16235463982},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=63},
      },
    },
    ["molten-solder-0"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-lead", amount=20},
        {type="fluid", name="molten-tin", amount=10},
      },
      results = {
        {type="fluid", name="molten-solder", amount=20},
      },
    },
    ["molten-solder-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-lead", amount=20},
        {type="fluid", name="molten-tin", amount=10},
        {type="fluid", name="vacuum", amount=328},
      },
      results = {
        {type="fluid", name="molten-solder", amount=40},
      },
    },
    ["solder"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-solder", amount=50},
      },
      results = {
        {type="item", name="solder", amount=5},
      },
    },
    ["hotair-solder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-solder", amount=50},
        {type="fluid", name="water", amount=195},
      },
      results = {
        {type="item", name="solder", amount=7},
      },
    },
    ["molten-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="molten-iron", amount=50},
        {type="item", name="coke", amount=10},
      },
      results = {
        {type="fluid", name="flue-gas", amount=500},
        {type="fluid", name="molten-steel", amount=50},
      },
    },
    ["hotair-steel-20"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-steel", amount=100},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="steel-plate", amount=32},
      },
    },
    ["steel-20"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-steel", amount=100},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="steel-plate", amount=25},
      },
    },
    ["kicalk-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="kicalk-codex", amount=1},
      },
    },
    ["tuuphra-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=371.118152701},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="tuuphra-codex", amount=1},
      },
    },
    ["yaedols-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="yaedols-codex", amount=1},
      },
    },
    ["sea-sponge-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="sea-sponge-codex", amount=1},
      },
    },
    ["lard-from-brains"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="brain", amount=10},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=10},
      },
    },
    ["leaching-station-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="concrete", amount=9.82857854644},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="fluid-drill-mk01", amount=0.795498186383},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="py-tank-5000", amount=3},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="stone-brick", amount=17.6922305625},
      },
      results = {
        {type="item", name="leaching-station-mk01", amount=1},
      },
    },
    ["wet-scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=0.795498186383},
        {type="item", name="inductor1", amount=37.1118152701},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="nexelit-plate", amount=10.9198079931},
        {type="item", name="pipe", amount=10},
        {type="item", name="py-tank-5000", amount=1},
        {type="item", name="steel-plate", amount=15},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=150},
        {type="item", name="copper-plate", amount=3},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=150},
      },
    },
    ["formamide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="methanol", amount=100},
        {type="fluid", name="oxygen", amount=353.899773021},
      },
      results = {
        {type="fluid", name="formamide", amount=100},
        {type="fluid", name="methanol", amount=100},
      },
    },
    ["military-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=1},
        {type="item", name="piercing-rounds-magazine", amount=1},
        {type="item", name="stone-wall", amount=2},
        {type="item", name="titanium-plate", amount=25.7823092826},
      },
      results = {
        {type="item", name="military-science-pack", amount=2},
      },
    },
    ["niobium-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=5},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="fluid-drill-mk01", amount=2.27230679534},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="niobium-mine", amount=1},
      },
    },
    ["nxsb-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=93.5672619898},
        {type="item", name="nexelit-plate", amount=10},
      },
      results = {
        {type="item", name="nxsb-alloy", amount=3},
      },
    },
    ["pbsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-lead", amount=50},
        {type="item", name="bio-sample", amount=3.21121637463},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=5},
      },
    },
    ["powdered-phosphate-rock"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="phosphate-rock", amount=10},
      },
      results = {
        {type="item", name="powdered-phosphate-rock", amount=5},
        {type="item", name="stone", amount=5},
      },
    },
    ["stone-wool"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=120},
        {type="item", name="coke", amount=3},
        {type="item", name="stone", amount=10},
      },
      results = {
        {type="item", name="stone-wool", amount=1},
      },
    },
    ["stone-wool2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="creosote", amount=60},
        {type="item", name="chromium", amount=1.57457505396},
        {type="item", name="gravel", amount=10},
      },
      results = {
        {type="item", name="stone-wool", amount=1},
      },
    },
    ["zipir-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="ceramic", amount=8.53956521146},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=4},
        {type="item", name="small-lamp", amount=2},
      },
      results = {
        {type="item", name="zipir-codex", amount=2},
      },
    },
    ["zipir-eggs-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=60},
        {type="fluid", name="water-saline", amount=748.403145287},
        {type="item", name="fawogae-substrate", amount=3.0438257126},
        {type="item", name="fish", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=200},
        {type="item", name="zipir-eggs", amount=4},
      },
    },
    ["zipir-reef-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=29.7143336616},
        {type="item", name="glass", amount=13.1795775148},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="small-parts-01", amount=213.806221551},
        {type="item", name="spore-collector-mk01", amount=1},
        {type="item", name="steel-plate", amount=100},
      },
      results = {
        {type="item", name="zipir-reef-mk01", amount=1},
      },
    },
    ["zipir-a-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=300},
        {type="fluid", name="steam", amount=66.6666666667},
        {type="item", name="fawogae-substrate", amount=10},
        {type="item", name="fish", amount=3},
        {type="item", name="stone-wool", amount=3},
        {type="item", name="zipir-eggs", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="zipir1", amount=0.8},
      },
    },
    ["full-render-zipir"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="zipir1", amount=1},
      },
      results = {
        {type="fluid", name="arthropod-blood", amount=65},
        {type="item", name="brain", amount=1},
        {type="item", name="guts", amount=4},
        {type="item", name="meat", amount=4},
        {type="item", name="mukmoux-fat", amount=3},
        {type="item", name="skin", amount=6},
      },
    },
    ["zipir-a-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="vacuum", amount=280},
        {type="fluid", name="water", amount=200},
        {type="item", name="fish", amount=3},
        {type="item", name="stone-wool", amount=3},
        {type="item", name="zipir-eggs", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="zipir1", amount=0.7},
      },
    },
    ["arthropod-blood-to-blood"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=30},
        {type="item", name="grade-1-iron", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=30},
        {type="item", name="grade-1-copper", amount=1},
      },
    },
    ["py-gas-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bolts", amount=2511.82752949},
        {type="item", name="concrete", amount=196.571570929},
        {type="item", name="copper-plate", amount=400},
        {type="item", name="distilator", amount=5},
        {type="item", name="electronic-circuit", amount=100},
        {type="item", name="engine-unit", amount=49.2982879339},
        {type="item", name="fluid-drill-mk01", amount=8.65923542003},
        {type="item", name="iron-plate", amount=200},
        {type="item", name="mechanical-parts-01", amount=3},
      },
      results = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
    },
    ["ree-mining-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=7.34396420615},
        {type="item", name="intermetallics", amount=3.9084409262},
        {type="item", name="nexelit-plate", amount=21.8396159862},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="ree-mining-drill-mk01", amount=1},
      },
    },
    ["pyrite-make"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="sand", amount=6.74074737752},
      },
      results = {
        {type="item", name="pyrite", amount=1},
      },
    },
    ["rich-clay-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="item", name="small-lamp", amount=2.16325921549},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="iron-oxide", amount=33.5920427935},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="ore-aluminium", amount=10},
      },
    },
    ["soot-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="copper-ore", amount=8},
      },
    },
    ["soot-to-gold"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="gold-plate", amount=0.5},
      },
    },
    ["soot-to-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="soot", amount=10},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["soot-to-silver"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bolts", amount=105.049521964},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="silver-plate", amount=0.3},
      },
    },
    ["soot-to-zinc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="sncr-alloy", amount=11.8606100177},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="ore-zinc", amount=8},
      },
    },
    ["tailings-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="tailings-dust", amount=15},
      },
      results = {
        {type="item", name="coal-dust", amount=5},
        {type="item", name="rich-dust", amount=2},
      },
    },
    ["richdust-separation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="tailings-dust", amount=9.3745472922},
      },
      results = {
        {type="item", name="chromite-sand", amount=3},
        {type="item", name="iron-oxide", amount=2},
      },
    },
    ["soot-to-lead"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="tailings-dust", amount=40.454218778},
      },
      results = {
        {type="item", name="ash", amount=0.3},
        {type="item", name="ore-lead", amount=8},
      },
    },
    ["fetal-serum-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="brain", amount=3.8547712232},
        {type="item", name="flask", amount=1},
        {type="item", name="silver-plate", amount=2},
      },
      results = {
        {type="fluid", name="fetal-serum", amount=50},
      },
    },
    ["salt-ex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water-saline", amount=230},
      },
      results = {
        {type="item", name="salt", amount=23},
      },
    },
    ["sand-washing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=66.6666666667},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=80},
        {type="item", name="pure-sand", amount=8},
      },
    },
    ["acetic-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="acetone", amount=100},
        {type="fluid", name="oxygen", amount=99.7420688157},
      },
      results = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="organic-solvent", amount=100},
      },
    },
    ["phosphorous-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=80},
        {type="item", name="ash", amount=4},
        {type="item", name="powdered-phosphate-rock", amount=5},
        {type="item", name="pure-sand", amount=20},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=50},
      },
    },
    ["tall-oil-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tar", amount=120},
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
      ingredients = {
        {type="item", name="chromium", amount=2.6242917566},
        {type="item", name="iron-plate", amount=6.00061597309},
      },
      results = {
        {type="fluid", name="ammonia", amount=20},
        {type="fluid", name="tall-oil", amount=20},
        {type="fluid", name="tar", amount=30},
      },
    },
    ["methane-py-fertilizer"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=80},
      },
    },
    ["phosphoric-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=1338.84849282},
        {type="fluid", name="steam", amount=120},
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="fluid", name="hydrofluoric-acid", amount=10},
        {type="fluid", name="phosphine-gas", amount=10},
        {type="fluid", name="phosphoric-acid", amount=20},
      },
    },
    ["propene"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="syngas", amount=60},
        {type="item", name="lead-plate", amount=4},
      },
      results = {
        {type="fluid", name="propene", amount=60},
        {type="fluid", name="water", amount=50},
      },
    },
    ["phosphoric-acid2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phosphine-gas", amount=50},
      },
      results = {
        {type="fluid", name="phosphoric-acid", amount=40},
      },
    },
    ["al-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phosphoric-acid", amount=30},
        {type="fluid", name="water", amount=100},
        {type="item", name="boron-trioxide", amount=2.39234466682},
        {type="item", name="powdered-aluminium", amount=5},
      },
      results = {
        {type="fluid", name="al-pulp-01", amount=100},
      },
    },
    ["al-pulp-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=100},
        {type="fluid", name="steam", amount=300},
      },
      results = {
        {type="fluid", name="al-pulp-02", amount=100},
      },
    },
    ["molten-aluminium-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="al-pulp-02", amount=100},
        {type="item", name="graphite", amount=3},
        {type="item", name="sand", amount=10.3893307659},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=50},
      },
    },
    ["fluorine-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrofluoric-acid", amount=100},
        {type="item", name="sodium-hydroxide", amount=10},
      },
      results = {
        {type="fluid", name="fluorine-gas", amount=50},
        {type="fluid", name="hydrogen", amount=50},
      },
    },
    ["syngas-distilation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=150},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="fluid", name="hydrogen", amount=100},
      },
    },
    ["gas-molten-salt-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrofluoric-acid", amount=1525.58117477},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["wastewater-recovery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2640.84822482},
        {type="item", name="lime", amount=3.61646862237},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=150},
      },
    },
    ["glass-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="lime", amount=3.61646862237},
        {type="item", name="powdered-quartz", amount=2},
      },
      results = {
        {type="fluid", name="molten-glass", amount=50},
      },
    },
    ["powdered-quartz"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="crushed-quartz", amount=5},
      },
      results = {
        {type="item", name="gravel", amount=0.5},
        {type="item", name="powdered-quartz", amount=5},
      },
    },
    ["seaweed-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=161.699432513},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="item", name="seaweed", amount=20},
      },
    },
    ["silver-plate-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="lead-dust", amount=27},
      },
      results = {
        {type="item", name="silver-plate", amount=9},
      },
    },
    ["sulfur-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="cdna", amount=1.33090271968},
        {type="item", name="electric-mining-drill", amount=5},
        {type="item", name="engine-unit", amount=9.85965758678},
        {type="item", name="soil-extractor-mk01", amount=1.34577064998},
        {type="item", name="steam-engine", amount=28.9966204271},
        {type="item", name="titanium-plate", amount=124.243918708},
      },
      results = {
        {type="item", name="sulfur-mine", amount=1},
      },
    },
    ["albumin-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="fish-oil", amount=438.091077299},
      },
      results = {
        {type="item", name="albumin", amount=5},
      },
    },
    ["formaldehyde-from-refined-natural-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=30},
        {type="fluid", name="pressured-air", amount=100},
        {type="fluid", name="refined-natural-gas", amount=100},
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
      ingredients = {
        {type="item", name="biomass", amount=20},
      },
      results = {
        {type="item", name="powdered-biomass", amount=20},
      },
    },
    ["sugar"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="sweet-syrup", amount=100},
        {type="item", name="bones", amount=3},
      },
      results = {
        {type="item", name="sugar", amount=10},
      },
    },
    ["waste-water-urea"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="powdered-biomass", amount=30},
      },
      results = {
        {type="item", name="biomass", amount=0.6},
        {type="item", name="fine-powdered-biomass", amount=18},
        {type="item", name="powdered-biomass", amount=1.2},
      },
    },
    ["fungal-substrate"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=50},
        {type="item", name="biomass", amount=5},
        {type="item", name="log", amount=2},
      },
      results = {
        {type="item", name="fungal-substrate", amount=10},
      },
    },
    ["dried-biomass"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="fine-powdered-biomass", amount=30},
      },
      results = {
        {type="item", name="dried-biomass", amount=30},
      },
    },
    ["fungal-substrate-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=50},
        {type="item", name="biomass", amount=10},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="iron-plate", amount=11.1736657156},
        {type="item", name="mukmoux-fat", amount=2.06316313417},
        {type="item", name="stopper", amount=4.81042186872},
        {type="item", name="wood", amount=4},
      },
      results = {
        {type="item", name="fungal-substrate-02", amount=10},
      },
    },
    ["fiber"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="raw-fiber", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=6},
        {type="item", name="fiber", amount=5},
      },
    },
    ["micro-fiber"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="fiber", amount=4},
        {type="item", name="sodium-hydroxide", amount=3},
      },
      results = {
        {type="item", name="micro-fiber", amount=2},
      },
    },
    ["bitumen-to-nickel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="methane", amount=252.11365691},
        {type="fluid", name="propene", amount=50},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["grade-3-nickel"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-1-nickel", amount=2},
      },
      results = {
        {type="item", name="grade-2-nickel", amount=1},
        {type="item", name="grade-3-nickel", amount=0.5},
        {type="item", name="gravel", amount=1},
        {type="item", name="nickel-rejects", amount=1},
      },
    },
    ["grade-2-nickel-recrush"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-nickel", amount=1},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=0.5},
        {type="item", name="sand", amount=1},
      },
    },
    ["grade-4-nickel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-nickel", amount=1.76},
      },
      results = {
        {type="item", name="grade-4-nickel", amount=1},
      },
    },
    ["nickel-rejects-recrush"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="nickel-rejects", amount=3},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=0.5},
      },
    },
    ["molten-nickel-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="grade-3-nickel", amount=3.18595041322},
        {type="item", name="lime", amount=1.74353195973},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=50},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-nickel", amount=100},
        {type="item", name="limestone", amount=3.25877209394},
      },
      results = {
        {type="item", name="nickel-plate", amount=63},
      },
    },
    ["nickel-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-nickel", amount=100},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=50},
      },
    },
    ["tar-to-nickel"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="tar", amount=500},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["soda-ash"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=250},
        {type="fluid", name="water-saline", amount=250},
        {type="item", name="ash", amount=50},
      },
      results = {
        {type="fluid", name="soda-ash", amount=200},
      },
    },
    ["industrial-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=866.124613291},
        {type="fluid", name="pressured-steam", amount=4875.55344097},
        {type="fluid", name="syngas", amount=200},
      },
      results = {
        {type="fluid", name="industrial-solvent", amount=100},
      },
    },
    ["vanabins"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acidgas", amount=200},
        {type="fluid", name="arthropod-blood", amount=150},
      },
      results = {
        {type="fluid", name="vanabins", amount=100},
      },
    },
    ["blue-liquor"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="vanabins", amount=60},
        {type="fluid", name="water", amount=100},
        {type="item", name="tailings-dust", amount=30},
      },
      results = {
        {type="fluid", name="blue-liquor", amount=200},
      },
    },
    ["vpulp1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="blue-liquor", amount=100},
        {type="fluid", name="steam", amount=300},
      },
      results = {
        {type="fluid", name="vpulp1", amount=100},
      },
    },
    ["molybdenum-pulp"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="molybdenum-concentrate", amount=30},
      },
      results = {
        {type="fluid", name="molybdenum-pulp", amount=100},
        {type="fluid", name="muddy-sludge", amount=200},
      },
    },
    ["vpulp2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="vpulp1", amount=200},
        {type="item", name="iron-oxide", amount=15},
      },
      results = {
        {type="fluid", name="vpulp2", amount=100},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="molybdenite-dust", amount=20},
      },
      results = {
        {type="fluid", name="molybdenite-pulp", amount=100},
      },
    },
    ["vpulp3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="vpulp2", amount=100},
      },
      results = {
        {type="fluid", name="vpulp3", amount=50},
        {type="item", name="vanadium-oxide", amount=2},
      },
    },
    ["bitumen-to-asphalt"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=10},
        {type="fluid", name="bitumen", amount=10},
        {type="item", name="gravel", amount=2},
      },
      results = {
        {type="item", name="py-asphalt", amount=2},
      },
    },
    ["py-aluminium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="graphite", amount=1},
        {type="item", name="sodium-hydroxide", amount=2.71435094478},
        {type="item", name="solder", amount=1},
      },
      results = {
        {type="item", name="py-aluminium", amount=1},
      },
    },
    ["py-coal-tile"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=170.80622696},
        {type="item", name="ash", amount=2},
        {type="item", name="tailings-dust", amount=10},
      },
      results = {
        {type="item", name="py-coal-tile", amount=1},
      },
    },
    ["py-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=5},
        {type="item", name="iron-plate", amount=4},
        {type="item", name="iron-stick", amount=1},
      },
      results = {
        {type="item", name="py-iron", amount=2},
      },
    },
    ["py-nexelit"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tar", amount=20},
        {type="item", name="nexelit-plate", amount=1},
        {type="item", name="resistor1", amount=1},
      },
      results = {
        {type="item", name="py-nexelit", amount=2},
      },
    },
    ["py-quartz"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=10},
        {type="item", name="gravel", amount=3.1011392288},
        {type="item", name="powdered-quartz", amount=1},
      },
      results = {
        {type="item", name="py-quartz", amount=2},
      },
    },
    ["py-steel"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="aromatics", amount=270.791882084},
        {type="fluid", name="hydrogen", amount=100},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="item", name="small-lamp", amount=0.5},
      },
    },
    ["methanol-void-denitrification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=206.280309645},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=100},
        {type="item", name="limestone", amount=6.09146273693},
      },
      results = {
        {type="fluid", name="nitrogen", amount=200},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=50},
      },
    },
    ["zinc-chloride"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="pressured-water", amount=414.893977135},
        {type="item", name="graphite", amount=2.61295705731},
        {type="item", name="mukmoux-fat", amount=2.53795547209},
        {type="item", name="rich-dust", amount=28.3208798415},
      },
      results = {
        {type="item", name="active-carbon", amount=5},
      },
    },
    ["co2-organics"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="chromium", amount=3},
        {type="item", name="copper-plate", amount=2.49974337089},
        {type="item", name="steel-plate", amount=8},
      },
      results = {
        {type="item", name="drill-head", amount=3},
      },
    },
    ["drill-head-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chromium", amount=3},
        {type="item", name="steam-engine", amount=0.559391009908},
        {type="item", name="tin-plate", amount=7.95644451361},
      },
      results = {
        {type="item", name="drill-head", amount=4},
      },
    },
    ["drill-head-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="pipe", amount=3.40324989412},
        {type="item", name="steel-plate", amount=8},
      },
      results = {
        {type="item", name="drill-head", amount=6},
      },
    },
    ["nichrome"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=372.340748711},
        {type="item", name="chromium", amount=8},
        {type="item", name="nickel-plate", amount=10},
      },
      results = {
        {type="item", name="nichrome", amount=1},
      },
    },
    ["evaporate-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=5},
      },
      results = {
        {type="fluid", name="nitrogen", amount=50},
      },
    },
    ["liquid-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="nitrogen", amount=50},
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1205.94115248},
        {type="fluid", name="coalbed-gas", amount=200},
        {type="item", name="active-carbon", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen", amount=300},
      },
    },
    ["drilling-fluid-0"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=309.215680122},
        {type="item", name="clay", amount=5},
        {type="item", name="sand", amount=5},
        {type="item", name="soil", amount=5},
      },
      results = {
        {type="fluid", name="drilling-fluid-0", amount=50},
      },
    },
    ["minor-extract-gas-from-coalbed-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=2500},
        {type="fluid", name="steam", amount=2125},
        {type="item", name="drill-head", amount=1},
      },
      results = {
        {type="fluid", name="coalbed-gas", amount=150},
        {type="fluid", name="water", amount=2500},
      },
    },
    ["pressured-hydrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hydrogen", amount=500},
        {type="fluid", name="water", amount=600},
      },
      results = {
        {type="fluid", name="pressured-hydrogen", amount=50},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["aromatics-2-diesel2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=1126.46208414},
        {type="fluid", name="water", amount=637.5},
        {type="item", name="coal-dust", amount=2.23878492002},
      },
      results = {
        {type="fluid", name="diesel", amount=300},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=200},
        {type="fluid", name="water", amount=1950},
        {type="item", name="active-carbon", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=300},
      },
    },
    ["coalbed-gas-to-coalgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=7148.49775244},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=400},
      },
    },
    ["coalbed-gas-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=200},
        {type="fluid", name="oxygen", amount=152.941176471},
        {type="item", name="active-carbon", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=200},
      },
    },
    ["natural-gas-to-syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1236.86272049},
        {type="fluid", name="syngas", amount=300},
        {type="item", name="alien-sample01", amount=0.912580073814},
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
      ingredients = {
        {type="fluid", name="light-oil", amount=150},
        {type="fluid", name="steam", amount=2299.73849917},
        {type="item", name="nichrome", amount=2},
      },
      results = {
        {type="fluid", name="olefin", amount=150},
        {type="fluid", name="petroleum-gas", amount=400},
      },
    },
    ["bone-solvent"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1236.86272049},
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
      ingredients = {
        {type="fluid", name="water", amount=2000},
        {type="item", name="nichrome", amount=1},
        {type="item", name="skin", amount=7.54168831973},
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
      ingredients = {
        {type="fluid", name="olefin", amount=100},
        {type="fluid", name="water-saline", amount=380.256389593},
      },
      results = {
        {type="fluid", name="methanol", amount=100},
        {type="fluid", name="petroleum-gas", amount=100},
      },
    },
    ["fish-oil-to-lube"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="fish-oil", amount=100},
        {type="item", name="ash", amount=5},
      },
      results = {
        {type="fluid", name="lubricant", amount=100},
      },
    },
    ["olefin-lube"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="olefin", amount=300},
        {type="fluid", name="oleochemicals", amount=100},
      },
      results = {
        {type="fluid", name="lubricant", amount=250},
      },
    },
    ["coal-slurry"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=250},
      },
      results = {
        {type="fluid", name="coal-slurry", amount=150},
        {type="fluid", name="water", amount=100},
      },
    },
    ["refsyngas-from-filtered-syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=100},
        {type="item", name="active-carbon", amount=1},
      },
      results = {
        {type="fluid", name="refsyngas", amount=70},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=3000},
        {type="item", name="sncr-alloy", amount=1.52390773139},
      },
      results = {
        {type="fluid", name="syngas", amount=300},
      },
    },
    ["hydrogen-peroxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=100},
        {type="item", name="sodium-hydroxide", amount=7.61748798719},
      },
      results = {
        {type="fluid", name="hydrogen-peroxide", amount=50},
      },
    },
    ["syngas2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coal-gas", amount=50},
        {type="fluid", name="oxygen", amount=60},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="syngas", amount=100},
        {type="fluid", name="tar", amount=30},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-slurry-fuel"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coal-slurry", amount=200},
      },
      results = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="benzene", amount=50},
      },
    },
    ["acidgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=217.005701769},
        {type="item", name="sulfur", amount=10},
      },
      results = {
        {type="fluid", name="acidgas", amount=150},
      },
    },
    ["acidgas-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=371.058816147},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="tar", amount=315.520627407},
      },
      results = {
        {type="fluid", name="acidgas", amount=30},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["pyrite-burn"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="pyrite", amount=5},
      },
      results = {
        {type="fluid", name="acidgas", amount=50},
        {type="item", name="iron-oxide", amount=12},
      },
    },
    ["log4"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="geothermal-water", amount=1134.48453608},
        {type="item", name="boron-trioxide", amount=1.61382136325},
      },
      results = {
        {type="item", name="log", amount=7},
      },
    },
    ["log6"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=350},
        {type="fluid", name="oxygen", amount=215.774509804},
        {type="item", name="ash", amount=30},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=8},
      },
    },
    ["wood-seedling-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=66.6666666667},
        {type="item", name="rich-clay", amount=4.28595458877},
        {type="item", name="sodium-hydroxide", amount=3.94652254972},
        {type="item", name="wood-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="moss-gen", amount=3},
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="wood-seeds", amount=0.5},
        {type="item", name="wood-seeds-mk02", amount=0.005},
      },
    },
    ["wood-seeds-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="tree-mk01", amount=6.01173185535},
      },
      results = {
        {type="item", name="wood-seeds-mk02", amount=5},
      },
    },
    ["tree-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="planter-box", amount=1},
        {type="item", name="wood-seedling-mk02", amount=3},
      },
      results = {
        {type="item", name="tree-mk02", amount=1},
      },
    },
    ["ulric"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=256.41025641},
        {type="item", name="alien-sample01", amount=4},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-horse-sample", amount=1},
        {type="item", name="vrauks-codex", amount=2.12316660269},
      },
      results = {
        {type="item", name="ulric", amount=1},
      },
    },
    ["ulric-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="ulric-codex", amount=1},
      },
    },
    ["ulric-corral-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=14.9511319273},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
    },
    ["ulric-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="ash", amount=10},
        {type="item", name="fawogae", amount=5},
        {type="item", name="native-flora", amount=10},
        {type="item", name="ralesia", amount=5},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood-seeds", amount=10},
      },
      results = {
        {type="item", name="ulric-food-01", amount=6},
      },
    },
    ["caged-ulric"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="cage", amount=1},
        {type="item", name="ulric", amount=1},
      },
      results = {
        {type="item", name="caged-ulric", amount=1},
      },
    },
    ["ulric-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fawogae", amount=3},
        {type="item", name="methanol-barrel", amount=8.46306826779},
        {type="item", name="ulric-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="ulric-cub", amount=3},
      },
    },
    ["ulric-manure-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="methanol-gas-canister", amount=1.52887648173},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=3},
      },
    },
    ["ulric-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="salt", amount=13.7129390104},
        {type="item", name="ulric-cub", amount=3},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="ulric", amount=3},
      },
    },
    ["uncaged-ulric"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="ulric-cub", amount=4.33746831835},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="ulric", amount=1},
      },
    },
    ["full-render-ulrics"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="caged-ulric", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=80},
        {type="item", name="bonemeal", amount=6},
        {type="item", name="brain", amount=1},
        {type="item", name="cage", amount=1},
        {type="item", name="guts", amount=3},
        {type="item", name="meat", amount=4},
        {type="item", name="mukmoux-fat", amount=2},
        {type="item", name="skin", amount=2},
      },
    },
    ["earth-cow-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=9.06932258817},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="moondrop-codex", amount=1.36132758514},
      },
      results = {
        {type="item", name="earth-cow-sample", amount=1},
      },
    },
    ["earth-crustacean-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="earth-cow-sample", amount=0.536363028034},
        {type="item", name="logistic-science-pack", amount=15},
        {type="item", name="zipir-codex", amount=1},
      },
      results = {
        {type="item", name="earth-crustacean-sample", amount=1},
      },
    },
    ["earth-palmtree-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=50},
        {type="item", name="mechanical-parts-01", amount=1.56575146244},
        {type="item", name="ulric-codex", amount=4.10355259667},
      },
      results = {
        {type="item", name="earth-palmtree-sample", amount=1},
      },
    },
    ["earth-potato-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=100},
        {type="item", name="tuuphra-codex", amount=1},
      },
      results = {
        {type="item", name="earth-potato-sample", amount=1},
      },
    },
    ["earth-sea-sponge-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="earth-sea-sponge-sample", amount=1},
      },
    },
    ["earth-bee-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-codex", amount=5},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=55.1309091874},
      },
      results = {
        {type="item", name="earth-bee-sample", amount=1},
      },
    },
    ["earth-horse-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-codex", amount=5},
        {type="item", name="automation-science-pack", amount=15},
        {type="item", name="utility-box-mk01", amount=3.11301071209},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=1},
      },
    },
    ["kicalk-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="animal-sample-01", amount=10.6682056444},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="earth-palmtree-sample", amount=1},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="planter-box", amount=1},
        {type="item", name="zinc-chloride", amount=19.6481088518},
      },
      results = {
        {type="item", name="kicalk", amount=1},
      },
    },
    ["kicalk-fiber"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="kicalk", amount=1},
      },
      results = {
        {type="item", name="raw-fiber", amount=5},
      },
    },
    ["kicalk-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="kicalk", amount=2},
      },
      results = {
        {type="item", name="kicalk-seeds", amount=5},
      },
    },
    ["kicalk-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="ceramic", amount=2.5930966695},
        {type="item", name="kicalk-seeds", amount=15},
      },
      results = {
        {type="item", name="kicalk", amount=10},
      },
    },
    ["kicalk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=166.666666667},
        {type="item", name="clay", amount=4},
        {type="item", name="kicalk-seeds", amount=15},
        {type="item", name="rich-clay", amount=2.21398073897},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=12},
      },
    },
    ["sea-sponge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="alien-sample01", amount=2},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-sea-sponge-sample", amount=1},
        {type="item", name="sea-sponge-codex", amount=1},
        {type="item", name="small-lamp", amount=28.5318002383},
      },
      results = {
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bonemeal", amount=8.59215258301},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
    },
    ["sea-sponge-processing-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="cocoon", amount=8.42626800142},
      },
      results = {
        {type="item", name="ore-quartz", amount=10},
      },
    },
    ["sea-sponge-sprouts-processing-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="item", name="ore-quartz", amount=7},
      },
    },
    ["arthropod-blood-to-organic-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="cumene", amount=20},
        {type="fluid", name="fish-oil", amount=233.726985735},
        {type="item", name="nickel-plate", amount=1},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=130},
      },
    },
    ["chloride-void-muddy-sludge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="chlorine", amount=50},
        {type="fluid", name="water", amount=100},
        {type="item", name="coke", amount=0.729335706049},
      },
      results = {
        {type="fluid", name="tailings", amount=50},
      },
    },
    ["coarse-tar"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="coal", amount=10},
        {type="item", name="coarse", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=70},
      },
    },
    ["cobalt-extract"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=150},
        {type="fluid", name="pressured-air", amount=450},
        {type="item", name="mixed-ores", amount=15},
      },
      results = {
        {type="fluid", name="tailings", amount=50},
        {type="item", name="cobalt-extract", amount=3},
      },
    },
    ["flue-gas-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="aromatics", amount=255.051216924},
        {type="fluid", name="hydrogen", amount=50},
        {type="fluid", name="light-oil", amount=200},
        {type="item", name="nexelit-plate", amount=2},
      },
      results = {
        {type="fluid", name="gasoline", amount=150},
      },
    },
    ["olefin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=200},
        {type="fluid", name="hydrogen", amount=400},
        {type="item", name="nickel-plate", amount=2.32647764853},
      },
      results = {
        {type="fluid", name="olefin", amount=200},
      },
    },
    ["sea-sponge-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="fluid", name="phytoplankton", amount=252.527620374},
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sulfuric-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=50},
        {type="item", name="sulfur", amount=5},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=50},
      },
    },
    ["wastewater-filtration"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=100},
      },
    },
    ["agitator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="distilator", amount=2.01894362915},
        {type="item", name="glass", amount=40},
        {type="item", name="inductor1", amount=148.447261081},
        {type="item", name="melamine", amount=30},
        {type="item", name="pipe", amount=68.3422517544},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="agitator-mk01", amount=1},
      },
    },
    ["centrifugal-pan-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=1.16406677372},
        {type="item", name="inductor1", amount=185.559076351},
        {type="item", name="niobium-pipe", amount=40},
        {type="item", name="pipe", amount=85.4278146929},
        {type="item", name="pump", amount=9.21165102843},
        {type="item", name="secondary-crusher-mk01", amount=1.07473515799},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="tailings-pond", amount=1},
        {type="item", name="titanium-plate", amount=20},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=1},
      },
    },
    ["compressor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chemical-plant-mk01", amount=0.715883166712},
        {type="item", name="duralumin", amount=7.33047622296},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="iron-plate", amount=85.2115722014},
        {type="item", name="nexelit-plate", amount=32.7594239793},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="titanium-plate", amount=20},
      },
      results = {
        {type="item", name="compressor-mk01", amount=1},
      },
    },
    ["gas-separator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=25.0369616675},
        {type="item", name="duralumin", amount=10.6619539157},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="evaporator", amount=1},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="nichrome", amount=30},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="tar-processing-unit", amount=7.08968097413},
      },
      results = {
        {type="item", name="gas-separator-mk01", amount=1},
      },
    },
    ["hydrocyclone-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="copper-cable", amount=106.165615297},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="niobium-pipe", amount=30},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="hydrocyclone-mk01", amount=1},
      },
    },
    ["thickener-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="boiler", amount=3.99191045649},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="pipe", amount=15},
        {type="item", name="small-lamp", amount=4},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="stone-brick", amount=91.2181039669},
      },
      results = {
        {type="item", name="thickener-mk01", amount=1},
      },
    },
    ["casein"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="casein-pulp-02", amount=100},
      },
      results = {
        {type="item", name="casein", amount=5},
      },
    },
    ["green-sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="coal-dust", amount=16.4506294692},
        {type="item", name="crushed-quartz", amount=8.33684210526},
        {type="item", name="graphite", amount=3},
      },
      results = {
        {type="item", name="green-sic", amount=4},
      },
    },
    ["mixed-ores"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="copper-ore", amount=8},
        {type="item", name="ore-chromium", amount=8},
        {type="item", name="rare-earth-ore", amount=4},
      },
      results = {
        {type="item", name="mixed-ores", amount=5},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="hot-air", amount=100},
        {type="item", name="cobalt-extract", amount=3},
        {type="item", name="reo", amount=3},
      },
      results = {
        {type="item", name="cobalt-fluoride", amount=3},
      },
    },
    ["quartz-tube"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="gunpowder", amount=24.5170611954},
        {type="item", name="ree-concentrate", amount=10.3706108461},
      },
      results = {
        {type="item", name="quartz-tube", amount=3},
      },
    },
    ["sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="empty-planter-box", amount=4.43708897664},
      },
      results = {
        {type="item", name="sic", amount=4},
      },
    },
    ["artificial-blood"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flutec-pp6", amount=100},
        {type="item", name="albumin", amount=10},
      },
      results = {
        {type="fluid", name="artificial-blood", amount=100},
      },
    },
    ["decalin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="syngas", amount=225.292416827},
        {type="item", name="glass", amount=4.12425751948},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="fluid", name="decalin", amount=50},
      },
    },
    ["flutec-pp6"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="decalin", amount=100},
        {type="item", name="cobalt-fluoride", amount=5},
      },
      results = {
        {type="fluid", name="flutec-pp6", amount=100},
      },
    },
    ["bio-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="nitrogen", amount=300},
        {type="item", name="cobalt-extract", amount=0.66966842535},
        {type="item", name="dried-biomass", amount=30},
        {type="item", name="quartz-tube", amount=1},
      },
      results = {
        {type="fluid", name="bio-oil", amount=300},
        {type="item", name="quartz-tube", amount=0.75},
      },
    },
    ["bio-oil-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="steam", amount=212.5},
        {type="fluid", name="water", amount=100},
        {type="item", name="moondrop-seeds", amount=7},
        {type="item", name="soil", amount=20},
      },
      results = {
        {type="item", name="moondrop", amount=8},
      },
    },
    ["moondrop-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="muddy-sludge", amount=181.743832069},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="moondrop", amount=2},
        {type="item", name="moondrop-seeds", amount=10},
        {type="item", name="soil", amount=100},
      },
      results = {
        {type="item", name="moondrop", amount=0.5},
        {type="item", name="moondrop-mk02", amount=0.005},
      },
    },
    ["moondrop-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="decalin", amount=50},
        {type="fluid", name="hydrogen", amount=400},
        {type="item", name="ash", amount=10},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="moondrop-seeds-mk02", amount=5},
      },
      results = {
        {type="item", name="moondrop-mk02", amount=5},
      },
    },
    ["oleochemicals-bioplastic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=406.617758082},
        {type="fluid", name="oleochemicals", amount=350},
      },
      results = {
        {type="item", name="plastic-bar", amount=10},
      },
    },
    ["plastic-from-casein"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="methanal", amount=100},
        {type="item", name="casein", amount=5},
      },
      results = {
        {type="item", name="plastic-bar", amount=20},
      },
    },
    ["plastic-from-melamine"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="melamine", amount=10},
      },
      results = {
        {type="item", name="plastic-bar", amount=5},
      },
    },
    ["zipir1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=100},
        {type="fluid", name="fish-oil", amount=660.147763012},
        {type="item", name="alien-sample01", amount=5},
        {type="item", name="cdna", amount=5},
        {type="item", name="fish", amount=10},
        {type="item", name="retrovirus", amount=4.99897296545},
        {type="item", name="tuuphra-codex", amount=1.30359446395},
        {type="item", name="zipir-codex", amount=2},
      },
      results = {
        {type="item", name="zipir1", amount=1},
      },
    },
    ["alien-sample-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=4159.70188221},
        {type="fluid", name="formamide", amount=100},
        {type="fluid", name="milk", amount=100},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="boron-trioxide", amount=4.4652265056},
        {type="item", name="micro-fiber", amount=5},
        {type="item", name="petri-dish", amount=0.939321074988},
        {type="item", name="plasmids", amount=1.34447114102},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="primers", amount=1},
      },
      results = {
        {type="item", name="alien-sample-02", amount=1},
      },
    },
    ["cytostatics"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="decalin", amount=30},
        {type="item", name="flask", amount=3},
        {type="item", name="nexelit-plate", amount=7.30716406921},
        {type="item", name="plasmids", amount=6},
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="cytostatics", amount=1},
      },
    },
    ["dna-polymerase"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=50},
        {type="item", name="cocoon", amount=10},
        {type="item", name="petri-dish", amount=0.939321074988},
        {type="item", name="petri-dish-bacteria", amount=3.82522659786},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="dna-polymerase", amount=1},
      },
    },
    ["manure-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="agar", amount=1},
        {type="item", name="cellulose", amount=9.10925730346},
        {type="item", name="petri-dish-bacteria", amount=0.739174571467},
      },
      results = {
        {type="fluid", name="manure-bacteria", amount=100},
      },
    },
    ["primers"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=80},
        {type="item", name="fawogae", amount=5},
        {type="item", name="petri-dish", amount=5.17499755202},
        {type="item", name="petri-dish-bacteria", amount=10},
        {type="item", name="saps", amount=5},
      },
      results = {
        {type="item", name="primers", amount=0.7},
      },
    },
    ["retrovirus-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=20},
        {type="item", name="cocoon", amount=4},
        {type="item", name="flask", amount=1},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="retrovirus", amount=3},
      },
    },
    ["cottongut-science-green-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=50},
        {type="fluid", name="subcritical-water", amount=200},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="cottongut", amount=40},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="flask", amount=3},
      },
      results = {
        {type="item", name="paragen", amount=3},
        {type="item", name="solidified-sarcorus", amount=5},
      },
    },
    ["gasoline-cellulose"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="methane", amount=550.159014421},
        {type="fluid", name="water", amount=1000},
        {type="item", name="cellulose", amount=5},
      },
      results = {
        {type="fluid", name="gasoline", amount=100},
      },
    },
    ["tuuphra-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="alien-sample01", amount=10},
        {type="item", name="arqad-codex", amount=4.10355259667},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-potato-sample", amount=1},
        {type="item", name="nexelit-plate", amount=44.6282324921},
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="tuuphra", amount=2},
      },
    },
    ["tuuphra-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="tuuphra", amount=2},
      },
      results = {
        {type="item", name="tuuphra-seeds", amount=8},
      },
    },
    ["tuuphra-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=50},
        {type="fluid", name="vacuum", amount=53.3333333333},
        {type="item", name="coarse", amount=10},
        {type="item", name="limestone", amount=7.64705882353},
        {type="item", name="tuuphra-seeds", amount=5},
      },
      results = {
        {type="item", name="tuuphra", amount=3},
      },
    },
    ["sweet-syrup"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="a-molasse", amount=100},
        {type="item", name="boron-trioxide", amount=1.19617233341},
      },
      results = {
        {type="fluid", name="sweet-syrup", amount=50},
      },
    },
    ["a-molasse"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="tuuphra-seeds", amount=37.2368729896},
      },
      results = {
        {type="fluid", name="a-molasse", amount=100},
        {type="item", name="biomass", amount=8},
      },
    },
    ["korlex-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="lead-plate", amount=2.07536314183},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="tinned-cable", amount=10},
      },
      results = {
        {type="item", name="korlex-codex", amount=1},
      },
    },
    ["korlex-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="fish-oil", amount=100},
        {type="fluid", name="hot-air", amount=76.9230769231},
        {type="item", name="fawogae", amount=10},
        {type="item", name="fish", amount=5},
        {type="item", name="guts", amount=3.63209777719},
        {type="item", name="kicalk-seeds", amount=10},
        {type="item", name="lime", amount=4.49186569027},
        {type="item", name="native-flora", amount=5},
        {type="item", name="salt", amount=10},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="korlex-food-01", amount=3},
      },
    },
    ["korlex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=3436.96276513},
        {type="fluid", name="fetal-serum", amount=100},
        {type="item", name="alien-sample01", amount=5},
        {type="item", name="bio-sample", amount=20},
        {type="item", name="cdna", amount=5},
        {type="item", name="earth-mouse-sample", amount=0.734526331223},
        {type="item", name="fish", amount=5},
        {type="item", name="korlex-codex", amount=1},
      },
      results = {
        {type="item", name="korlex", amount=1},
      },
    },
    ["korlex-milk-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=3},
        {type="item", name="fish", amount=5},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="tuuphra", amount=5},
        {type="item", name="water-barrel", amount=10},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="barrel-milk", amount=3},
      },
    },
    ["caged-korlex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="cage", amount=1},
        {type="item", name="korlex", amount=1},
      },
      results = {
        {type="item", name="caged-korlex", amount=1},
      },
    },
    ["korlex-pup-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="fish-hydrolysate-barrel", amount=5},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="tuuphra-seeds", amount=10},
        {type="item", name="water-barrel", amount=20},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=3},
      },
    },
    ["full-render-kor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="korlex-pup", amount=1.65905095312},
      },
      results = {
        {type="fluid", name="blood", amount=30},
        {type="item", name="bones", amount=3},
        {type="item", name="brain", amount=1},
        {type="item", name="cage", amount=1},
        {type="item", name="guts", amount=2},
        {type="item", name="meat", amount=3},
        {type="item", name="mukmoux-fat", amount=3},
        {type="item", name="skin", amount=5},
      },
    },
    ["korlex-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="kicalk-seeds", amount=1.71778307751},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="korlex-pup", amount=2},
        {type="item", name="tuuphra", amount=5},
        {type="item", name="water-barrel", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=2},
      },
    },
    ["uncaged-korlex"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="caged-korlex", amount=1},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="korlex", amount=1},
      },
    },
    ["outlet-gas-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=284.820682305},
        {type="fluid", name="organic-solvent", amount=50},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=100},
        {type="item", name="sulfur", amount=20},
      },
    },
    ["quench-redcoke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=123.686272049},
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="redhot-coke", amount=6},
      },
      results = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="coke", amount=30},
      },
    },
    ["redhot-coke"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="item", name="coal", amount=20},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=50},
        {type="item", name="redhot-coke", amount=5},
      },
    },
    ["outlet-gas-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="fluid", name="tar", amount=50},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="nickel-plate", amount=1},
      },
      results = {
        {type="fluid", name="outlet-gas-01", amount=100},
      },
    },
    ["molybdenum-filtration"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molybdenum-pulp", amount=100},
        {type="item", name="chromium", amount=4.45054619019},
      },
      results = {
        {type="item", name="molybdenum-sulfide", amount=10},
      },
    },
    ["calcinate-bone"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="bones", amount=4},
      },
      results = {
        {type="item", name="calcinates", amount=3},
      },
    },
    ["molybdenum-concentrate"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molybdenite-pulp", amount=150},
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
      ingredients = {
        {type="fluid", name="steam", amount=425},
        {type="item", name="molybdenum-sulfide", amount=10},
      },
      results = {
        {type="item", name="molybdenum-oxide", amount=10},
        {type="item", name="sulfur", amount=1},
      },
    },
    ["calcinate-separation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="dried-meat", amount=28.5247723849},
      },
      results = {
        {type="item", name="copper-ore", amount=0.4},
        {type="item", name="iron-ore", amount=0.4},
        {type="item", name="limestone", amount=0.3},
        {type="item", name="ore-quartz", amount=0.6},
        {type="item", name="sulfur", amount=0.3},
      },
    },
    ["molybdenum-plate"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="item", name="molybdenum-oxide", amount=10},
      },
      results = {
        {type="fluid", name="water", amount=10},
        {type="item", name="molybdenum-plate", amount=3},
      },
    },
    ["seaweed-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="molybdenum-sulfide", amount=5.05480881829},
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="item", name="seaweed-mk02", amount=1},
      },
    },
    ["fertilizer-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="blood", amount=50},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=20},
        {type="item", name="bonemeal", amount=6.85370230747},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="ash", amount=20},
        {type="item", name="biomass", amount=20},
        {type="item", name="moss", amount=7.40461705565},
        {type="item", name="ore-titanium", amount=14.3729382845},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="formamide", amount=1021.09573218},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["formic-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="formamide", amount=100},
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
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="moss", amount=5},
        {type="item", name="sap-tree", amount=5},
        {type="item", name="saps", amount=2.42785650141},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=1},
      },
    },
    ["sap-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="sodium-alginate", amount=2.059429788},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=2},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="bones", amount=8.75439248866},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="sap-seeds-mk02", amount=6},
      },
      results = {
        {type="item", name="sap-tree-mk02", amount=1},
      },
    },
    ["casein-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="casein-mixture", amount=50},
        {type="fluid", name="steam", amount=166.666666667},
      },
      results = {
        {type="fluid", name="casein-pulp-01", amount=100},
        {type="fluid", name="muddy-sludge", amount=50},
      },
    },
    ["fish-hydrolysate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=10},
        {type="fluid", name="water", amount=100},
        {type="item", name="fish", amount=10},
        {type="item", name="starch", amount=1.11959664469},
      },
      results = {
        {type="fluid", name="fish-hydrolysate", amount=50},
      },
    },
    ["casein-mixture-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="casein-pulp-01", amount=50},
        {type="fluid", name="water", amount=1000},
      },
      results = {
        {type="fluid", name="casein-pulp-02", amount=50},
      },
    },
    ["casein-mixture-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=50},
        {type="fluid", name="milk", amount=50},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=60},
        {type="fluid", name="waste-water", amount=50},
      },
    },
    ["honey-wax"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1},
      },
      results = {
        {type="item", name="wax-barrel", amount=1},
      },
    },
    ["sugar-wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="empty-fuel-canister", amount=0.537653898048},
        {type="item", name="sugar", amount=5},
      },
      results = {
        {type="item", name="wax-barrel", amount=1},
      },
    },
    ["phosphate-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=1.9947611547},
        {type="item", name="electronic-circuit", amount=40},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="steel-plate", amount=21.1238914328},
      },
      results = {
        {type="item", name="phosphate-mine", amount=1},
      },
    },
    ["rare-earth-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="fenxsb-alloy", amount=43.1811573018},
        {type="item", name="inserter", amount=6.35570013242},
        {type="item", name="py-tank-3000", amount=3.14265371907},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="steel-plate", amount=60},
      },
      results = {
        {type="item", name="rare-earth-mine", amount=1},
      },
    },
    ["subcritical-water-03"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=300},
        {type="fluid", name="pressured-water", amount=200},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=200},
      },
    },
    ["wax"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=97.5},
        {type="item", name="used-comb", amount=5},
      },
      results = {
        {type="fluid", name="wax", amount=50},
      },
    },
    ["wax-honeycomb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=25},
        {type="item", name="empty-comb", amount=6.81688138827},
      },
      results = {
        {type="fluid", name="wax", amount=50},
      },
    },
    ["empty-comb-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="chlorine", amount=243.27229461},
      },
      results = {
        {type="item", name="empty-comb", amount=8},
      },
    },
    ["empty-honeycomb-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="concrete", amount=4},
        {type="item", name="small-lamp", amount=5.41426123889},
        {type="item", name="steel-plate", amount=6},
        {type="item", name="titanium-plate", amount=12.1096665448},
      },
      results = {
        {type="item", name="big-electric-pole", amount=1},
      },
    },
    ["breed-fish-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="albumin", amount=1.02674464731},
        {type="item", name="biomass", amount=10},
        {type="item", name="fish-egg", amount=10},
        {type="item", name="limestone", amount=6.09146273693},
        {type="item", name="tinned-cable", amount=10.5277520764},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=20},
      },
    },
    ["breed-fish-egg-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=448.985614987},
        {type="fluid", name="phytoplankton", amount=50},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish", amount=12},
        {type="item", name="fish-food-01", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=30},
      },
    },
    ["fish-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=60},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish", amount=20},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="seaweed", amount=10},
      },
      results = {
        {type="item", name="fish", amount=5},
        {type="item", name="fish-mk02", amount=0.005},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="steam", amount=484.019428369},
        {type="item", name="fish-mk02", amount=4},
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
      ingredients = {
        {type="fluid", name="fish-oil", amount=60},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="aluminium-plate", amount=20.4246758312},
        {type="item", name="fish-egg-mk02", amount=10},
        {type="item", name="fish-food-01", amount=0.637024275682},
        {type="item", name="seaweed", amount=10},
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
      ingredients = {
        {type="item", name="barrel", amount=1},
        {type="item", name="grenade", amount=1},
        {type="item", name="gunpowder", amount=121.13338053},
      },
      results = {
        {type="item", name="cliff-explosives", amount=1},
      },
    },
    ["fast-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="belt", amount=1},
        {type="item", name="fenxsb-alloy", amount=3.09403226568},
        {type="item", name="inductor1", amount=29.6894522161},
        {type="item", name="inserter", amount=1},
        {type="item", name="nbfe-alloy", amount=3},
        {type="item", name="small-parts-01", amount=10},
      },
      results = {
        {type="item", name="fast-inserter", amount=1},
      },
    },
    ["py-stack-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="nbfe-alloy", amount=10},
        {type="item", name="py-iron", amount=135.847478058},
      },
      results = {
        {type="item", name="py-stack-inserter", amount=1},
      },
    },
    ["flavonoids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fertilizer", amount=19.9902196779},
        {type="item", name="seaweed", amount=20},
      },
      results = {
        {type="fluid", name="flavonoids", amount=30},
      },
    },
    ["mo-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="intermetallics", amount=11.7253227786},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nbfe-alloy", amount=30},
        {type="item", name="small-parts-01", amount=103.116567066},
        {type="item", name="tinned-cable", amount=175.462534607},
      },
      results = {
        {type="item", name="mo-mine", amount=1},
      },
    },
    ["niobium-pipe"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-plate", amount=1},
      },
      results = {
        {type="item", name="niobium-pipe", amount=2},
      },
    },
    ["niobium-pipe-to-ground"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-pipe", amount=10},
        {type="item", name="niobium-plate", amount=1},
      },
      results = {
        {type="item", name="niobium-pipe-to-ground", amount=2},
      },
    },
    ["py-logistic-robot-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="battery-mk01", amount=2},
        {type="item", name="belt", amount=3},
        {type="item", name="duralumin", amount=3.14463140529},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="inductor1", amount=74.2236305403},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="niobium-powder", amount=30.4579428089},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="solder", amount=5},
        {type="item", name="titanium-plate", amount=20.0814673858},
        {type="item", name="zinc-chloride", amount=4.48261815657},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=1},
      },
    },
    ["yaedols-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=80},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="wood", amount=10},
        {type="item", name="yaedols-spores", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=3},
      },
    },
    ["yaedols-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="alien-sample01", amount=5},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="boron-trioxide", amount=35.4392927338},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-bear-sample", amount=0.826119420114},
        {type="item", name="fawogae-spore", amount=20},
        {type="item", name="yaedols-codex", amount=1},
        {type="item", name="yaedols-spores", amount=20},
      },
      results = {
        {type="item", name="yaedols", amount=1},
      },
    },
    ["anthracene-gasoline-hydrogenation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=50},
        {type="fluid", name="hydrogen", amount=50},
      },
      results = {
        {type="fluid", name="gasoline", amount=25},
      },
    },
    ["anthraquinone-from-naphthalene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=100},
        {type="item", name="calcinates", amount=14.2173405735},
      },
      results = {
        {type="fluid", name="anthraquinone", amount=100},
      },
    },
    ["aromatics-from-naphthalene"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=75},
      },
      results = {
        {type="fluid", name="aromatics", amount=40},
        {type="item", name="coke", amount=3},
      },
    },
    ["bitumen-to-heavy-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
        {type="fluid", name="carbon-dioxide", amount=123.686272049},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=100},
      },
    },
    ["hot-residual-mixture-to-coke"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=278.329054563},
        {type="fluid", name="steam", amount=300},
        {type="fluid", name="water", amount=300},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=60},
        {type="item", name="coke", amount=40},
      },
    },
    ["naphthalene-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="naphthalene-oil", amount=100},
        {type="fluid", name="nitrogen", amount=293.591930764},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=30},
      },
    },
    ["natural-gas-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=50},
        {type="item", name="pipe", amount=3.41711258772},
      },
      results = {
        {type="fluid", name="crude-oil", amount=40},
      },
    },
    ["rubber-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=853.64824467},
        {type="fluid", name="polybutadiene", amount=50},
        {type="item", name="carbon-black", amount=2},
        {type="item", name="latex", amount=2},
      },
      results = {
        {type="item", name="rubber", amount=4},
      },
    },
    ["rubber-from-oleochemicals"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=350},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=50},
        {type="item", name="small-parts-01", amount=2},
      },
      results = {
        {type="fluid", name="tar", amount=100},
      },
    },
    ["ticl4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="chlorine", amount=40},
        {type="item", name="tailings-dust", amount=3.53993903241},
        {type="item", name="titanium-plate", amount=3},
      },
      results = {
        {type="item", name="ticl4", amount=4},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="methane", amount=400},
        {type="item", name="boron-trioxide", amount=1.27227213628},
        {type="item", name="copper-plate", amount=2},
      },
      results = {
        {type="fluid", name="methanol", amount=300},
      },
    },
    ["naphtha-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="naphtha", amount=150},
        {type="fluid", name="water", amount=2400},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=400},
      },
    },
    ["reheat-coke-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="warm-stone-brick", amount=20.85898892},
      },
      results = {
        {type="fluid", name="hot-air", amount=300},
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["aromatics-2-diesel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="aromatics", amount=500},
        {type="fluid", name="naphtha", amount=100},
        {type="item", name="ticl4", amount=0.986157337574},
      },
      results = {
        {type="fluid", name="diesel", amount=350},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=225.292416827},
        {type="fluid", name="water", amount=1912.5},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=300},
      },
    },
    ["bio-oil-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="bio-oil", amount=300},
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
      ingredients = {
        {type="fluid", name="low-distillate", amount=100},
        {type="item", name="ticl4", amount=0.986157337574},
      },
      results = {
        {type="fluid", name="btx", amount=100},
      },
    },
    ["medium-distillate-to-high-distillate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=584.961527942},
        {type="fluid", name="water", amount=900},
        {type="item", name="ticl4", amount=0.986157337574},
      },
      results = {
        {type="fluid", name="high-distillate", amount=100},
      },
    },
    ["medium-distillate-to-stripped-distillate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="medium-distillate", amount=100},
        {type="item", name="sncr-alloy", amount=1.01403697148},
      },
      results = {
        {type="fluid", name="stripped-distillate", amount=100},
      },
    },
    ["low-distillate-to-coal-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="low-distillate", amount=100},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=200},
      },
    },
    ["stripped-distillate-to-benzene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="carbon-black", amount=0.81069450321},
      },
      results = {
        {type="fluid", name="benzene", amount=150},
      },
    },
    ["stripped-distillate-to-cumene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="sncr-alloy", amount=1.01403697148},
      },
      results = {
        {type="fluid", name="cumene", amount=200},
      },
    },
    ["stripped-distillate-to-gasoline"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="ticl4", amount=0.986157337574},
      },
      results = {
        {type="fluid", name="gasoline", amount=200},
      },
    },
    ["stripped-distillate-to-methanol"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="ticl4", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=150},
      },
    },
    ["fluorine-to-olefins"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="crude-oil", amount=50},
        {type="fluid", name="residual-mixture", amount=958.369149044},
        {type="item", name="nickel-plate", amount=1},
      },
      results = {
        {type="fluid", name="naphtha", amount=50},
        {type="fluid", name="olefin", amount=100},
      },
    },
    ["high-distillate-condensing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=387.442653029},
        {type="fluid", name="gasoline", amount=20},
      },
      results = {
        {type="fluid", name="condensed-distillate", amount=50},
        {type="fluid", name="naphtha", amount=150},
      },
    },
    ["natural-gas-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="methane", amount=214.177291022},
        {type="fluid", name="raw-gas", amount=500},
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=123.686272049},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="refined-natural-gas", amount=150},
      },
      results = {
        {type="fluid", name="condensates", amount=100},
        {type="fluid", name="naphtha", amount=50},
        {type="fluid", name="steam", amount=200},
      },
    },
    ["condensed-distillate-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="condensed-distillate", amount=100},
      },
      results = {
        {type="fluid", name="gasoline", amount=25},
        {type="fluid", name="petroleum-gas", amount=50},
      },
    },
    ["low-distillate-to-heavy-oil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=371.058816147},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="low-distillate", amount=100},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=200},
        {type="fluid", name="residual-oil", amount=50},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["naphtha-2-tall-oil"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="naphtha", amount=150},
      },
      results = {
        {type="fluid", name="tall-oil", amount=100},
      },
    },
    ["bitumen-comb"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="filled-comb", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=50},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["raw-gas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="residual-oil", amount=200},
        {type="fluid", name="steam", amount=200},
        {type="item", name="ash", amount=10},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=100},
      },
    },
    ["bio-oil-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="bitumen", amount=300},
        {type="fluid", name="muddy-sludge", amount=218.092598482},
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
      ingredients = {
        {type="fluid", name="gasoline", amount=554.777296269},
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
      ingredients = {
        {type="fluid", name="residual-mixture", amount=100},
        {type="item", name="chromium", amount=5.2485835132},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=100},
      },
    },
    ["oil-refining"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="crude-oil", amount=300},
        {type="fluid", name="steam", amount=400},
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
      ingredients = {
        {type="fluid", name="residual-mixture", amount=200},
        {type="fluid", name="steam", amount=125},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=25},
        {type="fluid", name="residual-oil", amount=50},
        {type="item", name="coke", amount=40},
      },
    },
    ["used-comb-oil-recycling"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=10},
        {type="item", name="used-comb", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=25},
        {type="fluid", name="residual-oil", amount=50},
      },
    },
    ["used-comb-to-residual-mixture"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="graphite", amount=1},
        {type="item", name="used-comb", amount=3},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=60},
      },
    },
    ["arqad-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="sodium-hydroxide", amount=31.5963395055},
        {type="item", name="steel-plate", amount=103.672100243},
      },
      results = {
        {type="item", name="arqad-codex", amount=1},
      },
    },
    ["arqad-egg-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=3},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="cottongut-mk01", amount=13.1070988778},
        {type="item", name="natural-gas-barrel", amount=10},
        {type="item", name="redhot-coke", amount=2},
      },
      results = {
        {type="item", name="arqad-egg", amount=10},
        {type="item", name="arqad-queen", amount=0.999},
        {type="item", name="barrel", amount=13},
      },
    },
    ["arqad-filled-comb-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=5.76776966735},
        {type="item", name="empty-comb", amount=5},
        {type="item", name="native-flora", amount=10},
        {type="item", name="soil", amount=61.2923076923},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="filled-comb", amount=5},
      },
    },
    ["arqad-filled-honeycomb-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="empty-honeycomb", amount=3},
        {type="item", name="ulric", amount=1},
      },
      results = {
        {type="item", name="honeycomb", amount=3},
      },
    },
    ["arqad"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1000},
        {type="item", name="alien-sample01", amount=69.5105631857},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="earth-palmtree-sample", amount=1.5330149584},
        {type="item", name="zipir-codex", amount=4.14881823091},
      },
      results = {
        {type="item", name="arqad", amount=1},
        {type="item", name="arqad-egg", amount=10},
      },
    },
    ["arqad-egg-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad", amount=7},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="natural-gas-barrel", amount=10},
        {type="item", name="ralesia", amount=15},
        {type="item", name="redhot-coke", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=5.8969607024},
      },
      results = {
        {type="item", name="arqad-egg", amount=15},
        {type="item", name="arqad-queen", amount=0.999},
        {type="item", name="barrel", amount=13},
      },
    },
    ["arqad-hive-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="concrete", amount=35.3306475813},
        {type="item", name="engine-unit", amount=4.92982879339},
        {type="item", name="gasifier", amount=1},
        {type="item", name="glass", amount=50},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=40},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=1},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1},
        {type="item", name="arqad-maggot", amount=5},
        {type="item", name="empty-comb", amount=1},
        {type="item", name="vrauks", amount=1},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="arqad-egg-nest", amount=1},
        {type="item", name="barrel", amount=1},
      },
    },
    ["arqad-maggots-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-egg", amount=30},
        {type="item", name="caged-vrauks", amount=10},
        {type="item", name="honeycomb", amount=5},
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
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=5},
        {type="item", name="arqad-maggot", amount=6.48379565621},
        {type="item", name="tall-oil-barrel", amount=3.03292467871},
      },
      results = {
        {type="item", name="arqad-queen", amount=0.01},
        {type="item", name="barrel", amount=8},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["caged-arqad-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-maggot", amount=12.9675913124},
        {type="item", name="biomass", amount=15},
        {type="item", name="natural-gas-barrel", amount=10},
        {type="item", name="ralesia", amount=5},
        {type="item", name="redhot-coke", amount=1},
        {type="item", name="saps", amount=5},
      },
      results = {
        {type="item", name="arqad", amount=7.5},
        {type="item", name="barrel", amount=10},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["caged-arqad-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=7.04838205351},
        {type="item", name="arqad-maggot", amount=6.48379565621},
        {type="item", name="biomass", amount=15},
        {type="item", name="ralesia-seeds", amount=6.08872528332},
      },
      results = {
        {type="item", name="arqad", amount=3},
        {type="item", name="barrel", amount=10},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["full-render-arqads"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-egg", amount=7.0802953017},
      },
      results = {
        {type="fluid", name="arthropod-blood", amount=40},
        {type="fluid", name="bee-venom", amount=30},
        {type="item", name="chitin", amount=4},
        {type="item", name="guts", amount=3},
        {type="item", name="meat", amount=3},
      },
    },
    ["honey-comb"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="honeycomb", amount=5},
      },
      results = {
        {type="fluid", name="arqad-honey", amount=250},
        {type="item", name="empty-honeycomb", amount=5},
      },
    },
    ["hotair-empty-honeycomb-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="wax", amount=100},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=10},
      },
    },
    ["bitumen-to-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
      },
      results = {
        {type="fluid", name="nitrogen", amount=200},
      },
    },
    ["bitumen-to-sulfur"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="oil-sand", amount=3},
      },
      results = {
        {type="item", name="crushed-oil-sand", amount=1},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["bitumen-gasification"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="bitumen", amount=100},
        {type="fluid", name="oxygen", amount=50},
        {type="fluid", name="steam", amount=300},
      },
      results = {
        {type="fluid", name="dirty-syngas", amount=100},
      },
    },
    ["hot-syngas-cooldown"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=76.9230769231},
        {type="fluid", name="hot-syngas", amount=100},
      },
      results = {
        {type="fluid", name="steam", amount=300},
        {type="fluid", name="syngas", amount=500},
      },
    },
    ["quenching-dirty-syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=400},
        {type="fluid", name="water", amount=1600},
        {type="item", name="filtration-media", amount=1},
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
      ingredients = {
        {type="fluid", name="purified-syngas", amount=100},
        {type="fluid", name="steam", amount=133.333333333},
      },
      results = {
        {type="fluid", name="hot-syngas", amount=100},
        {type="item", name="soot", amount=2},
      },
    },
    ["oil-sand-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=185.529408073},
        {type="fluid", name="steam", amount=350},
        {type="item", name="crushed-oil-sand", amount=2},
      },
      results = {
        {type="fluid", name="oil-sand-slurry", amount=100},
      },
    },
    ["bitumen-froth"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oil-sand-slurry", amount=100},
        {type="fluid", name="pressured-air", amount=200},
        {type="item", name="meat", amount=2.34674846907},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=100},
        {type="fluid", name="tailings", amount=100},
      },
    },
    ["btx-to-benzene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="nitrogen", amount=403.427605132},
        {type="fluid", name="vacuum", amount=320},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="fluid", name="benzene", amount=200},
      },
    },
    ["btx-to-methane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="btx", amount=200},
        {type="fluid", name="water", amount=1350},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=300},
      },
    },
    ["aromatics-to-petgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=394.249992156},
        {type="fluid", name="syngas", amount=225.292416827},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=80},
      },
    },
    ["bitumen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="creosote", amount=448.676614776},
        {type="fluid", name="methanol", amount=451.858120117},
      },
      results = {
        {type="item", name="explosives", amount=5},
      },
    },
    ["filtration-media"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="cellulose", amount=7.87838524537},
        {type="item", name="iron-oxide", amount=6.29782150742},
        {type="item", name="micro-fiber", amount=2},
        {type="item", name="pure-sand", amount=30},
        {type="item", name="titanium-plate", amount=8.02614815946},
      },
      results = {
        {type="item", name="filtration-media", amount=5},
      },
    },
    ["niobium-dust"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-powder", amount=5},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="niobium-dust", amount=10},
      },
    },
    ["stone-distilation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="rare-earth-powder", amount=5},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="rare-earth-dust", amount=3},
      },
    },
    ["rare-earth-beneficiation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1236.86272049},
        {type="fluid", name="sulfuric-acid", amount=200},
        {type="item", name="rare-earth-dust", amount=10},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=250},
        {type="fluid", name="steam", amount=2000},
        {type="item", name="rich-dust", amount=5},
        {type="item", name="sand", amount=10},
      },
    },
    ["milling-molybdenite"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="crushed-molybdenite", amount=5},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="molybdenite-dust", amount=10},
      },
    },
    ["ree-float"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=100},
        {type="item", name="rare-earth-dust", amount=3},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=100},
        {type="item", name="zinc-plate", amount=5},
      },
    },
    ["ree-slurry"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="rare-earth-mud", amount=100},
        {type="fluid", name="sulfuric-acid", amount=200},
      },
      results = {
        {type="fluid", name="ree-slurry", amount=100},
        {type="fluid", name="tailings", amount=100},
      },
    },
    ["ree-solution"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="ree-slurry", amount=100},
      },
      results = {
        {type="fluid", name="ree-solution", amount=100},
        {type="item", name="uranium-ore", amount=0.1},
      },
    },
    ["crusher-ree"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="rare-earth-ore", amount=10},
      },
      results = {
        {type="item", name="rare-earth-powder", amount=5},
        {type="item", name="stone", amount=5},
      },
    },
    ["ree-concentrate2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=50},
        {type="fluid", name="ree-solution", amount=100},
      },
      results = {
        {type="item", name="chromite-sand", amount=10},
        {type="item", name="ree-concentrate", amount=20},
      },
    },
    ["ree-concentrate1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="ree-solution", amount=100},
      },
      results = {
        {type="item", name="iron-oxide", amount=6},
        {type="item", name="ree-concentrate", amount=10},
      },
    },
    ["reo"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="ree-concentrate", amount=10},
      },
      results = {
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="reo", amount=5},
      },
    },
    ["ree-concentrate3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="ree-solution", amount=100},
        {type="fluid", name="sulfuric-acid", amount=150},
      },
      results = {
        {type="item", name="copper-ore", amount=5},
        {type="item", name="ree-concentrate", amount=20},
      },
    },
    ["xyhiphoe-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=185.559076351},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="xyhiphoe-codex", amount=1},
      },
    },
    ["xyhiphoe-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=1750},
        {type="fluid", name="water-saline", amount=1122.60471793},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="saps", amount=6},
        {type="item", name="sodium-alginate", amount=0.856481834618},
      },
      results = {
        {type="fluid", name="waste-water", amount=650},
        {type="item", name="xyhiphoe-cub", amount=4},
      },
    },
    ["xyhiphoe-pool-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="duralumin", amount=25.3265539588},
        {type="item", name="glass", amount=100},
        {type="item", name="inductor1", amount=148.447261081},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="iron-plate", amount=113.615429602},
        {type="item", name="kicalk-plantation-mk01", amount=1.34566148095},
        {type="item", name="small-electric-pole", amount=3.27149310096},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="titanium-plate", amount=100.407336929},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk01", amount=1},
      },
    },
    ["xyhiphoe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=100},
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="alien-sample01", amount=2},
        {type="item", name="arqad-codex", amount=2.05435980864},
        {type="item", name="bio-sample", amount=15},
        {type="item", name="cdna", amount=3},
        {type="item", name="cocoon", amount=5},
        {type="item", name="earth-crustacean-sample", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["xyhiphoe-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="pressured-water", amount=3000},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="xyhiphoe-cub", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=200},
        {type="item", name="xyhiphoe", amount=1.05},
      },
    },
    ["full-render-xyhiphoe"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="fluid", name="arthropod-blood", amount=80},
        {type="item", name="guts", amount=4},
        {type="item", name="meat", amount=2},
        {type="item", name="shell", amount=4},
      },
    },
    ["niobium-concentrate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-powder", amount=8.49709223821},
      },
      results = {
        {type="item", name="niobium-concentrate", amount=10},
        {type="item", name="sand", amount=2},
      },
    },
    ["nbfe-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="iron-plate", amount=15},
        {type="item", name="niobium-powder", amount=12.1831771236},
      },
      results = {
        {type="item", name="nbfe-alloy", amount=2},
      },
    },
    ["niobium-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=50},
        {type="fluid", name="steam", amount=1210.10743331},
      },
      results = {
        {type="item", name="niobium-oxide", amount=10},
      },
    },
    ["niobium-plate"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-oxide", amount=6},
        {type="item", name="salt", amount=20},
      },
      results = {
        {type="item", name="niobium-plate", amount=4},
      },
    },
    ["niobium-complex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="fluid", name="organic-solvent", amount=50},
        {type="item", name="niobium-dust", amount=16.0071821409},
      },
      results = {
        {type="fluid", name="niobium-complex", amount=100},
      },
    },
    ["niobium-powder"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-ore", amount=10},
      },
      results = {
        {type="item", name="niobium-powder", amount=5},
        {type="item", name="stone", amount=2},
      },
    },
    ["biomass-albumin"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="albumin", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-arqad"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-arqad-egg"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-egg", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-arqad-maggot"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-maggot", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-caged-korlex"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="caged-korlex", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-casein"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="casein", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=6},
      },
    },
    ["biomass-crawdad"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="crawdad", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=100},
      },
    },
    ["biomass-fiber"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="fiber", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-fish-food-01"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="fish-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-fish-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="fish-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-fungal-substrate"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="fungal-substrate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=4},
      },
    },
    ["biomass-fungal-substrate-02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="fungal-substrate-02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-kicalk"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="kicalk", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=280},
      },
    },
    ["biomass-kicalk-seeds"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="kicalk-seeds", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=280},
      },
    },
    ["biomass-korlex"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="korlex", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-korlex-food-01"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="korlex-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-korlex-pup"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="korlex-pup", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-micro-fiber"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="micro-fiber", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=4},
      },
    },
    ["biomass-moondrop-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-moondrop-seeds-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="moondrop-seeds-mk02", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=24},
      },
    },
    ["biomass-sap-tree-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="sap-tree-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-sea-sponge"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-sea-sponge-sprouts"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-shell"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="shell", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-sugar"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="sugar", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-tree-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="tree-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=30},
      },
    },
    ["biomass-tuuphra"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-tuuphra-seeds"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="tuuphra-seeds", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-ulric"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="ulric", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-ulric-food-01"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-used-comb"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="used-comb", amount=2},
      },
      results = {
        {type="item", name="biomass", amount=30},
      },
    },
    ["biomass-wood-seedling-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="wood-seedling-mk02", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-wood-seeds-mk02"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="wood-seeds-mk02", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=60},
      },
    },
    ["biomass-xyhiphoe"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-xyhiphoe-cub"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="xyhiphoe-cub", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-yaedols"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-zipir-eggs"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="zipir-eggs", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-zipir1"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="zipir1", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["empty-milk-barrel"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="barrel-milk", amount=1},
      },
      results = {
        {type="fluid", name="milk", amount=50},
        {type="item", name="empty-barrel-milk", amount=1},
      },
    },
    ["biomass-milk"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="fluid", name="milk", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["fill-methanol-gas-canister"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="fluid", name="methanol", amount=100},
        {type="item", name="empty-gas-canister", amount=1},
      },
      results = {
        {type="item", name="methanol-gas-canister", amount=1},
      },
    },
    ["empty-methanol-gas-canister"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="item", name="methanol-gas-canister", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=100},
        {type="item", name="empty-gas-canister", amount=1},
      },
    },
    ["hydrogen-chloride-void"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="chlorine", amount=100},
        {type="fluid", name="hydrogen", amount=100},
        {type="item", name="small-lamp", amount=0.5},
      },
    },
    ["purest-nitrogen-void"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=240},
      },
      results = {
        {type="fluid", name="pressured-air", amount=240},
      },
    },
    ["refsyngas-from-meth-canister"] = {
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=100},
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
      mode = "frozen-preserved",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=50},
        {type="fluid", name="vpulp3", amount=100},
      },
      results = {
        {type="fluid", name="flue-gas", amount=50},
        {type="fluid", name="vpulp1", amount=50},
      },
    },
    ["a-molasse-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="a-molasse", amount=20000},
      },
      results = {
      },
    },
    ["acetic-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=20000},
      },
      results = {
      },
    },
    ["active-provider-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="active-provider-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["agitator-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="agitator-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["al-pulp-01-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=20000},
      },
      results = {
      },
    },
    ["al-pulp-02-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="al-pulp-02", amount=20000},
      },
      results = {
      },
    },
    ["albumin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="albumin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["alien-sample-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["anthraquinone-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=20000},
      },
      results = {
      },
    },
    ["arqad-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arqad-egg-nest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad-egg-nest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arqad-egg-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad-egg", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arqad-hive-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arqad-honey-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=20000},
      },
      results = {
      },
    },
    ["arqad-maggot-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad-maggot", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arqad-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arqad-queen-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="arqad-queen", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arthropod-blood-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=20000},
      },
      results = {
      },
    },
    ["artificial-blood-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=20000},
      },
      results = {
      },
    },
    ["barrel-milk-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="barrel-milk", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bee-venom-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="bee-venom", amount=20000},
      },
      results = {
      },
    },
    ["benzene-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="benzene", amount=20000},
      },
      results = {
      },
    },
    ["big-electric-pole-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="big-electric-pole", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="bio-oil", amount=20000},
      },
      results = {
      },
    },
    ["bitumen-froth-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="bitumen-froth", amount=20000},
      },
      results = {
      },
    },
    ["bitumen-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="bitumen", amount=20000},
      },
      results = {
      },
    },
    ["blue-liquor-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="blue-liquor", amount=20000},
      },
      results = {
      },
    },
    ["btx-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="btx", amount=20000},
      },
      results = {
      },
    },
    ["buffer-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="buffer-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["caged-korlex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="caged-korlex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["caged-ulric-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="caged-ulric", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["calcinates-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="calcinates", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["carbon-filter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="carbon-filter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["casein-mixture-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="casein-mixture", amount=20000},
      },
      results = {
      },
    },
    ["casein-pulp-01-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="casein-pulp-01", amount=20000},
      },
      results = {
      },
    },
    ["casein-pulp-02-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="casein-pulp-02", amount=20000},
      },
      results = {
      },
    },
    ["casein-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="casein", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["centrifugal-pan-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="centrifugal-pan-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chromite-rejects-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="chromite-rejects", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cliff-explosives-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="cliff-explosives", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["coal-slurry-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="coal-slurry", amount=20000},
      },
      results = {
      },
    },
    ["coalbed-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=20000},
      },
      results = {
      },
    },
    ["coalbed-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="coalbed-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cobalt-extract-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="cobalt-extract", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cobalt-fluoride-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="cobalt-fluoride", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["compressor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="compressor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["condensed-distillate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="condensed-distillate", amount=20000},
      },
      results = {
      },
    },
    ["copper-low-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="copper-low-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["copper-rejects-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="copper-rejects", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crawdad-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="crawdad", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crude-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="crude-oil", amount=20000},
      },
      results = {
      },
    },
    ["crushed-molybdenite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="crushed-molybdenite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crushed-oil-sand-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="crushed-oil-sand", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cumene-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="cumene", amount=20000},
      },
      results = {
      },
    },
    ["cytostatics-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="cytostatics", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["decalin-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="decalin", amount=20000},
      },
      results = {
      },
    },
    ["diesel-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="diesel", amount=20000},
      },
      results = {
      },
    },
    ["dirty-syngas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=20000},
      },
      results = {
      },
    },
    ["dna-polymerase-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="dna-polymerase", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["drill-head-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="drill-head", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["drilling-fluid-0-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=20000},
      },
      results = {
      },
    },
    ["earth-bee-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-bee-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-cow-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-cow-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-crustacean-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-crustacean-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-horse-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-horse-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-palmtree-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-palmtree-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-potato-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-potato-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-sea-sponge-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="earth-sea-sponge-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-barrel-milk-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-comb-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="empty-comb", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-gas-canister-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="empty-gas-canister", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["empty-honeycomb-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="empty-honeycomb", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["explosives-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="explosives", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ez-ranch-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ez-ranch-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fast-inserter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fast-inserter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fetal-serum-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=20000},
      },
      results = {
      },
    },
    ["filled-comb-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="filled-comb", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["filtration-media-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-egg-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fish-egg-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fish-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-hydrolysate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=20000},
      },
      results = {
      },
    },
    ["fish-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fish-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flavonoids-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="flavonoids", amount=20000},
      },
      results = {
      },
    },
    ["fluid-separator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fluid-separator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fluorine-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="fluorine-gas", amount=20000},
      },
      results = {
      },
    },
    ["flutec-pp6-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="flutec-pp6", amount=20000},
      },
      results = {
      },
    },
    ["formamide-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="formamide", amount=20000},
      },
      results = {
      },
    },
    ["fts-reactor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fts-reactor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fungal-substrate-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fungal-substrate-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fungal-substrate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="fungal-substrate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gas-separator-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="gas-separator-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["glycerol-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="glycerol", amount=20000},
      },
      results = {
      },
    },
    ["gold-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="gold-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-iron-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-1-iron", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-chromite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-2-chromite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-iron-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-2-iron", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-lead-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-2-lead", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-nickel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-2-nickel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-chromite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-chromite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-copper-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-copper", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-iron-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-iron", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-lead-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-lead", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-nickel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-nickel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-tin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-tin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-3-zinc-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-zinc", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-4-chromite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-4-chromite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-4-copper-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-4-copper", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-4-nickel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-4-nickel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-4-tin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-4-tin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["green-sic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="green-sic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["high-distillate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="high-distillate", amount=20000},
      },
      results = {
      },
    },
    ["honeycomb-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="honeycomb", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hot-residual-mixture-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="hot-residual-mixture", amount=20000},
      },
      results = {
      },
    },
    ["hot-syngas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="hot-syngas", amount=20000},
      },
      results = {
      },
    },
    ["hydrocyclone-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="hydrocyclone-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hydrofluoric-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="hydrofluoric-acid", amount=20000},
      },
      results = {
      },
    },
    ["hydrogen-chloride-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=20000},
      },
      results = {
      },
    },
    ["hydrogen-peroxide-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=20000},
      },
      results = {
      },
    },
    ["industrial-solvent-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=20000},
      },
      results = {
      },
    },
    ["iron-ore-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="iron-ore-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["iron-pulp-01-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="iron-pulp-01", amount=20000},
      },
      results = {
      },
    },
    ["iron-slime-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="iron-slime", amount=20000},
      },
      results = {
      },
    },
    ["kicalk-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="kicalk-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kicalk-plantation-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="kicalk-plantation-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kicalk-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="kicalk", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kicalk-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="kicalk-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["korlex-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="korlex-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["korlex-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="korlex-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["korlex-pup-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="korlex-pup", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["korlex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="korlex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["leaching-station-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="leaching-station-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lead-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="lead-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["liquid-nitrogen-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=20000},
      },
      results = {
      },
    },
    ["logistic-science-pack-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="logistic-science-pack", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="lor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["low-distillate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="low-distillate", amount=20000},
      },
      results = {
      },
    },
    ["low-grade-copper-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="low-grade-copper", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["low-grade-rejects-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="low-grade-rejects", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lubricant-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="lubricant", amount=20000},
      },
      results = {
      },
    },
    ["manure-bacteria-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=20000},
      },
      results = {
      },
    },
    ["medium-distillate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="medium-distillate", amount=20000},
      },
      results = {
      },
    },
    ["methanol-gas-canister-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="methanol-gas-canister", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["methanol-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="methanol", amount=20000},
      },
      results = {
      },
    },
    ["methanol-reactor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="methanol-reactor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["micro-fiber-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="micro-fiber", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["military-science-pack-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="military-science-pack", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["milk-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="milk", amount=20000},
      },
      results = {
      },
    },
    ["mixed-ores-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="mixed-ores", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mo-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="mo-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molten-copper-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-copper", amount=20000},
      },
      results = {
      },
    },
    ["molten-lead-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-lead", amount=20000},
      },
      results = {
      },
    },
    ["molten-nickel-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-nickel", amount=20000},
      },
      results = {
      },
    },
    ["molten-solder-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-solder", amount=20000},
      },
      results = {
      },
    },
    ["molten-steel-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-steel", amount=20000},
      },
      results = {
      },
    },
    ["molten-tin-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-tin", amount=20000},
      },
      results = {
      },
    },
    ["molten-zinc-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molten-zinc", amount=20000},
      },
      results = {
      },
    },
    ["molybdenite-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="molybdenite-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molybdenite-pulp-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molybdenite-pulp", amount=20000},
      },
      results = {
      },
    },
    ["molybdenum-concentrate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="molybdenum-concentrate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molybdenum-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="molybdenum-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molybdenum-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="molybdenum-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molybdenum-pulp-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="molybdenum-pulp", amount=20000},
      },
      results = {
      },
    },
    ["molybdenum-sulfide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="molybdenum-sulfide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="moondrop-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-seeds-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="moondrop-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["naphtha-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="naphtha", amount=20000},
      },
      results = {
      },
    },
    ["natural-gas-derrick-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="natural-gas-derrick-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["natural-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="natural-gas", amount=20000},
      },
      results = {
      },
    },
    ["nbfe-alloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="nbfe-alloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nichrome-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="nichrome", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nickel-rejects-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="nickel-rejects", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-complex-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=20000},
      },
      results = {
      },
    },
    ["niobium-concentrate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-concentrate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-pipe-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-pipe", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-pipe-to-ground-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-pipe-to-ground", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["niobium-powder-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="niobium-powder", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nitrogen-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="nitrogen", amount=20000},
      },
      results = {
      },
    },
    ["nxsb-alloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["oil-derrick-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="oil-derrick-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["oil-sand-extractor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="oil-sand-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["oil-sand-slurry-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="oil-sand-slurry", amount=20000},
      },
      results = {
      },
    },
    ["olefin-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="olefin", amount=20000},
      },
      results = {
      },
    },
    ["oleochemicals-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=20000},
      },
      results = {
      },
    },
    ["organic-solvent-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=20000},
      },
      results = {
      },
    },
    ["outlet-gas-01-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="outlet-gas-01", amount=20000},
      },
      results = {
      },
    },
    ["outlet-gas-02-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="outlet-gas-02", amount=20000},
      },
      results = {
      },
    },
    ["paragen-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="paragen", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["passive-provider-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="passive-provider-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["petroleum-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="petroleum-gas", amount=20000},
      },
      results = {
      },
    },
    ["phosphate-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="phosphate-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["phosphine-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="phosphine-gas", amount=20000},
      },
      results = {
      },
    },
    ["phosphoric-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="phosphoric-acid", amount=20000},
      },
      results = {
      },
    },
    ["phosphorous-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="phosphorous-acid", amount=20000},
      },
      results = {
      },
    },
    ["powdered-phosphate-rock-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="powdered-phosphate-rock", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["powdered-quartz-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="powdered-quartz", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pressured-hydrogen-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="pressured-hydrogen", amount=20000},
      },
      results = {
      },
    },
    ["primers-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="primers", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["propene-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="propene", amount=20000},
      },
      results = {
      },
    },
    ["pumpjack-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="pumpjack-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pure-sand-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="pure-sand", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["purest-nitrogen-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=20000},
      },
      results = {
      },
    },
    ["purified-syngas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="purified-syngas", amount=20000},
      },
      results = {
      },
    },
    ["py-aluminium-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-aluminium", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-coal-tile-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-coal-tile", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-gas-powerplant-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-iron-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-iron", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-logistic-robot-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-logistic-robot-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-nexelit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-nexelit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-quartz-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-quartz", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-stack-inserter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-stack-inserter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-steel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="py-steel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pyrite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="pyrite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["quartz-tube-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="quartz-tube", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rare-earth-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="rare-earth-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rare-earth-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="rare-earth-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rare-earth-mud-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="rare-earth-mud", amount=20000},
      },
      results = {
      },
    },
    ["rare-earth-powder-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="rare-earth-powder", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["raw-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="raw-gas", amount=20000},
      },
      results = {
      },
    },
    ["redhot-coke-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="redhot-coke", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ree-concentrate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ree-concentrate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ree-mining-drill-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ree-mining-drill-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ree-slurry-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="ree-slurry", amount=20000},
      },
      results = {
      },
    },
    ["ree-solution-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="ree-solution", amount=20000},
      },
      results = {
      },
    },
    ["refined-natural-gas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="refined-natural-gas", amount=20000},
      },
      results = {
      },
    },
    ["refsyngas-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="refsyngas", amount=20000},
      },
      results = {
      },
    },
    ["reo-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="reo", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["requester-chest-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="requester-chest", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["residual-mixture-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="residual-mixture", amount=20000},
      },
      results = {
      },
    },
    ["residual-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="residual-oil", amount=20000},
      },
      results = {
      },
    },
    ["rich-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="rich-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-seeds-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sap-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-tree-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sap-tree-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sea-sponge-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sea-sponge-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sea-sponge-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sea-sponge-sprouts-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["seaweed-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="seaweed-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["shell-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="shell", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sic-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sic", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["silver-plate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="silver-plate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sncr-alloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["soda-ash-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="soda-ash", amount=20000},
      },
      results = {
      },
    },
    ["sponge-culture-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stone-wool-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="stone-wool", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stripped-distillate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=20000},
      },
      results = {
      },
    },
    ["sugar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sugar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sulfur-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="sulfur-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sulfuric-acid-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=20000},
      },
      results = {
      },
    },
    ["sweet-syrup-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="sweet-syrup", amount=20000},
      },
      results = {
      },
    },
    ["tar-extractor-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tar-extractor-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["thickener-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="thickener-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ticl4-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ticl4", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tin-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tin-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tin-ore-rejects-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tin-ore-rejects", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tree-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tree-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tuuphra-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tuuphra-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tuuphra-plantation-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tuuphra-plantation-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tuuphra-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tuuphra-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="tuuphra-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ulric-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-corral-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-cub-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ulric-cub", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="ulric", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["unslimed-iron-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="unslimed-iron", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["uranium-ore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="uranium-ore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["used-comb-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="used-comb", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vanabins-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="vanabins", amount=20000},
      },
      results = {
      },
    },
    ["vanadium-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="vanadium-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vpulp1-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="vpulp1", amount=20000},
      },
      results = {
      },
    },
    ["vpulp2-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="vpulp2", amount=20000},
      },
      results = {
      },
    },
    ["vpulp3-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="vpulp3", amount=20000},
      },
      results = {
      },
    },
    ["warmer-stone-brick-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="warmer-stone-brick", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wax-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="fluid", name="wax", amount=20000},
      },
      results = {
      },
    },
    ["wet-scrubber-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wood-seedling-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["wood-seeds-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="wood-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xyhiphoe-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="xyhiphoe-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xyhiphoe-cub-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="xyhiphoe-cub", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xyhiphoe-pool-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="xyhiphoe-pool-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xyhiphoe-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaedols-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="yaedols-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaedols-culture-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="yaedols-culture-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaedols-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zinc-chloride-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="zinc-chloride", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zipir-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="zipir-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zipir-eggs-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="zipir-eggs", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zipir-reef-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="zipir-reef-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zipir1-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="zipir1", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zipir1-pyvoid-hatchery"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="zipir1", amount=1},
      },
      results = {
        {type="item", name="processed-ash", amount=0.8},
      },
    },
    ["processed-ash-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="processed-ash", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["defender-capsule"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="item", name="inductor1", amount=22.6589822357},
        {type="item", name="nexelit-plate", amount=8.38943942895},
        {type="item", name="shotgun-shell", amount=9.46392471203},
      },
      results = {
        {type="item", name="defender-capsule", amount=1},
      },
    },
    ["flamethrower"] = {
      mode = "input-preserved-unmodified",
      science_level = 4,
      ingredients = {
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="flamethrower", amount=1},
      },
    },
    ["rocket-launcher"] = {
      mode = "input-preserved-unmodified",
      science_level = 4,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="rocket-launcher", amount=1},
      },
    },
    ["flamethrower-ammo"] = {
      mode = "input-preserved-unmodified",
      science_level = 4,
      ingredients = {
        {type="fluid", name="light-oil", amount=100},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="flamethrower-ammo", amount=1},
      },
    },
    ["rocket"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="item", name="iron-plate", amount=2},
        {type="item", name="zinc-chloride", amount=3.79914641718},
      },
      results = {
        {type="item", name="rocket", amount=1},
      },
    },
    ["flamethrower-turret"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="item", name="duralumin", amount=5.12143414072},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="pipe", amount=10},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="flamethrower-turret", amount=1},
      },
    },
    ["land-mine"] = {
      mode = "input-preserved-unmodified",
      science_level = 4,
      ingredients = {
        {type="item", name="explosives", amount=2},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="land-mine", amount=4},
      },
    },
    ["py-science-pack-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="fluid", name="arqad-honey", amount=600},
        {type="fluid", name="flavonoids", amount=100},
        {type="item", name="cdna", amount=3.55164543984},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="moss", amount=400},
        {type="item", name="paragen", amount=1},
        {type="item", name="petri-dish", amount=31.2782836075},
        {type="item", name="sic", amount=89.5315377022},
        {type="item", name="small-parts-01", amount=18.7435722429},
        {type="item", name="solidified-sarcorus", amount=2},
        {type="item", name="zipir-eggs", amount=15},
      },
      results = {
        {type="item", name="py-science-pack-2", amount=18},
      },
    },
    ["defender-capsule-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="defender-capsule", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flamethrower-ammo-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="flamethrower-ammo", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flamethrower-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="flamethrower", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["flamethrower-turret-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="flamethrower-turret", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["land-mine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="land-mine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rocket-launcher-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="rocket-launcher", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rocket-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 4,
      ingredients = {
        {type="item", name="rocket", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molybdenum-ore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="molybdenum-ore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ore-chromium-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ore-chromium", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["phosphate-rock-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="phosphate-rock", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-science-pack-2-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="py-science-pack-2", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["arthropod-blood-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=50},
      },
      results = {
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["guts-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="meat", amount=13.097622865},
      },
      results = {
        {type="item", name="copper-ore", amount=15},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="meat", amount=5},
        {type="item", name="skin", amount=3.18664547994},
      },
      results = {
        {type="item", name="copper-ore", amount=35},
      },
    },
    ["tuuphra-to-copper"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="blood", amount=100},
      },
      results = {
        {type="item", name="urea", amount=10},
      },
    },
    ["btx-to-ethylene"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="btx", amount=100},
        {type="fluid", name="steam", amount=200},
        {type="item", name="nexelit-plate", amount=1},
      },
      results = {
        {type="fluid", name="ethylene", amount=100},
      },
    },
    ["ceramic-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="clay", amount=10},
        {type="item", name="coke", amount=1},
        {type="item", name="sodium-hydroxide", amount=2.07811750601},
      },
      results = {
        {type="item", name="ceramic", amount=10},
      },
    },
    ["crude-cermet"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="ceramic", amount=5},
        {type="item", name="molybdenum-ore", amount=3},
        {type="item", name="ore-nickel", amount=5},
      },
      results = {
        {type="item", name="crude-cermet", amount=5},
      },
    },
    ["cermet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="crude-cermet", amount=3},
        {type="item", name="gravel", amount=5.20435104731},
      },
      results = {
        {type="item", name="cermet", amount=5},
      },
    },
    ["concrete-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=400},
        {type="fluid", name="water", amount=100},
        {type="item", name="agar", amount=4.16454341543},
        {type="item", name="pipe", amount=3.93276097877},
      },
      results = {
        {type="item", name="concrete", amount=20},
      },
    },
    ["cool-steam-500-to-250"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="item", name="nickel-plate", amount=6.6930258473},
      },
      results = {
        {type="fluid", name="water", amount=50},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["fawogae-to-sulfur"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="meat", amount=5},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["p2s5"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="phosphate-rock", amount=5},
        {type="item", name="pyrite", amount=5},
      },
      results = {
        {type="item", name="iron-ore", amount=1},
        {type="item", name="p2s5", amount=1},
      },
    },
    ["tuupha-to-iron"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="tuuphra", amount=7.89615049758},
      },
      results = {
        {type="item", name="iron-ore", amount=6},
      },
    },
    ["trits-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=34.1368963374},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="trits-codex", amount=1},
      },
    },
    ["trits-reef-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=50},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="pump", amount=3},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="steel-plate", amount=54.7269123583},
        {type="item", name="tin-plate", amount=114.67073292},
        {type="item", name="titanium-plate", amount=100},
      },
      results = {
        {type="item", name="trits-reef-mk01", amount=1},
      },
    },
    ["trits"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=100},
        {type="fluid", name="vacuum", amount=533.333333333},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="alien-sample01", amount=9.48195152066},
        {type="item", name="animal-sample-01", amount=10.0860112644},
        {type="item", name="cocoon", amount=5},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="earth-palmtree-sample", amount=0.508884453544},
        {type="item", name="trits-codex", amount=1},
      },
      results = {
        {type="item", name="trits", amount=1},
      },
    },
    ["full-render-trit"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="trits", amount=1},
      },
      results = {
        {type="fluid", name="blood", amount=80},
        {type="item", name="bones", amount=4},
        {type="item", name="brain", amount=1},
        {type="item", name="guts", amount=4},
        {type="item", name="meat", amount=6},
        {type="item", name="mukmoux-fat", amount=7},
        {type="item", name="photophore", amount=2},
        {type="item", name="skin", amount=3},
      },
    },
    ["trits-cub-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water-saline", amount=300},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="moondrop", amount=5},
        {type="item", name="native-flora", amount=22.3180502653},
        {type="item", name="sea-sponge", amount=2},
        {type="item", name="trits", amount=1},
        {type="item", name="wood-seeds", amount=15},
      },
      results = {
        {type="fluid", name="waste-water", amount=300},
        {type="item", name="trits-pup", amount=2},
      },
    },
    ["trits-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water-saline", amount=500},
        {type="item", name="fish-food-01", amount=0.909246559265},
        {type="item", name="moondrop", amount=15},
        {type="item", name="seaweed", amount=30},
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
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=107.628151212},
        {type="item", name="limestone", amount=3.38823529412},
        {type="item", name="silver-plate", amount=3},
      },
      results = {
        {type="item", name="glass-core", amount=1},
      },
    },
    ["hotair-glass-core"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="earth-shroom-sample", amount=2.0907135467},
        {type="item", name="molten-copper-barrel", amount=30.5927942034},
        {type="item", name="planter-box", amount=1},
        {type="item", name="tin-plate", amount=28.4934517691},
        {type="item", name="tuuphra-codex", amount=1},
      },
      results = {
        {type="item", name="guar", amount=1},
      },
    },
    ["guar-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="steam", amount=66.6666666667},
        {type="item", name="guar-seeds", amount=5},
        {type="item", name="sand", amount=8},
        {type="item", name="soil", amount=10},
      },
      results = {
        {type="item", name="guar", amount=10},
      },
    },
    ["acid-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=10},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="acid-refined-concrete", amount=3},
      },
    },
    ["black-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="carbon-black", amount=1},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="black-refined-concrete", amount=3},
      },
    },
    ["blue-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="blue-refined-concrete", amount=3},
      },
    },
    ["cyan-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=10},
        {type="item", name="hazard-concrete", amount=2.1386632416},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=3},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=1},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="orange-refined-concrete", amount=3},
      },
    },
    ["purple-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vpulp3", amount=5},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="purple-refined-concrete", amount=3},
      },
    },
    ["brown-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="refined-concrete", amount=2},
        {type="item", name="used-comb", amount=1},
      },
      results = {
        {type="item", name="brown-refined-concrete", amount=3},
      },
    },
    ["green-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="cellulose", amount=0.729948964257},
        {type="item", name="guar", amount=1},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=3},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="chromium", amount=1.49375850133},
        {type="item", name="ti-rejects", amount=1},
      },
      results = {
        {type="item", name="pink-refined-concrete", amount=3},
      },
    },
    ["red-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="blood", amount=15},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="red-refined-concrete", amount=3},
      },
    },
    ["yellow-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=1.43809879107},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="yellow-refined-concrete", amount=3},
      },
    },
    ["ipod"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=40},
        {type="item", name="inductor1", amount=204.821378024},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="lead-plate", amount=298.940169967},
        {type="item", name="plastic-bar", amount=104.224755655},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=50},
      },
      results = {
        {type="item", name="ipod", amount=1},
      },
    },
    ["kicalk-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=150},
        {type="fluid", name="steam", amount=166.666666667},
        {type="item", name="ash", amount=10},
        {type="item", name="clay", amount=4},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="kicalk-seeds", amount=15},
        {type="item", name="powdered-biomass", amount=4.73031190486},
        {type="item", name="sand", amount=10},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=20},
      },
    },
    ["kicalk-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="water", amount=1000},
        {type="item", name="kicalk", amount=2},
        {type="item", name="kicalk-seeds", amount=10},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="soil", amount=27.0769230769},
      },
      results = {
        {type="item", name="kicalk", amount=0.5},
        {type="item", name="kicalk-mk02", amount=0.005},
        {type="item", name="kicalk-seeds-mk02", amount=0.02},
      },
    },
    ["kicalk-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=400},
        {type="fluid", name="flutec-pp6", amount=50},
        {type="item", name="kicalk-seeds-mk02", amount=5},
        {type="item", name="rich-clay", amount=10},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="kicalk-mk02", amount=5},
        {type="item", name="kicalk-seeds", amount=1.5},
        {type="item", name="kicalk-seeds-mk02", amount=0.5},
      },
    },
    ["meat-to-phosphate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="skin", amount=3.79547265938},
      },
      results = {
        {type="item", name="phosphate-rock", amount=3},
      },
    },
    ["wood-seeds-to-phosphate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="artificial-blood", amount=200},
        {type="fluid", name="fetal-serum", amount=100},
        {type="item", name="alien-sample-02", amount=10},
        {type="item", name="alien-sample01", amount=63.2130101378},
        {type="item", name="cdna", amount=30},
        {type="item", name="earth-generic-sample", amount=10},
        {type="item", name="lens", amount=2},
      },
      results = {
        {type="item", name="ocula", amount=1},
      },
    },
    ["py-logo-15tiles"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=200},
        {type="item", name="py-iron-oxide", amount=45},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="wooden-chest", amount=4.69650241648},
      },
      results = {
        {type="item", name="py-logo-15tiles", amount=1},
      },
    },
    ["rail-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bolts", amount=4},
        {type="item", name="hazard-concrete", amount=8.55465296638},
        {type="item", name="solder", amount=2},
        {type="item", name="steel-plate", amount=2},
      },
      results = {
        {type="item", name="rail", amount=12},
      },
    },
    ["resorcinol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ceramic", amount=6.23828258557},
        {type="item", name="sodium-hydroxide", amount=10},
      },
      results = {
        {type="item", name="resorcinol", amount=2},
      },
    },
    ["sample-cup"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="zogna-bacteria", amount=100},
        {type="item", name="sea-sponge", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="sea-sponge", amount=0.5},
        {type="item", name="sea-sponge-mk02", amount=0.005},
      },
    },
    ["sea-sponge-sprouts-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="sea-sponge-mk02", amount=1},
      },
      results = {
        {type="item", name="sea-sponge-sprouts-mk02", amount=3},
      },
    },
    ["sea-sponge-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="bitumen", amount=1145.05801178},
        {type="fluid", name="slacked-lime", amount=50},
        {type="item", name="sea-sponge-sprouts-mk02", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="sea-sponge-mk02", amount=0.8},
      },
    },
    ["sea-sponge-sprouts-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="sea-sponge-mk02", amount=1},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=4},
      },
    },
    ["seaweed-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=50},
        {type="fluid", name="water", amount=214.671007537},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="item", name="seaweed", amount=30},
      },
    },
    ["seaweed-mk03"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tailings", amount=75},
        {type="fluid", name="water-saline", amount=200},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="molybdenum-oxide", amount=10},
        {type="item", name="seaweed-mk02", amount=5},
      },
      results = {
        {type="item", name="seaweed-mk03", amount=1},
      },
    },
    ["tuuphra-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=50},
        {type="fluid", name="water", amount=100},
        {type="item", name="ash", amount=5},
        {type="item", name="biomass", amount=10},
        {type="item", name="coarse", amount=10},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="limestone", amount=7.64705882353},
        {type="item", name="tuuphra-seeds", amount=10},
      },
      results = {
        {type="item", name="tuuphra", amount=8},
      },
    },
    ["tuuphra-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="water", amount=1000},
        {type="item", name="coarse", amount=20},
        {type="item", name="manure", amount=15},
        {type="item", name="soil", amount=100},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="tuuphra-seeds", amount=10},
      },
      results = {
        {type="item", name="tuuphra", amount=0.5},
        {type="item", name="tuuphra-mk02", amount=0.005},
      },
    },
    ["tuuphra-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=369.715976556},
        {type="fluid", name="phosphoric-acid", amount=300},
        {type="item", name="biomass", amount=100},
        {type="item", name="fertilizer", amount=30},
        {type="item", name="lime", amount=50},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="tuuphra-mk02", amount=6.5},
      },
    },
    ["xenogenic-from-bonemeal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=100},
        {type="item", name="skin", amount=1.68472467133},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=85},
      },
    },
    ["xenogenic-from-bones"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="bones", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=45},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="brain", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=20},
      },
    },
    ["xenogenic-from-chitin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="bones", amount=19.2477848549},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=70},
      },
    },
    ["xenogenic-from-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=150},
        {type="item", name="skin", amount=2.25617405561},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=20},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="brain", amount=1.59332273997},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=40},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="mukmoux-fat", amount=11.0807053817},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=60},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="meat", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=30},
      },
    },
    ["Moss-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="fluid", name="water", amount=214.671007537},
        {type="item", name="coarse", amount=5},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="moss", amount=24},
      },
    },
    ["moss-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="moss", amount=5},
        {type="item", name="sodium-alginate", amount=1},
        {type="item", name="urea", amount=1},
        {type="item", name="wood", amount=5},
      },
      results = {
        {type="item", name="moss-mk02", amount=0.02},
      },
    },
    ["moss-mk02r"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrogen", amount=743.584370115},
        {type="fluid", name="xenogenic-cells", amount=100},
        {type="item", name="moss-gen", amount=3},
        {type="item", name="moss-mk02", amount=2},
        {type="item", name="raw-borax", amount=8.81156537295},
        {type="item", name="retrovirus", amount=12.7493780878},
        {type="item", name="solidified-sarcorus", amount=1},
      },
      results = {
        {type="item", name="moss-mk02", amount=5},
      },
    },
    ["biomass-molten-salt-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-salt", amount=400},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=400},
      },
    },
    ["coal-molten-salt-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-salt", amount=500},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["fatty-acids-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="sulfuric-acid", amount=129.174930646},
        {type="item", name="seaweed", amount=100},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=50},
      },
    },
    ["oleochemicals-to-fatty-acids"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=100},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=50},
      },
    },
    ["perylene"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="benzene", amount=150},
        {type="fluid", name="tar", amount=100},
        {type="item", name="navens", amount=5},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="p2s5", amount=5},
      },
      results = {
        {type="fluid", name="perylene", amount=50},
      },
    },
    ["geo-he-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=600},
        {type="fluid", name="water", amount=131.25},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["oil-molten-salt-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetone", amount=1977.83282574},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["organic-acid-anhydride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=100},
        {type="fluid", name="geothermal-water", amount=100},
        {type="fluid", name="phosphoric-acid", amount=100},
        {type="item", name="sodium-carbonate", amount=1.09575143767},
      },
      results = {
        {type="fluid", name="organic-acid-anhydride", amount=100},
      },
    },
    ["processed-fatty-acids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=100},
        {type="fluid", name="sulfuric-acid", amount=242.714036168},
      },
      results = {
        {type="fluid", name="processed-fatty-acids", amount=50},
      },
    },
    ["middle-processed-lard"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="lime", amount=1.62040107521},
        {type="item", name="skin", amount=2.25617405561},
      },
      results = {
        {type="fluid", name="middle-processed-lard", amount=20},
        {type="fluid", name="steam", amount=500},
        {type="fluid", name="tar", amount=50},
      },
    },
    ["he-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=100},
        {type="fluid", name="pressured-water", amount=75},
      },
      results = {
        {type="fluid", name="molten-salt", amount=100},
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["pure-trichlorosilane"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="trichlorosilane", amount=50},
      },
      results = {
        {type="fluid", name="pure-trichlorosilane", amount=50},
        {type="item", name="copper-ore", amount=0.3},
        {type="item", name="iron-ore", amount=0.3},
        {type="item", name="ore-aluminium", amount=0.3},
      },
    },
    ["skin-fatty-acids"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="middle-processed-lard", amount=20},
        {type="item", name="skin", amount=50},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=50},
      },
    },
    ["fatty-acids"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=50},
        {type="fluid", name="middle-processed-lard", amount=50},
        {type="item", name="coke", amount=6.37736409924},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=70},
      },
    },
    ["carbon-sulfide"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="glycerol", amount=30},
        {type="fluid", name="hydrogen-chloride", amount=150},
        {type="fluid", name="oleochemicals", amount=10},
      },
      results = {
        {type="fluid", name="ech", amount=30},
      },
    },
    ["etching"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=50},
        {type="fluid", name="phosphoric-acid", amount=100},
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="skin", amount=4.51234811122},
      },
      results = {
        {type="fluid", name="etching", amount=150},
      },
    },
    ["ethylene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methane", amount=50},
        {type="fluid", name="pressured-air", amount=200},
        {type="item", name="coke", amount=6.72164961466},
      },
      results = {
        {type="fluid", name="ethylene", amount=60},
        {type="fluid", name="water", amount=50},
      },
    },
    ["guts-to-acetic-acid"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="guts", amount=20},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=60},
      },
    },
    ["meat-to-cyanic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="guts", amount=4.58098394025},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=50},
      },
    },
    ["methane-methanal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methane", amount=30},
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="molybdenum-ore", amount=3},
      },
      results = {
        {type="fluid", name="methanal", amount=100},
      },
    },
    ["nitrobenzene"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="pressured-air", amount=100},
        {type="fluid", name="propene", amount=50},
        {type="item", name="chromium", amount=0.999426246416},
        {type="item", name="copper-plate", amount=2},
      },
      results = {
        {type="fluid", name="acetone", amount=50},
      },
    },
    ["ethylene-from-fruit"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="graphite", amount=10},
        {type="item", name="nexelit-matrix", amount=15.8203654207},
        {type="item", name="pu-239", amount=1},
      },
      results = {
        {type="item", name="fuelrod-mk01", amount=1},
      },
    },
    ["grade-1-u"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="uranium-ore", amount=5},
      },
      results = {
        {type="item", name="grade-1-u", amount=1},
        {type="item", name="grade-2-u", amount=0.2},
        {type="item", name="stone", amount=1},
      },
    },
    ["grade-2-u-crush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-1-u", amount=1.09848484848},
      },
      results = {
        {type="item", name="powdered-u", amount=1},
        {type="item", name="sand", amount=0.5},
      },
    },
    ["u-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=300},
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="item", name="uranium-ore", amount=103.888888889},
      },
      results = {
        {type="fluid", name="u-pulp-01", amount=100},
      },
    },
    ["grade-1-u-recrush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="uranium-ore", amount=7.33333333333},
      },
      results = {
        {type="item", name="grade-2-u", amount=1},
        {type="item", name="gravel", amount=0.5},
      },
    },
    ["u-pulp-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="u-pulp-01", amount=150},
        {type="fluid", name="water", amount=900},
      },
      results = {
        {type="fluid", name="u-pulp-02", amount=100},
      },
    },
    ["u-pulp-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tar", amount=509.885640163},
        {type="fluid", name="u-pulp-02", amount=150},
      },
      results = {
        {type="fluid", name="u-pulp-03", amount=100},
      },
    },
    ["u-rich-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="u-pulp-03", amount=150},
        {type="item", name="grade-2-iron", amount=1.99606299213},
      },
      results = {
        {type="item", name="yellow-cake", amount=5},
      },
    },
    ["cladded-core"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="aramid", amount=1},
        {type="item", name="cladding", amount=1},
        {type="item", name="glass-core", amount=1},
      },
      results = {
        {type="item", name="cladded-core", amount=1},
      },
    },
    ["cladding"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=60},
        {type="fluid", name="nitrobenzene", amount=50},
        {type="item", name="glass", amount=5},
      },
      results = {
        {type="item", name="cladding", amount=1},
      },
    },
    ["copper-coating"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="cladded-core", amount=1},
        {type="item", name="copper-plate", amount=10},
      },
      results = {
        {type="item", name="copper-coating", amount=2},
      },
    },
    ["filtration-media-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="active-carbon", amount=3},
        {type="item", name="cellulose", amount=5},
        {type="item", name="lime", amount=15.7830216682},
        {type="item", name="pure-sand", amount=30},
      },
      results = {
        {type="item", name="filtration-media", amount=3},
      },
    },
    ["iron-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=50},
        {type="item", name="pipe", amount=3.27428099488},
      },
      results = {
        {type="item", name="iron-oxide", amount=10},
      },
    },
    ["kevlar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tar", amount=940.920602935},
        {type="fluid", name="tpa", amount=50},
        {type="item", name="nylon-parts", amount=23.5422138249},
        {type="item", name="ppd", amount=5},
      },
      results = {
        {type="item", name="kevlar", amount=5},
      },
    },
    ["kevlar-coating"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="kevlar", amount=1},
        {type="item", name="lens", amount=16.334637441},
      },
      results = {
        {type="item", name="kevlar-coating", amount=1},
      },
    },
    ["lab-instrument-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bio-sample01", amount=2.98481886385},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="ground-sample01", amount=23.8492539075},
        {type="item", name="nexelit-plate", amount=13.9783864263},
        {type="item", name="rubber", amount=10},
      },
      results = {
        {type="item", name="lab-instrument", amount=4},
      },
    },
    ["optical-fiber"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="limestone", amount=11.9264421018},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=50},
      },
    },
    ["ppd"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=500},
        {type="fluid", name="chlorine", amount=400},
        {type="fluid", name="nitrobenzene", amount=50},
      },
      results = {
        {type="item", name="ppd", amount=10},
      },
    },
    ["lime-from-shell"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="shell", amount=2},
      },
      results = {
        {type="item", name="lime", amount=10},
      },
    },
    ["nbfe-coating"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="niobium-oxide", amount=6.07751515425},
        {type="item", name="ppd", amount=6.76420841477},
      },
      results = {
        {type="item", name="nbfe-coating", amount=1},
      },
    },
    ["py-sodium-hydroxide"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=29.4971583889},
        {type="item", name="sodium-sulfate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="starch", amount=10},
      },
    },
    ["aramid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="fluid", name="tpa", amount=50},
        {type="item", name="glass", amount=16.4133677177},
        {type="item", name="molybdenum-plate", amount=5},
        {type="item", name="sodium-hydroxide", amount=10},
        {type="item", name="zinc-plate", amount=2.1593730768},
      },
      results = {
        {type="item", name="aramid", amount=8},
      },
    },
    ["sodium-sulfate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-bisulfate", amount=1},
        {type="item", name="sodium-hydroxide", amount=2.07811750601},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=40},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["starch-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="resistor1", amount=2.76457766782},
        {type="item", name="sodium-bisulfate", amount=0.939186792226},
        {type="item", name="sodium-sulfate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="starch", amount=10},
      },
    },
    ["casein-melamine"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=50},
        {type="item", name="casein", amount=5},
      },
      results = {
        {type="item", name="melamine", amount=10},
      },
    },
    ["fecr-alloy"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="chromium", amount=1},
        {type="item", name="graphite", amount=3},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="fecr-alloy", amount=2},
      },
    },
    ["phenol-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=300},
        {type="item", name="nichrome", amount=6.93996955494},
      },
      results = {
        {type="item", name="phenol", amount=6},
      },
    },
    ["silicon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="chromite-sand", amount=23.281896514},
        {type="item", name="lime", amount=9.89360230869},
      },
      results = {
        {type="item", name="silicon", amount=10},
      },
    },
    ["sodium-silicate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="refsyngas", amount=150},
        {type="item", name="gunpowder", amount=7.95299984621},
        {type="item", name="starch", amount=3.18870340732},
      },
      results = {
        {type="item", name="sodium-silicate", amount=1},
      },
    },
    ["bisphenol-a"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetone", amount=20},
        {type="fluid", name="hydrogen-chloride", amount=50},
        {type="item", name="powdered-phosphate-rock", amount=22.7443143371},
      },
      results = {
        {type="item", name="bisphenol-a", amount=3},
      },
    },
    ["melamine-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methanal", amount=40},
        {type="item", name="graphite", amount=23.4326028368},
      },
      results = {
        {type="item", name="melamine", amount=20},
      },
    },
    ["phenol-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="agar", amount=3.12782864857},
      },
      results = {
        {type="item", name="phenol", amount=5},
      },
    },
    ["silica-powder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="silica-powder", amount=10},
      },
    },
    ["bakelite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methanal", amount=20},
        {type="item", name="biomass", amount=30},
        {type="item", name="equipment-chassi", amount=0.865892004914},
        {type="item", name="sodium-silicate", amount=1.08139360243},
      },
      results = {
        {type="item", name="bakelite", amount=5},
      },
    },
    ["epoxy"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ech", amount=30},
        {type="item", name="bisphenol-a", amount=6},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="sodium-hydroxide", amount=5},
      },
      results = {
        {type="item", name="epoxy", amount=4},
      },
    },
    ["nylon2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="blood", amount=100},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="blood-meal", amount=1},
      },
    },
    ["nylon-parts"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="nylon", amount=1},
      },
      results = {
        {type="item", name="nylon-parts", amount=5},
      },
    },
    ["nylon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=300},
        {type="fluid", name="water", amount=900},
        {type="item", name="chromium", amount=1},
        {type="item", name="filtration-media", amount=6.85888443905},
        {type="item", name="phenol", amount=5},
      },
      results = {
        {type="item", name="nylon", amount=5},
      },
    },
    ["boric-acid-hcl"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=300},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=75},
        {type="fluid", name="tailings", amount=200},
      },
    },
    ["manure-to-nitrogen"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="manure", amount=8},
      },
      results = {
        {type="fluid", name="nitrogen", amount=50},
      },
    },
    ["mibc"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetone", amount=50},
        {type="fluid", name="petroleum-gas", amount=150},
        {type="item", name="copper-plate", amount=5},
      },
      results = {
        {type="fluid", name="mibc", amount=200},
      },
    },
    ["trichlorosilane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrogen", amount=311.451594238},
        {type="item", name="chromium", amount=4.88409295004},
      },
      results = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="trichlorosilane", amount=50},
      },
    },
    ["eg-si"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="grade-2-ti", amount=2.52212197109},
      },
      results = {
        {type="item", name="grade-4-ti", amount=1},
      },
    },
    ["concentrated-ti"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="item", name="concentrated-ti", amount=1},
        {type="item", name="iron-oxide", amount=0.5},
        {type="item", name="nexelit-ore", amount=0.5},
      },
    },
    ["high-grade-ti-powder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="purified-ti-pulp", amount=100},
      },
      results = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
    },
    ["hotair-titanium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-titanium", amount=100},
        {type="item", name="borax", amount=3.03307035269},
      },
      results = {
        {type="item", name="titanium-plate", amount=25},
      },
    },
    ["molten-titanium-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
        {type="item", name="coal-dust", amount=2.6152759431},
        {type="item", name="ti-enriched-dust", amount=2},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=40},
      },
    },
    ["molten-titanium-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
        {type="item", name="limestone", amount=3},
        {type="item", name="powdered-ti", amount=9.10460244259},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=510},
      },
    },
    ["powdered-ti"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=242.702383955},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="titanium-plate", amount=20},
      },
    },
    ["titanium-plate-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-1-ti", amount=168.247839676},
      },
      results = {
        {type="item", name="titanium-plate", amount=147},
      },
    },
    ["purified-ti-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tar", amount=764.828460244},
        {type="fluid", name="ti-pulp-03", amount=100},
      },
      results = {
        {type="fluid", name="purified-ti-pulp", amount=50},
        {type="fluid", name="ti-overflow-waste", amount=25},
      },
    },
    ["ti-enriched-dust"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="powdered-ti", amount=1},
      },
      results = {
        {type="item", name="ti-enriched-dust", amount=1},
        {type="item", name="ti-rejects", amount=0.5},
      },
    },
    ["molten-stainless-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-steel", amount=100},
        {type="item", name="cermet", amount=2.53485762395},
        {type="item", name="niobium-plate", amount=2},
        {type="item", name="oil-sand", amount=6.83804222823},
        {type="item", name="phosphate-rock", amount=4},
        {type="item", name="sic", amount=4.90071137668},
        {type="item", name="sulfur", amount=1},
        {type="item", name="zinc-plate", amount=2.3110725405},
      },
      results = {
        {type="fluid", name="molten-stainless-steel", amount=50},
      },
    },
    ["hotair-stainless-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-steel", amount=417.014103048},
        {type="item", name="aramid", amount=1},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="stainless-steel", amount=13},
      },
    },
    ["stainless-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-steel", amount=417.014103048},
        {type="item", name="aramid", amount=1},
        {type="item", name="borax", amount=6.06614070538},
      },
      results = {
        {type="item", name="stainless-steel", amount=10},
      },
    },
    ["guar-gum"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-seeds", amount=150},
        {type="item", name="plastic-bar", amount=1},
      },
      results = {
        {type="item", name="guar-gum", amount=3},
      },
    },
    ["long-handed-inserter-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="belt", amount=2},
        {type="item", name="fast-inserter", amount=2.85352666274},
        {type="item", name="inductor1", amount=20.4821378024},
        {type="item", name="nichrome", amount=2},
        {type="item", name="small-parts-02", amount=1},
        {type="item", name="vitreloy", amount=0.576493067052},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=15},
      },
    },
    ["small-parts-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aramid", amount=0.676576671209},
        {type="item", name="belt", amount=2},
        {type="item", name="carbon-black", amount=2.59150623173},
        {type="item", name="iron-stick", amount=3},
        {type="item", name="lead-plate", amount=5.97880339934},
        {type="item", name="nexelit-plate", amount=1},
        {type="item", name="nickel-plate", amount=1.25842375927},
        {type="item", name="nylon-parts", amount=4.70844276499},
        {type="item", name="pipe", amount=2.98745536134},
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
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="blade-mk02", amount=1.02996288947},
        {type="item", name="cellulose", amount=12.1109745986},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="inserter", amount=5},
        {type="item", name="nbfe-alloy", amount=15},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="yaw-drive-mk01", amount=0.551556163233},
      },
      results = {
        {type="item", name="fast-inserter", amount=15},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="belt", amount=10},
        {type="item", name="duralumin", amount=44.9082911978},
        {type="item", name="small-parts-02", amount=7},
        {type="item", name="transport-belt", amount=15},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=15},
      },
    },
    ["rotor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=2.2797623623},
        {type="item", name="titanium-plate", amount=29.6947590798},
      },
      results = {
        {type="item", name="rotor", amount=1},
      },
    },
    ["stator"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="copper-cable", amount=100},
        {type="item", name="plastic-bar", amount=3},
      },
      results = {
        {type="item", name="stator", amount=1},
      },
    },
    ["electric-engine-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="lubricant", amount=50},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="bolts", amount=20},
        {type="item", name="rotor", amount=1},
        {type="item", name="small-parts-01", amount=21.136356108},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="stator", amount=1},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=3},
      },
    },
    ["nexelit-power-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="stainless-steel", amount=1},
        {type="item", name="stone-brick", amount=8.17461291059},
      },
      results = {
        {type="item", name="nexelit-power-pole", amount=1},
      },
    },
    ["anemometer-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="silica-powder", amount=102.720996962},
        {type="item", name="small-parts-02", amount=15},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="anemometer-mk02", amount=1},
      },
    },
    ["blade-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=12.374736075},
        {type="item", name="nxsb-alloy", amount=5},
        {type="item", name="rayon", amount=5},
      },
      results = {
        {type="item", name="blade-mk02", amount=1},
      },
    },
    ["brake-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="agar", amount=26.0283963464},
        {type="item", name="bakelite", amount=10},
        {type="item", name="duralumin", amount=22.4541455989},
        {type="item", name="melamine", amount=31.2406823725},
        {type="item", name="shaft-mk01", amount=3.06782744773},
        {type="item", name="small-parts-01", amount=77.2136480159},
        {type="item", name="starch", amount=172.406258488},
      },
      results = {
        {type="item", name="brake-mk02", amount=1},
      },
    },
    ["controler-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="battery-mk01", amount=14.2367500279},
        {type="item", name="electronics-mk01", amount=1.06950493725},
        {type="item", name="fecr-alloy", amount=40.9425658581},
        {type="item", name="mechanical-parts-01", amount=3.77155924816},
        {type="item", name="nxsb-alloy", amount=8.12071702098},
        {type="item", name="small-lamp", amount=10},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="controler-mk02", amount=1},
      },
    },
    ["electronics-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="diode", amount=10.8034473081},
        {type="item", name="glass", amount=4},
        {type="item", name="inductor2", amount=1.51512423479},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="phenolicboard", amount=300.189060394},
        {type="item", name="resistor2", amount=15},
        {type="item", name="silica-powder", amount=75.5186816692},
        {type="item", name="silicon", amount=132.896008072},
        {type="item", name="steel-plate", amount=17.4794899588},
      },
      results = {
        {type="item", name="electronics-mk02", amount=3},
      },
    },
    ["gearbox-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="lubricant", amount=200},
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="belt", amount=10},
        {type="item", name="duralumin", amount=212.18351754},
        {type="item", name="niobium-powder", amount=32.0783037209},
        {type="item", name="nxsb-alloy", amount=8},
        {type="item", name="stainless-steel", amount=40},
        {type="item", name="titanium-plate", amount=25},
        {type="item", name="tower-mk01", amount=1.23792331642},
      },
      results = {
        {type="item", name="gearbox-mk02", amount=1},
      },
    },
    ["hotair-shaft-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-steel", amount=417.014103048},
        {type="item", name="sand-casting", amount=2},
        {type="item", name="shaft-mk01", amount=1},
      },
      results = {
        {type="item", name="shaft-mk02", amount=2},
      },
    },
    ["hotair-vane-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="item", name="nichrome", amount=28.3860101346},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="vane-mk02", amount=2},
      },
    },
    ["shaft-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=100},
        {type="item", name="gravel", amount=5.49070236516},
        {type="item", name="shaft-mk01", amount=1},
      },
      results = {
        {type="item", name="shaft-mk02", amount=1},
      },
    },
    ["utility-box-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=3},
        {type="item", name="nexelit-plate", amount=182.749411021},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="stone-brick", amount=17.0149253731},
        {type="item", name="tower-mk01", amount=1.46777257813},
        {type="item", name="zinc-acetate", amount=9.91471061357},
      },
      results = {
        {type="item", name="utility-box-mk02", amount=1},
      },
    },
    ["vane-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="kevlar", amount=20},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["nacelle-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="electronics-mk02", amount=1.1330681843},
        {type="item", name="intermetallics", amount=87.8225736395},
        {type="item", name="mechanical-parts-01", amount=8.10459081002},
        {type="item", name="nxsb-alloy", amount=4.06035851049},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="stainless-steel", amount=40},
        {type="item", name="tower-mk02", amount=1.29158668441},
        {type="item", name="utility-box-mk01", amount=4.92105913687},
        {type="item", name="utility-box-mk02", amount=1},
        {type="item", name="yaw-drive-mk02", amount=1},
      },
      results = {
        {type="item", name="nacelle-mk02", amount=1},
      },
    },
    ["rotor-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bakelite", amount=39.8663189627},
        {type="item", name="blade-mk02", amount=3},
        {type="item", name="bolts", amount=30},
        {type="item", name="nexelit-plate", amount=15.498124833},
        {type="item", name="rayon", amount=10},
        {type="item", name="rubber", amount=10},
      },
      results = {
        {type="item", name="rotor-mk02", amount=1},
      },
    },
    ["tower-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bio-sample", amount=49.6375592018},
        {type="item", name="electronics-mk01", amount=1.09224444969},
        {type="item", name="nxsb-alloy", amount=15},
        {type="item", name="small-parts-02", amount=20},
        {type="item", name="solder", amount=20},
        {type="item", name="stainless-steel", amount=30},
      },
      results = {
        {type="item", name="tower-mk02", amount=1},
      },
    },
    ["yaw-drive-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="coal-gas", amount=315.798835963},
        {type="item", name="brake-mk01", amount=0.52665419616},
        {type="item", name="cellulose", amount=94.6487674785},
        {type="item", name="controler-mk01", amount=3.39045090496},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="eva", amount=20},
        {type="item", name="moss-gen", amount=15.6294515342},
        {type="item", name="niobium-oxide", amount=182.325454628},
        {type="item", name="pbsb-alloy", amount=62.3105608371},
        {type="item", name="small-parts-01", amount=261.474258113},
      },
      results = {
        {type="item", name="yaw-drive-mk02", amount=1},
      },
    },
    ["efficiency-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=3.889912956},
        {type="item", name="brake-mk02", amount=1.75035558095},
        {type="item", name="electronics-mk02", amount=2},
      },
      results = {
        {type="item", name="efficiency-module", amount=1},
      },
    },
    ["productivity-module"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="controler-mk02", amount=1},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="utility-box-mk02", amount=1},
      },
      results = {
        {type="item", name="productivity-module", amount=1},
      },
    },
    ["speed-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="controler-mk02", amount=1},
        {type="item", name="rotor-mk02", amount=1.25539649961},
        {type="item", name="tower-mk02", amount=1.96802076218},
      },
      results = {
        {type="item", name="speed-module", amount=1},
      },
    },
    ["bhoddos-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="engine-unit", amount=5.50474794993},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="bhoddos-codex", amount=1},
      },
    },
    ["cadaveric-arum-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="raw-borax", amount=93.7347025703},
        {type="item", name="starch", amount=23.827722771},
      },
      results = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
    },
    ["navens-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="navens-codex", amount=1},
      },
    },
    ["rennea-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=204.821378024},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="rennea-codex", amount=1},
      },
    },
    ["grod-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="grod-codex", amount=1},
      },
    },
    ["yotoi-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=341.368963374},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="automation-science-pack", amount=121.066542419},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="grod-codex", amount=1},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=1},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="automation-science-pack", amount=242.133084838},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="rennea-codex", amount=1},
      },
      results = {
        {type="item", name="earth-sunflower-sample", amount=1},
      },
    },
    ["earth-tropical-tree-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=100},
        {type="item", name="yotoi-codex", amount=1},
      },
      results = {
        {type="item", name="earth-tropical-tree-sample", amount=1},
      },
    },
    ["cadaveric-arum-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="alien-sample01", amount=89.7703859006},
        {type="item", name="bio-sample", amount=7},
        {type="item", name="earth-potato-sample", amount=0.544099090984},
        {type="item", name="earth-sea-sponge-sample", amount=1.81917883121},
        {type="item", name="planter-box", amount=1},
        {type="item", name="tuuphra-codex", amount=2},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=2},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="pressured-water-barrel", amount=24.4888224372},
      },
      results = {
        {type="item", name="cadaveric-arum-seeds", amount=8},
      },
    },
    ["cadaveric-arum-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="coal-gas", amount=100},
        {type="fluid", name="water", amount=500},
        {type="item", name="cadaveric-arum-seeds", amount=5},
        {type="item", name="sand", amount=5},
        {type="item", name="stone-wool", amount=1},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=4},
      },
    },
    ["cadaveric-acidgas-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=100},
        {type="item", name="cadaveric-arum-seeds", amount=2},
      },
    },
    ["grod-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=78.431372549},
        {type="item", name="alien-sample01", amount=4},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-jute-sample", amount=1},
        {type="item", name="planter-box", amount=1},
        {type="item", name="rennea-codex", amount=1.5636696342},
      },
      results = {
        {type="item", name="grod", amount=1},
      },
    },
    ["dried-grods"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="grod", amount=8},
      },
      results = {
        {type="item", name="dried-grods", amount=5},
      },
    },
    ["dried-grods-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=25},
        {type="item", name="grod", amount=5},
      },
      results = {
        {type="item", name="dried-grods", amount=6},
      },
    },
    ["grod-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="coal-dust", amount=3.33319482944},
        {type="item", name="grod-seeds", amount=5},
        {type="item", name="limestone", amount=5},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="grod", amount=10},
      },
    },
    ["rennea-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="bio-sample", amount=20},
        {type="item", name="cdna", amount=10},
        {type="item", name="cytostatics", amount=22.3130338157},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="fawogae", amount=56.5430998413},
        {type="item", name="planter-box", amount=1},
        {type="item", name="ulric-codex", amount=2.29181557039},
      },
      results = {
        {type="item", name="rennea", amount=2},
      },
    },
    ["rennea-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=50},
        {type="fluid", name="water", amount=100},
        {type="item", name="coarse", amount=8},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="limestone", amount=3.82352941176},
        {type="item", name="rennea-seeds", amount=4},
      },
      results = {
        {type="item", name="rennea", amount=4},
      },
    },
    ["bhoddos-to-ti"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="fish", amount=10},
      },
      results = {
        {type="item", name="ore-tin", amount=25},
      },
    },
    ["grod-to-zinc"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="grod-seeds", amount=10},
      },
      results = {
        {type="item", name="ore-zinc", amount=5},
      },
    },
    ["meat-to-chromium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="guts", amount=2.29049197012},
      },
      results = {
        {type="item", name="ore-chromium", amount=15},
      },
    },
    ["navens-to-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="navens", amount=1},
      },
      results = {
        {type="item", name="ore-tin", amount=17},
      },
    },
    ["yotoi-leaves-to-chromium"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-leaves", amount=5},
      },
      results = {
        {type="item", name="ore-chromium", amount=17},
      },
    },
    ["yotoi-seed-to-chromium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-leaves", amount=3.49288747554},
      },
      results = {
        {type="item", name="ore-chromium", amount=25},
      },
    },
    ["cadaveric-pb"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
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
      ingredients = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="ralesia", amount=43.1733693468},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="cu-biomass", amount=10},
      },
    },
    ["tuuphra-nacl"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="nacl-biomass", amount=10},
      },
    },
    ["grod-sn"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="grod", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="sn-biomass", amount=10},
      },
    },
    ["navens-fe"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="navens", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=50},
        {type="item", name="fe-biomass", amount=8},
      },
    },
    ["yotoi-fe"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
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
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=8},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="moondrop-seeds-mk02", amount=0.967207243507},
        {type="item", name="soil", amount=20},
      },
      results = {
        {type="item", name="moondrop", amount=16},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methane", amount=100},
        {type="item", name="fe-biomass", amount=5},
        {type="item", name="moondrop-seeds", amount=10},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=15},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
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
      ingredients = {
        {type="item", name="moondrop-mk02", amount=0.534090471847},
      },
      results = {
        {type="fluid", name="fuel-oil", amount=400},
        {type="item", name="ash", amount=10},
      },
    },
    ["chloroethanol"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene", amount=50},
        {type="fluid", name="ethylene-chlorohydrin", amount=100},
        {type="fluid", name="water", amount=300},
      },
      results = {
        {type="fluid", name="chloroethanol", amount=100},
      },
    },
    ["ethylene-glycol"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="chloroethanol", amount=100},
        {type="fluid", name="slacked-lime", amount=20},
        {type="fluid", name="water", amount=100},
        {type="item", name="pure-sand", amount=5},
      },
      results = {
        {type="fluid", name="ethylene-glycol", amount=150},
      },
    },
    ["ferrite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="gravel", amount=34.5046990739},
        {type="item", name="nichrome", amount=3},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="ferrite", amount=4},
      },
    },
    ["lead-container"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="aramid", amount=3},
        {type="item", name="nbfe-alloy", amount=10},
        {type="item", name="pbsb-alloy", amount=4},
      },
      results = {
        {type="item", name="lead-container", amount=1},
      },
    },
    ["nexelit-matrix"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=483.449797294},
        {type="fluid", name="vacuum", amount=100},
        {type="item", name="bakelite", amount=6.61664270328},
        {type="item", name="glass", amount=3.19386666667},
      },
      results = {
        {type="item", name="nexelit-matrix", amount=4},
      },
    },
    ["nuclear-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="boric-acid", amount=100},
        {type="fluid", name="industrial-solvent", amount=100},
        {type="item", name="automation-science-pack", amount=1},
        {type="item", name="pu-238", amount=1},
      },
      results = {
        {type="item", name="nuclear-sample", amount=1},
      },
    },
    ["sodium-chlorate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=150},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="item", name="sodium-chlorate", amount=5},
      },
    },
    ["steam-heating"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="tuuphra-mk02", amount=0.5695727793},
      },
      results = {
        {type="item", name="molybdenum-ore", amount=5},
      },
    },
    ["plutonium-fuel-cell"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="molybdenum-plate", amount=5},
        {type="item", name="nichrome", amount=4.95952549808},
        {type="item", name="niobium-plate", amount=8},
        {type="item", name="u-238", amount=28},
      },
      results = {
        {type="item", name="mox-fuel-cell", amount=2},
      },
    },
    ["crmoni"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="boron-trioxide", amount=4.13371893965},
        {type="item", name="nickel-plate", amount=10},
        {type="item", name="vanadium-oxide", amount=1.63883894502},
      },
      results = {
        {type="item", name="crmoni", amount=2},
      },
    },
    ["nbalti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="niobium-powder", amount=3.20783037209},
        {type="item", name="tin-plate", amount=3.54755013851},
        {type="item", name="titanium-plate", amount=10},
      },
      results = {
        {type="item", name="nbalti", amount=2},
      },
    },
    ["ptcda"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=100},
        {type="fluid", name="perylene", amount=100},
        {type="item", name="chromium", amount=6.48947052473},
        {type="item", name="plastic-bar", amount=1},
      },
      results = {
        {type="item", name="ptcda", amount=1},
      },
    },
    ["self-assembly-monolayer"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pitch", amount=1354.93223933},
        {type="item", name="fenxsb-alloy", amount=22.7599428508},
        {type="item", name="nbalti", amount=1},
        {type="item", name="rayon", amount=3},
        {type="item", name="stone-brick", amount=6.79292537313},
        {type="item", name="vitreloy", amount=2.09217238292},
      },
      results = {
        {type="item", name="self-assembly-monolayer", amount=1},
      },
    },
    ["brain-cartridge-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=50},
        {type="fluid", name="scrude", amount=50},
        {type="item", name="nbalti", amount=1},
        {type="item", name="skin", amount=30},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=40.4049021305},
        {type="item", name="brain", amount=15},
        {type="item", name="distilator", amount=2.88831012915},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="nickel-plate", amount=25},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="tar-processing-unit", amount=0.616177902248},
        {type="item", name="titanium-plate", amount=35},
      },
      results = {
        {type="item", name="vat-brain", amount=1},
      },
    },
    ["mk02-locomotive"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="brake-mk02", amount=4},
        {type="item", name="copper-cable", amount=414.281415084},
        {type="item", name="copper-plate", amount=266.178176851},
        {type="item", name="electric-engine-unit", amount=2.12280843582},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="inductor1", amount=136.54758535},
        {type="item", name="latex", amount=15.6015049716},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="niobium-powder", amount=64.1566074418},
        {type="item", name="rubber", amount=40},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="stainless-steel", amount=59.0602291584},
        {type="item", name="steam-engine", amount=16.6975635146},
        {type="item", name="titanium-plate", amount=137.083384635},
        {type="item", name="tower-mk01", amount=3.20784046854},
      },
      results = {
        {type="item", name="mk02-locomotive", amount=1},
      },
    },
    ["mk02-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ceramic", amount=232.039563759},
        {type="item", name="copper-cable", amount=48.831025114},
        {type="item", name="duralumin", amount=20},
        {type="item", name="guar-gum", amount=20.1880958477},
        {type="item", name="nickel-plate", amount=40},
        {type="item", name="niobium-oxide", amount=21.0361391848},
        {type="item", name="pipe", amount=21.3719614713},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="stainless-steel", amount=64.9231921631},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="titanium-plate", amount=91.3889230901},
        {type="item", name="yaw-drive-mk01", amount=2.17568965321},
      },
      results = {
        {type="item", name="mk02-wagon", amount=1},
      },
    },
    ["mk02-fluid-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="brake-mk01", amount=4.74340417939},
        {type="item", name="duralumin", amount=20},
        {type="item", name="glass", amount=100},
        {type="item", name="intermetallics", amount=26.3467720918},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="nickel-plate", amount=40},
        {type="item", name="niobium-powder", amount=32.0783037209},
        {type="item", name="pipe", amount=298.745536134},
        {type="item", name="plastic-bar", amount=100},
        {type="item", name="rubber", amount=40},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="titanium-plate", amount=133.35408878},
      },
      results = {
        {type="item", name="mk02-fluid-wagon", amount=1},
      },
    },
    ["glycerol2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=900},
        {type="item", name="mukmoux-fat", amount=11.0807053817},
        {type="item", name="sodium-hydroxide", amount=5},
      },
      results = {
        {type="fluid", name="glycerol", amount=50},
      },
    },
    ["oleochemicals-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="refsyngas", amount=100},
        {type="item", name="dried-meat", amount=35.9483371366},
        {type="item", name="lead-plate", amount=2},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=200},
      },
    },
    ["sea-sponge-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="aramid", amount=1},
        {type="item", name="crucible", amount=0.821763210662},
        {type="item", name="crushed-quartz", amount=2},
        {type="item", name="graphite", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=100},
        {type="item", name="silicon-wafer", amount=2},
      },
    },
    ["heat-exchanger"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=123.74736075},
        {type="item", name="niobium-pipe", amount=10},
        {type="item", name="titanium-plate", amount=10},
      },
      results = {
        {type="item", name="heat-exchanger", amount=1},
      },
    },
    ["heat-pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="steel-plate", amount=10},
        {type="item", name="titanium-plate", amount=118.779036319},
      },
      results = {
        {type="item", name="heat-pipe", amount=1},
      },
    },
    ["nuclear-reactor"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=500},
        {type="item", name="concrete", amount=500},
        {type="item", name="stainless-steel", amount=500},
        {type="item", name="titanium-plate", amount=500},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=1},
      },
    },
    ["steam-turbine"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="copper-plate", amount=50},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="stainless-steel", amount=20},
      },
      results = {
        {type="item", name="steam-turbine", amount=1},
      },
    },
    ["zinc-acetate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=100},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="zinc-acetate", amount=1},
      },
    },
    ["heavy-n"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="ethanol", amount=1201.46889724},
        {type="item", name="fecr-alloy", amount=39.135155961},
        {type="item", name="reo", amount=20},
      },
      results = {
        {type="item", name="heavy-n", amount=10},
      },
    },
    ["light-n"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="phosphine-gas", amount=20},
        {type="item", name="zinc-acetate", amount=4.73851281714},
      },
      results = {
        {type="item", name="light-n", amount=10},
      },
    },
    ["p-dope"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="diborane", amount=20},
        {type="fluid", name="etching", amount=20},
        {type="item", name="bisphenol-a", amount=14.6589661169},
        {type="item", name="zinc-acetate", amount=2},
      },
      results = {
        {type="item", name="p-dope", amount=10},
      },
    },
    ["ammonium-chloride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="carbon-dioxide", amount=200},
        {type="fluid", name="hydrogen", amount=772.379416449},
        {type="item", name="salt", amount=20},
      },
      results = {
        {type="item", name="ammonium-chloride", amount=2},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["p2s5-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="u-235", amount=3},
        {type="item", name="u-238", amount=15},
      },
      results = {
        {type="item", name="uranium-fuel-cell", amount=1},
      },
    },
    ["fuel-cell-dissolve"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=1244.36376468},
        {type="fluid", name="steam", amount=83.3333333333},
        {type="item", name="depleted-uranium-fuel-cell", amount=10},
        {type="item", name="nickel-plate", amount=10.039538771},
      },
      results = {
        {type="fluid", name="sb-phosphate-1", amount=100},
      },
    },
    ["plutonium-fuel-reprocessing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-matrix", amount=135.237090549},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=14},
        {type="item", name="u-238", amount=10},
      },
    },
    ["antimony-phosphate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=698.565164808},
        {type="fluid", name="sb-phosphate-1", amount=5},
        {type="item", name="sb-oxide", amount=5},
      },
      results = {
        {type="fluid", name="purex-concentrate-1", amount=100},
        {type="item", name="sb-hpo-pu", amount=10},
      },
    },
    ["plutonium-seperation"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="plutonium-oxide", amount=5},
      },
      results = {
        {type="item", name="pu-238", amount=0.3},
        {type="item", name="pu-239", amount=7.95},
        {type="item", name="pu-240", amount=3.75},
        {type="item", name="pu-241", amount=2.25},
        {type="item", name="pu-242", amount=7.5},
      },
    },
    ["plutonium-oxidation"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
      results = {
        {type="item", name="pu-238", amount=1},
        {type="item", name="pu-242", amount=1},
      },
    },
    ["plutonium-shuffle-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="pu-241", amount=1},
        {type="item", name="u-238", amount=1.82718291881},
      },
      results = {
        {type="item", name="pu-240", amount=1},
        {type="item", name="pu-242", amount=1},
      },
    },
    ["plutonium-shuffle-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="pu-242", amount=2},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-241", amount=1},
      },
    },
    ["plutonium-shuffle-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="plutonium-oxide", amount=0.657600709825},
        {type="item", name="pu-241", amount=1},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
    },
    ["rayon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="carbon-sulfide", amount=50},
        {type="fluid", name="methanol", amount=349.878396999},
        {type="item", name="ammonium-chloride", amount=4.77323062782},
        {type="item", name="auog", amount=1.18412336798},
        {type="item", name="fiber", amount=15},
      },
      results = {
        {type="item", name="rayon", amount=5},
      },
    },
    ["battery-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="item", name="lead-plate", amount=1.84004322974},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="rayon", amount=2},
      },
      results = {
        {type="item", name="battery-mk01", amount=3},
      },
    },
    ["battery-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=248.872752937},
        {type="item", name="duralumin", amount=7.43664913561},
        {type="item", name="hydrogen-chloride-barrel", amount=10.1399350631},
        {type="item", name="lime", amount=1.62040107521},
        {type="item", name="pyrite", amount=5},
      },
      results = {
        {type="item", name="battery-mk01", amount=4},
      },
    },
    ["nas-battery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="chromium", amount=1},
        {type="item", name="graphite", amount=43.9925538395},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="rayon", amount=2},
        {type="item", name="sand", amount=23.5768261965},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="battery-mk01", amount=6},
      },
    },
    ["nexelit-battery"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=20},
        {type="fluid", name="olefin", amount=50},
        {type="item", name="aluminium-plate", amount=3.22619675211},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="nylon", amount=2},
        {type="item", name="sodium-silicate", amount=1.07166279609},
      },
      results = {
        {type="item", name="used-nexelit-battery", amount=1},
      },
    },
    ["nexelit-battery-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="washer", amount=0.79199122676},
      },
      results = {
        {type="item", name="nexelit-battery", amount=1},
      },
    },
    ["casein-mixture-03"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=100},
        {type="fluid", name="steam", amount=200},
      },
      results = {
        {type="fluid", name="fish-emulsion", amount=40},
        {type="fluid", name="fish-oil", amount=15},
        {type="item", name="fishmeal", amount=10},
      },
    },
    ["b-molasse"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="a-molasse", amount=50},
        {type="fluid", name="vacuum", amount=150},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="fluid", name="b-molasse", amount=100},
      },
    },
    ["ethanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="b-molasse", amount=50},
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="ralesia-seeds", amount=3.89783268043},
      },
      results = {
        {type="fluid", name="ethanol", amount=100},
      },
    },
    ["syrup-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="seeds-extract-01", amount=1},
        {type="item", name="sugar", amount=5},
      },
      results = {
        {type="fluid", name="syrup-01", amount=50},
      },
    },
    ["fertilizer-5"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=10},
        {type="item", name="bones", amount=6},
        {type="item", name="fine-powdered-biomass", amount=2},
        {type="item", name="sodium-carbonate", amount=1.04750857226},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="fertilizer", amount=15},
      },
    },
    ["fertilizer-fish-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-emulsion", amount=100},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["fertilizer-fish-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="fishmeal", amount=10},
      },
      results = {
        {type="item", name="fertilizer", amount=2},
      },
    },
    ["split-yellowcake"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="lens", amount=2},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="titanium-plate", amount=20.4003391757},
      },
      results = {
        {type="item", name="night-vision-equipment", amount=1},
      },
    },
    ["personal-roboport-mk2-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="belt-immunity-equipment", amount=9.87575296397},
        {type="item", name="electronic-circuit", amount=127.501431055},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="py-ze", amount=1},
        {type="item", name="small-parts-01", amount=10},
      },
      results = {
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
      },
    },
    ["belt-immunity-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=5.3532880862},
        {type="item", name="inductor1", amount=34.1368963374},
        {type="item", name="intermetallics", amount=5},
      },
      results = {
        {type="item", name="belt-immunity-equipment", amount=1},
      },
    },
    ["bio-scafold"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=200},
        {type="item", name="bonemeal", amount=5},
        {type="item", name="chitin", amount=20},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="bio-scafold", amount=1},
      },
    },
    ["bone-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=600},
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=2},
      },
    },
    ["print-bonemeal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=5},
      },
    },
    ["print-guts"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="brain", amount=30.7053665072},
      },
      results = {
        {type="item", name="guts", amount=6},
      },
    },
    ["print-meat"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="psc", amount=40},
        {type="item", name="chitin", amount=20.4900152988},
      },
      results = {
        {type="item", name="skin", amount=5},
      },
    },
    ["cellulose-gasification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=30},
        {type="fluid", name="water", amount=300},
        {type="item", name="agar", amount=5.20567926928},
      },
      results = {
        {type="fluid", name="syngas", amount=100},
      },
    },
    ["lignin-to-aromatics"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="lignin", amount=5},
      },
      results = {
        {type="fluid", name="aromatics", amount=150},
      },
    },
    ["tpa"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=50},
        {type="fluid", name="manure-bacteria", amount=20},
        {type="fluid", name="syngas", amount=257.349203947},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="fluid", name="tpa", amount=50},
      },
    },
    ["oleo-gasification"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="clay", amount=5},
        {type="item", name="nisi", amount=2},
        {type="item", name="silica-powder", amount=5},
      },
      results = {
        {type="item", name="crucible", amount=2},
      },
    },
    ["eva"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="heavy-oil", amount=200},
        {type="item", name="anemometer-mk02", amount=3.52695192918},
        {type="item", name="clay", amount=323.86019663},
        {type="item", name="controler-mk02", amount=1},
        {type="item", name="duralumin", amount=66.3073492314},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="gearbox-mk01", amount=13.0484243178},
        {type="item", name="mechanical-parts-01", amount=6},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="rayon", amount=5},
        {type="item", name="shaft-mk01", amount=1.61568419844},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="tower-mk02", amount=0.577549349128},
      },
      results = {
        {type="item", name="mechanical-parts-02", amount=6},
      },
    },
    ["sb-oxide-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="outlet-gas-02", amount=2310.56477925},
        {type="fluid", name="oxygen", amount=100},
        {type="item", name="plastic-bar", amount=10},
      },
      results = {
        {type="item", name="sb-oxide", amount=10},
      },
    },
    ["lead-acetate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=50},
        {type="fluid", name="hydrogen-peroxide", amount=50},
        {type="item", name="lead-plate", amount=3},
      },
      results = {
        {type="item", name="lead-acetate", amount=1},
      },
    },
    ["dowfroth-250"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methanol", amount=50},
        {type="fluid", name="middle-oil", amount=1007.79950116},
        {type="item", name="zinc-chloride", amount=0.723659668387},
      },
      results = {
        {type="fluid", name="dowfroth-250", amount=100},
      },
    },
    ["sb-crushed"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sb-grade-02", amount=12.4429540549},
        {type="item", name="zinc-chloride", amount=0.525208682366},
      },
      results = {
        {type="item", name="sb-crushed", amount=1},
      },
    },
    ["sb-dust"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="sb-crushed", amount=2},
      },
      results = {
        {type="item", name="sb-dust", amount=1},
        {type="item", name="sb-grade-04", amount=0.5},
      },
    },
    ["sb-pulp-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-oil", amount=25},
        {type="item", name="processed-ash", amount=0.975514082304},
        {type="item", name="sb-crushed", amount=4.21321541789},
      },
      results = {
        {type="fluid", name="sb-pulp-01", amount=200},
      },
    },
    ["sb-pulp-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="coke", amount=6.37736409924},
        {type="item", name="duralumin", amount=11.2270727994},
        {type="item", name="mechanical-parts-01", amount=2.51437283211},
        {type="item", name="nbfe-alloy", amount=1},
        {type="item", name="niobium-pipe", amount=44.5992156654},
        {type="item", name="splitter", amount=1},
      },
      results = {
        {type="item", name="fast-splitter", amount=1},
      },
    },
    ["fast-transport-belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="lubricant", amount=10},
        {type="item", name="duralumin", amount=5.30458793851},
        {type="item", name="lead-plate", amount=2.74060937758},
        {type="item", name="nbfe-alloy", amount=1},
        {type="item", name="stainless-steel", amount=2},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=2},
      },
    },
    ["fast-underground-belt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="lubricant", amount=50},
        {type="item", name="fast-transport-belt", amount=8},
        {type="item", name="gravel", amount=3.27373549268},
        {type="item", name="nbfe-alloy", amount=5},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="stainless-steel", amount=10},
        {type="item", name="underground-belt", amount=2},
      },
      results = {
        {type="item", name="fast-underground-belt", amount=2},
      },
    },
    ["neutron-absorber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="concrete", amount=50},
        {type="item", name="duralumin", amount=3.5681712286},
        {type="item", name="inductor1", amount=136.54758535},
        {type="item", name="intermetallics", amount=20},
        {type="item", name="iron-plate", amount=274.088183558},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="niobium-oxide", amount=182.325454628},
        {type="item", name="small-parts-01", amount=150},
        {type="item", name="stone-brick", amount=67.9292537313},
        {type="item", name="tin-plate", amount=35.4755013851},
      },
      results = {
        {type="item", name="neutron-absorber-mk01", amount=1},
      },
    },
    ["py-biomass-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=100},
        {type="item", name="aluminium-plate", amount=100},
        {type="item", name="concrete", amount=1668.35769527},
        {type="item", name="copper-cable", amount=472.615483875},
        {type="item", name="duralumin", amount=397.844095388},
        {type="item", name="engine-unit", amount=20},
        {type="item", name="eva", amount=50},
        {type="item", name="mechanical-parts-02", amount=5},
        {type="item", name="neuroprocessor", amount=20},
        {type="item", name="plastic-bar", amount=110.432366457},
        {type="item", name="py-gas-powerplant-mk01", amount=0.560521269378},
        {type="item", name="self-assembly-monolayer", amount=40},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk02", amount=1},
      },
    },
    ["py-coal-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="controler-mk02", amount=4.44341249716},
        {type="item", name="copper-cable", amount=138.052251924},
        {type="item", name="duralumin", amount=50},
        {type="item", name="engine-unit", amount=20},
        {type="item", name="glass", amount=109.422451451},
        {type="item", name="lead-plate", amount=1342.48922036},
        {type="item", name="mechanical-parts-02", amount=5},
        {type="item", name="microchip", amount=155.29852394},
        {type="item", name="small-parts-01", amount=772.136480159},
        {type="item", name="steam-turbine-mk01", amount=1.91322326124},
      },
      results = {
        {type="item", name="py-coal-powerplant-mk02", amount=1},
      },
    },
    ["py-oil-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="electric-engine-unit", amount=8.49123374329},
        {type="item", name="eva", amount=50},
        {type="item", name="glass", amount=209.974013876},
        {type="item", name="mechanical-parts-02", amount=5},
        {type="item", name="niobium-pipe", amount=200},
        {type="item", name="py-gas-powerplant-mk01", amount=0.868254280769},
        {type="item", name="self-assembly-monolayer", amount=20},
        {type="item", name="small-parts-02", amount=100},
        {type="item", name="stainless-steel", amount=50},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk02", amount=1},
      },
    },
    ["tidal-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="brake-mk02", amount=3},
        {type="item", name="duralumin", amount=224.541455989},
        {type="item", name="electronics-mk02", amount=3.9377227392},
        {type="item", name="mechanical-parts-01", amount=62.8593208027},
        {type="item", name="mechanical-parts-02", amount=10},
        {type="item", name="niobium-pipe", amount=50},
        {type="item", name="py-biomass-powerplant-mk01", amount=1.45380040711},
        {type="item", name="self-assembly-monolayer", amount=15},
        {type="item", name="shaft-mk01", amount=4.84705259533},
        {type="item", name="small-parts-01", amount=113.526245506},
        {type="item", name="small-parts-02", amount=150},
        {type="item", name="stone-brick", amount=81.7461291059},
        {type="item", name="utility-box-mk02", amount=2},
      },
      results = {
        {type="item", name="tidal-mk02", amount=1},
      },
    },
    ["vawt-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=10},
        {type="item", name="brake-mk01", amount=10.6077821507},
        {type="item", name="controler-mk02", amount=2},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="electronics-mk01", amount=0.875936486813},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="eva", amount=40},
        {type="item", name="rubber", amount=30},
        {type="item", name="self-assembly-monolayer", amount=20},
        {type="item", name="small-parts-02", amount=300},
        {type="item", name="stainless-steel", amount=50},
        {type="item", name="utility-box-mk02", amount=3},
        {type="item", name="yaw-drive-mk01", amount=1.07975118555},
      },
      results = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
    },
    ["hawt-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="gearbox-mk01", amount=87.76842416},
        {type="item", name="tower-mk01", amount=3.58462803358},
        {type="item", name="tower-mk02", amount=1},
        {type="item", name="utility-box-mk02", amount=2.92015263555},
        {type="item", name="vane-mk02", amount=1},
        {type="item", name="yaw-drive-mk02", amount=0.500981379899},
      },
      results = {
        {type="item", name="hawt-turbine-mk02", amount=1},
      },
    },
    ["steam-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="anemometer-mk02", amount=1.11860995007},
        {type="item", name="antimony-drill-mk01", amount=1.6281439043},
        {type="item", name="controler-mk01", amount=82.4819407336},
        {type="item", name="controler-mk02", amount=5},
        {type="item", name="duralumin", amount=75},
        {type="item", name="electronics-mk02", amount=10.2734355851},
        {type="item", name="guar-gum", amount=50.4702396191},
        {type="item", name="intermetallics", amount=878.225736395},
        {type="item", name="pipe", amount=160.289711035},
        {type="item", name="small-parts-01", amount=3860.68240079},
        {type="item", name="stainless-steel", amount=500},
        {type="item", name="steam-turbine-mk01", amount=1},
        {type="item", name="steel-plate", amount=200},
        {type="item", name="tower-mk02", amount=14.4387337282},
      },
      results = {
        {type="item", name="steam-turbine-mk02", amount=1},
      },
    },
    ["jig-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=2},
        {type="item", name="eva", amount=23.2701703335},
        {type="item", name="glass", amount=33.5288507757},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="mixer-mk01", amount=0.934988506246},
        {type="item", name="niobium-pipe", amount=40},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="stainless-steel", amount=20},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="jig-mk01", amount=1},
      },
    },
    ["nmf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="evaporator", amount=2},
        {type="item", name="inductor1", amount=273.095170699},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=137.044091779},
        {type="item", name="niobium-pipe", amount=15},
        {type="item", name="pipe", amount=149.372768067},
        {type="item", name="titanium-plate", amount=45.6944615451},
        {type="item", name="transport-belt", amount=35},
      },
      results = {
        {type="item", name="nmf-mk01", amount=1},
      },
    },
    ["py-heat-exchanger-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=30},
        {type="item", name="compressor-mk01", amount=2.01589525056},
        {type="item", name="duralumin", amount=132.614698463},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="glass", amount=11.977},
        {type="item", name="mechanical-parts-02", amount=2},
        {type="item", name="py-tank-8000", amount=1},
        {type="item", name="self-assembly-monolayer", amount=5},
      },
      results = {
        {type="item", name="py-heat-exchanger-mk02", amount=1},
      },
    },
    ["bio-printer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="chromium", amount=116.593545638},
        {type="item", name="diesel-barrel", amount=73.7221567487},
        {type="item", name="distilator", amount=1.21042108809},
        {type="item", name="inductor1", amount=341.368963374},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=40.2684081947},
        {type="item", name="nexelit-plate", amount=25},
        {type="item", name="nickel-plate", amount=62.2906475659},
        {type="item", name="treated-wood", amount=123.240251919},
      },
      results = {
        {type="item", name="bio-printer-mk01", amount=1},
      },
    },
    ["botanical-nursery-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=5.90662602732},
        {type="item", name="pipe", amount=32.057942207},
        {type="item", name="small-parts-01", amount=29.1120248777},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="titanium-plate", amount=45.6944615451},
      },
      results = {
        {type="item", name="botanical-nursery-mk02", amount=1},
      },
    },
    ["spore-collector-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="distilator", amount=2.88831012915},
        {type="item", name="electric-engine-unit", amount=3.39649349732},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="shaft-mk02", amount=78.4801125719},
        {type="item", name="small-parts-01", amount=145.560124388},
        {type="item", name="small-parts-02", amount=25},
        {type="item", name="spore-collector-mk01", amount=1},
        {type="item", name="titanium-plate", amount=35.7743616679},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="biomass", amount=10},
        {type="item", name="fe-biomass", amount=17.1116334212},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=10},
        {type="item", name="fishmeal", amount=3.77493978472},
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
      ingredients = {
        {type="fluid", name="hot-air", amount=129.761904762},
        {type="fluid", name="phytoplankton", amount=50},
        {type="item", name="bio-sample", amount=1.84765923118},
        {type="item", name="fish", amount=12},
        {type="item", name="grade-3-zinc", amount=4.215775984},
        {type="item", name="seaweed", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=35},
      },
    },
    ["fish-egg-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fish-mk02", amount=291.378358877},
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
      ingredients = {
        {type="fluid", name="phytoplankton", amount=60},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish-food-01", amount=4.26670711118},
        {type="item", name="fish-mk02", amount=20},
        {type="item", name="seaweed", amount=10},
      },
      results = {
        {type="item", name="fish", amount=6},
        {type="item", name="fish-mk03", amount=0.004},
      },
    },
    ["fish-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="cdna", amount=7.30227500707},
        {type="item", name="fish-egg-mk02", amount=613.941976191},
        {type="item", name="nichrome", amount=2.03136605182},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-mk02", amount=1.5},
        {type="item", name="fish-mk03", amount=6.5},
      },
    },
    ["energy-drink"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="syrup-01", amount=25},
        {type="fluid", name="water", amount=500},
        {type="item", name="titanium-plate", amount=7.91639662392},
      },
      results = {
        {type="item", name="energy-drink", amount=7},
      },
    },
    ["neuroprocessor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="alien-sample01", amount=1.89639030413},
        {type="item", name="aluminium-plate", amount=3.21075486956},
        {type="item", name="brain", amount=5},
        {type="item", name="capacitor2", amount=2.67517008392},
        {type="item", name="concrete", amount=8.67351007588},
        {type="item", name="inductor1", amount=10},
        {type="item", name="kevlar", amount=15.8422065764},
        {type="item", name="melamine-resin", amount=21.3799499204},
        {type="item", name="nexelit-matrix", amount=5},
        {type="item", name="resistor1", amount=5},
        {type="item", name="vacuum-tube", amount=1.86846077824},
      },
      results = {
        {type="item", name="neuroprocessor", amount=2},
      },
    },
    ["nisi"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=300},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="nickel-plate", amount=1},
        {type="item", name="phenol", amount=1.47867408177},
      },
      results = {
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="nisi", amount=1},
      },
    },
    ["capacitor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=10},
        {type="fluid", name="steam", amount=644.599729726},
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="capacitor1", amount=5},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="capacitor2", amount=5},
      },
    },
    ["microchip"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="cermet", amount=5},
        {type="item", name="heavy-n", amount=2.39748673068},
        {type="item", name="phenol", amount=108.082153463},
        {type="item", name="pipe", amount=11.6709177417},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="tinned-cable", amount=10},
      },
      results = {
        {type="item", name="microchip", amount=3},
      },
    },
    ["mosfet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=15},
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="aluminium-plate", amount=1},
        {type="item", name="empty-planter-box", amount=2.790049565},
        {type="item", name="heavy-n", amount=4},
        {type="item", name="light-n", amount=4},
        {type="item", name="nisi", amount=2},
        {type="item", name="p-dope", amount=4},
        {type="item", name="plastic-bar", amount=3},
        {type="item", name="reo", amount=5},
      },
      results = {
        {type="item", name="mosfet", amount=4},
      },
    },
    ["phenolicboard"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=30},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="vacuum-tube", amount=8.52139238108},
        {type="item", name="zinc-acetate", amount=1.65245176893},
      },
      results = {
        {type="item", name="phenolicboard", amount=5},
      },
    },
    ["resistor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=50},
        {type="item", name="capacitor1", amount=3.29934536076},
        {type="item", name="fecr-alloy", amount=4},
        {type="item", name="powdered-phosphate-rock", amount=24.2242948861},
      },
      results = {
        {type="item", name="resistor2", amount=4},
      },
    },
    ["inductor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="inductor1", amount=5},
        {type="item", name="melamine-resin", amount=5},
        {type="item", name="molybdenum-sulfide", amount=40.0091898483},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="inductor2", amount=5},
      },
    },
    ["pcb2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="etching", amount=25},
        {type="item", name="copper-plate", amount=5},
        {type="item", name="inductor2", amount=1.32162915371},
        {type="item", name="nylon-parts", amount=10},
        {type="item", name="tin-plate", amount=5},
      },
      results = {
        {type="item", name="pcb2", amount=3},
      },
    },
    ["transistor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=100},
        {type="item", name="cermet", amount=1.16931985777},
        {type="item", name="heavy-n", amount=5},
        {type="item", name="light-n", amount=5},
        {type="item", name="nylon", amount=1},
        {type="item", name="p-dope", amount=5},
      },
      results = {
        {type="item", name="transistor", amount=5},
      },
    },
    ["diode"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="cermet", amount=4},
        {type="item", name="heavy-n", amount=0.958994692273},
        {type="item", name="nylon", amount=3},
        {type="item", name="p-dope", amount=4},
        {type="item", name="reo", amount=4},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="diode", amount=4},
      },
    },
    ["advanced-circuit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="battery-mk01", amount=5},
        {type="item", name="diode", amount=3},
        {type="item", name="inductor1", amount=6.82737926748},
        {type="item", name="inductor2", amount=4},
        {type="item", name="kevlar", amount=3.16844131527},
        {type="item", name="microchip", amount=3},
        {type="item", name="mosfet", amount=5},
        {type="item", name="pcb2", amount=1},
        {type="item", name="phenolicboard", amount=5.3566990636},
        {type="item", name="resistor2", amount=15},
        {type="item", name="solder", amount=4},
        {type="item", name="transistor", amount=3},
      },
      results = {
        {type="item", name="advanced-circuit", amount=5},
      },
    },
    ["uranium-mining-drill"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="electric-mining-drill", amount=10},
        {type="item", name="nbfe-alloy", amount=50},
        {type="item", name="pcb2", amount=88.7424414494},
        {type="item", name="small-parts-02", amount=100},
        {type="item", name="stainless-steel", amount=50},
        {type="item", name="stator", amount=41.2492640281},
        {type="item", name="utility-box-mk02", amount=3.30044420373},
      },
      results = {
        {type="item", name="uranium-mining-drill", amount=1},
      },
    },
    ["aerial-base"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="duralumin", amount=79.5688190776},
        {type="item", name="electric-mining-drill", amount=14.1236499904},
        {type="item", name="electronics-mk02", amount=2.05468711702},
        {type="item", name="gearbox-mk02", amount=2.58972363828},
        {type="item", name="intermetallics", amount=351.290294558},
        {type="item", name="lead-plate", amount=46.0010807434},
        {type="item", name="shaft-mk02", amount=8.93966659186},
        {type="item", name="titanium-plate", amount=56.5456901708},
      },
      results = {
        {type="item", name="aerial-base", amount=1},
      },
    },
    ["aerial-blimp-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=4000},
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="fluidavan", amount=4.58548627342},
        {type="item", name="gearbox-mk02", amount=1.72648242552},
        {type="item", name="mechanical-parts-02", amount=1},
        {type="item", name="nexelit-plate", amount=1354.3044981},
        {type="item", name="nxsb-alloy", amount=51.7748866603},
        {type="item", name="rubber", amount=60},
        {type="item", name="self-assembly-monolayer", amount=40},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="titanium-plate", amount=226.182760683},
        {type="item", name="tower-mk02", amount=1.96802076218},
        {type="item", name="utility-box-mk02", amount=2},
        {type="item", name="vane-mk02", amount=7.47200946193},
        {type="item", name="washer", amount=82.1329987237},
      },
      results = {
        {type="item", name="aerial-blimp-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=70.4711674928},
        {type="item", name="duralumin", amount=35},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=30},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="nuclear-reactor", amount=1},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="stone-brick", amount=27.1717014925},
      },
      results = {
        {type="item", name="bhoddos-culture-mk01", amount=1},
      },
    },
    ["cadaveric-arum-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="hydrocyclone-mk01", amount=1},
        {type="item", name="incubator-mk01", amount=0.810814248997},
        {type="item", name="inductor1", amount=170.684481687},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="iron-plate", amount=164.452910135},
        {type="item", name="plastic-bar", amount=100},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=1},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bio-sample", amount=29.923618217},
        {type="item", name="concrete", amount=134.392904321},
        {type="item", name="inductor1", amount=136.54758535},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="nexelit-plate", amount=50.0960173666},
        {type="item", name="pipe", amount=40},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="tin-plate", amount=38.4477789241},
        {type="item", name="titanium-plate", amount=50},
        {type="item", name="treated-wood", amount=50},
      },
      results = {
        {type="item", name="grods-swamp-mk01", amount=1},
      },
    },
    ["guar-gum-plantation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="duralumin", amount=50},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="iron-plate", amount=54.8176367116},
        {type="item", name="mechanical-parts-01", amount=1.12716413312},
        {type="item", name="pipe", amount=20},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="guar-gum-plantation", amount=1},
      },
    },
    ["navens-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="duralumin", amount=35},
        {type="item", name="gasifier", amount=2},
        {type="item", name="glass", amount=30},
        {type="item", name="mechanical-parts-01", amount=18.8577962408},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="pump", amount=3.02244678783},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="tin-plate", amount=50},
      },
      results = {
        {type="item", name="navens-culture-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="concrete", amount=60.0180597289},
        {type="item", name="duralumin", amount=40},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="mechanical-parts-02", amount=2.42715268368},
        {type="item", name="pump", amount=4},
        {type="item", name="ralesia-plantation-mk01", amount=1},
        {type="item", name="small-parts-02", amount=60.4159845262},
        {type="item", name="tin-plate", amount=31.3688817644},
      },
      results = {
        {type="item", name="ralesia-plantation-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="concrete", amount=99.7065763634},
        {type="item", name="duralumin", amount=3.44943063628},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="engine-unit", amount=3.14637138037},
        {type="item", name="iron-plate", amount=137.044091779},
        {type="item", name="limestone", amount=344.117647059},
        {type="item", name="pump", amount=5},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="storage-tank", amount=4},
        {type="item", name="treated-wood", amount=50},
      },
      results = {
        {type="item", name="rennea-plantation-mk01", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="inductor1", amount=136.54758535},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=32.2007565204},
        {type="item", name="plastic-bar", amount=40},
        {type="item", name="pump", amount=5.46247772017},
        {type="item", name="small-parts-01", amount=5.02099552486},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=50},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=1},
      },
    },
    ["sponge-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=30},
        {type="item", name="duralumin", amount=50},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="glass", amount=16.4133677177},
        {type="item", name="latex", amount=30},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="mechanical-parts-02", amount=3.23620357824},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="small-parts-02", amount=30},
        {type="item", name="sponge-culture-mk01", amount=1},
        {type="item", name="steel-plate", amount=15},
      },
      results = {
        {type="item", name="sponge-culture-mk02", amount=1},
      },
    },
    ["cadaveric-arum-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="glass", amount=54.7112257256},
        {type="item", name="grods-swamp-mk01", amount=1.25227641297},
        {type="item", name="intermetallics", amount=17.5645147279},
        {type="item", name="latex", amount=10},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=10},
        {type="item", name="plastic-bar", amount=100},
        {type="item", name="small-parts-02", amount=22.6219267907},
      },
      results = {
        {type="item", name="cadaveric-arum-mk02", amount=1},
      },
    },
    ["grods-swamp-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="bio-sample", amount=31.4310250418},
        {type="item", name="copper-cable", amount=91.5001540934},
        {type="item", name="duralumin", amount=79.5688190776},
        {type="item", name="iron-stick", amount=107.065022453},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="pump", amount=19.2122697702},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="sponge-culture-mk01", amount=1.0671509321},
        {type="item", name="tin-plate", amount=18.0584055489},
        {type="item", name="treated-wood", amount=50},
      },
      results = {
        {type="item", name="grods-swamp-mk02", amount=1},
      },
    },
    ["guar-gum-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="engine-unit", amount=3},
        {type="item", name="fish-oil-barrel", amount=446.124859496},
        {type="item", name="gearbox-mk02", amount=0.802663438424},
        {type="item", name="intermetallics", amount=87.8225736395},
        {type="item", name="iron-plate", amount=137.044091779},
        {type="item", name="latex", amount=20},
        {type="item", name="nexelit-plate", amount=1079.32220935},
        {type="item", name="stainless-steel", amount=20},
        {type="item", name="titanium-plate", amount=42.3823939954},
        {type="item", name="trits-reef-mk01", amount=0.713223003646},
      },
      results = {
        {type="item", name="guar-gum-plantation-mk02", amount=1},
      },
    },
    ["kicalk-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=40},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="kicalk-plantation-mk01", amount=1},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="niobium-pipe", amount=269.450552352},
        {type="item", name="titanium-plate", amount=35},
      },
      results = {
        {type="item", name="kicalk-plantation-mk02", amount=1},
      },
    },
    ["moondrop-greenhouse-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=10},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fawogae-plantation-mk01", amount=0.612666368597},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="niobium-powder", amount=32.0783037209},
        {type="item", name="pipe", amount=40},
        {type="item", name="self-assembly-monolayer", amount=3},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk02", amount=1},
      },
    },
    ["moss-farm-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="assembling-machine-1", amount=5.04126206605},
        {type="item", name="duralumin", amount=50},
        {type="item", name="electric-engine-unit", amount=4.24561687165},
        {type="item", name="intermetallics", amount=8.87182239584},
        {type="item", name="lead-plate", amount=19.3180631327},
        {type="item", name="sap-extractor-mk01", amount=1.4537620849},
        {type="item", name="self-assembly-monolayer", amount=7},
        {type="item", name="small-parts-02", amount=30},
      },
      results = {
        {type="item", name="moss-farm-mk02", amount=1},
      },
    },
    ["navens-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="duralumin", amount=80.1204757026},
        {type="item", name="electric-engine-unit", amount=1.27368506149},
        {type="item", name="lead-plate", amount=40},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=30},
        {type="item", name="pipe", amount=21.3719614713},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="small-parts-02", amount=30},
        {type="item", name="yaedols-culture-mk01", amount=2.50568219834},
      },
      results = {
        {type="item", name="navens-culture-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="concrete", amount=53.0234909279},
        {type="item", name="duralumin", amount=5.01772645732},
        {type="item", name="electric-engine-unit", amount=4.24561687165},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="small-parts-02", amount=18.5080287847},
        {type="item", name="storage-tank", amount=4},
        {type="item", name="transistor", amount=198.927791925},
        {type="item", name="treated-wood", amount=20},
        {type="item", name="yaedols-culture-mk01", amount=0.832056180292},
      },
      results = {
        {type="item", name="rennea-plantation-mk02", amount=1},
      },
    },
    ["sap-extractor-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="duralumin", amount=12},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fast-inserter", amount=2},
        {type="item", name="intermetallics", amount=35.1290294558},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="moss-farm-mk01", amount=0.687870464076},
        {type="item", name="small-parts-02", amount=15},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="treated-wood", amount=100},
      },
      results = {
        {type="item", name="sap-extractor-mk02", amount=1},
      },
    },
    ["seaweed-crop-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="latex", amount=2.2267536465},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="pipe", amount=304.398061801},
        {type="item", name="seaweed-crop-mk01", amount=1},
        {type="item", name="small-parts-01", amount=231.640944048},
        {type="item", name="steel-plate", amount=40},
      },
      results = {
        {type="item", name="seaweed-crop-mk02", amount=1},
      },
    },
    ["tuuphra-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=30},
        {type="item", name="duralumin", amount=50},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="fish-farm-mk01", amount=0.707462464435},
        {type="item", name="glass", amount=16.4133677177},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=20},
        {type="item", name="small-parts-02", amount=36.2495907157},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="duralumin", amount=8.36287742887},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="latex", amount=40},
        {type="item", name="mechanical-parts-02", amount=3.23620357824},
        {type="item", name="nickel-plate", amount=55.0799250816},
        {type="item", name="rennea-plantation-mk01", amount=91.9435556245},
        {type="item", name="small-parts-02", amount=18.5080287847},
        {type="item", name="tin-plate", amount=50},
      },
      results = {
        {type="item", name="bhoddos-culture-mk02", amount=1},
      },
    },
    ["fawogae-plantation-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="distilator", amount=2.88831012915},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="fwf-mk01", amount=1.51556538448},
        {type="item", name="intermetallics", amount=17.5645147279},
        {type="item", name="plastic-bar", amount=20},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="treated-wood", amount=30},
      },
      results = {
        {type="item", name="fawogae-plantation-mk02", amount=1},
      },
    },
    ["fwf-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="aluminium-plate", amount=157.543885255},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="fawogae-plantation-mk01", amount=0.659819767753},
        {type="item", name="glass", amount=32.8267354353},
        {type="item", name="intermetallics", amount=35.1290294558},
        {type="item", name="latex", amount=30},
        {type="item", name="plastic-bar", amount=50},
        {type="item", name="steam-engine", amount=19.3391968791},
        {type="item", name="utility-box-mk01", amount=1.42143585826},
      },
      results = {
        {type="item", name="fwf-mk02", amount=1},
      },
    },
    ["bulk-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=1},
        {type="item", name="crmoni", amount=1},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="inserter", amount=1.75221772598},
        {type="item", name="small-parts-02", amount=1},
      },
      results = {
        {type="item", name="bulk-inserter", amount=1},
      },
    },
    ["assembling-machine-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=2},
        {type="item", name="bulk-inserter", amount=2},
        {type="item", name="eva", amount=10.7951741298},
        {type="item", name="mechanical-parts-02", amount=5},
      },
      results = {
        {type="item", name="assembling-machine-3", amount=1},
      },
    },
    ["chemical-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=50},
        {type="item", name="advanced-circuit", amount=2},
        {type="item", name="belt", amount=19.5378098409},
        {type="item", name="duralumin", amount=7.95688190776},
        {type="item", name="intermetallics", amount=17.5645147279},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="mox-fuel-cell", amount=0.856006734993},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="optical-fiber", amount=10},
        {type="item", name="stainless-steel", amount=20},
      },
      results = {
        {type="item", name="chemical-science-pack", amount=12},
      },
    },
    ["electric-furnace"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="iron-plate", amount=27.4088183558},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="refined-concrete", amount=6.11649756959},
      },
      results = {
        {type="item", name="electric-furnace", amount=1},
      },
    },
    ["megadar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="concrete", amount=102.089296732},
        {type="item", name="eva", amount=29.8705059035},
        {type="item", name="niobium-plate", amount=10},
        {type="item", name="pipe", amount=21.3719614713},
      },
      results = {
        {type="item", name="megadar", amount=1},
      },
    },
    ["modular-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=400},
        {type="item", name="advanced-circuit", amount=55},
        {type="item", name="brake-mk02", amount=1.75035558095},
        {type="item", name="chromium", amount=12.9789410495},
        {type="item", name="electronics-mk02", amount=10},
        {type="item", name="engine-unit", amount=6.03285166728},
        {type="item", name="glass", amount=145.919313054},
        {type="item", name="kevlar", amount=80},
        {type="item", name="latex", amount=151.625286461},
        {type="item", name="mechanical-parts-02", amount=10},
        {type="item", name="small-parts-01", amount=40},
      },
      results = {
        {type="item", name="modular-armor", amount=1},
      },
    },
    ["particle-accelerator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="agitator-mk01", amount=1},
        {type="item", name="concrete", amount=100},
        {type="item", name="copper-cable", amount=1000},
        {type="item", name="electric-engine-unit", amount=20},
        {type="item", name="latex", amount=12.4139332642},
        {type="item", name="plastic-bar", amount=100},
        {type="item", name="small-parts-01", amount=28.6873419126},
        {type="item", name="stainless-steel", amount=49.2836025125},
        {type="item", name="steel-plate", amount=500},
      },
      results = {
        {type="item", name="particle-accelerator-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="engine-unit", amount=5.58280961559},
        {type="item", name="eva", amount=24.0382651885},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="latex", amount=50},
        {type="item", name="neuroprocessor", amount=50},
        {type="item", name="pipe", amount=58.5263187612},
        {type="item", name="rennea-plantation-mk01", amount=1.20184192328},
        {type="item", name="small-parts-02", amount=1163.4021188},
        {type="item", name="titanium-plate", amount=18.277784618},
      },
      results = {
        {type="item", name="yaedols-culture-mk02", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="concrete", amount=100},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="guar-gum-plantation", amount=0.735890407632},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="niobium-pipe", amount=15},
        {type="item", name="stainless-steel", amount=50},
        {type="item", name="titanium-plate", amount=38.3785980101},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
    },
    ["kicalk-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="kicalk-mk02", amount=4},
      },
      results = {
        {type="item", name="kicalk-seeds-mk02", amount=5},
      },
    },
    ["yotoi-fiber"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-leaves", amount=5},
      },
      results = {
        {type="item", name="raw-fiber", amount=3},
      },
    },
    ["bedding"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="dried-grods", amount=1},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="wood", amount=5},
        {type="item", name="yotoi-fruit", amount=3.92285236466},
      },
      results = {
        {type="item", name="bedding", amount=2},
      },
    },
    ["cu-biomass-extraction"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="cu-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["fe-biomass-extraction"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="fe-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="iron-ore", amount=20},
      },
    },
    ["fungal-substrate-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water-saline", amount=631.19266055},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=15},
        {type="item", name="fungal-substrate-02", amount=1},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="skin", amount=1.55711698846},
        {type="item", name="tuuphra", amount=3},
      },
      results = {
        {type="item", name="fungal-substrate-03", amount=10},
      },
    },
    ["nacl-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="urea", amount=16.3073137122},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="salt", amount=30},
      },
    },
    ["psc"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=150},
        {type="fluid", name="xenogenic-cells", amount=150},
        {type="item", name="bio-sample", amount=3.71292661362},
        {type="item", name="cellulose", amount=14.6705113848},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="fluid", name="psc", amount=50},
      },
    },
    ["s-biomass-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="nacl-biomass", amount=13.714725936},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="sulfur", amount=10},
      },
    },
    ["sn-biomass-extraction"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
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
      ingredients = {
        {type="item", name="coke", amount=5},
        {type="item", name="limestone", amount=3},
        {type="item", name="sodium-bisulfate", amount=0.821429486789},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["sporopollenin"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="bhoddos-spore", amount=3},
        {type="item", name="navens-spore", amount=5},
        {type="item", name="rennea", amount=8},
      },
      results = {
        {type="item", name="sporopollenin", amount=5},
      },
    },
    ["vinyl-acetate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="agar", amount=4.16454341543},
        {type="item", name="sodium-hydroxide", amount=2},
      },
      results = {
        {type="item", name="lignin", amount=8},
      },
    },
    ["seeds-extract-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="grod-seeds", amount=10},
        {type="item", name="guar-seeds", amount=100},
        {type="item", name="rennea-seeds", amount=10},
        {type="item", name="wood-seeds", amount=10},
      },
      results = {
        {type="item", name="seeds-extract-01", amount=5},
      },
    },
    ["yotoi-cellulose"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="yotoi-leaves", amount=10},
      },
      results = {
        {type="item", name="cellulose", amount=3},
      },
    },
    ["ulric-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1.19792038597},
        {type="item", name="bedding", amount=1},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="salt", amount=5},
        {type="item", name="ulric-cub", amount=6},
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="ulric", amount=6},
      },
    },
    ["ulric-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-02", amount=0.501827403085},
        {type="item", name="fawogae", amount=3},
        {type="item", name="moss", amount=16.6186485298},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="salt", amount=10},
        {type="item", name="water-barrel", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="ulric-cub", amount=6},
      },
    },
    ["ulric-manure-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="sand", amount=5.89420654912},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=6},
      },
    },
    ["ulric-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="fiber", amount=2.75047082171},
        {type="item", name="ulric", amount=2},
        {type="item", name="ulric-food-01", amount=2},
        {type="item", name="water-barrel", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric", amount=0.5},
        {type="item", name="ulric-mk02", amount=0.005},
      },
    },
    ["ulric-mk02-dna-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="latex", amount=2},
        {type="item", name="sample-cup", amount=1},
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=1},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-dna-sample-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=0.860347018442},
        {type="item", name="latex", amount=2},
        {type="item", name="sample-cup", amount=6},
        {type="item", name="ulric", amount=89.405900763},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=6},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-breeding"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="ulric-mk02", amount=1},
        {type="item", name="ulric-mk02-dna-sample", amount=12},
        {type="item", name="water-barrel", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=7},
        {type="item", name="ulric-cub-mk02", amount=1},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-recharge-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="used-ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-raising"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="bedding", amount=4},
        {type="item", name="fawogae", amount=15},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="raw-fiber", amount=8},
        {type="item", name="ulric-cub-mk02", amount=4},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["compile-korlex-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="neuroprocessor", amount=1},
        {type="item", name="zipir-codex", amount=3.68213185838},
      },
      results = {
        {type="item", name="korlex-codex-mk02", amount=1},
      },
    },
    ["korlex-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ash", amount=10},
        {type="item", name="bedding", amount=2},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="kicalk", amount=1},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="korlex-pup", amount=4},
        {type="item", name="seaweed", amount=46.722679817},
        {type="item", name="tuuphra-mk02", amount=0.5695727793},
        {type="item", name="water-barrel", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=4},
      },
    },
    ["korlex-milk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ash", amount=10},
        {type="item", name="bhoddos", amount=2},
        {type="item", name="empty-barrel-milk", amount=6},
        {type="item", name="fish", amount=5},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="tuuphra-seeds", amount=18.9965984116},
        {type="item", name="water-barrel", amount=10},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="barrel-milk", amount=6},
      },
    },
    ["korlex-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="korlex", amount=2},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="rennea", amount=10},
        {type="item", name="saps", amount=24.491140181},
        {type="item", name="sodium-hydroxide", amount=4.15623501201},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="korlex", amount=0.5},
        {type="item", name="korlex-mk02", amount=0.005},
      },
    },
    ["korlex-pup-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ash", amount=20},
        {type="item", name="bedding", amount=1},
        {type="item", name="fish-emulsion-barrel", amount=5},
        {type="item", name="fishmeal", amount=6.80237433528},
        {type="item", name="tuuphra", amount=2.63205016586},
        {type="item", name="water-barrel", amount=20},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=6},
      },
    },
    ["korlex-mk02r"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="psc", amount=100},
        {type="fluid", name="xenogenic-cells", amount=100},
        {type="item", name="animal-sample-01", amount=1},
        {type="item", name="bio-scafold", amount=5},
        {type="item", name="cdna", amount=2},
        {type="item", name="korlex-codex-mk02", amount=1},
        {type="item", name="korlex-mk02", amount=4},
      },
      results = {
        {type="item", name="korlex-mk02", amount=5},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="moss", amount=5},
        {type="item", name="sap-tree", amount=9.29995934254},
        {type="item", name="sodium-alginate", amount=1},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=1},
      },
    },
    ["sap-seeds-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="saps-mk02", amount=5},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=2},
      },
    },
    ["sap-tree-mk03-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="bonemeal", amount=10},
        {type="item", name="kicalk", amount=2.6110517269},
        {type="item", name="sap-seeds-mk02", amount=6},
      },
      results = {
        {type="item", name="sap-tree-mk03", amount=1},
      },
    },
    ["xyhiphoe-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="steam", amount=1750},
        {type="item", name="blood-meal", amount=5},
        {type="item", name="cottongut-food-01", amount=3.66519105687},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="saps", amount=2},
        {type="item", name="xyhiphoe-cub", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=200},
        {type="item", name="xyhiphoe", amount=1.2},
      },
    },
    ["xyhiphoe-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1000},
        {type="fluid", name="water-saline", amount=1893.57798165},
        {type="item", name="albumin", amount=1},
        {type="item", name="blood-meal", amount=4},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="saps", amount=6},
      },
      results = {
        {type="fluid", name="waste-water", amount=650},
        {type="item", name="xyhiphoe-cub", amount=7},
      },
    },
    ["xyhiphoe-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=5250},
        {type="item", name="chromium", amount=32.4473526236},
        {type="item", name="fish-food-01", amount=2.84447140745},
        {type="item", name="nylon-parts", amount=56.6459541393},
        {type="item", name="xyhiphoe", amount=2},
      },
      results = {
        {type="item", name="xyhiphoe", amount=0.5},
        {type="item", name="xyhiphoe-mk02", amount=0.005},
      },
    },
    ["xyhiphoe-pool-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=10},
        {type="item", name="concrete", amount=12.4273451881},
        {type="item", name="electric-engine-unit", amount=2.12280843582},
        {type="item", name="grods-swamp-mk01", amount=1.74038131592},
        {type="item", name="latex", amount=30},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=30},
        {type="item", name="nexelit-plate", amount=15},
        {type="item", name="niobium-plate", amount=20},
        {type="item", name="self-assembly-monolayer", amount=6},
        {type="item", name="small-parts-02", amount=50},
        {type="item", name="titanium-plate", amount=91.3889230901},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=1},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=250},
        {type="item", name="blood-meal", amount=6},
        {type="item", name="fawogae-mk02", amount=1},
        {type="item", name="fish-food-02", amount=1.59826981716},
        {type="item", name="fish-mk02", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe-cub", amount=0.7},
        {type="item", name="xyhiphoe-cub-mk02", amount=2.3},
      },
    },
    ["xyhiphoe-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="wax", amount=710.090353721},
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
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="bhoddos-spore", amount=5},
        {type="item", name="fungal-substrate-02", amount=1},
        {type="item", name="powdered-biomass", amount=4.73031190486},
      },
      results = {
        {type="item", name="bhoddos", amount=5},
      },
    },
    ["bhoddos-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=465.82908958},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="arqad-codex", amount=1.64892837483},
        {type="item", name="bhoddos-spore", amount=50},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-bear-sample", amount=0.790299650697},
        {type="item", name="fawogae-mk02", amount=0.899365351014},
        {type="item", name="moss-gen", amount=5},
      },
      results = {
        {type="item", name="bhoddos", amount=1},
      },
    },
    ["fish-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="ash", amount=10},
        {type="item", name="blood-meal", amount=5},
        {type="item", name="bones", amount=5},
        {type="item", name="brain", amount=0.902469622244},
        {type="item", name="fawogae", amount=10},
        {type="item", name="fish", amount=2},
        {type="item", name="native-flora", amount=10},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="pyrite", amount=6.41317704468},
        {type="item", name="seaweed", amount=5},
        {type="item", name="skin", amount=5},
        {type="item", name="yotoi-fruit", amount=3},
      },
      results = {
        {type="item", name="fish-food-02", amount=5},
      },
    },
    ["naven-coal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="vacuum", amount=53.3333333333},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="fungal-substrate-02", amount=2},
        {type="item", name="meat", amount=10.9146857208},
        {type="item", name="navens-spore", amount=2},
      },
      results = {
        {type="item", name="navens", amount=7},
      },
    },
    ["navens-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-shroom-sample", amount=1},
        {type="item", name="fawogae-codex", amount=23.0119760555},
        {type="item", name="navens-spore", amount=100},
      },
      results = {
        {type="item", name="navens", amount=2},
      },
    },
    ["mukmoux-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="nexelit-plate", amount=2.50480086833},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="stripped-distillate-canister", amount=3.51244298933},
      },
      results = {
        {type="item", name="mukmoux-codex", amount=1},
      },
    },
    ["mukmoux-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="glass", amount=3.48824839447},
        {type="item", name="lime", amount=3.55117987534},
        {type="item", name="moss", amount=5},
        {type="item", name="native-flora", amount=10},
        {type="item", name="saps", amount=5},
        {type="item", name="seaweed", amount=5},
        {type="item", name="tuuphra", amount=5},
      },
      results = {
        {type="item", name="mukmoux-food-01", amount=3},
      },
    },
    ["mukmoux-manure-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=3.59376115791},
        {type="item", name="bedding", amount=2},
        {type="item", name="fawogae", amount=30},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="ralesia-seeds", amount=30},
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
      ingredients = {
        {type="fluid", name="artificial-blood", amount=100},
        {type="fluid", name="fetal-serum", amount=100},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="crushed-oil-sand", amount=200.257733607},
        {type="item", name="earth-crustacean-sample", amount=0.735873717487},
        {type="item", name="earth-flower-sample", amount=0.806101127764},
      },
      results = {
        {type="item", name="mukmoux", amount=1},
      },
    },
    ["mukmoux-calf-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=2},
        {type="item", name="fawogae", amount=30},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="natural-gas-barrel", amount=1.15550085449},
        {type="item", name="ralesia", amount=20.8608756132},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="mukmoux-calf", amount=2},
      },
    },
    ["caged-mukmoux"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="empty-fuel-canister", amount=5.60223615743},
        {type="item", name="mukmoux", amount=1},
      },
      results = {
        {type="item", name="caged-mukmoux", amount=1},
      },
    },
    ["mukmoux-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-calf", amount=3},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="raw-fiber", amount=16.757820947},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="mukmoux", amount=2},
      },
    },
    ["mukmoux-pasture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="duralumin", amount=30},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=2.51709710429},
        {type="item", name="soil", amount=500},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="storage-tank", amount=5},
      },
      results = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
    },
    ["full-render-mukmoux"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux", amount=1.17078830926},
      },
      results = {
        {type="fluid", name="blood", amount=130},
        {type="item", name="bones", amount=3},
        {type="item", name="brain", amount=1},
        {type="item", name="cage", amount=1},
        {type="item", name="guts", amount=8},
        {type="item", name="meat", amount=5},
        {type="item", name="mukmoux-fat", amount=5},
        {type="item", name="skin", amount=4},
      },
    },
    ["uncaged-mukmoux"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=1},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="mukmoux", amount=1},
      },
    },
    ["cottongut-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="ash", amount=10},
        {type="item", name="coke", amount=16.4365782476},
        {type="item", name="moondrop", amount=10},
        {type="item", name="ralesia-seeds", amount=5},
        {type="item", name="rennea-seeds", amount=10},
        {type="item", name="seaweed", amount=10},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood-seeds", amount=15},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=6},
      },
    },
    ["cottongut-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=20},
        {type="fluid", name="fetal-serum", amount=50},
        {type="item", name="cottongut-pup-mk01", amount=1},
        {type="item", name="dna-polymerase", amount=1},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=0.5},
        {type="item", name="cottongut-mk02", amount=0.005},
      },
    },
    ["cottongut-pup-mk02-raising"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="cocoon", amount=1},
        {type="item", name="cottongut-food-02", amount=1},
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="saps", amount=6.12278504525},
        {type="item", name="tuuphra-seeds", amount=5},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=1.5},
        {type="item", name="cottongut-pup-mk02", amount=3.85},
      },
    },
    ["caged-cottongut-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-pup-mk01", amount=12.4445866179},
        {type="item", name="moondrop", amount=4},
        {type="item", name="saps", amount=6.12278504525},
        {type="item", name="tuuphra", amount=1.31602508293},
        {type="item", name="water-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="cottongut", amount=9},
      },
    },
    ["cottongut-cub-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="bedding", amount=1},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut", amount=4},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="urea", amount=2.76499531338},
        {type="item", name="water-barrel", amount=3},
        {type="item", name="yotoi-seeds", amount=10},
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
      ingredients = {
        {type="item", name="cadaveric-arum", amount=1},
        {type="item", name="cottongut-pup-mk02", amount=3},
        {type="item", name="dried-grods", amount=3},
        {type="item", name="molybdenite-pulp-barrel", amount=4.2119242254},
        {type="item", name="rennea", amount=2},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
      },
    },
    ["auog-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=300},
        {type="item", name="ash", amount=10},
        {type="item", name="casein", amount=10},
        {type="item", name="fawogae", amount=5},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=10},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="ralesia", amount=5},
        {type="item", name="seaweed", amount=5},
        {type="item", name="starch", amount=4},
        {type="item", name="wood-seeds", amount=1},
      },
      results = {
        {type="item", name="auog-food-02", amount=5},
      },
    },
    ["auog-maturing-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="albumin", amount=1.81011110842},
        {type="item", name="auog-pup", amount=12},
        {type="item", name="cottongut-food-01", amount=2.61912084851},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
        {type="item", name="raw-fiber", amount=15},
        {type="item", name="saps", amount=12},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog", amount=8},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="albumin", amount=10},
        {type="item", name="auog-pup", amount=1},
        {type="item", name="casein", amount=2},
        {type="item", name="energy-drink", amount=1},
      },
      results = {
        {type="item", name="auog", amount=0.7},
        {type="item", name="auog-mk02", amount=0.005},
        {type="item", name="charged-auog", amount=0.1},
      },
    },
    ["charged-auog"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog", amount=1},
        {type="item", name="saps", amount=5.26771985825},
      },
      results = {
        {type="item", name="charged-auog", amount=1},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-mk02", amount=2},
        {type="item", name="bedding", amount=4},
        {type="item", name="moss", amount=10},
        {type="item", name="mukmoux-calf", amount=0.624867067237},
        {type="item", name="saps", amount=10},
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
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="energy-drink", amount=1},
        {type="item", name="saps", amount=12.2455700905},
        {type="item", name="used-auog-mk02", amount=4},
      },
      results = {
        {type="item", name="auog-mk02", amount=4},
      },
    },
    ["auog-pooping-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="albumin", amount=1.18254101363},
        {type="item", name="arqad-honey-barrel", amount=1.19792038597},
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="bedding", amount=3},
        {type="item", name="casein", amount=1.27510008042},
        {type="item", name="native-flora", amount=20},
        {type="item", name="raw-fiber", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=10.5},
      },
    },
    ["auog-pup-breeding-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="bedding", amount=3},
        {type="item", name="fiber", amount=6.87617705428},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
        {type="item", name="petri-dish-bacteria", amount=2.20709335783},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog-pup", amount=12},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bedding", amount=1},
        {type="item", name="used-auog", amount=4},
      },
      results = {
        {type="item", name="auog", amount=4},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="auog-pup-mk02", amount=4},
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="bedding", amount=4},
        {type="item", name="saps", amount=10},
        {type="item", name="seaweed", amount=10},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="auog-mk02", amount=3},
        {type="item", name="barrel", amount=3},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["ralesia-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=10},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="ralesia-seeds", amount=13},
        {type="item", name="soil", amount=15},
      },
      results = {
        {type="item", name="ralesia", amount=25},
      },
    },
    ["ralesia-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="fawogae", amount=18.8476999471},
        {type="item", name="ralesia", amount=2},
        {type="item", name="ralesia-seeds", amount=10},
        {type="item", name="soil", amount=100},
      },
      results = {
        {type="item", name="ralesia", amount=0.5},
        {type="item", name="ralesia-mk02", amount=0.005},
      },
    },
    ["ralesia-seeds-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-mk02", amount=5},
      },
      results = {
        {type="item", name="ralesia-seeds-mk02", amount=8},
      },
    },
    ["ralesia-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=400},
        {type="item", name="fawogae-mk02", amount=2},
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
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="cottongut-food-02", amount=0.517064412605},
        {type="item", name="fawogae", amount=5},
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=10.5654550416},
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=139.748726874},
        {type="fluid", name="fish-oil", amount=30},
        {type="item", name="agar", amount=6},
        {type="item", name="chromium", amount=4.20855597439},
        {type="item", name="dried-grods", amount=1.13659982956},
        {type="item", name="fiberboard", amount=2},
        {type="item", name="meat", amount=4.36587428833},
        {type="item", name="native-flora", amount=5},
        {type="item", name="p2s5", amount=3.56811803038},
        {type="item", name="ralesia", amount=5},
        {type="item", name="saps", amount=3.68428577948},
        {type="item", name="sic", amount=2.56168961429},
        {type="item", name="tuuphra-seeds", amount=3},
      },
      results = {
        {type="item", name="vrauks-food-02", amount=6},
      },
    },
    ["vrauks-mk03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="bedding", amount=4},
        {type="item", name="cocoon", amount=223.561635794},
        {type="item", name="moss", amount=5.88628252149},
        {type="item", name="saps", amount=8},
        {type="item", name="vrauks-food-02", amount=3},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk02", amount=2.55},
        {type="item", name="vrauks-mk03", amount=0.004},
      },
    },
    ["vrauks-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="bhoddos-spore", amount=9.53187791799},
        {type="item", name="cocoon-mk02", amount=6.70955906486},
        {type="item", name="moss", amount=8},
        {type="item", name="saps", amount=20},
        {type="item", name="vrauks-food-02", amount=1},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=8},
      },
    },
    ["vrauks-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="arqad-honey-barrel", amount=1.19792038597},
        {type="item", name="bedding", amount=4},
        {type="item", name="cocoon-mk02", amount=3.87136105077},
        {type="item", name="dried-grods", amount=32.2743290672},
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=8},
        {type="item", name="vrauks-food-02", amount=3},
        {type="item", name="vrauks-mk03", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk03", amount=1.95},
      },
    },
    ["vrauks-mk03-cocoon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1.19792038597},
        {type="item", name="barrel-milk", amount=1.26290211523},
        {type="item", name="filtration-media", amount=3.86976617342},
        {type="item", name="moss", amount=21.7138421904},
        {type="item", name="native-flora", amount=15},
        {type="item", name="sea-sponge", amount=5},
        {type="item", name="vrauks-mk03", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="cocoon-mk03", amount=5.5},
        {type="item", name="vrauks-mk03", amount=1.98},
      },
    },
    ["yotoi-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="aluminium-plate", amount=80.3186724829},
        {type="item", name="cdna", amount=3},
        {type="item", name="copper-cable", amount=16.9238821949},
        {type="item", name="earth-crustacean-sample", amount=5.06275942057},
        {type="item", name="sic", amount=1.49511730099},
        {type="item", name="yotoi-codex", amount=1},
      },
      results = {
        {type="item", name="yotoi", amount=2},
      },
    },
    ["yotoi-leaves"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="gravel", amount=3.81730769231},
        {type="item", name="limestone", amount=6},
        {type="item", name="yotoi-seeds", amount=1},
      },
      results = {
        {type="item", name="yotoi", amount=4},
      },
    },
    ["yotoi-fruit-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="boron-trioxide", amount=1.57836474147},
        {type="item", name="limestone", amount=5},
        {type="item", name="soil", amount=4},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=5},
      },
    },
    ["fawogae-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="fawogae-spore", amount=3},
        {type="item", name="fungal-substrate", amount=1},
      },
      results = {
        {type="item", name="fawogae", amount=15},
      },
    },
    ["fawogae-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="water", amount=1000},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fawogae-spore", amount=10},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="limestone", amount=38.2352941176},
      },
      results = {
        {type="item", name="fawogae", amount=0.5},
        {type="item", name="fawogae-mk02", amount=0.005},
      },
    },
    ["fawogae-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="water", amount=750},
        {type="item", name="biomass", amount=20},
        {type="item", name="fawogae-spore-mk02", amount=10},
        {type="item", name="ralesia", amount=2.04339733156},
      },
      results = {
        {type="item", name="fawogae-mk02", amount=2.5},
      },
    },
    ["fawogae-spore-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-mk02", amount=1},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=5},
      },
    },
    ["yaedols-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=80},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="fungal-substrate-03", amount=2},
        {type="item", name="wood", amount=10},
        {type="item", name="yaedols-spores", amount=4},
      },
      results = {
        {type="item", name="yaedols", amount=6},
      },
    },
    ["yaedols-spore-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="yaedols-mk02", amount=1},
      },
      results = {
        {type="item", name="yaedols-spores-mk02", amount=5},
      },
    },
    ["yaedols-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=465.82908958},
        {type="item", name="fungal-substrate-03", amount=5},
        {type="item", name="wood", amount=15},
        {type="item", name="yaedols", amount=2},
        {type="item", name="yaedols-spores", amount=5},
      },
      results = {
        {type="item", name="yaedols", amount=0.5},
        {type="item", name="yaedols-mk02", amount=0.005},
      },
    },
    ["yaedols-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrogen", amount=400},
        {type="fluid", name="steam", amount=133.333333333},
        {type="item", name="cobalt-fluoride", amount=5},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="silica-powder", amount=441.238982914},
        {type="item", name="wood", amount=10},
      },
      results = {
        {type="item", name="yaedols-mk02", amount=2.25},
      },
    },
    ["acid-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="acid-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["advanced-circuit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["aerial-base-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="aerial-base", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["aerial-blimp-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="aerial-blimp-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ammonium-chloride-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ammonium-chloride", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["anemometer-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["aramid-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="aramid", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["assembling-machine-3-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="assembling-machine-3", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-food-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["auog-pup-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-pup-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["b-molasse-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="b-molasse", amount=20000},
      },
      results = {
      },
    },
    ["bakelite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bakelite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bedding-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["belt-immunity-equipment-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="belt-immunity-equipment", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bhoddos-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bhoddos-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bhoddos-culture-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bhoddos-culture-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bhoddos-culture-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bhoddos-culture-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bhoddos-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bhoddos", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-printer-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bio-printer-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bio-scafold-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["biomass-auog-food-02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-auog-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-bedding"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bedding", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-bhoddos"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bhoddos", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-blood-meal"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="blood-meal", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=2},
      },
    },
    ["biomass-cadaveric-arum"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cadaveric-arum-seeds"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum-seeds", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=25},
      },
    },
    ["biomass-caged-mukmoux"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-cottongut-food-02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-food-02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cottongut-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-cu-biomass"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cu-biomass", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-dried-grods"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="dried-grods", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-fawogae-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-mk02", amount=20},
      },
      results = {
        {type="item", name="biomass", amount=65},
      },
    },
    ["biomass-fawogae-spore-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-spore-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-fe-biomass"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fe-biomass", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-fish-food-02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fish-food-02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-fish-mk03"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fish-mk03", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-fungal-substrate-03"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fungal-substrate-03", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=6},
      },
    },
    ["biomass-grod"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grod", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-grod-seeds"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grod-seeds", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=25},
      },
    },
    ["biomass-guar"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar", amount=12},
      },
      results = {
        {type="item", name="biomass", amount=16},
      },
    },
    ["biomass-guar-gum"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-gum", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-guar-seeds"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-seeds", amount=100},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-kicalk-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kicalk-mk02", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=300},
      },
    },
    ["biomass-kicalk-seeds-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kicalk-seeds-mk02", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=300},
      },
    },
    ["biomass-korlex-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="korlex-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-lignin"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="lignin", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=12},
      },
    },
    ["biomass-moondrop-fueloil"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="moondrop-fueloil", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=1},
      },
    },
    ["biomass-mukmoux"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=25},
      },
    },
    ["biomass-mukmoux-calf"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-calf", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-mukmoux-food-01"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-food-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-nacl-biomass"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nacl-biomass", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-navens"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="navens", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-photophore"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="photophore", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-ralesia-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=2},
      },
    },
    ["biomass-ralesia-seeds-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-seeds-mk02", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-rennea"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea", amount=5},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-rennea-seeds"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea-seeds", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=45},
      },
    },
    ["biomass-s-biomass"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="s-biomass", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-sap-tree-mk03"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sap-tree-mk03", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=25},
      },
    },
    ["biomass-sea-sponge-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sea-sponge-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-seeds-extract-01"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="seeds-extract-01", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-sn-biomass"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sn-biomass", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=8},
      },
    },
    ["biomass-sporopollenin"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sporopollenin", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-trits"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="trits", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=30},
      },
    },
    ["biomass-trits-pup"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="trits-pup", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-tuuphra-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-ulric-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["biomass-vrauks-food-02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vrauks-food-02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=5},
      },
    },
    ["biomass-vrauks-mk03"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vrauks-mk03", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=12},
      },
    },
    ["biomass-xyhiphoe-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-yaedols-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yaedols-mk02", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-yaedols-spores-mk02"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yaedols-spores-mk02", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=20},
      },
    },
    ["biomass-yotoi"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=15},
      },
    },
    ["biomass-yotoi-fruit"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
      },
    },
    ["biomass-yotoi-leaves"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-leaves", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=2},
      },
    },
    ["biomass-yotoi-seeds"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-seeds", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=10},
      },
    },
    ["bisphenol-a-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bisphenol-a", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["black-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="black-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["blade-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="blade-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["blood-meal-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="blood-meal", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["blue-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="blue-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["botanical-nursery-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="botanical-nursery-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["brain-cartridge-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["brain-food-01"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
      results = {
      },
    },
    ["brake-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="brake-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["brown-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="brown-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["bulk-inserter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="bulk-inserter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cadaveric-arum-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cadaveric-arum-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cadaveric-arum-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cadaveric-arum-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cadaveric-arum-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cadaveric-arum-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["caged-mukmoux-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["capacitor2-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="capacitor2", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["carbon-sulfide-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-sulfide", amount=20000},
      },
      results = {
      },
    },
    ["cermet-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cermet", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["charged-auog-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="charged-auog", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["chloroethanol-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="chloroethanol", amount=20000},
      },
      results = {
      },
    },
    ["cladded-core-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cladded-core", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cladding-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cladding", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cocoon-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cocoon-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["concentrated-ti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="concentrated-ti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["controler-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="controler-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["copper-coating-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="copper-coating", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-food-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-food-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cottongut-pup-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-pup-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crmoni-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="crmoni", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crucible-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="crucible", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["crude-cermet-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="crude-cermet", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["cyan-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="cyan-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["diode-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="diode", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["dowfroth-250-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="dowfroth-250", amount=20000},
      },
      results = {
      },
    },
    ["dried-grods-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="dried-grods", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-jute-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-jute-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-sunflower-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-sunflower-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["earth-tropical-tree-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-tropical-tree-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ech-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ech", amount=20000},
      },
      results = {
      },
    },
    ["efficiency-module-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="efficiency-module", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["eg-si-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="eg-si", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electric-engine-unit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="electric-engine-unit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electric-furnace-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="electric-furnace", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["electronics-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="electronics-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["energy-drink-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="energy-drink", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["epoxy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="epoxy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["etching-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="etching", amount=20000},
      },
      results = {
      },
    },
    ["ethanol-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethanol", amount=20000},
      },
      results = {
      },
    },
    ["ethylene-chlorohydrin-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene-chlorohydrin", amount=20000},
      },
      results = {
      },
    },
    ["ethylene-glycol-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene-glycol", amount=20000},
      },
      results = {
      },
    },
    ["ethylene-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene", amount=20000},
      },
      results = {
      },
    },
    ["eva-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="eva", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fast-splitter-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fast-splitter", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fast-transport-belt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fast-transport-belt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fast-underground-belt-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fast-underground-belt", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fatty-acids-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=20000},
      },
      results = {
      },
    },
    ["fawogae-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fawogae-plantation-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-plantation-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fawogae-spore-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fawogae-spore-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fecr-alloy-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fecr-alloy", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ferrite-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ferrite", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-egg-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fish-egg-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-emulsion-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-emulsion", amount=20000},
      },
      results = {
      },
    },
    ["fish-food-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fish-food-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fish-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fish-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fishmeal-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fishmeal", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fuel-oil-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fuel-oil", amount=20000},
      },
      results = {
      },
    },
    ["fuelrod-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fuelrod-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fungal-substrate-03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fungal-substrate-03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["fwf-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="fwf-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["gearbox-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="gearbox-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["glass-core-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="glass-core", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-1-u-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-1-u", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-2-u-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-2-u", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grade-4-ti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-4-ti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["green-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="green-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grod-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grod-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grod-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grod", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grod-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grod-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grods-swamp-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grods-swamp-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["grods-swamp-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="grods-swamp-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["guar-gum-plantation-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-gum-plantation-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["guar-gum-plantation-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-gum-plantation", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["guar-gum-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-gum", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["guar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["guar-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["hawt-turbine-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="hawt-turbine-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["heat-exchanger-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="heat-exchanger", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["heat-pipe-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="heat-pipe", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["heavy-n-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="heavy-n", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["high-grade-ti-powder-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["inductor2-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="inductor2", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ipod-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ipod", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["jig-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="jig-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kevlar-coating-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kevlar-coating", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kevlar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kevlar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kicalk-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kicalk-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kicalk-plantation-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kicalk-plantation-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["kicalk-seeds-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="kicalk-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["korlex-codex-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="korlex-codex-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["korlex-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="korlex-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lead-acetate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="lead-acetate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["lead-container-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="lead-container", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["light-n-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="light-n", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mechanical-parts-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mechanical-parts-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["megadar-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="megadar", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mibc-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="mibc", amount=20000},
      },
      results = {
      },
    },
    ["microchip-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="microchip", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["middle-processed-lard-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="middle-processed-lard", amount=20000},
      },
      results = {
      },
    },
    ["mk02-fluid-wagon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mk02-fluid-wagon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mk02-locomotive-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mk02-locomotive", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mk02-wagon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mk02-wagon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["modular-armor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="modular-armor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["molten-stainless-steel-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=20000},
      },
      results = {
      },
    },
    ["molten-titanium-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=20000},
      },
      results = {
      },
    },
    ["moondrop-fueloil-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="moondrop-fueloil", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moondrop-greenhouse-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="moondrop-greenhouse-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mosfet-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mosfet", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moss-farm-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="moss-farm-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["moss-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="moss-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mox-fuel-cell-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mox-fuel-cell", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mukmoux-calf-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-calf", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mukmoux-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mukmoux-food-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-food-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mukmoux-pasture-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["mukmoux-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="mukmoux", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nacelle-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nacelle-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["navens-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="navens-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["navens-culture-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="navens-culture-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["navens-culture-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="navens-culture-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["navens-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="navens", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nbalti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nbalti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nbfe-coating-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nbfe-coating", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["neuroprocessor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="neuroprocessor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["neutron-absorber-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="neutron-absorber-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nexelit-battery-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-battery", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nexelit-matrix-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-matrix", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nexelit-power-pole-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-power-pole", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["night-vision-equipment-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="night-vision-equipment", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nisi-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nisi", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nitrobenzene-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=20000},
      },
      results = {
      },
    },
    ["nmf-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nmf-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nuclear-reactor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nuclear-reactor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nuclear-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nuclear-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nylon-parts-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nylon-parts", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["nylon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="nylon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ocula-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ocula", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["optical-fiber-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="optical-fiber", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["orange-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="orange-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["organic-acid-anhydride-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=20000},
      },
      results = {
      },
    },
    ["p-dope-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="p-dope", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["p2s5-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="p2s5", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["particle-accelerator-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="particle-accelerator-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pcb2-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pcb2", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["personal-roboport-mk2-equipment-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["perylene-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="perylene", amount=20000},
      },
      results = {
      },
    },
    ["phenol-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="phenol", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["phenolicboard-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="phenolicboard", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["photophore-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="photophore", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pink-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pink-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["plutonium-oxide-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="plutonium-oxide", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["plutonium-peroxide-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=20000},
      },
      results = {
      },
    },
    ["powdered-ti-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="powdered-ti", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["powdered-u-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="powdered-u", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ppd-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ppd", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["processed-fatty-acids-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=20000},
      },
      results = {
      },
    },
    ["productivity-module-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="productivity-module", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["psc-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="psc", amount=20000},
      },
      results = {
      },
    },
    ["ptcda-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ptcda", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pu-238-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pu-238", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pu-239-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pu-239", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pu-240-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pu-240", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pu-241-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pu-241", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pu-242-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="pu-242", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["pure-trichlorosilane-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pure-trichlorosilane", amount=20000},
      },
      results = {
      },
    },
    ["purex-antimony-void"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="purex-concentrate-1", amount=30},
        {type="fluid", name="sb-phosphate-2", amount=60},
        {type="item", name="plastic-bar", amount=3},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=120},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="sb-oxide", amount=0.5},
      },
    },
    ["purex-concentrate-1-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="purex-concentrate-1", amount=20000},
      },
      results = {
      },
    },
    ["purified-ti-pulp-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="purified-ti-pulp", amount=20000},
      },
      results = {
      },
    },
    ["purple-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="purple-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-biomass-powerplant-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="py-biomass-powerplant-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-coal-powerplant-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="py-coal-powerplant-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-heat-exchanger-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="py-heat-exchanger-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-logo-15tiles-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="py-logo-15tiles", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["py-oil-powerplant-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="py-oil-powerplant-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-plantation-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-plantation-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ralesia-seeds-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rayon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rayon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["red-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="red-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rennea-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rennea-plantation-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea-plantation-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rennea-plantation-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea-plantation-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rennea-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rennea-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rennea-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["resistor2-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="resistor2", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["resorcinol-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="resorcinol", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rotor-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rotor-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["rotor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="rotor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["s-biomass-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="s-biomass", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sample-cup-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sample-cup", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-extractor-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sap-extractor-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-seeds-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sap-seeds-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sap-tree-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sap-tree-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-58-conc-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sb-58-conc", amount=20000},
      },
      results = {
      },
    },
    ["sb-crushed-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sb-crushed", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sb-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-hpo-pu-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sb-hpo-pu", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sb-phosphate-1-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sb-phosphate-1", amount=20000},
      },
      results = {
      },
    },
    ["sb-phosphate-2-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sb-phosphate-2", amount=20000},
      },
      results = {
      },
    },
    ["sb-pulp-01-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sb-pulp-01", amount=20000},
      },
      results = {
      },
    },
    ["sb-pulp-02-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=20000},
      },
      results = {
      },
    },
    ["sea-sponge-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sea-sponge-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sea-sponge-sprouts-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sea-sponge-sprouts-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["seaweed-crop-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="seaweed-crop-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["seaweed-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="seaweed-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["seeds-extract-01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="seeds-extract-01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["self-assembly-monolayer-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="self-assembly-monolayer", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["shaft-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="shaft-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["silica-powder-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="silica-powder", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["silicon-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="silicon", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["silicon-wafer-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="silicon-wafer", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["small-parts-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="small-parts-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-bisulfate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-carbonate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-carbonate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-chlorate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-chlorate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-silicate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sodium-sulfate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sodium-sulfate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["speed-module-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="speed-module", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sponge-culture-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sponge-culture-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["spore-collector-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["sporopollenin-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="sporopollenin", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stainless-steel-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="stainless-steel", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["stator-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="stator", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steam-turbine-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="steam-turbine-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["steam-turbine-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="steam-turbine", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["syrup-01-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="syrup-01", amount=20000},
      },
      results = {
      },
    },
    ["ti-enriched-dust-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ti-enriched-dust", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ti-overflow-waste-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ti-overflow-waste", amount=20000},
      },
      results = {
      },
    },
    ["ti-pulp-03-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ti-pulp-03", amount=20000},
      },
      results = {
      },
    },
    ["tidal-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="tidal-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["titanium-overflow-waste-void"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ti-overflow-waste", amount=25},
      },
      results = {
        {type="item", name="ti-rejects", amount=1},
      },
    },
    ["titanium-pulp-stage-3-void"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ti-pulp-03", amount=60},
      },
      results = {
        {type="fluid", name="mibc", amount=30},
        {type="fluid", name="ti-overflow-waste", amount=30},
      },
    },
    ["tower-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="tower-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tpa-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="tpa", amount=20000},
      },
      results = {
      },
    },
    ["transistor-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="transistor", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["trichlorosilane-pyvoid-gas"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="trichlorosilane", amount=20000},
      },
      results = {
      },
    },
    ["trits-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="trits-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["trits-pup-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="trits-pup", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["trits-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="trits", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["trits-reef-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="trits-reef-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tuuphra-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["tuuphra-plantation-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="tuuphra-plantation-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["u-235-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="u-235", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["u-238-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="u-238", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["u-pulp-01-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="u-pulp-01", amount=20000},
      },
      results = {
      },
    },
    ["u-pulp-02-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="u-pulp-02", amount=20000},
      },
      results = {
      },
    },
    ["u-pulp-03-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="u-pulp-03", amount=20000},
      },
      results = {
      },
    },
    ["ulric-cub-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ulric-cub-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-mk02-dna-sample-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ulric-mk02-dna-sample", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["ulric-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["uranium-235-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="u-235", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["uranium-238-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="u-238", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["uranium-fuel-cell-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="uranium-fuel-cell", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["uranium-mining-drill-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="uranium-mining-drill", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["used-nexelit-battery-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="used-nexelit-battery", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["used-ulric-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="used-ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["utility-box-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="utility-box-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vane-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vane-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vat-brain-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vat-brain", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vawt-turbine-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vinyl-acetate-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vinyl-acetate", amount=20000},
      },
      results = {
      },
    },
    ["vrauks-food-02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vrauks-food-02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["vrauks-mk03-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="vrauks-mk03", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xenogenic-cells-pyvoid-fluid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="fluid", name="xenogenic-cells", amount=20000},
      },
      results = {
      },
    },
    ["xyhiphoe-cub-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xyhiphoe-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["xyhiphoe-pool-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="xyhiphoe-pool-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaedols-culture-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yaedols-culture-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaedols-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yaedols-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaedols-spores-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yaedols-spores-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yaw-drive-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yaw-drive-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yellow-cake-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yellow-cake", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yellow-refined-concrete-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yellow-refined-concrete", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-aloe-orchard-mk01-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-aloe-orchard-mk02-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-codex-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-codex", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-fruit-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-leaves-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-leaves", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["yotoi-seeds-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-seeds", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
    ["zinc-acetate-pyvoid"] = {
      mode = "frozen-preserved",
      science_level = 5,
      ingredients = {
        {type="item", name="zinc-acetate", amount=1},
      },
      results = {
        {type="item", name="ash", amount=0.2},
      },
    },
  },
}

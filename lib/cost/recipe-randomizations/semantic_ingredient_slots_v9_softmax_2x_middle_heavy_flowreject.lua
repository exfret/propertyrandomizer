-- Semantic ingredient-slot substitutions v9: direct softmax at 0.10/0.20/0.40, middle-heavy 25/60/15 classes, original ingredient allowed, post-scale flow rejection.
return {
  metadata = {
    format = "semantic-ingredient-slot-softmax-v9-2x-middle-heavy-flowreject",
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-ore", amount=12.3333333333},
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
        {type="item", name="iron-stick", amount=1},
        {type="item", name="stone-brick", amount=13.2786885246},
      },
      results = {
        {type="item", name="inductor1", amount=1},
      },
    },
    ["soil"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="fluid", name="steam", amount=72.7272727273},
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="bolts", amount=4.73684210526},
        {type="item", name="iron-plate", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="stone-brick", amount=23.606557377},
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
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-stick", amount=2},
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
        {type="item", name="copper-cable", amount=18.2716049383},
        {type="item", name="pipe", amount=5},
        {type="item", name="small-parts-01", amount=8},
      },
      results = {
        {type="item", name="steam-engine", amount=1},
      },
    },
    ["burner-mining-drill"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="iron-plate", amount=3},
        {type="item", name="small-parts-01", amount=3},
        {type="item", name="stone-furnace", amount=1},
      },
      results = {
        {type="item", name="burner-mining-drill", amount=1},
      },
    },
    ["offshore-pump"] = {
      mode = "input-preserved-unmodified",
      science_level = 0,
      ingredients = {
        {type="item", name="pipe", amount=3},
        {type="item", name="small-parts-01", amount=2},
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
        {type="item", name="transport-belt", amount=21.5625},
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
        {type="item", name="iron-plate", amount=20},
        {type="item", name="iron-stick", amount=50},
        {type="item", name="log", amount=5},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="wpu-mk01", amount=1},
      },
    },
    ["flora-collector-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="offshore-pump", amount=2.68373493976},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="transport-belt", amount=14.375},
      },
      results = {
        {type="item", name="flora-collector-mk01", amount=1},
      },
    },
    ["automation-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 0,
      ingredients = {
        {type="item", name="bolts", amount=9.47368421053},
        {type="item", name="iron-ore", amount=10},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="copper-ore", amount=16},
      },
      results = {
        {type="item", name="copper-plate", amount=2},
      },
    },
    ["grade-1-copper-crush"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="grade-1-copper", amount=2},
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
        {type="item", name="iron-stick", amount=6.32585435356},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=3},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="copper-ore", amount=193.333333333},
        {type="item", name="copper-plate", amount=10},
        {type="item", name="small-parts-01", amount=10},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=2},
        {type="item", name="stone-brick", amount=13.381147541},
      },
      results = {
        {type="item", name="repair-pack", amount=1},
      },
    },
    ["seaweed-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="copper-cable", amount=27.2083333333},
        {type="item", name="copper-plate", amount=10},
        {type="item", name="iron-plate", amount=15},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=6.6909859212},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="copper-plate", amount=1},
        {type="item", name="sand", amount=3.43421052632},
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
        {type="item", name="small-parts-01", amount=3.98162327718},
        {type="item", name="stone-brick", amount=100},
      },
      results = {
        {type="item", name="tailings-pond", amount=1},
      },
    },
    ["tin-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=63.2558139535},
      },
      results = {
        {type="item", name="tin-plate", amount=4},
      },
    },
    ["acetylene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=600},
        {type="item", name="gravel", amount=18.8407514705},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="transport-belt", amount=1.80144811821},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="pipe", amount=5.00328702992},
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
        {type="item", name="graphite", amount=3.46568704105},
      },
      results = {
        {type="item", name="aluminium-plate", amount=1},
      },
    },
    ["graphite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=7.56310830104},
      },
      results = {
        {type="item", name="graphite", amount=2},
      },
    },
    ["clay"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
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
        {type="item", name="sand", amount=3.55263157895},
        {type="item", name="tin-plate", amount=1},
      },
      results = {
        {type="item", name="tinned-cable", amount=1},
      },
    },
    ["engine-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="raw-fiber", amount=56.3926981815},
        {type="item", name="small-electric-pole", amount=0.815444022833},
      },
      results = {
        {type="item", name="engine-unit", amount=1},
      },
    },
    ["iron-oxide-smelting"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=434.633739868},
      },
      results = {
        {type="item", name="iron-plate", amount=10},
      },
    },
    ["lead-plate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-tin", amount=10.6534269896},
      },
      results = {
        {type="item", name="lead-plate", amount=1},
      },
    },
    ["moondrop-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="inductor1", amount=50},
        {type="item", name="small-lamp", amount=16.9507575758},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="tar", amount=500},
        {type="fluid", name="vacuum", amount=1000},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=300},
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
        {type="item", name="lime", amount=7.0863604812},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="raw-borax", amount=59.7437218774},
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
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {type="fluid", name="pressured-water", amount=466.666666667},
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
        {type="item", name="aluminium-plate", amount=23.3392657838},
        {type="item", name="coke", amount=39.9737210366},
        {type="item", name="lead-plate", amount=10},
      },
      results = {
        {type="item", name="py-tank-1000", amount=1},
      },
    },
    ["py-tank-3000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="cage", amount=3.21425720969},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="pipe", amount=20},
      },
      results = {
        {type="item", name="py-tank-3000", amount=1},
      },
    },
    ["py-tank-4000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=9.55882352941},
        {type="item", name="iron-stick", amount=40},
        {type="item", name="solder", amount=4.97285375781},
      },
      results = {
        {type="item", name="py-tank-4000", amount=1},
      },
    },
    ["py-tank-8000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=40},
        {type="item", name="pipe", amount=12},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="treated-wood", amount=44.4560681876},
      },
      results = {
        {type="item", name="py-tank-8000", amount=1},
      },
    },
    ["py-tank-10000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=171.321169982},
        {type="item", name="py-tank-4000", amount=2},
        {type="item", name="small-parts-01", amount=102.752939321},
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
        {type="item", name="pipe", amount=10},
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
        {type="item", name="iron-stick", amount=30},
        {type="item", name="lab", amount=2.9600989827},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="transport-belt", amount=4.55640744797},
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
        {type="item", name="small-parts-01", amount=102.752939321},
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
        {type="item", name="lead-plate", amount=30},
        {type="item", name="pipe", amount=8},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="stone", amount=216.666666667},
      },
      results = {
        {type="item", name="py-tank-5000", amount=1},
      },
    },
    ["py-tank-9000"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=16.4150943396},
        {type="item", name="py-tank-1500", amount=0.797644756626},
        {type="item", name="py-tank-4000", amount=2.93078767599},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=1933.33333333},
        {type="item", name="lime", amount=1.32956608068},
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
        {type="fluid", name="steam", amount=375.585898511},
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
        {type="fluid", name="coal-gas", amount=345.054386937},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=47.1317829457},
        {type="item", name="rich-clay", amount=35},
      },
      results = {
        {type="item", name="stone-brick", amount=20},
      },
    },
    ["tar-to-carbolic"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="fluid", name="tar", amount=100},
        {type="item", name="raw-coal", amount=1},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=10},
        {type="fluid", name="coal-gas", amount=35},
        {type="item", name="ash", amount=1},
        {type="item", name="rich-clay", amount=0.3},
      },
    },
    ["Moss-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="hydrogen", amount=313.392857143},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="moss", amount=16},
      },
    },
    ["Moss-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="muddy-sludge", amount=100},
      },
      results = {
        {type="item", name="moss", amount=8},
      },
    },
    ["aromatics-to-plastic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=50},
        {type="fluid", name="oxygen", amount=185.816603064},
      },
      results = {
        {type="item", name="plastic-bar", amount=1},
      },
    },
    ["log1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="fawogae-substrate", amount=1.2065129936},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
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
        {type="item", name="coke", amount=5},
        {type="item", name="iron-stick", amount=1.65384615385},
        {type="item", name="sodium-alginate", amount=0.740740740741},
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
        {type="item", name="iron-plate", amount=6.4909944557},
        {type="item", name="saps", amount=4.99056045356},
        {type="item", name="steel-plate", amount=1},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="empty-fuel-canister", amount=1},
      },
    },
    ["shotgun-shell"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="gunpowder", amount=2},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="lead-plate", amount=1},
      },
      results = {
        {type="item", name="shotgun-shell", amount=3},
      },
    },
    ["firearm-magazine"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="gunpowder", amount=10},
        {type="item", name="lead-plate", amount=2},
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
        {type="item", name="burner-mining-drill", amount=16.2669600293},
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
        {type="item", name="inductor1", amount=10},
        {type="item", name="iron-stick", amount=55.2862205545},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="soil", amount=50},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=50},
        {type="item", name="titanium-plate", amount=6.16238394178},
      },
      results = {
        {type="item", name="moss-farm-mk01", amount=1},
      },
    },
    ["sap-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="native-flora", amount=122},
        {type="item", name="pipe", amount=15},
        {type="item", name="soil", amount=100},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="sap-extractor-mk01", amount=1},
      },
    },
    ["seaweed-crop-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=20.5042016807},
        {type="item", name="coke", amount=16.5275961978},
        {type="item", name="pipe", amount=15},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="stone-furnace", amount=41.8005660629},
        {type="item", name="tin-plate", amount=50},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=60.9523809524},
        {type="item", name="pipe", amount=15},
        {type="item", name="small-parts-01", amount=40},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="tin-plate", amount=28.7841191067},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=176.199431855},
        {type="item", name="lead-plate", amount=10},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="storage-tank", amount=1},
      },
    },
    ["light-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=4},
        {type="item", name="iron-plate", amount=100.363246288},
        {type="item", name="steam-engine", amount=1.47204688909},
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
        {type="item", name="engine-unit", amount=1},
        {type="item", name="iron-plate", amount=5.01816231442},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="pump", amount=1},
      },
    },
    ["small-electric-pole-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=2.76923076923},
        {type="item", name="treated-wood", amount=3},
      },
      results = {
        {type="item", name="small-electric-pole", amount=3},
      },
    },
    ["py-gas-vent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=21.8867924528},
        {type="item", name="pipe", amount=15},
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
        {type="item", name="iron-plate", amount=40},
        {type="item", name="iron-stick", amount=37.5384615385},
        {type="item", name="offshore-pump", amount=5},
        {type="item", name="pipe", amount=20},
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
        {type="item", name="copper-plate", amount=164.747215605},
        {type="item", name="pipe", amount=20},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="planter-box", amount=1},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="tree-mk01", amount=1},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=2.61828388132},
        {type="item", name="empty-planter-box", amount=4.54259319742},
        {type="item", name="iron-plate", amount=30},
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
        {type="item", name="inductor1", amount=20},
        {type="item", name="jaw-crusher", amount=0.621426227978},
        {type="item", name="small-parts-01", amount=15},
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
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="transport-belt", amount=5.69550930997},
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
        {type="item", name="pipe", amount=20},
        {type="item", name="sand", amount=289.983552632},
        {type="item", name="steel-plate", amount=5},
        {type="item", name="stone-furnace", amount=58.3684210526},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=1},
      },
    },
    ["gasifier"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=0.501643180574},
        {type="item", name="inductor1", amount=4},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=20},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="stone-brick", amount=66.9057377049},
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
        {type="item", name="pipe", amount=22.3076923077},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=4},
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
        {type="item", name="copper-cable", amount=485.089023727},
        {type="item", name="copper-plate", amount=154.009433962},
        {type="item", name="inductor1", amount=30},
        {type="item", name="kerogen", amount=193.333333333},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="solid-separator", amount=1},
      },
    },
    ["tar-processing-unit"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="cellulose", amount=5.44822995152},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=2},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="pipe", amount=25},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-brick", amount=30},
      },
      results = {
        {type="item", name="washer", amount=1},
      },
    },
    ["evaporator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1.21688346755},
        {type="item", name="hpf", amount=5.39115708866},
        {type="item", name="pipe", amount=124},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="stone-furnace", amount=64.4407894737},
      },
      results = {
        {type="item", name="evaporator", amount=1},
      },
    },
    ["quenching-tower"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=50},
        {type="item", name="glass", amount=11.9485294118},
        {type="item", name="pump", amount=2},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="raw-coal", amount=108.333333333},
        {type="item", name="small-parts-01", amount=14.2113323124},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="clay-pit-mk01", amount=1},
      },
    },
    ["electronics-factory-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13.6283784803},
        {type="item", name="distilator", amount=1},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="wood", amount=47.424424154},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=1},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-electric-pole", amount=41.7381886764},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="stone-brick", amount=30},
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
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="copper-plate", amount=65.6603773585},
        {type="item", name="distilator", amount=2},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="vacuum-tube", amount=249.849277617},
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
        {type="item", name="pipe", amount=251.153846154},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="tar-processing-unit", amount=1.10291547285},
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
        {type="item", name="boiler", amount=39.4661921708},
        {type="item", name="duralumin", amount=50},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=50},
        {type="item", name="pipe", amount=50.2307692308},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="tin-plate", amount=14.012816815},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="glass", amount=10},
        {type="item", name="inductor1", amount=5},
        {type="item", name="iron-plate", amount=35},
        {type="item", name="planter-box", amount=10},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="soil-extractor-mk01", amount=1},
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
        {type="item", name="biofactory-mk01", amount=1.97065612668},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="glass", amount=50},
        {type="item", name="plastic-bar", amount=20},
        {type="item", name="pump", amount=3.21596375557},
        {type="item", name="small-parts-01", amount=19.0298553283},
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
        {type="item", name="advanced-foundry-mk01", amount=3.03894061166},
        {type="item", name="concrete", amount=28.57103438},
        {type="item", name="duralumin", amount=15},
        {type="item", name="iron-oxide", amount=18.9884551032},
        {type="item", name="small-parts-01", amount=30},
        {type="item", name="titanium-plate", amount=30},
      },
      results = {
        {type="item", name="incubator-mk01", amount=1},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="glass", amount=12},
        {type="item", name="inductor1", amount=10},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="soil-extractor-mk01", amount=1.79335736785},
        {type="item", name="steam-engine", amount=1.40554553652},
        {type="item", name="stone-brick", amount=50},
      },
      results = {
        {type="item", name="micro-mine-mk01", amount=1},
      },
    },
    ["rc-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="agar", amount=437.575279804},
        {type="item", name="aluminium-plate", amount=64.5591384875},
        {type="item", name="assembling-machine-1", amount=3.65065040264},
        {type="item", name="pipe", amount=502.307692308},
        {type="item", name="small-electric-pole", amount=59.7164169461},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="stone-brick", amount=400},
        {type="item", name="tinned-cable", amount=10.1303538175},
        {type="item", name="zinc-plate", amount=85.2196477297},
      },
      results = {
        {type="item", name="rc-mk01", amount=1},
      },
    },
    ["genlab-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=93.3570631354},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="firearm-magazine", amount=13.8252767825},
        {type="item", name="flora-collector-mk01", amount=7.88936910038},
        {type="item", name="py-tank-3000", amount=2},
        {type="item", name="tin-plate", amount=13.4987593052},
        {type="item", name="tinned-cable", amount=14.6063846562},
        {type="item", name="titanium-plate", amount=40},
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
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="fluid-drill-mk01", amount=0.68979838095},
        {type="item", name="glass", amount=40},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="micro-mine-mk01", amount=1},
      },
      results = {
        {type="item", name="research-center-mk01", amount=1},
      },
    },
    ["slaughterhouse-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="concrete", amount=25.629898488},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="graphite", amount=244.953522731},
        {type="item", name="pipe", amount=20},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="tin-plate", amount=37.3675115068},
        {type="item", name="wood-seeds", amount=91.5862434998},
      },
      results = {
        {type="item", name="slaughterhouse-mk01", amount=1},
      },
    },
    ["gate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="inductor1", amount=52.0653537753},
        {type="item", name="steel-plate", amount=2},
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
        {type="item", name="bolts", amount=3.41736694678},
      },
      results = {
        {type="item", name="stone-wall", amount=1},
      },
    },
    ["automated-screener-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="steel-plate", amount=60},
        {type="item", name="tar-processing-unit", amount=0.799447710598},
        {type="item", name="titanium-plate", amount=43.3624645903},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=1},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=20},
        {type="item", name="iron-stick", amount=50.2307692308},
        {type="item", name="pipe", amount=10},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=1},
      },
    },
    ["bio-sample"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="bio-container", amount=1},
        {type="item", name="native-flora", amount=15},
      },
      results = {
        {type="item", name="bio-sample", amount=1},
      },
    },
    ["moss-gen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bolts", amount=15.2101438067},
        {type="item", name="petri-dish", amount=2},
      },
      results = {
        {type="item", name="moss-gen", amount=1},
      },
    },
    ["earth-generic-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=10},
        {type="item", name="native-flora", amount=2430.38257774},
        {type="item", name="wooden-chest", amount=9.78842591743},
      },
      results = {
        {type="item", name="earth-generic-sample", amount=1},
      },
    },
    ["vrauks-cocoon-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=3.69830354655},
        {type="item", name="native-flora", amount=5},
        {type="item", name="pipe", amount=4.17693949152},
        {type="item", name="saps", amount=3},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="native-flora", amount=10},
        {type="item", name="petri-dish-bacteria", amount=9.12045889101},
        {type="item", name="py-tank-3000", amount=3.40223393016},
        {type="item", name="sodium-hydroxide", amount=37.7603834851},
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
        {type="item", name="boiler", amount=25.5772550608},
        {type="item", name="cellulose", amount=5.11006395453},
        {type="item", name="copper-plate", amount=20},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="micro-mine-mk01", amount=1},
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
        {type="item", name="saps", amount=2.1686746988},
        {type="item", name="stone", amount=22.6250889124},
        {type="item", name="water-barrel", amount=3},
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
        {type="item", name="cocoon", amount=10},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="moss-gen", amount=15},
        {type="item", name="planter-box", amount=35.1159717536},
        {type="item", name="pump", amount=2},
        {type="item", name="py-tank-3000", amount=0.553926214464},
      },
      results = {
        {type="item", name="fluidavan", amount=1},
      },
    },
    ["caravan"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="cocoon", amount=10},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="moss-gen", amount=15},
      },
      results = {
        {type="item", name="caravan", amount=1},
      },
    },
    ["concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="coal", amount=5.00964785513},
        {type="item", name="lime", amount=5},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="item", name="concrete", amount=5},
      },
    },
    ["stone-brick-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="item", name="lead-plate", amount=4.59669324656},
      },
      results = {
        {type="item", name="hazard-concrete", amount=10},
      },
    },
    ["refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=200},
        {type="item", name="concrete", amount=5},
        {type="item", name="iron-stick", amount=8},
        {type="item", name="steel-plate", amount=1},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="refined-concrete", amount=10},
      },
      results = {
        {type="item", name="refined-hazard-concrete", amount=10},
      },
    },
    ["outpost"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="agar", amount=1.52755724756},
        {type="item", name="concrete", amount=20},
        {type="item", name="glass", amount=5},
        {type="item", name="iron-plate", amount=140.732758621},
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
        {type="item", name="glass", amount=5},
        {type="item", name="py-tank-4000", amount=1},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=5},
        {type="item", name="stone-brick", amount=78.033863495},
      },
      results = {
        {type="item", name="outpost-fluid", amount=1},
      },
    },
    ["data-array"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=198.961654891},
        {type="item", name="concrete", amount=440.498579637},
        {type="item", name="copper-cable", amount=72.5333333333},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="tin-plate", amount=93.4187787669},
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
        {type="item", name="iron-stick", amount=2.55384615385},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="creamy-latex", amount=100},
        {type="fluid", name="oxygen", amount=788.907440791},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="latex-slab", amount=1},
      },
    },
    ["sap-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="saps", amount=5},
      },
      results = {
        {type="item", name="sap-seeds", amount=2},
      },
    },
    ["latex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=1650},
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
        {type="item", name="kerogen", amount=10.8333333333},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="lime", amount=4.44941672522},
        {type="item", name="pipe", amount=1},
        {type="item", name="zinc-plate", amount=1.31765949764},
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
        {type="item", name="iron-stick", amount=25.1153846154},
        {type="item", name="saps", amount=9.90796465016},
      },
      results = {
        {type="item", name="py-local-radar", amount=1},
      },
    },
    ["radar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="lead-plate", amount=2.80046775197},
        {type="item", name="pipe", amount=12.5576923077},
      },
      results = {
        {type="item", name="radar", amount=1},
      },
    },
    ["battery-mk00"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=250},
        {type="item", name="cellulose", amount=5},
        {type="item", name="copper-plate", amount=10},
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
        {type="item", name="assembling-machine-1", amount=2.30319062072},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="iron-oxide", amount=23.0738259446},
        {type="item", name="lead-plate", amount=7.88235104326},
        {type="item", name="quenching-tower", amount=0.550163843016},
        {type="item", name="raw-borax", amount=773.592078317},
      },
      results = {
        {type="item", name="electrolyzer-mk01", amount=1},
      },
    },
    ["smelter-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="fawogae-substrate", amount=44.5254479565},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="moss", amount=17.9741466759},
        {type="item", name="pipe", amount=68.5529255662},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="titanium-plate", amount=15},
      },
      results = {
        {type="item", name="smelter-mk01", amount=1},
      },
    },
    ["inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="duralumin", amount=1},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="planter-box", amount=2.07953589048},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="methane", amount=60},
        {type="item", name="copper-plate", amount=5},
      },
      results = {
        {type="fluid", name="methanal", amount=50},
      },
    },
    ["capacitor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="ceramic", amount=1},
        {type="item", name="py-check-valve", amount=0.764497074311},
      },
      results = {
        {type="item", name="capacitor1", amount=3},
      },
    },
    ["inductor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coal-dust", amount=1.78622501984},
        {type="item", name="lead-plate", amount=2.89703560548},
      },
      results = {
        {type="item", name="inductor1", amount=5},
      },
    },
    ["resistor1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=2},
        {type="item", name="glass", amount=1},
        {type="item", name="iron-stick", amount=6.2},
      },
      results = {
        {type="item", name="resistor1", amount=3},
      },
    },
    ["formica"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=840.800526057},
        {type="item", name="raw-fiber", amount=5},
        {type="item", name="saps", amount=10},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="fluid", name="vacuum", amount=50},
        {type="item", name="copper-plate", amount=5},
        {type="item", name="formica", amount=2},
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
        {type="item", name="limestone", amount=359.343655111},
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
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="engine-unit", amount=10.0872075355},
        {type="item", name="pipe", amount=37.6730769231},
        {type="item", name="steel-plate", amount=40},
      },
      results = {
        {type="item", name="olefin-plant", amount=1},
      },
    },
    ["reformer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="lab", amount=4.21292944694},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="titanium-plate", amount=61.8476857272},
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
        {type="fluid", name="vacuum", amount=2000},
        {type="item", name="empty-petri-dish", amount=3.50735294118},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="sodium-alginate", amount=1.85078096017},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="fish", amount=5},
        {type="item", name="inductor1", amount=18},
        {type="item", name="small-electric-pole", amount=6},
        {type="item", name="small-parts-01", amount=4},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="stone-brick", amount=20},
      },
      results = {
        {type="item", name="multiblade-turbine-mk01", amount=1},
      },
    },
    ["py-science-pack-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="refined-concrete", amount=31.5824825413},
        {type="item", name="stopper", amount=7.58673443609},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=3},
      },
    },
    ["agar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="wood-seeds", amount=2.12129902224},
      },
      results = {
        {type="item", name="agar", amount=1},
      },
    },
    ["cellulose-00"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="limestone", amount=4},
        {type="item", name="wood", amount=7},
      },
      results = {
        {type="item", name="cellulose", amount=1},
      },
    },
    ["cellulose-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=12.6433968624},
        {type="item", name="sodium-hydroxide", amount=3},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="coke", amount=15},
        {type="item", name="limestone", amount=10},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="item", name="lime", amount=10},
      },
    },
    ["dried-meat-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="chitin", amount=5},
      },
      results = {
        {type="item", name="dried-meat", amount=5},
      },
    },
    ["petri-dish-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=1.75367647059},
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
        {type="item", name="empty-petri-dish", amount=3.84558823529},
        {type="item", name="moss", amount=5},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
      ingredients = {
        {type="item", name="ore-quartz", amount=4},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="fluid", name="molten-glass", amount=10},
      },
    },
    ["stopper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="item", name="coal", amount=5},
        {type="item", name="refined-concrete", amount=18.1330546637},
      },
      results = {
        {type="item", name="stopper", amount=4},
      },
    },
    ["flask"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=857.354268673},
        {type="item", name="stopper", amount=4},
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
        {type="fluid", name="hydrogen", amount=392.857142857},
        {type="fluid", name="scrude", amount=300},
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=181.363402989},
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
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=181.363402989},
        {type="fluid", name="pitch", amount=100},
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
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=288.108306549},
      },
      results = {
        {type="fluid", name="creosote", amount=50},
      },
    },
    ["kerogen-extraction"] = {
      mode = "softmax-semantic-substitution",
      science_level = 1,
      ingredients = {
        {type="fluid", name="water", amount=1100},
        {type="item", name="kerogen", amount=25},
      },
      results = {
        {type="fluid", name="scrude", amount=250},
      },
    },
    ["light-oil-aromatics"] = {
      mode = "input-preserved-unmodified",
      science_level = 1,
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
      ingredients = {
        {type="fluid", name="tar", amount=327.588516182},
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
        {type="item", name="copper-cable", amount=48.8343965619},
        {type="item", name="electronic-circuit", amount=3},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-salt", amount=400},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=400},
      },
    },
    ["chitin-to-geothermal-water"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="battery-mk00", amount=0.673340144877},
      },
      results = {
        {type="fluid", name="geothermal-water", amount=50},
      },
    },
    ["he-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=200},
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
        {type="fluid", name="kerosene", amount=1430.25038324},
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
        {type="fluid", name="aromatics", amount=5053.56283101},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["borax-washing"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=150},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=100},
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
        {type="fluid", name="condensates", amount=658.281329588},
      },
      results = {
        {type="item", name="nexelit-ore", amount=1},
        {type="item", name="tailings-dust", amount=0.4},
      },
    },
    ["nexelit-plate-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="wood-seedling", amount=6.17425808386},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="soil", amount=149.995834375},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="rich-clay", amount=2.96155829435},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="fluid", name="oxygen", amount=1428.57142857},
        {type="item", name="automation-science-pack", amount=234.81326543},
        {type="item", name="petri-dish-bacteria", amount=8.19371727749},
        {type="item", name="py-underflow-valve", amount=19.0238633093},
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
        {type="item", name="graphite", amount=18.6784389818},
        {type="item", name="iron-plate", amount=10},
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
        {type="item", name="iron-plate", amount=137.488756266},
        {type="item", name="native-flora", amount=189.475324955},
      },
      results = {
        {type="item", name="fawogae-codex", amount=1},
      },
    },
    ["ralesia-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ceramic", amount=2.30367368976},
        {type="item", name="electronic-circuit", amount=50},
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
        {type="item", name="rich-clay", amount=5.88716861179},
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="steel-plate", amount=4.58888085797},
        {type="item", name="stone-furnace", amount=4},
        {type="item", name="titanium-plate", amount=8.63890274556},
      },
      results = {
        {type="item", name="fbreactor-mk01", amount=1},
      },
    },
    ["geothermal-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="hpf", amount=4.16266828422},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="geothermal-plant-mk01", amount=1},
      },
    },
    ["grade-1-lead"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-titanium", amount=8.94215241303},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ore-chromium", amount=5},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["nickel-plate-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-nickel", amount=1},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-ti", amount=3},
      },
      results = {
        {type="item", name="grade-3-ti", amount=1},
        {type="item", name="ti-rejects", amount=0.5},
      },
    },
    ["ti-rejects-recrush"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="ti-rejects", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-stick", amount=3},
        {type="item", name="ore-tin", amount=8.88377581121},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-2-zinc", amount=20},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="bones", amount=5},
      },
      results = {
        {type="fluid", name="chlorine", amount=100},
      },
    },
    ["phytoplankton"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=89.2857142857},
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["piercing-rounds-magazine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="lead-plate", amount=1},
        {type="item", name="shotgun-shell", amount=5.7384337884},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="piercing-rounds-magazine", amount=2},
      },
    },
    ["py-asphalt"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pitch", amount=10},
        {type="item", name="ash", amount=3},
        {type="item", name="wood", amount=2.78893163144},
      },
      results = {
        {type="item", name="py-asphalt", amount=1},
      },
    },
    ["py-iron-oxide"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=20},
        {type="item", name="iron-oxide", amount=4},
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
        {type="item", name="sodium-hydroxide", amount=2.38888888889},
      },
      results = {
        {type="item", name="py-limestone", amount=2},
      },
    },
    ["py-burner"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=9.79381862429},
        {type="item", name="small-lamp", amount=8.62624289763},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="stone-furnace", amount=5},
      },
      results = {
        {type="item", name="py-burner", amount=1},
      },
    },
    ["py-deposit-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cellulose", amount=5.28839018449},
        {type="item", name="lead-plate", amount=9.94919296755},
        {type="item", name="pipe", amount=112.739417547},
        {type="item", name="steel-plate", amount=80},
      },
      results = {
        {type="item", name="py-deposit-basic", amount=1},
      },
    },
    ["py-shed-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=53.1420132283},
        {type="item", name="iron-plate", amount=40},
        {type="item", name="refined-hazard-concrete", amount=3.39231841379},
        {type="item", name="wooden-chest", amount=5},
      },
      results = {
        {type="item", name="py-shed-basic", amount=1},
      },
    },
    ["py-storehouse-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=164.385966077},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="stone-brick", amount=15},
        {type="item", name="wooden-chest", amount=10},
      },
      results = {
        {type="item", name="py-storehouse-basic", amount=1},
      },
    },
    ["py-warehouse-basic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=4.94777793518},
        {type="item", name="duralumin", amount=51.3271751144},
        {type="item", name="tinned-cable", amount=14.5466440626},
        {type="item", name="treated-wood", amount=6.3835285191},
      },
      results = {
        {type="item", name="py-warehouse-basic", amount=1},
      },
    },
    ["rail"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=3.2286936234},
        {type="item", name="seaweed", amount=5.48887519922},
        {type="item", name="solder", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=5},
        {type="item", name="steam-engine", amount=0.864088864069},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=1},
      },
    },
    ["train-stop"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="gravel", amount=7.92560074362},
        {type="item", name="iron-plate", amount=6},
        {type="item", name="tin-plate", amount=9.56691459517},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="sb-grade-02", amount=10},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="refined-concrete", amount=10},
        {type="item", name="steel-plate", amount=6},
      },
      results = {
        {type="item", name="steel-furnace", amount=1},
      },
    },
    ["storage-chest"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="storage-chest", amount=1},
      },
    },
    ["anemometer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="small-parts-01", amount=15},
        {type="item", name="stone-brick", amount=69.2628172314},
      },
      results = {
        {type="item", name="anemometer-mk01", amount=1},
      },
    },
    ["blade-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="coke", amount=129.965431211},
        {type="item", name="melamine", amount=5},
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
        {type="item", name="duralumin", amount=20},
        {type="item", name="fenxsb-alloy", amount=8.46354808009},
        {type="item", name="glass", amount=10},
        {type="item", name="pipe", amount=35.0657031566},
        {type="item", name="steel-plate", amount=5},
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
        {type="item", name="resistor1", amount=20},
        {type="item", name="small-lamp", amount=6.40364825142},
        {type="item", name="solder", amount=5},
        {type="item", name="vacuum-tube", amount=5},
        {type="item", name="wood", amount=5.87667736626},
      },
      results = {
        {type="item", name="electronics-mk01", amount=1},
      },
    },
    ["shaft-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="advanced-foundry-mk01", amount=0.657777591751},
        {type="item", name="stone-brick", amount=21.1712661258},
        {type="item", name="vitreloy", amount=1.1815375662},
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
        {type="item", name="moss", amount=37.1095430151},
        {type="item", name="steel-plate", amount=11.8956025437},
        {type="item", name="stone-brick", amount=56.7767453583},
        {type="item", name="tinned-cable", amount=50},
      },
      results = {
        {type="item", name="utility-box-mk01", amount=1},
      },
    },
    ["vane-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="bolts", amount=50},
        {type="item", name="iron-plate", amount=15},
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
        {type="item", name="ceramic", amount=4.60734737951},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="ore-quartz", amount=5},
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
        {type="item", name="sodium-hydroxide", amount=26.0450114997},
        {type="item", name="steel-plate", amount=5},
        {type="item", name="titanium-plate", amount=4},
        {type="item", name="utility-box-mk01", amount=0.638549188519},
      },
      results = {
        {type="item", name="gearbox-mk01", amount=1},
      },
    },
    ["nacelle-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=11.3153311915},
        {type="item", name="battery-mk01", amount=2.33208383212},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="gearbox-mk01", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="py-local-radar", amount=4.3393214927},
        {type="item", name="rail-signal", amount=1.31657843721},
        {type="item", name="steel-plate", amount=19.7114706489},
        {type="item", name="utility-box-mk01", amount=5},
        {type="item", name="vane-mk01", amount=7.64351173838},
      },
      results = {
        {type="item", name="nacelle-mk01", amount=1},
      },
    },
    ["tower-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="bolts", amount=30},
        {type="item", name="solder", amount=15},
        {type="item", name="steel-plate", amount=50},
      },
      results = {
        {type="item", name="tower-mk01", amount=1},
      },
    },
    ["yaw-drive-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=127.859347995},
        {type="item", name="py-iron-oxide", amount=15.7102598655},
        {type="item", name="rubber", amount=15},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="small-parts-01", amount=50},
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
        {type="fluid", name="muddy-sludge", amount=1084.6381532},
        {type="item", name="brain", amount=3},
        {type="item", name="chitin", amount=0.974505858468},
        {type="item", name="guts", amount=3},
        {type="item", name="meat", amount=7},
        {type="item", name="mukmoux-fat", amount=1},
        {type="item", name="plasmids", amount=1},
        {type="item", name="seaweed", amount=56.8298742841},
      },
      results = {
        {type="item", name="animal-sample-01", amount=1},
      },
    },
    ["bio-sample01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="bonemeal", amount=10},
        {type="item", name="native-flora", amount=12},
        {type="item", name="ralesia-seeds", amount=18},
        {type="item", name="stopper", amount=1.24839594735},
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
        {type="item", name="concrete", amount=12.8870675422},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="fenxsb-alloy", amount=1},
      },
      results = {
        {type="item", name="equipment-chassi", amount=2},
      },
    },
    ["ground-sample01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="coal-dust", amount=4.5585208278},
        {type="item", name="soil", amount=10},
      },
      results = {
        {type="item", name="ground-sample01", amount=10},
      },
    },
    ["rich-clay"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="ash", amount=25},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["sand-casting"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="creosote", amount=20},
        {type="item", name="limestone", amount=3.79047030287},
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
        {type="item", name="dried-meat", amount=83.2225236114},
        {type="item", name="landfill", amount=0.509798165058},
        {type="item", name="nexelit-plate", amount=17.0335187671},
        {type="item", name="shotgun-shell", amount=22.5407741968},
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
        {type="item", name="lime", amount=1.31166593514},
        {type="item", name="raw-borax", amount=40},
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
        {type="item", name="chromium", amount=1},
        {type="item", name="nickel-plate", amount=1.94801864828},
        {type="item", name="saps", amount=1.44578313253},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="lime", amount=3.22750120803},
        {type="item", name="powdered-aluminium", amount=2},
        {type="item", name="sand-casting", amount=0.838008701074},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=10},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=100},
        {type="item", name="iron-stick", amount=3.07467943788},
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
        {type="fluid", name="hydrogen", amount=123.80952381},
        {type="fluid", name="molten-glass", amount=50},
      },
      results = {
        {type="item", name="glass", amount=7},
      },
    },
    ["antimony-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electric-mining-drill", amount=5},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="plastic-bar", amount=34.5399217116},
        {type="item", name="small-parts-01", amount=40},
        {type="item", name="soil", amount=180.169936028},
      },
      results = {
        {type="item", name="antimony-drill-mk01", amount=1},
      },
    },
    ["centrifuge-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=488.343965619},
        {type="item", name="electric-mining-drill", amount=2},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=14.7514456215},
        {type="item", name="pipe", amount=350.657031566},
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
        {type="item", name="antimony-drill-mk01", amount=5.63593296076},
        {type="item", name="bio-sample01", amount=0.979000424903},
        {type="item", name="rotor-mk01", amount=1},
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
        {type="item", name="inductor1", amount=747.559529602},
        {type="item", name="intermetallics", amount=20},
        {type="item", name="iron-plate", amount=300},
        {type="item", name="lead-plate", amount=137.821826822},
        {type="item", name="mechanical-parts-01", amount=4},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="soil-extractor-mk01", amount=5.96117769197},
        {type="item", name="titanium-plate", amount=14.36759476},
        {type="item", name="treated-wood", amount=108.184548351},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
      },
    },
    ["py-oil-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=1085.65869749},
        {type="item", name="gas-refinery-mk01", amount=1},
        {type="item", name="hpf", amount=1.48708905267},
        {type="item", name="latex", amount=18.9840749213},
        {type="item", name="micro-mine-mk01", amount=4.18485862469},
        {type="item", name="pipe", amount=200},
        {type="item", name="sodium-hydroxide", amount=2208.6447379},
        {type="item", name="steam-engine", amount=20},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="stone-brick", amount=846.850645034},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=1},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="glass", amount=208.580812434},
        {type="item", name="hydrogen-barrel", amount=90.0466313728},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="rectisol", amount=0.68810874276},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="steam-engine", amount=17.1819415313},
        {type="item", name="treated-wood", amount=5.30096480899},
        {type="item", name="yaw-drive-mk01", amount=0.719142110501},
      },
      results = {
        {type="item", name="steam-turbine-mk01", amount=1},
      },
    },
    ["tidal-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=3},
        {type="item", name="ceramic", amount=360.376597344},
        {type="item", name="gearbox-mk01", amount=3},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="lime", amount=138.57642195},
        {type="item", name="mechanical-parts-01", amount=10},
        {type="item", name="nexelit-plate", amount=340.670375341},
        {type="item", name="pipe", amount=20},
        {type="item", name="rail-signal", amount=18.0716586694},
        {type="item", name="shaft-mk01", amount=3},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="zogna-bacteria-barrel", amount=11.7946046222},
      },
      results = {
        {type="item", name="tidal-mk01", amount=1},
      },
    },
    ["vawt-turbine-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="belt", amount=15},
        {type="item", name="bonemeal", amount=21.8589364535},
        {type="item", name="copper-cable", amount=50},
        {type="item", name="duralumin", amount=80},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="gearbox-mk01", amount=5},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="kerogen", amount=144.08297398},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="syngas-barrel", amount=10.5078902706},
        {type="item", name="treated-wood", amount=92.9410292177},
        {type="item", name="vane-mk01", amount=51.1049895029},
      },
      results = {
        {type="item", name="vawt-turbine-mk01", amount=1},
      },
    },
    ["py-coal-powerplant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=0.532748378731},
        {type="item", name="electronic-circuit", amount=100},
        {type="item", name="fluid-drill-mk01", amount=2.9173598117},
        {type="item", name="intermetallics", amount=50},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="rotor-mk01", amount=3.3675101396},
        {type="item", name="small-parts-01", amount=300},
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
        {type="item", name="cyanic-acid-barrel", amount=3.83949780256},
        {type="item", name="wood-fence", amount=0.682936068898},
      },
      results = {
        {type="item", name="arithmetic-combinator", amount=1},
      },
    },
    ["constant-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=5},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="intermetallics", amount=1.03819661818},
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
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="melamine", amount=4.13144708285},
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
        {type="item", name="iron-gear-wheel", amount=3.03890851258},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="py-tank-4000", amount=0.791451962369},
      },
      results = {
        {type="item", name="power-switch", amount=1},
      },
    },
    ["programmable-speaker"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="ash", amount=2.44383620251},
        {type="item", name="copper-cable", amount=5},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="moss", amount=2.58785369819},
      },
      results = {
        {type="item", name="programmable-speaker", amount=1},
      },
    },
    ["selector-combinator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="constant-combinator", amount=8.86480835011},
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
        {type="fluid", name="hydrogen", amount=273.80952381},
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
        {type="fluid", name="creosote", amount=1835.11498249},
        {type="fluid", name="methane", amount=100},
        {type="item", name="coal", amount=20},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=100},
        {type="fluid", name="hydrogen", amount=50},
      },
    },
    ["melamine"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="ammonia", amount=20},
        {type="fluid", name="cyanic-acid", amount=20},
        {type="fluid", name="water", amount=200},
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
        {type="fluid", name="carbon-dioxide", amount=151.62159678},
      },
      results = {
        {type="fluid", name="water", amount=400},
      },
    },
    ["flue-gas-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="gravel", amount=3.2536270146},
      },
      results = {
        {type="fluid", name="flue-gas", amount=150},
      },
    },
    ["flue-gas-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=346.666666667},
        {type="item", name="ore-lead", amount=1.53426101963},
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
        {type="item", name="coal", amount=39.0936553632},
        {type="item", name="formica", amount=50.2713709985},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="titanium-plate", amount=10},
        {type="item", name="vane-mk01", amount=0.862236331456},
      },
      results = {
        {type="item", name="cracker-mk01", amount=1},
      },
    },
    ["heavy-oil-refinery-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13.5579932389},
        {type="item", name="duralumin", amount=3.37244701919},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="iron-stick", amount=150.319223396},
        {type="item", name="steam-engine", amount=10},
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
        {type="item", name="duralumin", amount=5},
        {type="item", name="fbreactor-mk01", amount=5.91526068629},
        {type="item", name="inductor1", amount=74.7559529602},
        {type="item", name="jaw-crusher", amount=0.762713654697},
        {type="item", name="pipe", amount=30},
        {type="item", name="refined-concrete", amount=6.18440834417},
        {type="item", name="sb-oxide", amount=2.5223671302},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="steel-plate", amount=30},
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
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="heavy-oil-refinery-mk01", amount=1.08393872924},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="pipe", amount=30},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=30},
      },
      results = {
        {type="item", name="upgrader-mk01", amount=1},
      },
    },
    ["earth-bear-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-codex", amount=5},
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="seaweed", amount=1338.20218269},
      },
      results = {
        {type="item", name="earth-bear-sample", amount=1},
      },
    },
    ["earth-flower-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="light-oil-barrel", amount=213.676917899},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="utility-box-mk01", amount=1.34317038219},
      },
      results = {
        {type="item", name="earth-flower-sample", amount=1},
      },
    },
    ["earth-shroom-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-codex", amount=3.82898582479},
        {type="item", name="automation-science-pack", amount=100},
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
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="moondrop-codex", amount=5.58625023707},
      },
      results = {
        {type="item", name="earth-mouse-sample", amount=1},
      },
    },
    ["molten-iron-05"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="borax", amount=3},
        {type="item", name="iron-ore", amount=11.1111111111},
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
        {type="fluid", name="steam", amount=226.086956522},
        {type="item", name="graphite", amount=1.37248117829},
        {type="item", name="sand-casting", amount=1},
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
        {type="item", name="graphite", amount=1.37248117829},
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
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="iron-plate", amount=177.517126811},
        {type="item", name="nexelit-plate", amount=85.1675938353},
        {type="item", name="rubber", amount=3},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="vrauks-codex", amount=1.90725218402},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=3},
      },
    },
    ["sb-oxide-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="glass", amount=5.7532443552},
        {type="item", name="sb-grade-01", amount=11.5865564074},
      },
      results = {
        {type="item", name="sb-oxide", amount=1},
      },
    },
    ["pbsb-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="pipe", amount=12.4855917348},
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
        {type="fluid", name="pitch", amount=583.227145763},
        {type="item", name="bolts", amount=3},
        {type="item", name="graphite", amount=3},
        {type="item", name="melamine", amount=2},
        {type="item", name="raw-borax", amount=3.26634409812},
        {type="item", name="small-parts-01", amount=7.22288729338},
        {type="item", name="zinc-plate", amount=3},
      },
      results = {
        {type="item", name="battery-mk01", amount=1},
      },
    },
    ["accumulator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="graphite", amount=1.60141003273},
        {type="item", name="lab", amount=41.1765948397},
      },
      results = {
        {type="item", name="accumulator", amount=1},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete-wall", amount=0.866781416351},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="sb-oxide", amount=1},
      },
      results = {
        {type="item", name="fenxsb-alloy", amount=2},
      },
    },
    ["vitreloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=12.4586213652},
        {type="item", name="copper-plate", amount=3},
        {type="item", name="duralumin", amount=3},
        {type="item", name="glass", amount=10.4716262134},
        {type="item", name="wood-fence", amount=1.21305098107},
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
        {type="item", name="boiler", amount=7.5516650811},
        {type="item", name="cellulose", amount=58.5925496064},
        {type="item", name="coal-dust", amount=12.5473411584},
        {type="item", name="copper-plate", amount=30},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="gunpowder", amount=10.5320253419},
        {type="item", name="lab", amount=0.870236830316},
        {type="item", name="moss", amount=304.040768992},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=1},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-plate", amount=20},
        {type="item", name="duralumin", amount=5.05867052878},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="flora-collector-mk01", amount=0.639872626651},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=23.9554968142},
        {type="item", name="nexelit-plate", amount=14.6038155934},
        {type="item", name="tin-plate", amount=7.17046151529},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=1},
      },
    },
    ["classifier"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="rich-clay", amount=5.89969742482},
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
        {type="item", name="concrete", amount=82.1929830387},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=25},
        {type="item", name="lab", amount=1.74047366063},
        {type="item", name="pipe", amount=20},
        {type="item", name="py-tank-5000", amount=0.683373417137},
        {type="item", name="rich-clay", amount=32.039484649},
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
        {type="item", name="brake-mk01", amount=0.69120454166},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="inserter", amount=3},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="iron-plate", amount=236.689502414},
        {type="item", name="pipe", amount=70.1314063132},
      },
      results = {
        {type="item", name="automated-factory-mk01", amount=1},
      },
    },
    ["fluid-drill-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="distilator", amount=1.50278865417},
        {type="item", name="electric-mining-drill", amount=2},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="gravel", amount=81.0967403303},
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
        {type="item", name="iron-plate", amount=15},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-chest", amount=4.93925870267},
        {type="item", name="steel-furnace", amount=1},
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
        {type="item", name="py-local-radar", amount=1},
        {type="item", name="rail-chain-signal", amount=1.13836580669},
        {type="item", name="steel-furnace", amount=2},
        {type="item", name="tin-plate", amount=47.8345729759},
        {type="item", name="titanium-plate", amount=10.0761962586},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=1},
      },
    },
    ["eaf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=1.50414506951},
        {type="item", name="boiler", amount=5},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=25},
      },
      results = {
        {type="item", name="eaf-mk01", amount=1},
      },
    },
    ["hydroclassifier-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="equipment-chassi", amount=19.0232347304},
        {type="item", name="guts", amount=31.5042001049},
        {type="item", name="moss-gen", amount=15.2412049031},
        {type="item", name="slacked-lime-barrel", amount=0.521244044304},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="smelter-mk01", amount=0.824822546506},
        {type="item", name="soil-extractor-mk01", amount=1.87533495813},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=1},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=22.8465214822},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="glass", amount=103.647457627},
        {type="item", name="nickel-plate", amount=7.15445299426},
        {type="item", name="py-local-radar", amount=2},
        {type="item", name="steam-engine", amount=6},
        {type="item", name="steel-plate", amount=39.6259628505},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=1},
      },
    },
    ["scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="boron-trioxide", amount=10.3079655486},
        {type="item", name="copper-cable", amount=496.945066028},
        {type="item", name="fluid-drill-mk01", amount=0.533238073371},
        {type="item", name="latex", amount=21.4508311743},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="washer", amount=0.933134275587},
      },
      results = {
        {type="item", name="scrubber-mk01", amount=1},
      },
    },
    ["flotation-cell-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=41.0964915194},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=16.8509609643},
        {type="item", name="log", amount=49.9464455218},
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
        {type="item", name="concrete", amount=48.0406234255},
        {type="item", name="gearbox-mk01", amount=0.725036954164},
        {type="item", name="glass", amount=174.527103557},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="cargo-wagon", amount=1},
      },
    },
    ["fluid-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=113.368779725},
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="engine-unit", amount=1.04963954868},
        {type="item", name="glass", amount=35.1713869576},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=3.84443132688},
        {type="item", name="muddy-sludge-barrel", amount=29.0374238088},
        {type="item", name="sodium-hydroxide", amount=89.1211244066},
        {type="item", name="storage-tank", amount=1},
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
        {type="item", name="cooling-tower-mk01", amount=0.789401906746},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=70.3427739153},
        {type="item", name="lead-plate", amount=124.916424694},
        {type="item", name="pipe", amount=20},
        {type="item", name="pump", amount=2.71584695235},
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
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=20.0602775884},
        {type="item", name="py-check-valve", amount=22.952892211},
        {type="item", name="storage-tank", amount=0.65972555978},
        {type="item", name="water-barrel", amount=5.48863313776},
      },
      results = {
        {type="item", name="cooling-tower-mk01", amount=1},
      },
    },
    ["fawogae-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="agar", amount=105.359377956},
        {type="item", name="boron-trioxide", amount=5.0084177284},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="pipe", amount=10},
        {type="item", name="tinned-cable", amount=25},
        {type="item", name="vacuum-pump-mk01", amount=0.800808490766},
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
        {type="item", name="duralumin", amount=10.1173410576},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=50},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="small-lamp", amount=8},
        {type="item", name="sodium-hydroxide", amount=38.4458620825},
        {type="item", name="steel-plate", amount=40},
      },
      results = {
        {type="item", name="prandium-lab-mk01", amount=1},
      },
    },
    ["ralesia-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cellulose", amount=16.4188196957},
        {type="item", name="inductor1", amount=186.8898824},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="seaweed", amount=360.905380866},
        {type="item", name="soil", amount=300},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="titanium-plate", amount=29.8779971969},
        {type="item", name="treated-wood", amount=50},
        {type="item", name="wood", amount=77.5090851277},
      },
      results = {
        {type="item", name="ralesia-plantation-mk01", amount=1},
      },
    },
    ["fish-farm-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1.14911247739},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=140},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="lens", amount=113.282069726},
        {type="item", name="pump", amount=5},
        {type="item", name="titanium-plate", amount=89.6339915906},
        {type="item", name="wooden-chest", amount=51.8409859122},
      },
      results = {
        {type="item", name="fish-farm-mk01", amount=1},
      },
    },
    ["heavy-armor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="intermetallics", amount=5},
        {type="item", name="latex-slab", amount=4},
        {type="item", name="pbsb-alloy", amount=2.76897578318},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="rubber", amount=24.3640753386},
        {type="item", name="sodium-hydroxide", amount=130.225057498},
        {type="item", name="zinc-plate", amount=44.6530338146},
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
        {type="item", name="burner-inserter", amount=23.8168620247},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="py-tank-8000", amount=1},
        {type="item", name="slacked-lime-barrel", amount=13.5799268236},
        {type="item", name="steel-plate", amount=11.8268823893},
        {type="item", name="titanium-plate", amount=50},
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
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="pipe", amount=20},
        {type="item", name="pump", amount=6.19011204756},
        {type="item", name="py-tank-7000", amount=1},
        {type="item", name="small-parts-01", amount=50},
      },
      results = {
        {type="item", name="py-heat-exchanger", amount=1},
      },
    },
    ["secondary-crusher-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=96.0812468509},
        {type="item", name="glass", amount=40.939944876},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="soil-extractor-mk01", amount=5.9093167097},
        {type="item", name="steel-plate", amount=40},
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
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=50},
        {type="item", name="glassworks-mk01", amount=0.51656023961},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="pipe", amount=103.97703198},
        {type="item", name="planter-box", amount=9.50101772581},
        {type="item", name="titanium-plate", amount=35},
      },
      results = {
        {type="item", name="atomizer-mk01", amount=1},
      },
    },
    ["bio-reactor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=473.379004828},
        {type="item", name="resistor1", amount=178.739783215},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="tailings-pond", amount=1},
        {type="item", name="titanium-plate", amount=14.3244226773},
        {type="item", name="washer", amount=10.4628302202},
      },
      results = {
        {type="item", name="bio-reactor-mk01", amount=1},
      },
    },
    ["plankton-farm"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="inductor1", amount=37.3779764801},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="pipe", amount=20},
        {type="item", name="rail-signal", amount=0.76627315744},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="stone-brick", amount=20},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="titanium-plate", amount=25.1904906465},
      },
      results = {
        {type="item", name="plankton-farm", amount=1},
      },
    },
    ["spore-collector-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="concrete", amount=32.4028914542},
        {type="item", name="inductor1", amount=74.7559529602},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=20},
        {type="item", name="soil-extractor-mk01", amount=2.2486718896},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="titanium-plate", amount=11.8984337057},
      },
      results = {
        {type="item", name="spore-collector-mk01", amount=1},
      },
    },
    ["compost-plant-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=203.23392497},
        {type="item", name="glass", amount=175.856934788},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="pcb1", amount=38.0433469947},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="steel-chest", amount=3.89887198462},
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
        {type="item", name="fish-oil-barrel", amount=7.73628702593},
        {type="item", name="gasifier", amount=1},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="lab", amount=1},
        {type="item", name="pipe", amount=70.1314063132},
        {type="item", name="tinned-cable", amount=14.5466440626},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=1},
      },
    },
    ["py-electric-boiler"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="distilator", amount=2.09940434136},
        {type="item", name="iron-plate", amount=100},
        {type="item", name="lab", amount=1},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="wpu-mk01", amount=1.65849422376},
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
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="pipe", amount=30},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="tin-plate", amount=14.8454320998},
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
        {type="item", name="ceramic", amount=182.302647225},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=12},
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
        {type="item", name="display-panel", amount=10.940448234},
        {type="item", name="gasoline-barrel", amount=33.665512691},
        {type="item", name="glass", amount=49.2399417407},
        {type="item", name="nexelit-plate", amount=172.828492308},
        {type="item", name="small-electric-pole", amount=1},
      },
      results = {
        {type="item", name="portable-gasoline-generator", amount=1},
      },
    },
    ["py-recharge-station-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="copper-cable", amount=30},
        {type="item", name="copper-plate", amount=15},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="transport-belt", amount=6.81155567051},
      },
      results = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
    },
    ["py-roboport-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="nexelit-plate", amount=68.1340750682},
        {type="item", name="pipe", amount=177.894910944},
        {type="item", name="water-saline-barrel", amount=11.2677146455},
      },
      results = {
        {type="item", name="py-roboport-mk01", amount=1},
      },
    },
    ["py-ze"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="inductor1", amount=37.706010781},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="small-parts-01", amount=20},
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
        {type="item", name="intermetallics", amount=20},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="soil-extractor-mk01", amount=3.18763731831},
        {type="item", name="washer", amount=10.6618579334},
      },
      results = {
        {type="item", name="salt-mine", amount=1},
      },
    },
    ["dino-dig-site"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="iron-plate", amount=591.723756036},
        {type="item", name="lead-plate", amount=50},
        {type="item", name="refined-concrete", amount=128.994891685},
        {type="item", name="steam-engine", amount=8.59097076563},
        {type="item", name="zinc-plate", amount=111.632584536},
      },
      results = {
        {type="item", name="dino-dig-site", amount=1},
      },
    },
    ["generator-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog", amount=1},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="iron-stick", amount=30},
        {type="item", name="pipe", amount=10},
        {type="item", name="py-shed-basic", amount=0.542360389333},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="stone-brick", amount=169.370129007},
        {type="item", name="tin-plate", amount=27.5137371774},
        {type="item", name="titanium-plate", amount=17.9387922385},
      },
      results = {
        {type="item", name="generator-1", amount=1},
      },
    },
    ["pyphoon-bay"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="inductor1", amount=37.1620462398},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="iron-plate", amount=50},
        {type="item", name="lead-plate", amount=213.720240164},
        {type="item", name="py-gas-vent", amount=16.5260194},
        {type="item", name="sand", amount=100},
        {type="item", name="wood", amount=50},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=1},
      },
    },
    ["belt"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="rubber", amount=1},
      },
      results = {
        {type="item", name="belt", amount=2},
      },
    },
    ["polybutadiene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="pressured-water", amount=833.333333333},
        {type="fluid", name="scrude", amount=509.068627451},
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
      ingredients = {
        {type="item", name="belt", amount=1},
        {type="item", name="chromium", amount=10},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="inserter", amount=1},
        {type="item", name="pipe", amount=17.5328515783},
        {type="item", name="steel-plate", amount=3.96520084791},
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
        {type="item", name="concrete", amount=81.0072286356},
        {type="item", name="duralumin", amount=5},
        {type="item", name="latex-slab", amount=2.84435719948},
        {type="item", name="nickel-plate", amount=3.17300423842},
      },
      results = {
        {type="item", name="engine-unit", amount=3},
      },
    },
    ["transport-belt-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="belt", amount=5},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="pipe", amount=10.519710947},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="aromatics", amount=2102.84614854},
        {type="fluid", name="liquid-manure", amount=100},
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
        {type="item", name="alien-sample01", amount=1.23639767529},
        {type="item", name="capacitor1", amount=5},
        {type="item", name="formica", amount=1.27663512483},
        {type="item", name="inductor1", amount=3},
        {type="item", name="resistor1", amount=6},
        {type="item", name="solder", amount=2},
        {type="item", name="treated-wood", amount=9.82890001847},
      },
      results = {
        {type="item", name="electronic-circuit", amount=5},
      },
    },
    ["formica-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="melamine", amount=39.8866931913},
        {type="item", name="stone", amount=89.4127315071},
      },
      results = {
        {type="item", name="formica", amount=5},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=123.80952381},
        {type="fluid", name="molten-glass", amount=50},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=2},
      },
    },
    ["hotair-flask"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["stopper-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="rubber", amount=1},
      },
      results = {
        {type="item", name="stopper", amount=2},
      },
    },
    ["meat-to-tin"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="meat", amount=5},
      },
      results = {
        {type="item", name="ore-tin", amount=15},
      },
    },
    ["skin-to-lead"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="brain", amount=3.5},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="sodium-hydroxide", amount=1.33333333333},
      },
      results = {
        {type="fluid", name="water-saline", amount=100},
      },
    },
    ["starch"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="formica", amount=0.678379901251},
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
        {type="item", name="anemometer-mk01", amount=4},
        {type="item", name="battery-mk01", amount=100},
        {type="item", name="copper-cable", amount=100},
        {type="item", name="display-panel", amount=9.5024374913},
        {type="item", name="gearbox-mk01", amount=0.725036954164},
        {type="item", name="lead-plate", amount=147.514456215},
        {type="item", name="middle-oil-barrel", amount=10.3575490698},
        {type="item", name="py-science-pack-1", amount=7.35013026952},
        {type="item", name="rich-clay", amount=230.556474034},
        {type="item", name="titanium-plate", amount=7.05225987543},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="aerial-blimp-mk01", amount=1},
      },
    },
    ["blood-to-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="blood", amount=50},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="item", name="planter-box", amount=6.80919605636},
      },
      results = {
        {type="item", name="bonemeal", amount=5},
      },
    },
    ["bones-to-kerogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="py-asphalt", amount=5.95760272921},
      },
      results = {
        {type="item", name="kerogen", amount=8},
      },
    },
    ["breed-fish-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="vacuum", amount=672},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="cocoon", amount=17.2500246844},
        {type="item", name="native-flora", amount=5.78422580373},
        {type="item", name="nexelit-plate", amount=23.5162093993},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish", amount=10},
      },
    },
    ["breed-fish-egg-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fish", amount=12},
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
        {type="item", name="battery-mk01", amount=2},
        {type="item", name="chromium", amount=17.0776226581},
        {type="item", name="concrete", amount=18.8586903263},
        {type="item", name="firearm-magazine", amount=18.6809874594},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="nexelit-plate", amount=22.3668869421},
        {type="item", name="shaft-mk01", amount=2.75848008645},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="solder", amount=5},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="py-construction-robot-mk01", amount=1},
      },
    },
    ["liquid-manure"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=500},
        {type="item", name="iron-stick", amount=77.5260116084},
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
        {type="item", name="petri-dish-bacteria", amount=1.6387434555},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="wood", amount=5},
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
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="petri-dish", amount=1.22044728435},
        {type="item", name="stopper", amount=1.60022426449},
      },
      results = {
        {type="item", name="plasmids", amount=1},
      },
    },
    ["retrovirus"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="water", amount=346.666666667},
        {type="item", name="cocoon", amount=4},
        {type="item", name="empty-petri-dish", amount=2.12203389831},
        {type="item", name="petri-dish-bacteria", amount=2.56364860505},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="stopper", amount=15.6735877108},
      },
      results = {
        {type="item", name="retrovirus", amount=1},
      },
    },
    ["cdna"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=5},
        {type="item", name="calcium-carbide", amount=37.7199344899},
        {type="item", name="flask", amount=3},
        {type="item", name="moss-gen", amount=5},
        {type="item", name="petri-dish", amount=6.10223642173},
        {type="item", name="plasmids", amount=1},
        {type="item", name="py-tank-3000", amount=1.43708859258},
        {type="item", name="stopper", amount=15.6735877108},
      },
      results = {
        {type="item", name="cdna", amount=1},
      },
    },
    ["ralesia-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=144.230769231},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="refined-hazard-concrete", amount=3.39695749584},
        {type="item", name="spore-collector-mk01", amount=1.19739435379},
      },
      results = {
        {type="item", name="ralesia", amount=2},
      },
    },
    ["ralesia-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="lens", amount=3.46208053933},
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
        {type="item", name="capacitor1", amount=17.2617974827},
        {type="item", name="concrete", amount=47.7444537949},
        {type="item", name="glass", amount=2},
        {type="item", name="steam-engine", amount=43.2044432035},
      },
      results = {
        {type="item", name="cottongut-codex", amount=1},
      },
    },
    ["cottongut-cub-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="cottongut", amount=4},
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
        {type="fluid", name="hot-air", amount=144.230769231},
        {type="item", name="acetylene-barrel", amount=9.43781812333},
        {type="item", name="cdna", amount=3},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-generic-sample", amount=5},
        {type="item", name="earth-mouse-sample", amount=1},
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
        {type="item", name="burner-inserter", amount=4.46615139531},
        {type="item", name="ralesia-seeds", amount=2},
        {type="item", name="seaweed", amount=5},
        {type="item", name="tin-plate", amount=2},
        {type="item", name="wood-seeds", amount=5},
      },
      results = {
        {type="item", name="cottongut-food-01", amount=4},
      },
    },
    ["cottongut-science-red-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="depolymerized-organics", amount=50},
        {type="item", name="cottongut", amount=20},
        {type="item", name="fawogae-substrate", amount=10},
        {type="item", name="native-flora", amount=5},
        {type="item", name="plasmids", amount=1},
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
        {type="item", name="alien-sample01", amount=2},
        {type="item", name="battery-mk01", amount=3},
        {type="item", name="grenade", amount=15.4379947976},
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
        {type="fluid", name="tailings", amount=183.545922962},
        {type="fluid", name="water", amount=100},
        {type="item", name="bones", amount=4.5},
        {type="item", name="brain", amount=1.33333333333},
        {type="item", name="kerogen", amount=26.2},
        {type="item", name="mukmoux-fat", amount=1},
        {type="item", name="native-flora", amount=5},
        {type="item", name="seaweed", amount=5},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="item", name="workers-food", amount=2},
      },
    },
    ["auog-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=5},
        {type="item", name="tin-plate", amount=37.048346056},
      },
      results = {
        {type="item", name="auog-codex", amount=1},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="coke", amount=176.069515865},
        {type="item", name="ground-sample01", amount=20.4367215086},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=80},
        {type="item", name="stone-furnace", amount=15.7894736842},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=1},
      },
    },
    ["auog-pooping-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="ore-lead", amount=5.30498314446},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=5.5},
      },
    },
    ["auog-pup-breeding-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
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
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="py-shed-basic", amount=5.52431554066},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["auog-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="limestone", amount=35.6295813953},
        {type="item", name="moss", amount=5},
        {type="item", name="native-flora", amount=5},
        {type="item", name="plastic-bar", amount=2},
        {type="item", name="seaweed", amount=3},
      },
      results = {
        {type="item", name="auog-food-01", amount=3},
      },
    },
    ["auog-maturing-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-pup", amount=4},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
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
      ingredients = {
        {type="item", name="brain", amount=1.25},
        {type="item", name="chromium", amount=1.20618559877},
        {type="item", name="used-auog", amount=1},
      },
      results = {
        {type="item", name="auog", amount=1},
      },
    },
    ["auog-maturing-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-pup", amount=8},
        {type="item", name="graphite", amount=8.23338259546},
        {type="item", name="native-flora", amount=20},
        {type="item", name="saps", amount=12},
        {type="item", name="stopper", amount=2.14265125017},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="auog", amount=5.5},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-pooping-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
        {type="item", name="water-barrel", amount=5},
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
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="kerosene-canister", amount=0.762416673672},
        {type="item", name="saps", amount=2.62392756925},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
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
      ingredients = {
        {type="fluid", name="diborane", amount=827.672360823},
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
        {type="fluid", name="steam", amount=1000},
        {type="item", name="earth-shroom-sample", amount=1},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="fawogae-spore", amount=10},
        {type="item", name="tailings-dust", amount=2.46951054598},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="oxygen", amount=535.714285714},
        {type="item", name="boron-trioxide", amount=1},
      },
      results = {
        {type="item", name="lens", amount=4},
      },
    },
    ["lens"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="boron-trioxide", amount=1},
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
        {type="item", name="moss", amount=8},
        {type="item", name="small-parts-01", amount=4.19977365649},
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
        {type="item", name="agar", amount=4},
        {type="item", name="aluminium-plate", amount=11.8688847259},
        {type="item", name="fawogae", amount=5},
        {type="item", name="moss", amount=10},
        {type="item", name="tin-plate", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon", amount=50},
        {type="item", name="lime", amount=32.2495979478},
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=8},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks", amount=1.275},
        {type="item", name="vrauks-mk02", amount=0.005},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="cocoon-mk02", amount=8},
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=8},
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
      mode = "input-preserved-unmodified",
      science_level = 2,
      ingredients = {
        {type="item", name="native-flora", amount=15},
        {type="item", name="saps", amount=8},
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
      mode = "softmax-semantic-substitution",
      science_level = 2,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="cellulose", amount=0.68190614755},
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
        {type="item", name="inductor1", amount=22.2670891621},
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
        {type="item", name="plastic-bar", amount=47.9267236569},
        {type="item", name="steel-chest", amount=1},
      },
      results = {
        {type="item", name="buffer-chest", amount=1},
      },
    },
    ["passive-provider-chest"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=3},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="bones", amount=2},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-tin", amount=1.19623663292},
      },
      results = {
        {type="item", name="tin-dust", amount=1},
      },
    },
    ["tin-plate-4"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="tin-ore-rejects", amount=2.32870174373},
      },
      results = {
        {type="item", name="tin-plate", amount=8},
      },
    },
    ["molten-tin-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="borax", amount=4},
        {type="item", name="fish", amount=2.79181092339},
        {type="item", name="tin-dust", amount=6},
      },
      results = {
        {type="fluid", name="molten-tin", amount=30},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
        {type="item", name="glass", amount=45.0361002267},
        {type="item", name="ground-sample01", amount=2.67953775286},
        {type="item", name="moondrop", amount=5.6749847421},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="tin-ore-rejects", amount=8.45224547695},
      },
      results = {
        {type="item", name="carbon-filter", amount=1},
      },
    },
    ["fts-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=0.901643488384},
        {type="item", name="burner-mining-drill", amount=5.35705203773},
        {type="item", name="concrete", amount=20},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="glass", amount=10},
        {type="item", name="sb-grade-04", amount=367.549787506},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="underground-belt", amount=3.60405756731},
      },
      results = {
        {type="item", name="fts-reactor", amount=1},
      },
    },
    ["methanol-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="boiler", amount=2},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="rubber", amount=110.334222645},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="stone-brick", amount=26.5383458437},
      },
      results = {
        {type="item", name="methanol-reactor", amount=1},
      },
    },
    ["fluid-separator"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="burner-inserter", amount=102.992937418},
        {type="item", name="duralumin", amount=4.99226344674},
        {type="item", name="inductor1", amount=10.4146123534},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=249.795855245},
        {type="item", name="solid-separator", amount=3.46216550187},
      },
      results = {
        {type="item", name="fluid-separator", amount=1},
      },
    },
    ["chromite-rejects-processing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="methanal-barrel", amount=2.06096519628},
      },
      results = {
        {type="item", name="grade-3-chromite", amount=0.6},
      },
    },
    ["grade-4-chromite"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="grade-3-chromite", amount=2},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="naphthalene-oil-canister", amount=0.502696592738},
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
        {type="item", name="grade-2-iron", amount=2.13543183545},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=50},
        {type="fluid", name="iron-slime", amount=50},
      },
    },
    ["grade-2-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=5},
      },
      results = {
        {type="item", name="grade-1-iron", amount=1},
        {type="item", name="grade-2-iron", amount=0.5},
        {type="item", name="grade-3-iron", amount=0.5},
      },
    },
    ["iron-slime"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=300},
        {type="item", name="iron-oxide", amount=140},
      },
      results = {
        {type="fluid", name="iron-slime", amount=50},
      },
    },
    ["unslimed-iron"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="iron-slime", amount=100},
        {type="fluid", name="water", amount=200},
      },
      results = {
        {type="fluid", name="tailings", amount=100},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["grade-2-crush"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-iron", amount=0.549583475373},
      },
      results = {
        {type="item", name="grade-1-iron", amount=1},
        {type="item", name="gravel", amount=0.5},
      },
    },
    ["grade-3-iron-processing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-1-iron", amount=3.24087112517},
      },
      results = {
        {type="item", name="grade-2-iron", amount=1},
      },
    },
    ["iron-ore-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=3.8309110156},
      },
      results = {
        {type="item", name="iron-ore-dust", amount=1},
      },
    },
    ["molten-iron-06"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="borax", amount=3},
        {type="item", name="grade-3-iron", amount=2.13611616945},
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
        {type="item", name="wood-fence", amount=1.18682338924},
      },
      results = {
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="grade-4-copper", amount=0.3},
      },
    },
    ["copper-rejects-recrush"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="copper-rejects", amount=1},
      },
      results = {
        {type="item", name="grade-3-copper", amount=0.5},
        {type="item", name="gravel", amount=1},
      },
    },
    ["grade-3-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-1-copper", amount=0.914285714286},
      },
      results = {
        {type="item", name="copper-rejects", amount=1},
        {type="item", name="grade-3-copper", amount=1},
      },
    },
    ["grade-4-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-2-copper", amount=3.98611111111},
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
        {type="item", name="borax", amount=3},
        {type="item", name="starch", amount=0.528313339281},
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
        {type="item", name="low-grade-rejects", amount=4.2284843869},
      },
      results = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="low-grade-copper", amount=1},
      },
    },
    ["copper-plate-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-copper", amount=100},
        {type="item", name="borax", amount=3},
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
        {type="fluid", name="water", amount=765},
        {type="item", name="borax", amount=3},
        {type="item", name="grade-3-copper", amount=6.30813513104},
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
        {type="item", name="electric-mining-drill", amount=3},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="lab", amount=1},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="tin-plate", amount=62.9778648293},
        {type="item", name="titanium-plate", amount=72.9031958325},
        {type="item", name="washer", amount=5.46949715917},
      },
      results = {
        {type="item", name="coalbed-mk01", amount=1},
      },
    },
    ["lor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="concrete", amount=29.4857356393},
        {type="item", name="engine-unit", amount=1.69047302588},
        {type="item", name="gasifier", amount=1.10733996273},
        {type="item", name="intermetallics", amount=15},
        {type="item", name="lens", amount=3.53841255256},
        {type="item", name="melamine", amount=28.5660527245},
        {type="item", name="raw-coal", amount=2180.79804211},
        {type="item", name="steel-plate", amount=30},
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
        {type="item", name="intermetallics", amount=4},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="moss-farm-mk01", amount=0.54594296619},
        {type="item", name="pipe", amount=10},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="natural-gas-derrick-mk01", amount=1},
      },
    },
    ["oil-derrick-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="coke", amount=24.5969825185},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="plastic-bar", amount=8.74655136117},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=1},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13.7302136543},
        {type="item", name="electric-mining-drill", amount=4},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="soil-extractor-mk01", amount=2.92982311689},
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
        {type="item", name="intermetallics", amount=5},
        {type="item", name="offshore-pump", amount=1.36712009321},
        {type="item", name="pipe", amount=34.1711258772},
        {type="item", name="resistor1", amount=29.587142287},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="zinc-plate", amount=27.8908712285},
      },
      results = {
        {type="item", name="pumpjack-mk01", amount=1},
      },
    },
    ["tar-extractor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="antimony-drill-mk01", amount=1.45457123181},
        {type="item", name="chromium", amount=5},
        {type="item", name="copper-cable", amount=70.7770768649},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="gravel", amount=74.6470260579},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="jaw-crusher", amount=0.630685645024},
        {type="item", name="lead-plate", amount=15},
        {type="item", name="steel-plate", amount=50},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="coarse-coal", amount=3},
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
        {type="item", name="aluminium-plate", amount=28.4023457146},
        {type="item", name="copper-cable", amount=353.885384325},
        {type="item", name="distilator", amount=2.17705975155},
        {type="item", name="duralumin", amount=30},
        {type="item", name="ground-sample01", amount=30.4964755112},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="planter-box", amount=21.5247399436},
        {type="item", name="plastic-bar", amount=20},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=1},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=267.474791046},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="py-tank-5000", amount=1.54843319818},
        {type="item", name="steam-engine", amount=1.74809690596},
        {type="item", name="tin-plate", amount=37.7867188976},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=1},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="coal-dust", amount=40.8925414419},
        {type="item", name="dried-meat", amount=4.22121813042},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="fish-egg", amount=12.1175633816},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=730.527937639},
        {type="item", name="refined-concrete", amount=36.9706190625},
        {type="item", name="steam-engine", amount=2},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bio-sample", amount=18.1632950436},
        {type="item", name="concrete", amount=200},
        {type="item", name="electronic-circuit", amount=100},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="small-parts-01", amount=234.478597429},
        {type="item", name="storage-tank", amount=1},
        {type="item", name="tin-plate", amount=25.1911459317},
        {type="item", name="titanium-plate", amount=100},
      },
      results = {
        {type="item", name="yaedols-culture-mk01", amount=1},
      },
    },
    ["crawdad"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="blood", amount=300},
        {type="fluid", name="hydrogen", amount=1138.86924322},
        {type="item", name="alien-sample01", amount=10},
        {type="item", name="bio-sample", amount=50},
        {type="item", name="engine-unit", amount=104.813952975},
        {type="item", name="heavy-armor", amount=1},
        {type="item", name="moss-gen", amount=30},
        {type="item", name="py-deposit-basic", amount=38.2869618531},
        {type="item", name="py-shed-basic", amount=1},
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
        {type="item", name="anemometer-mk01", amount=10.5786224136},
        {type="item", name="concrete", amount=14.7428678197},
        {type="item", name="distilator", amount=4.0378872583},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=100},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="nickel-plate", amount=9.48810988292},
        {type="item", name="sodium-hydroxide", amount=57.076667839},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="tinned-cable", amount=24.4990296973},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="pipe", amount=3.61436354767},
        {type="item", name="sodium-hydroxide", amount=2.37829391397},
      },
      results = {
        {type="item", name="sncr-alloy", amount=2},
      },
    },
    ["empty-comb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=436.887221372},
        {type="item", name="ash", amount=5},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="limestone", amount=1.88493673495},
        {type="item", name="tailings-dust", amount=15},
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
        {type="item", name="bones", amount=5},
        {type="item", name="chitin", amount=0.763272432875},
        {type="item", name="fawogae", amount=10},
        {type="item", name="gasoline-barrel", amount=0.709598185779},
        {type="item", name="lens", amount=0.868092792137},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="salt", amount=8.29749812907},
        {type="item", name="sb-grade-04", amount=35.8724091473},
      },
      results = {
        {type="item", name="fish-food-01", amount=3},
      },
    },
    ["flask-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=120.594115248},
        {type="fluid", name="pitch", amount=397.875252628},
        {type="item", name="lens", amount=4.9722102343},
        {type="item", name="petri-dish-bacteria", amount=0.831527901121},
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
        {type="item", name="grade-1-lead", amount=4.35714285714},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
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
        {type="item", name="borax", amount=2.2978843232},
        {type="item", name="grade-1-zinc", amount=4.59162951845},
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
        {type="item", name="pure-sand", amount=3.21405979478},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=50},
      },
    },
    ["hotair-zinc-plate-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-zinc", amount=100},
        {type="fluid", name="water", amount=195},
        {type="item", name="borax", amount=2},
        {type="item", name="iron-gear-wheel", amount=3.22516325759},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-lead", amount=20},
        {type="fluid", name="molten-tin", amount=10},
        {type="fluid", name="tar", amount=30},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-solder", amount=50},
      },
      results = {
        {type="item", name="solder", amount=7},
      },
    },
    ["molten-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="molten-iron", amount=50},
        {type="fluid", name="oxygen", amount=100},
        {type="item", name="log", amount=2.18440080273},
      },
      results = {
        {type="fluid", name="flue-gas", amount=500},
        {type="fluid", name="molten-steel", amount=50},
      },
    },
    ["hotair-steel-20"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=120.594115248},
        {type="fluid", name="molten-steel", amount=100},
        {type="item", name="rich-dust", amount=10.0640680527},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=2},
        {type="item", name="melamine-resin", amount=12.1096570948},
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
        {type="item", name="belt", amount=0.965306998038},
        {type="item", name="fawogae-plantation-mk01", amount=2.40746236446},
        {type="item", name="lead-plate", amount=25.4340038816},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="tuuphra-codex", amount=1},
      },
    },
    ["yaedols-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bolts", amount=6.69283756854},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="yaedols-codex", amount=1},
      },
    },
    ["sea-sponge-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="alien-sample01", amount=1.14143452434},
        {type="item", name="lead-plate", amount=2.07536314183},
        {type="item", name="tinned-cable", amount=20},
        {type="item", name="vacuum-tube", amount=161.39103679},
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
        {type="item", name="agar", amount=2.32260345486},
        {type="item", name="distilator", amount=1},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="py-tank-3000", amount=4.71734741491},
        {type="item", name="steel-plate", amount=15},
        {type="item", name="titanium-plate", amount=20.0814673858},
        {type="item", name="treated-wood", amount=36.8555189643},
      },
      results = {
        {type="item", name="leaching-station-mk01", amount=1},
      },
    },
    ["wet-scrubber-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="alien-sample01", amount=0.796866361585},
        {type="item", name="assembling-machine-1", amount=4.18779144217},
        {type="item", name="distilator", amount=1},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="pipe", amount=10},
        {type="item", name="py-tank-1500", amount=1.30654182313},
        {type="item", name="steel-plate", amount=15},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=150},
        {type="item", name="tin-plate", amount=4.11911964327},
        {type="item", name="wood", amount=2.87415202708},
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
        {type="fluid", name="methane", amount=308.399033354},
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
      ingredients = {
        {type="item", name="aluminium-plate", amount=1},
        {type="item", name="grade-3-tin", amount=1.98233097003},
        {type="item", name="iron-chest", amount=0.911817452203},
        {type="item", name="lead-plate", amount=20},
      },
      results = {
        {type="item", name="military-science-pack", amount=2},
      },
    },
    ["niobium-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="battery-mk00", amount=8.34322585509},
        {type="item", name="electric-mining-drill", amount=5},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="glassworks-mk01", amount=0.538174086025},
        {type="item", name="hot-air-barrel", amount=16.6374918079},
        {type="item", name="steam-engine", amount=1.01715774043},
      },
      results = {
        {type="item", name="niobium-mine", amount=1},
      },
    },
    ["nxsb-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="alien-sample01", amount=5.22901337899},
        {type="item", name="pipe", amount=15.6463950185},
      },
      results = {
        {type="item", name="nxsb-alloy", amount=3},
      },
    },
    ["pbsb-alloy-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="lubricant", amount=354.679621733},
        {type="item", name="sb-oxide", amount=4},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="creosote", amount=60},
        {type="item", name="coke", amount=3},
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
        {type="item", name="boron-trioxide", amount=2.03870547699},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="naphthalene-oil-barrel", amount=0.709425354608},
        {type="item", name="titanium-plate", amount=5.35076543964},
      },
      results = {
        {type="item", name="zipir-codex", amount=2},
      },
    },
    ["zipir-eggs-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=100},
        {type="fluid", name="pressured-water", amount=60},
        {type="item", name="fish", amount=5},
        {type="item", name="stone-wool", amount=2},
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
        {type="item", name="alien-sample01", amount=17.436618751},
        {type="item", name="caged-auog", amount=19.644067768},
        {type="item", name="classifier", amount=4.11768074624},
        {type="item", name="glass", amount=13.1795775148},
        {type="item", name="sodium-hydroxide", amount=413.757618143},
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
        {type="fluid", name="carbon-dioxide", amount=123.686272049},
        {type="fluid", name="pressured-water", amount=300},
        {type="item", name="grenade", amount=0.619932369114},
        {type="item", name="gunpowder", amount=35.4180235866},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=300},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=30},
        {type="item", name="processed-iron-ore", amount=3.8309110156},
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
        {type="item", name="copper-plate", amount=400},
        {type="item", name="electronic-circuit", amount=100},
        {type="item", name="engine-unit", amount=49.2982879339},
        {type="item", name="iron-plate", amount=200},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="pipe", amount=200},
        {type="item", name="small-parts-01", amount=500},
        {type="item", name="steam-engine", amount=50},
        {type="item", name="utility-box-mk01", amount=3.48016648296},
      },
      results = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
    },
    ["ree-mining-drill-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bio-sample", amount=4.94667015286},
        {type="item", name="glass", amount=30.0240668178},
        {type="item", name="iron-plate", amount=294.468755171},
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
        {type="item", name="gravel", amount=11.9088799058},
        {type="item", name="sulfur", amount=3},
      },
      results = {
        {type="item", name="pyrite", amount=1},
      },
    },
    ["rich-clay-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=340.276395191},
        {type="item", name="clay", amount=20},
      },
      results = {
        {type="item", name="rich-clay", amount=10},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chromite-sand", amount=78.6581244043},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="soot", amount=10},
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
        {type="item", name="tin-plate", amount=39.5395497164},
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
        {type="item", name="rich-clay", amount=9.5081821387},
      },
      results = {
        {type="item", name="chromite-sand", amount=3},
        {type="item", name="iron-oxide", amount=2},
      },
    },
    ["soot-to-lead"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="soot", amount=10},
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
        {type="item", name="silver-plate", amount=2},
        {type="item", name="stopper", amount=1.66999147506},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=80},
        {type="item", name="pure-sand", amount=8},
      },
    },
    ["acetic-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=406.617758082},
        {type="fluid", name="vacuum", amount=68.9917578723},
        {type="item", name="pure-sand", amount=1.68476426859},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acetone", amount=100},
        {type="fluid", name="syngas", amount=100},
      },
      results = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="organic-solvent", amount=100},
      },
    },
    ["phosphorous-acid"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=260.863872287},
        {type="item", name="ash", amount=4},
        {type="item", name="iron-oxide", amount=7.81216853306},
        {type="item", name="powdered-phosphate-rock", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water-saline", amount=169.414687085},
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
        {type="item", name="copper-plate", amount=3},
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
        {type="fluid", name="phosphorous-acid", amount=40},
        {type="fluid", name="steam", amount=120},
        {type="item", name="powdered-phosphate-rock", amount=3.52560030955},
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
      ingredients = {
        {type="fluid", name="steam", amount=200},
        {type="fluid", name="syngas", amount=60},
        {type="item", name="pipe", amount=4.3871820668},
      },
      results = {
        {type="fluid", name="propene", amount=60},
        {type="fluid", name="water", amount=50},
      },
    },
    ["phosphoric-acid2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="light-oil", amount=1277.20719161},
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
        {type="item", name="powdered-aluminium", amount=5},
        {type="item", name="zinc-chloride", amount=2.63172810863},
      },
      results = {
        {type="fluid", name="al-pulp-01", amount=100},
      },
    },
    ["al-pulp-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=100},
        {type="fluid", name="water", amount=900},
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
        {type="item", name="melamine", amount=10.5603221934},
        {type="item", name="sand-casting", amount=1.20187792504},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=346.688548521},
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
        {type="fluid", name="propene", amount=3655.31436177},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=500},
      },
    },
    ["wastewater-recovery"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="pure-sand", amount=10},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=150},
      },
    },
    ["glass-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="crushed-quartz", amount=2.08421052632},
        {type="item", name="py-asphalt", amount=3.08415951725},
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
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="borax", amount=1.53192288213},
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
        {type="item", name="cdna", amount=0.94068178014},
        {type="item", name="electric-mining-drill", amount=5},
        {type="item", name="flora-collector-mk01", amount=4.273232982},
        {type="item", name="latex", amount=19.0096639276},
        {type="item", name="soil-extractor-mk01", amount=1.34577064998},
        {type="item", name="steel-plate", amount=60},
      },
      results = {
        {type="item", name="sulfur-mine", amount=1},
      },
    },
    ["albumin-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=1109.21473784},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="decalin", amount=542.95709681},
        {type="item", name="mukmoux-fat", amount=3.09474470126},
      },
      results = {
        {type="item", name="sugar", amount=10},
      },
    },
    ["waste-water-urea"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=1339.72257412},
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
        {type="item", name="bones", amount=2},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="petri-dish", amount=1.35286039131},
        {type="item", name="powdered-biomass", amount=87.7904912351},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fiber", amount=4},
        {type="item", name="lead-plate", amount=2.41490035994},
      },
      results = {
        {type="item", name="micro-fiber", amount=2},
      },
    },
    ["bitumen-to-nickel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1436.37395822},
        {type="fluid", name="steam", amount=1229.56807351},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-nickel", amount=1},
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
        {type="item", name="coal", amount=4.45882389852},
        {type="item", name="grade-1-nickel", amount=12.2380952381},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=50},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-nickel", amount=100},
        {type="item", name="sand-casting", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tar", amount=500},
        {type="fluid", name="water", amount=637.5},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["soda-ash"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=83.3333333333},
        {type="fluid", name="water-saline", amount=250},
        {type="item", name="ash", amount=50},
      },
      results = {
        {type="fluid", name="soda-ash", amount=200},
      },
    },
    ["industrial-solvent"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=200},
        {type="fluid", name="soda-ash", amount=200},
        {type="fluid", name="syngas", amount=200},
      },
      results = {
        {type="fluid", name="industrial-solvent", amount=100},
      },
    },
    ["vanabins"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acidgas", amount=200},
        {type="fluid", name="phosphoric-acid", amount=364.394909837},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=556.58822422},
        {type="fluid", name="naphtha", amount=738.025815495},
      },
      results = {
        {type="fluid", name="vpulp1", amount=100},
      },
    },
    ["molybdenum-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="molybdenum-concentrate", amount=30},
      },
      results = {
        {type="fluid", name="molybdenum-pulp", amount=100},
        {type="fluid", name="muddy-sludge", amount=200},
      },
    },
    ["vpulp2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="vpulp1", amount=200},
        {type="item", name="coal-dust", amount=51.0296841962},
      },
      results = {
        {type="fluid", name="vpulp2", amount=100},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="dried-biomass", amount=48.0620330805},
      },
      results = {
        {type="fluid", name="molybdenite-pulp", amount=100},
      },
    },
    ["vpulp3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="boric-acid", amount=475.275428424},
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
        {type="item", name="sand", amount=12.4309189032},
        {type="item", name="solder", amount=1},
        {type="item", name="zinc-plate", amount=1.2154665408},
      },
      results = {
        {type="item", name="py-aluminium", amount=1},
      },
    },
    ["py-coal-tile"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=724.054073851},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tar", amount=20},
        {type="item", name="capacitor1", amount=1.014908046},
        {type="item", name="nexelit-plate", amount=1},
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
        {type="item", name="ground-sample01", amount=1.11318830492},
        {type="item", name="powdered-quartz", amount=1},
      },
      results = {
        {type="item", name="py-quartz", amount=2},
      },
    },
    ["py-steel"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=5},
        {type="fluid", name="molten-steel", amount=10},
        {type="item", name="graphite", amount=1.26414806886},
      },
      results = {
        {type="item", name="py-steel", amount=2},
      },
    },
    ["hydrogen-chloride"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="chlorine", amount=100},
        {type="fluid", name="hydrogen", amount=100},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=100},
        {type="item", name="small-lamp", amount=0.5},
      },
    },
    ["methanol-void-denitrification"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="item", name="brain", amount=2.56984748213},
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
        {type="item", name="pipe", amount=3.11502266253},
      },
      results = {
        {type="fluid", name="nitrogen", amount=200},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="vacuum", amount=53.3333333333},
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
        {type="fluid", name="hydrogen", amount=113.892464312},
        {type="item", name="ore-lead", amount=20.1539343926},
        {type="item", name="raw-borax", amount=18.9716360542},
        {type="item", name="tin-plate", amount=3.90833495764},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="chromium", amount=3},
        {type="item", name="iron-plate", amount=5},
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
        {type="item", name="iron-stick", amount=5.43472515967},
        {type="item", name="salt", amount=23.1215648842},
        {type="item", name="workers-food", amount=0.745439008274},
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
        {type="item", name="steel-plate", amount=8},
        {type="item", name="zinc-plate", amount=3.0605924374},
      },
      results = {
        {type="item", name="drill-head", amount=6},
      },
    },
    ["nichrome"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="nitrogen", amount=100},
        {type="item", name="ceramic", amount=6.85635405052},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="nitrogen", amount=50},
        {type="fluid", name="vacuum", amount=53.3333333333},
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
        {type="fluid", name="hot-air", amount=500},
        {type="fluid", name="steam", amount=1926.51338315},
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
        {type="fluid", name="water", amount=500},
        {type="item", name="clay", amount=5},
        {type="item", name="sodium-hydroxide", amount=1.09177405384},
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
        {type="fluid", name="aromatics", amount=222.507707098},
        {type="fluid", name="pressured-water", amount=2500},
        {type="item", name="lime", amount=3.42328010247},
      },
      results = {
        {type="fluid", name="coalbed-gas", amount=150},
        {type="fluid", name="water", amount=2500},
      },
    },
    ["pressured-hydrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hot-air", amount=153.846153846},
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
      ingredients = {
        {type="fluid", name="syngas", amount=1126.46208414},
        {type="fluid", name="water", amount=637.5},
        {type="item", name="borax", amount=1.04837145303},
      },
      results = {
        {type="fluid", name="diesel", amount=300},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=3574.24887622},
        {type="fluid", name="steam", amount=325},
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
        {type="fluid", name="hydrogen", amount=906.594533248},
        {type="fluid", name="pressured-water", amount=1114.28571429},
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
        {type="fluid", name="flue-gas", amount=3574.14081096},
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
        {type="fluid", name="methane", amount=395.0170345},
        {type="fluid", name="steam", amount=650},
        {type="item", name="small-electric-pole", amount=1.5017623643},
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
        {type="fluid", name="hot-air", amount=512.820512821},
        {type="fluid", name="syngas", amount=300},
        {type="item", name="nichrome", amount=2},
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
        {type="fluid", name="subcritical-water", amount=1408.00316276},
        {type="item", name="green-sic", amount=2.31098294975},
      },
      results = {
        {type="fluid", name="olefin", amount=150},
        {type="fluid", name="petroleum-gas", amount=400},
      },
    },
    ["bone-solvent"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=191.537016918},
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
        {type="fluid", name="flue-gas", amount=618.412662345},
        {type="item", name="brain", amount=3.86540275801},
        {type="item", name="gravel", amount=6.35106208819},
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
        {type="fluid", name="pressured-air", amount=1333.33333333},
        {type="item", name="guts", amount=15.0413702949},
        {type="item", name="nichrome", amount=1},
      },
      results = {
        {type="fluid", name="glycerol", amount=150},
        {type="fluid", name="oleochemicals", amount=300},
        {type="fluid", name="steam", amount=2000},
      },
    },
    ["petgas-methanol"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="olefin", amount=100},
        {type="fluid", name="organic-solvent", amount=100},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="syngas", amount=100},
        {type="item", name="native-flora", amount=10.9513644401},
      },
      results = {
        {type="fluid", name="refsyngas", amount=70},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=3000},
        {type="item", name="active-carbon", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=300},
      },
    },
    ["hydrogen-peroxide"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthraquinone", amount=100},
        {type="item", name="nickel-plate", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen-peroxide", amount=50},
      },
    },
    ["syngas2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coal-gas", amount=50},
        {type="fluid", name="pressured-water", amount=437.142857143},
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
        {type="fluid", name="refsyngas", amount=100},
        {type="item", name="copper-cable", amount=8.97194336087},
      },
      results = {
        {type="fluid", name="acidgas", amount=150},
      },
    },
    ["acidgas-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2000},
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="water", amount=600},
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
        {type="fluid", name="oxygen", amount=215.774509804},
        {type="fluid", name="pressured-water", amount=277.199027166},
        {type="item", name="wood-seedling", amount=3},
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
        {type="fluid", name="water", amount=2751.125},
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
        {type="item", name="ground-sample01", amount=5},
        {type="item", name="moss", amount=5},
        {type="item", name="wood-seeds-mk02", amount=1},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tailings", amount=200},
        {type="item", name="bio-sample", amount=7.3110983767},
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
        {type="fluid", name="vacuum", amount=533.333333333},
        {type="item", name="alien-sample01", amount=4},
        {type="item", name="battery-mk01", amount=4.44664792035},
        {type="item", name="earth-horse-sample", amount=1},
        {type="item", name="iron-ore-dust", amount=436.100012484},
        {type="item", name="ulric-codex", amount=1},
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
        {type="item", name="duralumin", amount=4.26478156626},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=10},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="titanium-plate", amount=20},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
    },
    ["ulric-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="ash", amount=10},
        {type="item", name="fawogae", amount=5},
        {type="item", name="graphite", amount=1.33712032649},
        {type="item", name="native-flora", amount=10},
        {type="item", name="ralesia", amount=5},
        {type="item", name="wood-seeds", amount=10},
      },
      results = {
        {type="item", name="ulric-food-01", amount=6},
      },
    },
    ["caged-ulric"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bio-container", amount=2.98251470951},
        {type="item", name="ulric", amount=1},
      },
      results = {
        {type="item", name="caged-ulric", amount=1},
      },
    },
    ["ulric-cub-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="fawogae", amount=3},
        {type="item", name="ulric-food-01", amount=2},
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
      ingredients = {
        {type="item", name="fawogae-spore", amount=6.06453242701},
        {type="item", name="ulric-food-01", amount=1},
        {type="item", name="water-barrel", amount=5},
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
        {type="item", name="fungal-substrate-02", amount=1.71468641057},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="stone", amount=81.406806118},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="ulric", amount=3},
      },
    },
    ["uncaged-ulric"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="caged-ulric", amount=1},
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
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="moondrop-codex", amount=1.36132758514},
        {type="item", name="wood-seeds-mk02", amount=8.83794558273},
      },
      results = {
        {type="item", name="earth-cow-sample", amount=1},
      },
    },
    ["earth-crustacean-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="boiler", amount=106.917094833},
        {type="item", name="earth-generic-sample", amount=1},
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
        {type="item", name="fts-reactor", amount=0.54794192274},
        {type="item", name="logistic-science-pack", amount=27.5654545937},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=100},
        {type="item", name="cottongut-codex", amount=0.536144838542},
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
        {type="item", name="logistic-science-pack", amount=55.1309091874},
        {type="item", name="shaft-mk01", amount=5.89548342486},
        {type="item", name="yaedols-codex", amount=1.24974491369},
      },
      results = {
        {type="item", name="earth-bee-sample", amount=1},
      },
    },
    ["earth-horse-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=15},
        {type="item", name="py-storehouse-basic", amount=4.01768860039},
        {type="item", name="sea-sponge-codex", amount=1.21845641848},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=1},
      },
    },
    ["kicalk-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=256.41025641},
        {type="item", name="alien-sample01", amount=4},
        {type="item", name="blood-barrel", amount=104.390996836},
        {type="item", name="chromium", amount=99.7645113104},
        {type="item", name="earth-bear-sample", amount=0.652309355835},
        {type="item", name="korlex-codex", amount=4.63785558324},
        {type="item", name="planter-box", amount=1},
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
        {type="item", name="fungal-substrate-02", amount=4.45378920019},
        {type="item", name="pipe", amount=2.11769473319},
      },
      results = {
        {type="item", name="kicalk", amount=10},
      },
    },
    ["kicalk-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=309.215680122},
        {type="item", name="clay", amount=4},
        {type="item", name="kicalk-seeds", amount=15},
        {type="item", name="sand", amount=10},
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
        {type="fluid", name="carbon-dioxide", amount=618.431360245},
        {type="item", name="arqad-codex", amount=4.10355259667},
        {type="item", name="earth-sea-sponge-sample", amount=1},
        {type="item", name="primers", amount=6.3127749552},
        {type="item", name="steel-plate", amount=79.2676958488},
        {type="item", name="underground-belt", amount=4.38609242469},
      },
      results = {
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
    },
    ["sea-sponge-processing-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="sea-sponge", amount=1},
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
        {type="fluid", name="syngas", amount=305.03678786},
        {type="fluid", name="water", amount=100},
        {type="item", name="iron-gear-wheel", amount=0.518532022286},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=1185.62952426},
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
        {type="fluid", name="light-oil", amount=200},
        {type="fluid", name="methanal", amount=365.327850028},
        {type="fluid", name="steam", amount=106.25},
        {type="item", name="chromium", amount=4.4709147434},
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
        {type="fluid", name="oxygen", amount=200},
        {type="item", name="nexelit-plate", amount=2},
      },
      results = {
        {type="fluid", name="olefin", amount=200},
      },
    },
    ["sea-sponge-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=100},
        {type="fluid", name="zogna-bacteria", amount=40},
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
        {type="item", name="ceramic", amount=14.1043162973},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="pure-sand", amount=109.582450252},
        {type="item", name="soil-extractor-mk01", amount=0.878946935068},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="stone-brick", amount=70.7689222499},
        {type="item", name="storage-tank", amount=1.30209762432},
      },
      results = {
        {type="item", name="agitator-mk01", amount=1},
      },
    },
    ["centrifugal-pan-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=25},
        {type="item", name="glass", amount=14.9511319273},
        {type="item", name="nexelit-plate", amount=54.5990399655},
        {type="item", name="niobium-pipe", amount=40},
        {type="item", name="oil-derrick-mk01", amount=2.10062468091},
        {type="item", name="py-tank-6500", amount=1.53950081159},
        {type="item", name="retrovirus", amount=16.7279568029},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="tailings-pond", amount=1},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=1},
      },
    },
    ["compressor-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chromium", amount=24.3117346026},
        {type="item", name="duralumin", amount=6.59654451598},
        {type="item", name="fiberboard", amount=82.6442501481},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="lead-plate", amount=46.7331312313},
        {type="item", name="saps-mk02", amount=19.6039979994},
        {type="item", name="steam-engine", amount=3},
      },
      results = {
        {type="item", name="compressor-mk01", amount=1},
      },
    },
    ["gas-separator-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="bolts", amount=88.2087715288},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="evaporator", amount=1},
        {type="item", name="fenxsb-alloy", amount=43.1811573018},
        {type="item", name="nichrome", amount=30},
        {type="item", name="small-parts-01", amount=50},
        {type="item", name="solid-separator", amount=3.46216550187},
        {type="item", name="steel-plate", amount=50},
      },
      results = {
        {type="item", name="gas-separator-mk01", amount=1},
      },
    },
    ["hydrocyclone-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="boiler", amount=7.98382091299},
        {type="item", name="concrete", amount=50.3780392056},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=30},
        {type="item", name="steel-plate", amount=30},
        {type="item", name="ulric-cub", amount=12.215099739},
      },
      results = {
        {type="item", name="hydrocyclone-mk01", amount=1},
      },
    },
    ["thickener-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="concrete", amount=83.9633986761},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="small-electric-pole", amount=4.90723965144},
        {type="item", name="small-lamp", amount=4},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="steel-plate", amount=50},
      },
      results = {
        {type="item", name="thickener-mk01", amount=1},
      },
    },
    ["casein"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="creosote", amount=365.700536009},
      },
      results = {
        {type="item", name="casein", amount=5},
      },
    },
    ["green-sic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="graphite", amount=3},
        {type="item", name="powdered-quartz", amount=8},
        {type="item", name="pure-sand", amount=12.3796763492},
      },
      results = {
        {type="item", name="green-sic", amount=4},
      },
    },
    ["mixed-ores"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="grade-3-chromite", amount=0.602107375815},
        {type="item", name="iron-ore", amount=12.4464078575},
        {type="item", name="rare-earth-ore", amount=4},
      },
      results = {
        {type="item", name="mixed-ores", amount=5},
        {type="item", name="stone", amount=0.5},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="acidgas", amount=100},
        {type="fluid", name="steam", amount=130},
        {type="item", name="reo", amount=3},
        {type="item", name="sugar", amount=11.2964255598},
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
        {type="item", name="reo", amount=5},
        {type="item", name="sand-casting", amount=14.4071043357},
      },
      results = {
        {type="item", name="quartz-tube", amount=3},
      },
    },
    ["sic"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="green-sic", amount=3},
      },
      results = {
        {type="item", name="sic", amount=4},
      },
    },
    ["artificial-blood"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="purified-syngas", amount=1383.69902071},
        {type="item", name="sea-sponge-sprouts", amount=16.2602583338},
      },
      results = {
        {type="fluid", name="artificial-blood", amount=100},
      },
    },
    ["decalin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="hydrogen", amount=200},
        {type="item", name="clay", amount=8.86609090909},
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
        {type="fluid", name="oxygen", amount=341.677392935},
        {type="item", name="dried-biomass", amount=30},
        {type="item", name="quartz-tube", amount=1},
        {type="item", name="sic", amount=2},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="moondrop-seeds", amount=7},
        {type="item", name="soil", amount=20},
      },
      results = {
        {type="item", name="moondrop", amount=8},
      },
    },
    ["moondrop-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=300},
        {type="fluid", name="water", amount=1000},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="decalin", amount=50},
        {type="fluid", name="hydrogen", amount=400},
        {type="item", name="ash", amount=10},
        {type="item", name="crushed-coal", amount=47.948439648},
        {type="item", name="solder", amount=2.12925778546},
      },
      results = {
        {type="item", name="moondrop-mk02", amount=5},
      },
    },
    ["oleochemicals-bioplastic"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="methanol", amount=50},
        {type="fluid", name="muddy-sludge", amount=7833.5763506},
      },
      results = {
        {type="item", name="plastic-bar", amount=10},
      },
    },
    ["plastic-from-casein"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=100},
        {type="fluid", name="methanal", amount=100},
        {type="item", name="korlex-food-01", amount=1.44820371285},
      },
      results = {
        {type="item", name="plastic-bar", amount=20},
      },
    },
    ["plastic-from-melamine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chromium", amount=5.48564293049},
      },
      results = {
        {type="item", name="plastic-bar", amount=5},
      },
    },
    ["zipir1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="lubricant", amount=1888.02628151},
        {type="fluid", name="sulfuric-acid", amount=2304.1262107},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="cdna", amount=5},
        {type="item", name="display-panel", amount=5.55016579911},
        {type="item", name="fish", amount=10},
        {type="item", name="korlex-codex", amount=6.04588286291},
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
        {type="fluid", name="bee-venom", amount=50},
        {type="fluid", name="slacked-lime", amount=265.69026988},
        {type="fluid", name="subcritical-water", amount=1075.95917029},
        {type="item", name="alien-sample01", amount=1},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="micro-fiber", amount=5},
        {type="item", name="petri-dish", amount=0.939321074988},
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="primers", amount=1},
        {type="item", name="urea", amount=53.9806749386},
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
        {type="item", name="plastic-bar", amount=10},
        {type="item", name="sea-sponge", amount=1},
        {type="item", name="shaft-mk01", amount=6.33869477455},
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
        {type="item", name="bio-sample", amount=2.00041089822},
        {type="item", name="cocoon", amount=10},
        {type="item", name="empty-petri-dish", amount=12.2266943142},
        {type="item", name="petri-dish", amount=0.939321074988},
      },
      results = {
        {type="item", name="dna-polymerase", amount=1},
      },
    },
    ["manure-bacteria"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="clay", amount=30.0759152901},
        {type="item", name="dried-meat", amount=1.21163404558},
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
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="small-electric-pole", amount=4.9007894991},
        {type="item", name="stopper", amount=48.1042186872},
        {type="item", name="zinc-plate", amount=3.23380477746},
      },
      results = {
        {type="item", name="primers", amount=0.7},
      },
    },
    ["retrovirus-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=20},
        {type="item", name="cocoon", amount=4},
        {type="item", name="empty-petri-dish", amount=1.10964222991},
        {type="item", name="petri-dish-bacteria", amount=3.82522659786},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="stopper", amount=3.55574152338},
      },
      results = {
        {type="item", name="retrovirus", amount=3},
      },
    },
    ["cottongut-science-green-seeds"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=50},
        {type="fluid", name="pressured-water", amount=560},
        {type="item", name="cottongut", amount=40},
        {type="item", name="petri-dish-bacteria", amount=1.04148337961},
        {type="item", name="pipe", amount=27.9308381819},
        {type="item", name="plasmids", amount=6.6092229449},
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
        {type="fluid", name="manure-bacteria", amount=50},
        {type="fluid", name="pressured-water", amount=571.428571429},
        {type="item", name="agar", amount=2.02994523151},
      },
      results = {
        {type="fluid", name="gasoline", amount=100},
      },
    },
    ["tuuphra-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="burner-mining-drill", amount=22.7933114374},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-mouse-sample", amount=1.49690668826},
        {type="item", name="pipe", amount=8.18502152048},
        {type="item", name="py-tank-5000", amount=4.07095251692},
        {type="item", name="sb-oxide", amount=6.22816953662},
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
        {type="fluid", name="coal-gas", amount=322.480169533},
        {type="fluid", name="water", amount=100},
        {type="item", name="coal-gas-canister", amount=0.579630759789},
        {type="item", name="coarse", amount=10},
        {type="item", name="tuuphra-seeds", amount=5},
      },
      results = {
        {type="item", name="tuuphra", amount=3},
      },
    },
    ["sweet-syrup"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="a-molasse", amount=100},
        {type="item", name="lime", amount=5},
      },
      results = {
        {type="fluid", name="sweet-syrup", amount=50},
      },
    },
    ["a-molasse"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="tuuphra", amount=10},
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
        {type="item", name="petri-dish", amount=19.407195294},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="tinned-cable", amount=10},
        {type="item", name="transport-belt", amount=1.72934428761},
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
        {type="fluid", name="steam", amount=100},
        {type="item", name="bones", amount=4.68162421389},
        {type="item", name="carbon-black", amount=0.564050090744},
        {type="item", name="fawogae", amount=10},
        {type="item", name="fish", amount=5},
        {type="item", name="kicalk-seeds", amount=10},
        {type="item", name="salt", amount=10},
        {type="item", name="seaweed", amount=10},
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
        {type="fluid", name="fetal-serum", amount=100},
        {type="fluid", name="hydrofluoric-acid", amount=1093.67021014},
        {type="item", name="alien-sample01", amount=5},
        {type="item", name="cdna", amount=5},
        {type="item", name="cooling-tower-mk01", amount=5.72418478807},
        {type="item", name="fish", amount=5},
        {type="item", name="korlex-codex", amount=1},
        {type="item", name="nichrome", amount=28.5495445435},
      },
      results = {
        {type="item", name="korlex", amount=1},
      },
    },
    ["korlex-milk-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="fish", amount=5},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="methane-canister", amount=7.533064675},
        {type="item", name="molten-solder-barrel", amount=1.04534893281},
        {type="item", name="saps", amount=2.34243617811},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="phytoplankton-barrel", amount=14.2654375596},
        {type="item", name="tuuphra-seeds", amount=10},
        {type="item", name="water-barrel", amount=20},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=3},
      },
    },
    ["full-render-kor"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="caged-korlex", amount=1},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="kicalk", amount=1},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=50},
        {type="fluid", name="outlet-gas-01", amount=100},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=100},
        {type="item", name="sulfur", amount=20},
      },
    },
    ["quench-redcoke"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-air", amount=150},
        {type="fluid", name="water", amount=200},
        {type="item", name="redhot-coke", amount=6},
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=371.058816147},
        {type="item", name="fawogae-substrate", amount=2.59022458361},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=50},
        {type="item", name="redhot-coke", amount=5},
      },
    },
    ["outlet-gas-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="fluid", name="tar", amount=50},
        {type="item", name="cellulose", amount=0.828607142005},
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
        {type="fluid", name="bitumen", amount=1193.80763821},
        {type="item", name="sodium-hydroxide", amount=3.52823563932},
      },
      results = {
        {type="item", name="molybdenum-sulfide", amount=10},
      },
    },
    ["calcinate-bone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chitin", amount=0.787377772418},
      },
      results = {
        {type="item", name="calcinates", amount=3},
      },
    },
    ["molybdenum-concentrate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=455.569857247},
        {type="fluid", name="tar", amount=526.829268293},
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
        {type="fluid", name="hot-air", amount=326.923076923},
        {type="item", name="molybdenum-sulfide", amount=10},
      },
      results = {
        {type="item", name="molybdenum-oxide", amount=10},
        {type="item", name="sulfur", amount=1},
      },
    },
    ["calcinate-separation"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="calcinates", amount=20},
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
        {type="item", name="lead-plate", amount=40.7852160852},
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
        {type="item", name="guts", amount=4.65492010197},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-3"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="ash", amount=20},
        {type="item", name="biomass", amount=20},
        {type="item", name="seaweed", amount=10},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="fertilizer", amount=10},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
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
      ingredients = {
        {type="fluid", name="hot-air", amount=1015.74382043},
        {type="fluid", name="muddy-sludge", amount=958.18981951},
        {type="fluid", name="water", amount=100},
      },
      results = {
        {type="fluid", name="formic-acid", amount=100},
      },
    },
    ["sap-seeds-mk02-gen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="moss", amount=5},
        {type="item", name="sap-tree", amount=5},
        {type="item", name="sodium-alginate", amount=1},
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
        {type="item", name="ralesia", amount=19.1572418254},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=2},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="bonemeal", amount=10},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=10},
        {type="fluid", name="water", amount=100},
        {type="item", name="fish", amount=10},
        {type="item", name="sodium-hydroxide", amount=4},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=524.57963307},
        {type="fluid", name="methane", amount=659.81255189},
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
        {type="item", name="plastic-bar", amount=23.0276623491},
        {type="item", name="pressured-air-barrel", amount=0.794136475313},
      },
      results = {
        {type="item", name="wax-barrel", amount=1},
      },
    },
    ["phosphate-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=40},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="washer", amount=1.65468490293},
        {type="item", name="wpu-mk01", amount=1.64131774372},
      },
      results = {
        {type="item", name="phosphate-mine", amount=1},
      },
    },
    ["rare-earth-mine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="battery-mk01", amount=5.47645607264},
        {type="item", name="engine-unit", amount=10},
        {type="item", name="fast-inserter", amount=4},
        {type="item", name="inductor1", amount=148.447261081},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="pipe", amount=105.708275797},
        {type="item", name="washer", amount=1.11341318866},
      },
      results = {
        {type="item", name="rare-earth-mine", amount=1},
      },
    },
    ["subcritical-water-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=200},
        {type="fluid", name="water", amount=1170},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=200},
      },
    },
    ["wax"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hot-air", amount=25},
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
        {type="fluid", name="vacuum", amount=52},
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
        {type="fluid", name="aromatics", amount=658.761625166},
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
        {type="item", name="pipe", amount=10.5708275797},
        {type="item", name="pitch-barrel", amount=2.22662932138},
        {type="item", name="tinned-cable", amount=19},
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
        {type="item", name="biomass", amount=10},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=10},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="native-flora", amount=35.0315277212},
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
        {type="fluid", name="oxygen", amount=426.166661849},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fish", amount=12},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="small-parts-01", amount=3.64637989831},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=30},
      },
    },
    ["fish-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=2688.80409331},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish", amount=20},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="tinned-cable", amount=3.69947767868},
      },
      results = {
        {type="item", name="fish", amount=5},
        {type="item", name="fish-mk02", amount=0.005},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="water-saline", amount=100},
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
        {type="fluid", name="ammonia", amount=185.897082728},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="aluminium-plate", amount=20.4246758312},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish-egg-mk02", amount=10},
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
        {type="item", name="explosives", amount=10},
        {type="item", name="fawogae-substrate", amount=4.05272668816},
      },
      results = {
        {type="item", name="cliff-explosives", amount=1},
      },
    },
    ["fast-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="burner-inserter", amount=8.02283685862},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="inductor1", amount=0.958245678275},
        {type="item", name="nbfe-alloy", amount=3},
        {type="item", name="offshore-pump", amount=2.48313073307},
        {type="item", name="vitreloy", amount=1},
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
        {type="item", name="cobalt-fluoride", amount=9.36036651261},
        {type="item", name="niobium-dust", amount=40.9666485333},
        {type="item", name="small-parts-01", amount=53.4515553878},
        {type="item", name="steam-engine", amount=5.64343155293},
      },
      results = {
        {type="item", name="py-stack-inserter", amount=1},
      },
    },
    ["flavonoids"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="seaweed", amount=20},
        {type="item", name="yaedols", amount=4},
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
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nbfe-alloy", amount=30},
        {type="item", name="steel-plate", amount=100},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-plate", amount=1},
        {type="item", name="sb-oxide", amount=2.61939586869},
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
        {type="item", name="dried-meat", amount=51.4003612467},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lab", amount=2.27301747247},
        {type="item", name="nichrome", amount=2},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="py-shed-basic", amount=3.01180772452},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="solder", amount=5},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=1},
      },
    },
    ["yaedols-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=80},
        {type="item", name="aluminium-plate", amount=3.22878385056},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="fungal-substrate", amount=2},
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
        {type="fluid", name="carbon-dioxide", amount=618.431360245},
        {type="item", name="alien-sample01", amount=5},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-shroom-sample", amount=1},
        {type="item", name="fawogae-spore", amount=20},
        {type="item", name="korlex-codex", amount=4.52174267046},
        {type="item", name="primers", amount=0.720793816235},
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
        {type="fluid", name="aromatics", amount=266.874883568},
        {type="item", name="vanadium-oxide", amount=2},
      },
      results = {
        {type="fluid", name="anthraquinone", amount=100},
      },
    },
    ["aromatics-from-naphthalene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="boric-acid", amount=604.030669124},
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
        {type="fluid", name="hydrogen", amount=578.620269886},
        {type="fluid", name="vacuum", amount=106.666666667},
        {type="item", name="iron-stick", amount=1.81157505322},
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
        {type="fluid", name="carbolic-oil", amount=20},
        {type="fluid", name="pitch", amount=362.868152255},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=30},
      },
    },
    ["natural-gas-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=50},
        {type="item", name="piercing-rounds-magazine", amount=0.685424789035},
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
        {type="item", name="tin-plate", amount=3.78170324336},
      },
      results = {
        {type="fluid", name="crude-oil", amount=40},
      },
    },
    ["rubber-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=50},
        {type="fluid", name="polybutadiene", amount=50},
        {type="item", name="carbon-black", amount=2},
        {type="item", name="duralumin", amount=8.68185891871},
      },
      results = {
        {type="item", name="rubber", amount=4},
      },
    },
    ["rubber-from-oleochemicals"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="benzene", amount=1279.23720498},
        {type="fluid", name="polybutadiene", amount=20},
        {type="item", name="burner-inserter", amount=4.99056982874},
        {type="item", name="sulfur", amount=2},
        {type="item", name="tall-oil-canister", amount=6.52558948944},
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
        {type="fluid", name="steam", amount=1034.45000973},
        {type="item", name="moss", amount=3.66274674191},
        {type="item", name="pressured-air-barrel", amount=1.06128990948},
      },
      results = {
        {type="item", name="ticl4", amount=4},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=904.834111962},
        {type="fluid", name="hot-air", amount=100},
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
        {type="fluid", name="aromatics", amount=204.268933481},
        {type="fluid", name="hot-air", amount=100},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="sncr-alloy", amount=2.02807394297},
      },
      results = {
        {type="fluid", name="methanol", amount=300},
      },
    },
    ["naphtha-to-syngas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oxygen", amount=188.235294118},
        {type="fluid", name="pitch", amount=351.286187609},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="carbon-black", amount=1.35779471555},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=100},
        {type="item", name="warmer-stone-brick", amount=5},
      },
    },
    ["warmer-air-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="pressured-air", amount=150},
        {type="item", name="warmer-stone-brick", amount=20},
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
        {type="fluid", name="naphtha", amount=100},
        {type="fluid", name="oxygen", amount=1123.55658714},
        {type="item", name="bolts", amount=8.85700835011},
      },
      results = {
        {type="fluid", name="diesel", amount=350},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="hydrogen", amount=300},
        {type="item", name="boron-trioxide", amount=0.627330251292},
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
        {type="fluid", name="pitch", amount=422.082697367},
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
        {type="fluid", name="medium-distillate", amount=100},
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
        {type="fluid", name="pitch", amount=515.428323758},
        {type="item", name="sncr-alloy", amount=1.01403697148},
      },
      results = {
        {type="fluid", name="stripped-distillate", amount=100},
      },
    },
    ["low-distillate-to-coal-gas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="aromatics", amount=310.424792079},
        {type="item", name="carbon-black", amount=0.81069450321},
      },
      results = {
        {type="fluid", name="coal-gas", amount=200},
      },
    },
    ["stripped-distillate-to-benzene"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="methanal", amount=620.605095138},
        {type="item", name="sand-casting", amount=1.80760247666},
      },
      results = {
        {type="fluid", name="benzene", amount=150},
      },
    },
    ["stripped-distillate-to-cumene"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="stripped-distillate", amount=100},
        {type="item", name="ticl4", amount=1},
      },
      results = {
        {type="fluid", name="cumene", amount=200},
      },
    },
    ["stripped-distillate-to-gasoline"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coal-gas", amount=497.315970204},
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
        {type="fluid", name="fluorine-gas", amount=100},
        {type="fluid", name="syngas", amount=185.990999438},
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
        {type="fluid", name="flue-gas", amount=387.578119303},
        {type="fluid", name="high-distillate", amount=200},
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
        {type="fluid", name="fish-oil", amount=243.853895613},
        {type="fluid", name="gasoline", amount=50},
      },
      results = {
        {type="fluid", name="condensates", amount=100},
        {type="fluid", name="naphtha", amount=50},
        {type="fluid", name="natural-gas", amount=250},
      },
    },
    ["refined-natural-gas-to-condensates"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="refined-natural-gas", amount=150},
        {type="fluid", name="water", amount=200},
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
      ingredients = {
        {type="fluid", name="slacked-lime", amount=395.241394866},
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
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="tar", amount=433.848068722},
        {type="fluid", name="water", amount=600},
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
      ingredients = {
        {type="fluid", name="pitch", amount=351.286187609},
      },
      results = {
        {type="fluid", name="tall-oil", amount=100},
      },
    },
    ["bitumen-comb"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="empty-comb", amount=2.30137552445},
      },
      results = {
        {type="fluid", name="bitumen", amount=50},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["raw-gas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1070.47231852},
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
      ingredients = {
        {type="fluid", name="methane", amount=849.489454953},
        {type="fluid", name="water", amount=600},
        {type="item", name="ash", amount=10},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=100},
      },
    },
    ["bio-oil-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="ammonia", amount=273.43216803},
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
        {type="fluid", name="boric-acid", amount=1165.60118555},
        {type="fluid", name="steam", amount=400},
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
        {type="fluid", name="diborane", amount=897.455625483},
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
        {type="fluid", name="hot-air", amount=1131.02277486},
        {type="item", name="coal-dust", amount=11.7504496208},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=100},
      },
    },
    ["oil-refining"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="coal-gas", amount=568.550511606},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="residual-mixture", amount=200},
        {type="fluid", name="vacuum", amount=200},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="borax", amount=2.02441075472},
        {type="item", name="copper-low-dust", amount=1.69595162399},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=60},
      },
    },
    ["arqad-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="limestone", amount=47.8580703707},
        {type="item", name="nickel-plate", amount=1.6922883483},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="arqad-codex", amount=1},
      },
    },
    ["arqad-egg-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-egg-nest", amount=1.3346742139},
        {type="item", name="arqad-honey-barrel", amount=3},
        {type="item", name="arqad-queen", amount=1},
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
        {type="item", name="empty-comb", amount=5},
        {type="item", name="gasoline-canister", amount=3.15559771656},
        {type="item", name="native-flora", amount=10},
        {type="item", name="transport-belt", amount=9.10482755698},
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
        {type="item", name="arqad-codex", amount=1},
        {type="item", name="bio-sample", amount=5},
        {type="item", name="earth-bee-sample", amount=1},
        {type="item", name="earth-generic-sample", amount=2.87926814112},
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
        {type="item", name="acetylene-barrel", amount=13.3135570148},
        {type="item", name="arqad", amount=7},
        {type="item", name="arqad-honey-barrel", amount=3},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="fawogae", amount=6.03265376775},
        {type="item", name="ralesia", amount=15},
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
        {type="item", name="gasifier", amount=1},
        {type="item", name="pipe", amount=20},
        {type="item", name="py-tank-4000", amount=4.11469154483},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="tailings-dust", amount=96.7296361853},
        {type="item", name="ticl4", amount=11.7682140858},
        {type="item", name="tin-plate", amount=62.9778648293},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=1},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad-egg", amount=6.81813406207},
        {type="item", name="empty-comb", amount=1},
        {type="item", name="pitch-canister", amount=1.42136435344},
        {type="item", name="vrauks", amount=1},
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
      ingredients = {
        {type="item", name="caged-vrauks", amount=10},
        {type="item", name="empty-honeycomb", amount=243.153838847},
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
        {type="item", name="arqad-egg", amount=8.84147760302},
        {type="item", name="cumene-barrel", amount=2.86173223328},
        {type="item", name="phosphoric-acid-barrel", amount=2.15978406563},
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
        {type="item", name="arqad-honey-barrel", amount=7.04838205351},
        {type="item", name="arqad-maggot", amount=12.9675913124},
        {type="item", name="biomass", amount=15},
        {type="item", name="pyrite", amount=1.50436293007},
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
        {type="item", name="arqad-egg-nest", amount=1},
        {type="item", name="arqad-honey-barrel", amount=7.04838205351},
        {type="item", name="biomass", amount=15},
        {type="item", name="ralesia", amount=5},
      },
      results = {
        {type="item", name="arqad", amount=3},
        {type="item", name="barrel", amount=10},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["full-render-arqads"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="arqad", amount=3},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="ammonia", amount=418.285638894},
        {type="fluid", name="hot-air", amount=50},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=2281.21036864},
        {type="fluid", name="pressured-water", amount=364.285714286},
        {type="fluid", name="water", amount=900},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=593.649711143},
        {type="fluid", name="carbon-dioxide", amount=989.490176392},
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
        {type="fluid", name="hot-air", amount=76.9230769231},
        {type="fluid", name="vacuum", amount=560},
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
        {type="fluid", name="pressured-air", amount=200},
        {type="fluid", name="subcritical-water", amount=780.612244898},
        {type="item", name="kerogen", amount=9},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=100},
        {type="fluid", name="tailings", amount=100},
      },
    },
    ["btx-to-benzene"] = {
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="fluid", name="btx", amount=100},
        {type="fluid", name="steam", amount=200},
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
        {type="fluid", name="steam", amount=450},
        {type="item", name="lime", amount=1.36204117672},
      },
      results = {
        {type="fluid", name="methane", amount=300},
      },
    },
    ["aromatics-to-petgas"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=100},
        {type="fluid", name="water-saline", amount=197.310901814},
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
        {type="fluid", name="aromatics", amount=414.796344037},
        {type="fluid", name="glycerol", amount=100},
      },
      results = {
        {type="item", name="explosives", amount=5},
      },
    },
    ["filtration-media"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="chromium", amount=9.56994840589},
        {type="item", name="lead-plate", amount=12.5559852157},
        {type="item", name="micro-fiber", amount=2},
        {type="item", name="pure-sand", amount=30},
        {type="item", name="tin-plate", amount=7.55734377951},
      },
      results = {
        {type="item", name="filtration-media", amount=5},
      },
    },
    ["niobium-dust"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="niobium-ore", amount=11.2467030674},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="niobium-dust", amount=10},
      },
    },
    ["stone-distilation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="water", amount=200},
        {type="item", name="coal-dust", amount=42.850112353},
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
        {type="fluid", name="oxygen", amount=156.862745098},
        {type="fluid", name="sulfuric-acid", amount=200},
        {type="item", name="rare-earth-powder", amount=22.5225225225},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="tar", amount=269.343629743},
        {type="item", name="rare-earth-powder", amount=6.75675675676},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=100},
        {type="item", name="zinc-plate", amount=5},
      },
    },
    ["ree-slurry"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="rare-earth-mud", amount=100},
        {type="fluid", name="water-saline", amount=1091.25120948},
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
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="item", name="rare-earth-dust", amount=12.2841758388},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="electronic-circuit", amount=25},
        {type="item", name="glass", amount=2},
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
        {type="fluid", name="olefin", amount=669.221116621},
        {type="fluid", name="pressured-water", amount=1000},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="saps", amount=6},
        {type="item", name="tailings-dust", amount=7.05426001914},
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
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="lead-plate", amount=103.768157092},
        {type="item", name="plastic-bar", amount=8.74655136117},
        {type="item", name="requester-chest", amount=2.95915147476},
        {type="item", name="small-electric-pole", amount=23.0549263323},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="tin-plate", amount=94.5425810839},
        {type="item", name="ulric-corral-mk01", amount=2.59234667696},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk01", amount=1},
      },
    },
    ["xyhiphoe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=749.411914633},
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="cocoon", amount=5},
        {type="item", name="earth-crustacean-sample", amount=1},
        {type="item", name="primers", amount=6.3127749552},
        {type="item", name="requester-chest", amount=3.05473704075},
        {type="item", name="treated-wood", amount=8.45473987606},
        {type="item", name="xyhiphoe-codex", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["xyhiphoe-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=823.529411765},
        {type="fluid", name="muddy-sludge", amount=987.52781836},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="iron-plate", amount=5.02204726198},
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
      mode = "input-preserved-unmodified",
      science_level = 3,
      ingredients = {
        {type="item", name="iron-plate", amount=15},
        {type="item", name="niobium-plate", amount=4},
      },
      results = {
        {type="item", name="nbfe-alloy", amount=2},
      },
    },
    ["niobium-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=569.462321558},
        {type="fluid", name="niobium-complex", amount=50},
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
        {type="item", name="niobium-powder", amount=9.06763354167},
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
        {type="item", name="belt", amount=0.834463575953},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="shotgun-shell", amount=9.46392471203},
      },
      results = {
        {type="item", name="defender-capsule", amount=1},
      },
    },
    ["flamethrower"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="item", name="pipe", amount=29.8667232123},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="flamethrower", amount=1},
      },
    },
    ["rocket-launcher"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="item", name="grade-3-chromite", amount=24.8921302153},
        {type="item", name="iron-plate", amount=5},
        {type="item", name="small-parts-01", amount=5},
      },
      results = {
        {type="item", name="rocket-launcher", amount=1},
      },
    },
    ["flamethrower-ammo"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="fluid", name="boric-acid", amount=594.025075036},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="flamethrower-ammo", amount=1},
      },
    },
    ["rocket"] = {
      mode = "input-preserved-unmodified",
      science_level = 4,
      ingredients = {
        {type="item", name="explosives", amount=1},
        {type="item", name="iron-plate", amount=2},
      },
      results = {
        {type="item", name="rocket", amount=1},
      },
    },
    ["flamethrower-turret"] = {
      mode = "softmax-semantic-substitution",
      science_level = 4,
      ingredients = {
        {type="item", name="engine-unit", amount=5},
        {type="item", name="lead-plate", amount=6.85997928641},
        {type="item", name="small-parts-01", amount=15},
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
        {type="fluid", name="sulfuric-acid", amount=1330.21766254},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="cdna", amount=1.16159690488},
        {type="item", name="lab-instrument", amount=1.93856860807},
        {type="item", name="moss", amount=400},
        {type="item", name="paragen", amount=1},
        {type="item", name="solidified-sarcorus", amount=2},
        {type="item", name="steel-chest", amount=28.1125601305},
        {type="item", name="zinc-plate", amount=24.3093492555},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="guts", amount=6},
      },
      results = {
        {type="item", name="copper-ore", amount=15},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bones", amount=1.875},
        {type="item", name="guts", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=730.111428731},
        {type="fluid", name="water", amount=600},
        {type="item", name="ceramic", amount=1.76475034781},
      },
      results = {
        {type="fluid", name="ethylene", amount=100},
      },
    },
    ["ceramic-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="clay", amount=10},
        {type="item", name="coke", amount=1},
        {type="item", name="salt", amount=5},
      },
      results = {
        {type="item", name="ceramic", amount=10},
      },
    },
    ["crude-cermet"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="molybdenum-ore", amount=3},
        {type="item", name="ore-nickel", amount=5},
        {type="item", name="wooden-chest", amount=2.54642308599},
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
        {type="item", name="iron-stick", amount=5.47428453633},
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
        {type="item", name="crude-cermet", amount=10.5832017482},
        {type="item", name="native-flora", amount=13.2936507937},
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
        {type="item", name="stone-brick", amount=9.0495220289},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="guts", amount=2.29049197012},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="glass", amount=2},
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
        {type="item", name="grade-1-ti", amount=377.958413493},
        {type="item", name="intermetallics", amount=10},
        {type="item", name="iron-plate", amount=150},
        {type="item", name="nexelit-plate", amount=77.4906241649},
        {type="item", name="small-parts-01", amount=89.5954937839},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="titanium-plate", amount=100},
        {type="item", name="treated-wood", amount=67.683709609},
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
        {type="fluid", name="hydrogen", amount=156.862745098},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="cocoon", amount=5},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="fish-hydrolysate-barrel", amount=2.96485530718},
        {type="item", name="gate", amount=38.8972521991},
        {type="item", name="nichrome", amount=7.2549746317},
        {type="item", name="pyphoon-bay", amount=1.36549777791},
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
        {type="item", name="crude-cermet", amount=4.95797556244},
        {type="item", name="outlet-gas-02-canister", amount=1.30407592292},
        {type="item", name="sea-sponge", amount=2},
        {type="item", name="steel-chest", amount=1.51974894111},
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
        {type="item", name="graphite", amount=23.0191000387},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="molten-glass", amount=100},
        {type="item", name="silver-plate", amount=3},
        {type="item", name="sulfur", amount=4},
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
        {type="item", name="bof-mk01", amount=24.9789956506},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="planter-box", amount=1},
        {type="item", name="tuuphra-codex", amount=1},
        {type="item", name="zinc-chloride", amount=13.9768754436},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="refined-concrete", amount=2},
        {type="item", name="zinc-chloride", amount=0.533406289017},
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
        {type="item", name="refined-hazard-concrete", amount=1.95136715869},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=3},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="refined-concrete", amount=2},
        {type="item", name="sand-casting", amount=2.45140655321},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bolts", amount=3.90997854013},
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
        {type="item", name="clay", amount=7.11297487026},
        {type="item", name="guar", amount=1},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=3},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="refined-concrete", amount=2},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="ralesia", amount=1},
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
        {type="item", name="duralumin", amount=50},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="plastic-bar", amount=104.224755655},
        {type="item", name="powdered-biomass", amount=1995.55782765},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="zinc-plate", amount=23.266468755},
      },
      results = {
        {type="item", name="ipod", amount=1},
      },
    },
    ["kicalk-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=285.714285714},
        {type="fluid", name="steam", amount=107.335503768},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=10},
        {type="item", name="chromium", amount=1.45755044232},
        {type="item", name="clay", amount=4},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="kicalk-seeds", amount=15},
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
        {type="fluid", name="vacuum", amount=343.473612059},
        {type="fluid", name="water", amount=1000},
        {type="item", name="clay", amount=10},
        {type="item", name="kicalk", amount=2},
        {type="item", name="kicalk-seeds", amount=10},
        {type="item", name="molten-lead-barrel", amount=0.716770359884},
      },
      results = {
        {type="item", name="kicalk", amount=0.5},
        {type="item", name="kicalk-mk02", amount=0.005},
        {type="item", name="kicalk-seeds-mk02", amount=0.02},
      },
    },
    ["kicalk-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="bio-oil", amount=851.687103066},
        {type="fluid", name="carbon-dioxide", amount=400},
        {type="item", name="kicalk-seeds-mk02", amount=5},
        {type="item", name="sand", amount=33.4234002592},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="kicalk-mk02", amount=5},
        {type="item", name="kicalk-seeds", amount=1.5},
        {type="item", name="kicalk-seeds-mk02", amount=0.5},
      },
    },
    ["meat-to-phosphate"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
        {type="fluid", name="fetal-serum", amount=100},
        {type="fluid", name="raw-gas", amount=1995.42191381},
        {type="item", name="alien-sample-02", amount=10},
        {type="item", name="bio-sample", amount=100},
        {type="item", name="cdna", amount=30},
        {type="item", name="earth-generic-sample", amount=10},
        {type="item", name="filtration-media", amount=0.899065317611},
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
        {type="item", name="iron-chest", amount=1},
        {type="item", name="py-iron-oxide", amount=45},
        {type="item", name="sodium-hydroxide", amount=41.9708954914},
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
        {type="item", name="purified-syngas-barrel", amount=1.28083518166},
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
        {type="item", name="melamine-resin", amount=2},
        {type="item", name="small-lamp", amount=1.05904529391},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="blood", amount=653.771807332},
        {type="fluid", name="sulfuric-acid", amount=164.55148452},
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
        {type="fluid", name="boric-acid", amount=394.733998336},
        {type="fluid", name="methane", amount=1510.23226516},
        {type="item", name="sea-sponge-sprouts-mk02", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="sea-sponge-mk02", amount=0.8},
      },
    },
    ["sea-sponge-sprouts-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sea-sponge", amount=5.78528329572},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=4},
      },
    },
    ["seaweed-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="hydrogen", amount=427.450980392},
        {type="fluid", name="slacked-lime", amount=50},
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
        {type="item", name="seaweed", amount=6.06758498423},
        {type="item", name="tuuphra-seeds", amount=10},
      },
      results = {
        {type="item", name="tuuphra", amount=8},
      },
    },
    ["tuuphra-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=214.671007537},
        {type="fluid", name="water", amount=1000},
        {type="item", name="coarse", amount=20},
        {type="item", name="manure", amount=15},
        {type="item", name="native-flora", amount=45.1388888889},
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
        {type="fluid", name="acetic-acid", amount=870.71749984},
        {type="fluid", name="formamide", amount=782.936036521},
        {type="item", name="biomass", amount=100},
        {type="item", name="borax", amount=87.4992715367},
        {type="item", name="fertilizer", amount=30},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="tuuphra-mk02", amount=6.5},
      },
    },
    ["xenogenic-from-bonemeal"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=100},
        {type="item", name="bonemeal", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=85},
      },
    },
    ["xenogenic-from-bones"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=212.5},
        {type="item", name="mukmoux-fat", amount=8.62697729699},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=45},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=340},
        {type="item", name="skin", amount=10},
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
        {type="item", name="brain", amount=7.49276319695},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=70},
      },
    },
    ["xenogenic-from-fat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=75},
        {type="item", name="skin", amount=2.25617405561},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=20},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=50},
        {type="item", name="guts", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=40},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=296.966044607},
        {type="item", name="meat", amount=17.1256667702},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=60},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=212.5},
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
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="vacuum", amount=293.453333333},
        {type="item", name="coarse", amount=5},
        {type="item", name="stone", amount=20},
      },
      results = {
        {type="item", name="moss", amount=24},
      },
    },
    ["moss-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="saps", amount=1.84214288974},
        {type="item", name="shotgun-shell", amount=3.64871800602},
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
        {type="fluid", name="liquid-manure", amount=50},
        {type="fluid", name="xenogenic-cells", amount=100},
        {type="item", name="cdna", amount=1},
        {type="item", name="gravel", amount=6.00662558816},
        {type="item", name="moss-gen", amount=3},
        {type="item", name="moss-mk02", amount=2},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="petroleum-gas", amount=8427.91286313},
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
        {type="fluid", name="methane", amount=398.03447496},
        {type="item", name="pure-sand", amount=106.810318407},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="benzene", amount=150},
        {type="fluid", name="hot-air", amount=97.619047619},
        {type="item", name="navens", amount=5},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="pyrite", amount=8.98677816999},
      },
      results = {
        {type="fluid", name="perylene", amount=50},
      },
    },
    ["geo-he-01"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=600},
        {type="fluid", name="pressured-water", amount=75},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["oil-molten-salt-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=4562.90543536},
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
        {type="item", name="sodium-hydroxide", amount=26.3674369888},
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
        {type="fluid", name="nitrogen", amount=1030.48256823},
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
        {type="item", name="chitin", amount=0.752784385515},
        {type="item", name="ground-sample01", amount=2.13654390152},
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
      ingredients = {
        {type="fluid", name="creosote", amount=1493.06650397},
        {type="fluid", name="vacuum", amount=70},
      },
      results = {
        {type="fluid", name="molten-salt", amount=100},
        {type="fluid", name="pressured-steam", amount=75},
      },
    },
    ["pure-trichlorosilane"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=3198.91965268},
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
        {type="item", name="grade-1-iron", amount=0.753665724934},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=70},
      },
    },
    ["carbon-sulfide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="propene", amount=30},
        {type="item", name="coal", amount=5},
        {type="item", name="nexelit-plate", amount=2.76846411763},
      },
      results = {
        {type="fluid", name="carbon-sulfide", amount=60},
      },
    },
    ["ech"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="glycerol", amount=30},
        {type="fluid", name="nitrogen", amount=467.177391356},
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
        {type="fluid", name="acetic-acid", amount=568.098554873},
        {type="fluid", name="hot-air", amount=497.745505873},
        {type="fluid", name="hydrogen-peroxide", amount=50},
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
        {type="item", name="raw-borax", amount=5.06175068017},
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
        {type="item", name="mukmoux-fat", amount=6.47023297274},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=30},
        {type="fluid", name="aromatics", amount=213.00899378},
        {type="fluid", name="benzene", amount=50},
      },
      results = {
        {type="fluid", name="nitrobenzene", amount=100},
      },
    },
    ["propene-to-acetone"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=556.380006139},
        {type="fluid", name="pressured-air", amount=100},
        {type="item", name="copper-plate", amount=2},
        {type="item", name="log", amount=0.888376680889},
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
        {type="item", name="lead-container", amount=1},
        {type="item", name="pu-242", amount=0.957795924597},
        {type="item", name="py-iron", amount=3.96015622635},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-2-u", amount=1},
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
        {type="fluid", name="sulfuric-acid", amount=50},
        {type="fluid", name="water", amount=900},
        {type="item", name="grade-2-u", amount=12.8965517241},
      },
      results = {
        {type="fluid", name="u-pulp-01", amount=100},
      },
    },
    ["grade-1-u-recrush"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-1-u", amount=1},
      },
      results = {
        {type="item", name="grade-2-u", amount=1},
        {type="item", name="gravel", amount=0.5},
      },
    },
    ["u-pulp-02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=300},
        {type="fluid", name="u-pulp-01", amount=150},
      },
      results = {
        {type="fluid", name="u-pulp-02", amount=100},
      },
    },
    ["u-pulp-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methanal", amount=366.972021986},
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
        {type="fluid", name="carbon-dioxide", amount=279.497453748},
        {type="fluid", name="u-pulp-03", amount=150},
        {type="item", name="iron-ore-dust", amount=3},
      },
      results = {
        {type="item", name="yellow-cake", amount=5},
      },
    },
    ["cladded-core"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aramid", amount=1},
        {type="item", name="cladding", amount=1},
        {type="item", name="splitter", amount=2.94612705948},
      },
      results = {
        {type="item", name="cladded-core", amount=1},
      },
    },
    ["cladding"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=60},
        {type="fluid", name="nitrobenzene", amount=50},
        {type="item", name="sodium-hydroxide", amount=9.40100776527},
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
        {type="item", name="boron-trioxide", amount=3.94591185368},
        {type="item", name="cellulose", amount=5},
        {type="item", name="melamine", amount=21.2615278216},
        {type="item", name="ticl4", amount=4.44561799267},
      },
      results = {
        {type="item", name="filtration-media", amount=3},
      },
    },
    ["iron-oxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methanal", amount=300.142116591},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="iron-oxide", amount=10},
      },
    },
    ["kevlar"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="scrude", amount=739.037255179},
        {type="fluid", name="tpa", amount=50},
        {type="item", name="aluminium-plate", amount=38.4637792501},
        {type="item", name="equipment-chassi", amount=3.16945032794},
      },
      results = {
        {type="item", name="kevlar", amount=5},
      },
    },
    ["kevlar-coating"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="copper-coating", amount=1},
        {type="item", name="small-lamp", amount=5.80765925181},
      },
      results = {
        {type="item", name="kevlar-coating", amount=1},
      },
    },
    ["lab-instrument-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="chromium", amount=8.75168681767},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="pipe", amount=14.9372768067},
        {type="item", name="small-lamp", amount=24.8089595998},
        {type="item", name="wood", amount=426.913549866},
        {type="item", name="zinc-chloride", amount=11.5487843094},
      },
      results = {
        {type="item", name="lab-instrument", amount=4},
      },
    },
    ["optical-fiber"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="formica", amount=24.5453812698},
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
        {type="fluid", name="steam", amount=66.6666666667},
        {type="item", name="empty-planter-box", amount=0.839225412443},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=50},
      },
    },
    ["ppd"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acidgas", amount=1901.90460675},
        {type="fluid", name="methane", amount=1181.12840035},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="nbfe-alloy", amount=1},
      },
      results = {
        {type="item", name="nbfe-coating", amount=1},
      },
    },
    ["py-sodium-hydroxide"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=299.347563107},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="item", name="limestone", amount=5},
        {type="item", name="sodium-hydroxide", amount=10},
      },
    },
    ["sodium-bisulfate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="nitrogen", amount=424.566532904},
        {type="item", name="salt", amount=10},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=30},
        {type="item", name="sodium-bisulfate", amount=1},
      },
    },
    ["starch-4"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar-seeds", amount=100},
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
        {type="fluid", name="fish-oil", amount=212.124910516},
        {type="fluid", name="sulfuric-acid", amount=100},
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="chromium", amount=4.13407968411},
        {type="item", name="latex-slab", amount=4.9565899607},
        {type="item", name="ore-quartz", amount=74.250949199},
      },
      results = {
        {type="item", name="aramid", amount=8},
      },
    },
    ["sodium-sulfate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ore-quartz", amount=5},
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
      ingredients = {
        {type="item", name="concrete-wall", amount=3.16631300631},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="resistor1", amount=2.76457766782},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="starch", amount=10},
      },
    },
    ["casein-melamine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methane", amount=355.557308074},
        {type="item", name="small-parts-01", amount=9.89527227104},
      },
      results = {
        {type="item", name="melamine", amount=10},
      },
    },
    ["fecr-alloy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="boron-trioxide", amount=0.874023544729},
        {type="item", name="chromium", amount=1},
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
        {type="item", name="vanadium-oxide", amount=2.42728293308},
      },
      results = {
        {type="item", name="phenol", amount=6},
      },
    },
    ["silicon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="copper-cable", amount=11.812606877},
        {type="item", name="ore-titanium", amount=15.892746139},
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
        {type="item", name="chromium", amount=6.20111952616},
        {type="item", name="pure-sand", amount=20},
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
        {type="item", name="melamine-resin", amount=12.0442465827},
      },
      results = {
        {type="item", name="bisphenol-a", amount=3},
      },
    },
    ["melamine-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="item", name="dried-meat", amount=1.99367152618},
      },
      results = {
        {type="item", name="phenol", amount=5},
      },
    },
    ["silica-powder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sb-oxide", amount=2.60350553322},
      },
      results = {
        {type="item", name="silica-powder", amount=10},
      },
    },
    ["bakelite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=189.890145971},
        {type="item", name="biomass", amount=30},
        {type="item", name="nickel-rejects", amount=6.97275240146},
        {type="item", name="zinc-chloride", amount=5},
      },
      results = {
        {type="item", name="bakelite", amount=5},
      },
    },
    ["epoxy"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ech", amount=30},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="ore-aluminium", amount=4.54595116626},
        {type="item", name="shell", amount=2.23155336909},
      },
      results = {
        {type="item", name="epoxy", amount=4},
      },
    },
    ["nylon2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=100},
        {type="fluid", name="benzene", amount=100},
        {type="fluid", name="syngas", amount=262.654861211},
        {type="item", name="nichrome", amount=2},
      },
      results = {
        {type="item", name="nylon", amount=6},
      },
    },
    ["blood-meal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=1253.78112825},
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
        {type="item", name="fish-food-01", amount=3.1182085383},
        {type="item", name="silicon", amount=6.76281550025},
        {type="item", name="wood", amount=4.080865121},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=296.527406422},
        {type="fluid", name="syngas", amount=463.860576171},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="grade-3-ti", amount=2},
      },
      results = {
        {type="item", name="grade-4-ti", amount=1},
      },
    },
    ["concentrated-ti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ti-enriched-dust", amount=9.17642033859},
      },
      results = {
        {type="item", name="concentrated-ti", amount=1},
        {type="item", name="iron-oxide", amount=0.5},
        {type="item", name="nexelit-ore", amount=0.5},
      },
    },
    ["high-grade-ti-powder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=64916.5206436},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="mibc", amount=100},
        {type="fluid", name="water", amount=100},
        {type="item", name="grade-3-ti", amount=4.17213149508},
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
        {type="fluid", name="hot-air", amount=746.61825881},
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
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="fawogae", amount=2.50611511171},
        {type="item", name="niobium-plate", amount=2},
        {type="item", name="phosphate-rock", amount=4},
        {type="item", name="sand", amount=21.1886238842},
        {type="item", name="sulfur", amount=1},
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
        {type="fluid", name="molten-stainless-steel", amount=100},
        {type="item", name="cobalt-fluoride", amount=0.904181250245},
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
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="stainless-steel", amount=10},
      },
    },
    ["guar-gum"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="hot-syngas-barrel", amount=11.3861594675},
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
        {type="item", name="carbon-black", amount=6.72470471787},
        {type="item", name="inserter", amount=5},
        {type="item", name="small-parts-02", amount=1},
        {type="item", name="sodium-carbonate", amount=3.2113405475},
        {type="item", name="ti-rejects", amount=5.55417426197},
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
        {type="item", name="duralumin", amount=1},
        {type="item", name="fungal-substrate-02", amount=4.59599985592},
        {type="item", name="glass", amount=1},
        {type="item", name="iron-oxide", amount=3.29247447832},
        {type="item", name="nexelit-plate", amount=1},
        {type="item", name="rayon", amount=0.603878042098},
        {type="item", name="sodium-silicate", amount=0.540938713181},
        {type="item", name="stone", amount=5.07035005849},
        {type="item", name="tin-plate", amount=1},
        {type="item", name="titanium-plate", amount=2},
        {type="item", name="warmer-stone-brick", amount=5.66426429531},
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
        {type="item", name="belt", amount=5},
        {type="item", name="controler-mk01", amount=2},
        {type="item", name="electronics-mk01", amount=2},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="glass", amount=172.360561352},
        {type="item", name="kevlar", amount=6.34325202945},
        {type="item", name="long-handed-inserter", amount=9.92120370214},
      },
      results = {
        {type="item", name="fast-inserter", amount=15},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=235.834222515},
        {type="item", name="blue-refined-concrete", amount=15.8034989451},
        {type="item", name="duralumin", amount=18.5660577848},
        {type="item", name="zinc-chloride", amount=17.9349989415},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=15},
      },
    },
    ["rotor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=1.74497691849},
        {type="item", name="plastic-bar", amount=30.9492900933},
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
        {type="item", name="bolts", amount=20},
        {type="item", name="electronic-circuit", amount=3},
        {type="item", name="processed-fatty-acids-barrel", amount=3.23344570802},
        {type="item", name="stator", amount=1},
        {type="item", name="titanium-plate", amount=11.3091380342},
        {type="item", name="xenogenic-cells-barrel", amount=23.6475463475},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=3},
      },
    },
    ["nexelit-power-pole"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="coal", amount=16.4474193697},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="stainless-steel", amount=1},
      },
      results = {
        {type="item", name="nexelit-power-pole", amount=1},
      },
    },
    ["anemometer-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="blade-mk01", amount=1.49851586369},
        {type="item", name="blade-mk02", amount=0.861688833883},
        {type="item", name="stainless-steel", amount=17.7180687475},
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
        {type="item", name="bolts", amount=25.1775333234},
        {type="item", name="electronic-circuit", amount=7.68211583642},
        {type="item", name="nxsb-alloy", amount=5},
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
        {type="item", name="aramid", amount=20},
        {type="item", name="brake-mk01", amount=1},
        {type="item", name="coke", amount=67.2851511153},
        {type="item", name="small-lamp", amount=16.6276757769},
        {type="item", name="stainless-steel", amount=10},
        {type="item", name="steel-plate", amount=128.516603883},
      },
      results = {
        {type="item", name="brake-mk02", amount=1},
      },
    },
    ["controler-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=3},
        {type="item", name="battery-mk01", amount=14.2367500279},
        {type="item", name="blade-mk02", amount=0.514981444736},
        {type="item", name="nxsb-alloy", amount=8.12071702098},
        {type="item", name="pipe", amount=17.9488346069},
        {type="item", name="silicon-wafer", amount=5.23091895927},
        {type="item", name="small-lamp", amount=10},
        {type="item", name="stainless-steel", amount=11.8120458317},
      },
      results = {
        {type="item", name="controler-mk02", amount=1},
      },
    },
    ["electronics-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="diode", amount=2.61181694239},
        {type="item", name="glass", amount=4},
        {type="item", name="inductor2", amount=1.51512423479},
        {type="item", name="lead-plate", amount=11.3850246673},
        {type="item", name="log", amount=16.1970926132},
        {type="item", name="microchip", amount=3.9249651637},
        {type="item", name="niobium-pipe", amount=72.0245697165},
        {type="item", name="petri-dish-bacteria", amount=22.1552143719},
        {type="item", name="phenolicboard", amount=300.189060394},
        {type="item", name="sodium-hydroxide", amount=4.600052179},
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
        {type="item", name="kevlar", amount=6.48968454267},
        {type="item", name="niobium-plate", amount=10},
        {type="item", name="nxsb-alloy", amount=8},
        {type="item", name="secondary-crusher-mk01", amount=0.821713135823},
        {type="item", name="small-parts-02", amount=80},
        {type="item", name="titanium-plate", amount=25},
      },
      results = {
        {type="item", name="gearbox-mk02", amount=1},
      },
    },
    ["hotair-shaft-mk02"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=50},
        {type="fluid", name="molten-stainless-steel", amount=100},
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
        {type="fluid", name="vacuum", amount=560},
        {type="item", name="kevlar", amount=20},
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
        {type="fluid", name="molten-steel", amount=417.014103048},
        {type="item", name="black-refined-concrete", amount=1.6445368298},
        {type="item", name="grade-1-zinc", amount=20.7018087943},
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
        {type="item", name="controler-mk01", amount=1.49897994486},
        {type="item", name="p-dope", amount=7.9427443916},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="sodium-silicate", amount=10.6252264986},
        {type="item", name="tinned-cable", amount=3.35486254465},
      },
      results = {
        {type="item", name="utility-box-mk02", amount=1},
      },
    },
    ["vane-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sand-casting", amount=2},
        {type="item", name="starch", amount=233.152166406},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["nacelle-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="active-provider-chest", amount=36.6406368482},
        {type="item", name="controler-mk01", amount=0.819011167039},
        {type="item", name="eg-si", amount=588.939096076},
        {type="item", name="electronics-mk02", amount=1.3125742464},
        {type="item", name="engine-unit", amount=55.2644864499},
        {type="item", name="eva", amount=10},
        {type="item", name="nacelle-mk01", amount=0.518169602296},
        {type="item", name="stainless-steel", amount=40},
        {type="item", name="stator", amount=2.06246320141},
        {type="item", name="utility-box-mk01", amount=4.92105913687},
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
        {type="item", name="aluminium-plate", amount=10},
        {type="item", name="anemometer-mk01", amount=5.55577824055},
        {type="item", name="bolts", amount=30},
        {type="item", name="brake-mk01", amount=3.74597952225},
        {type="item", name="rubber", amount=10},
        {type="item", name="shaft-mk01", amount=4.38642209617},
      },
      results = {
        {type="item", name="rotor-mk02", amount=1},
      },
    },
    ["tower-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="duralumin", amount=53.0458793851},
        {type="item", name="micro-mine-mk01", amount=1.71981036998},
        {type="item", name="nbfe-alloy", amount=40},
        {type="item", name="shaft-mk02", amount=1.24694480266},
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
        {type="fluid", name="heavy-oil", amount=200},
        {type="item", name="blade-mk02", amount=1.74601930534},
        {type="item", name="crucible", amount=10.1211773938},
        {type="item", name="nbfe-alloy", amount=30},
        {type="item", name="nichrome", amount=41.9372623385},
        {type="item", name="plasmids", amount=4.94929725784},
        {type="item", name="py-local-radar", amount=1.56581018267},
        {type="item", name="rayon", amount=15},
        {type="item", name="rubber", amount=20},
        {type="item", name="shotgun", amount=2.04127369278},
      },
      results = {
        {type="item", name="yaw-drive-mk02", amount=1},
      },
    },
    ["efficiency-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-flower-sample", amount=0.662395476805},
        {type="item", name="steam-turbine", amount=8.29275822489},
        {type="item", name="tower-mk02", amount=1.11495085583},
      },
      results = {
        {type="item", name="efficiency-module", amount=1},
      },
    },
    ["productivity-module"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=3.52695192918},
        {type="item", name="tower-mk02", amount=1.96802076218},
        {type="item", name="vane-mk02", amount=7.26636660333},
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
        {type="item", name="evaporator", amount=7.89748307299},
        {type="item", name="gold-plate", amount=39.7615557117},
      },
      results = {
        {type="item", name="speed-module", amount=1},
      },
    },
    ["bhoddos-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="glass", amount=2},
        {type="item", name="limestone", amount=228.440523098},
        {type="item", name="py-tank-8000", amount=2.6071216875},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="bhoddos-codex", amount=1},
      },
    },
    ["cadaveric-arum-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="crude-cermet", amount=2.00993696148},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="resorcinol", amount=5.8919123523},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
    },
    ["navens-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electric-engine-unit", amount=148.992120924},
        {type="item", name="pipe", amount=2.67662538256},
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
        {type="item", name="coke", amount=9.91412656203},
        {type="item", name="electronic-circuit", amount=30},
        {type="item", name="nickel-plate", amount=31.5993370907},
        {type="item", name="tinned-cable", amount=20},
      },
      results = {
        {type="item", name="rennea-codex", amount=1},
      },
    },
    ["grod-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="nexelit-plate", amount=2.50480086833},
        {type="item", name="pure-sand", amount=193.601087566},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="grod-codex", amount=1},
      },
    },
    ["yotoi-codex"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="py-nexelit", amount=17.5382669039},
        {type="item", name="small-electric-pole", amount=0.760821941337},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=50},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=1},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="logistic-science-pack", amount=100},
        {type="item", name="zipir-codex", amount=10.3146501082},
      },
      results = {
        {type="item", name="earth-sunflower-sample", amount=1},
      },
    },
    ["earth-tropical-tree-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="ferrite", amount=16.0543326316},
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
        {type="item", name="bio-sample", amount=7},
        {type="item", name="dried-meat", amount=1.29985150248},
        {type="item", name="earth-tropical-tree-sample", amount=1},
        {type="item", name="grod-codex", amount=2},
        {type="item", name="hydrogen-barrel", amount=689.911136528},
        {type="item", name="py-tank-9000", amount=9.37219954858},
        {type="item", name="tailings-pond", amount=41.3360386422},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=2},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="coal-gas", amount=100},
        {type="fluid", name="pressured-water", amount=285.714285714},
        {type="item", name="cadaveric-arum-seeds", amount=5},
        {type="item", name="sand", amount=5},
        {type="item", name="stone-furnace", amount=2.59671824826},
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
        {type="fluid", name="water", amount=1000},
        {type="item", name="alien-sample-02", amount=0.821661741607},
        {type="item", name="alien-sample01", amount=4},
        {type="item", name="earth-bear-sample", amount=1.01124921923},
        {type="item", name="grod-codex", amount=1},
        {type="item", name="nylon", amount=5.2204095677},
        {type="item", name="planter-box", amount=1},
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
        {type="item", name="coarse", amount=1.3153779642},
        {type="item", name="grod-seeds", amount=5},
        {type="item", name="limestone", amount=5},
        {type="item", name="ralesia-seeds", amount=19.4489146901},
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
        {type="item", name="active-carbon", amount=52.4166731693},
        {type="item", name="alien-sample-02", amount=10},
        {type="item", name="cdna", amount=10},
        {type="item", name="earth-sunflower-sample", amount=1},
        {type="item", name="fertilizer", amount=30},
        {type="item", name="planter-box", amount=1},
        {type="item", name="rennea-codex", amount=1},
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
        {type="item", name="fertilizer", amount=3},
        {type="item", name="limestone", amount=3.82352941176},
        {type="item", name="powdered-u", amount=2.64253767623},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=1037.80599194},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="meat", amount=5},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="yotoi-seeds", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="vacuum", amount=102.666666667},
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
        {type="item", name="ammonia-barrel", amount=4.61914997967},
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
        {type="fluid", name="carbon-dioxide", amount=296.966044607},
        {type="fluid", name="water", amount=100},
        {type="item", name="ash", amount=10},
        {type="item", name="biomass", amount=8},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="moondrop-seeds", amount=11},
        {type="item", name="tailings-dust", amount=3.22727637168},
      },
      results = {
        {type="item", name="moondrop", amount=16},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="syngas", amount=177.900970721},
        {type="item", name="cu-biomass", amount=0.972444353515},
        {type="item", name="ticl4", amount=3.34189830133},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=15},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene", amount=50},
        {type="fluid", name="nitrogen", amount=406.855719889},
        {type="fluid", name="vacuum", amount=160},
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
        {type="item", name="moondrop-seeds", amount=8.94252937831},
      },
      results = {
        {type="fluid", name="fuel-oil", amount=400},
        {type="item", name="ash", amount=10},
      },
    },
    ["chloroethanol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene", amount=50},
        {type="fluid", name="ethylene-chlorohydrin", amount=100},
        {type="fluid", name="steam", amount=100},
      },
      results = {
        {type="fluid", name="chloroethanol", amount=100},
      },
    },
    ["ethylene-glycol"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="medium-distillate", amount=827.849449068},
        {type="fluid", name="slacked-lime", amount=20},
        {type="fluid", name="water", amount=100},
        {type="item", name="ore-zinc", amount=3.71986837129},
      },
      results = {
        {type="fluid", name="ethylene-glycol", amount=150},
      },
    },
    ["ferrite"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="lens", amount=3.61296824162},
        {type="item", name="nichrome", amount=3},
        {type="item", name="pipe", amount=23.008436826},
      },
      results = {
        {type="item", name="ferrite", amount=4},
      },
    },
    ["lead-container"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aramid", amount=3},
        {type="item", name="nbfe-alloy", amount=10},
        {type="item", name="niobium-pipe", amount=23.8585642981},
      },
      results = {
        {type="item", name="lead-container", amount=1},
      },
    },
    ["nexelit-matrix"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=150},
        {type="fluid", name="vacuum", amount=100},
        {type="item", name="epoxy", amount=3},
        {type="item", name="nexelit-plate", amount=4},
      },
      results = {
        {type="item", name="nexelit-matrix", amount=4},
      },
    },
    ["nuclear-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=100},
        {type="fluid", name="hydrogen", amount=384.87394958},
        {type="fluid", name="industrial-solvent", amount=100},
        {type="item", name="automation-science-pack", amount=1},
        {type="item", name="sb-hpo-pu", amount=6.84864101276},
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
        {type="item", name="niobium-powder", amount=25.6626429767},
        {type="item", name="pu-239", amount=2},
        {type="item", name="sodium-hydroxide", amount=181.044640899},
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
        {type="item", name="nickel-plate", amount=10},
        {type="item", name="syngas-barrel", amount=35.3294169216},
        {type="item", name="tin-plate", amount=5.90105047201},
      },
      results = {
        {type="item", name="crmoni", amount=2},
      },
    },
    ["nbalti"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bolts", amount=12.5887666617},
        {type="item", name="fecr-alloy", amount=1.39544932613},
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
        {type="fluid", name="acetic-acid", amount=1258.96016438},
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
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=372.340359397},
        {type="item", name="crmoni", amount=1},
        {type="item", name="nbalti", amount=1},
        {type="item", name="rayon", amount=3},
        {type="item", name="rocket-launcher", amount=1.91714351489},
        {type="item", name="wooden-chest", amount=4.49380102668},
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
        {type="item", name="guts", amount=47.0714426642},
        {type="item", name="nbalti", amount=1},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="lead-plate", amount=35.2348571704},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="nickel-plate", amount=25},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="skin", amount=30},
        {type="item", name="small-parts-02", amount=9.12462008603},
        {type="item", name="soil-extractor-mk01", amount=1.02336640735},
        {type="item", name="tinned-cable", amount=16.7743127233},
      },
      results = {
        {type="item", name="vat-brain", amount=1},
      },
    },
    ["mk02-locomotive"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bolts", amount=908.345477528},
        {type="item", name="brake-mk02", amount=4},
        {type="item", name="copper-plate", amount=112.973192689},
        {type="item", name="distilator", amount=7.80285724305},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="glass", amount=150},
        {type="item", name="inductor1", amount=87.3315677029},
        {type="item", name="pipe", amount=434.854374001},
        {type="item", name="py-tank-5000", amount=2.47010334804},
        {type="item", name="rubber", amount=40},
        {type="item", name="secondary-crusher-mk01", amount=2.22284332583},
        {type="item", name="starch", amount=83.9252848921},
        {type="item", name="titanium-plate", amount=14.594201758},
        {type="item", name="tower-mk02", amount=1.29158668441},
        {type="item", name="washer", amount=3.44933778221},
      },
      results = {
        {type="item", name="mk02-locomotive", amount=1},
      },
    },
    ["mk02-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=20},
        {type="item", name="buffer-chest", amount=8.56478776116},
        {type="item", name="grade-3-ti", amount=17.5183582588},
        {type="item", name="iron-plate", amount=137.044091779},
        {type="item", name="iron-stick", amount=597.491112172},
        {type="item", name="niobium-ore", amount=69.1324700135},
        {type="item", name="nxsb-alloy", amount=0.954804240382},
        {type="item", name="ppd", amount=1.22702719886},
        {type="item", name="self-assembly-monolayer", amount=3},
        {type="item", name="stainless-steel", amount=8.90704120177},
        {type="item", name="tin-plate", amount=57.3353664598},
        {type="item", name="tower-mk01", amount=1.60392023427},
        {type="item", name="tower-mk02", amount=0.577549349128},
      },
      results = {
        {type="item", name="mk02-wagon", amount=1},
      },
    },
    ["mk02-fluid-wagon"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bulk-inserter", amount=1.62093929875},
        {type="item", name="ceramic", amount=232.039563759},
        {type="item", name="cladded-core", amount=4.42431072661},
        {type="item", name="duralumin", amount=20},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="nickel-plate", amount=40},
        {type="item", name="niobium-concentrate", amount=37.9650392221},
        {type="item", name="self-assembly-monolayer", amount=3},
        {type="item", name="shaft-mk02", amount=2},
        {type="item", name="small-parts-01", amount=100},
        {type="item", name="stainless-steel", amount=10},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="tin-plate", amount=57.3353664598},
      },
      results = {
        {type="item", name="mk02-fluid-wagon", amount=1},
      },
    },
    ["glycerol2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=480},
        {type="item", name="skin", amount=5},
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
        {type="fluid", name="hot-air", amount=320.286740617},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="sugar", amount=11.0773723006},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=200},
      },
    },
    ["sea-sponge-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="middle-oil", amount=416.789875024},
        {type="fluid", name="oxygen", amount=1079.21568627},
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
        {type="item", name="ceramic", amount=48.5126795888},
        {type="item", name="crushed-quartz", amount=2},
        {type="item", name="kerogen", amount=9.84449027684},
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
        {type="item", name="ceramic", amount=24.1842668352},
        {type="item", name="nichrome", amount=6.02182481975},
        {type="item", name="niobium-pipe", amount=10},
      },
      results = {
        {type="item", name="heat-exchanger", amount=1},
      },
    },
    ["heat-pipe"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="engine-unit", amount=2.27457881261},
        {type="item", name="steel-plate", amount=10},
      },
      results = {
        {type="item", name="heat-pipe", amount=1},
      },
    },
    ["nuclear-reactor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=500},
        {type="item", name="glass", amount=437.314232634},
        {type="item", name="small-lamp", amount=1452.7862559},
        {type="item", name="urea", amount=363.586549712},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=1},
      },
    },
    ["steam-turbine"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="copper-plate", amount=50},
        {type="item", name="eva", amount=8.25716015615},
        {type="item", name="fawogae-spore", amount=360.0606426},
        {type="item", name="pipe", amount=20},
      },
      results = {
        {type="item", name="steam-turbine", amount=1},
      },
    },
    ["zinc-acetate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methane", amount=247.918916766},
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
        {type="fluid", name="sb-pulp-02", amount=200},
        {type="item", name="cermet", amount=19.8404096904},
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
        {type="fluid", name="methane", amount=778.053283737},
        {type="fluid", name="phosphine-gas", amount=20},
        {type="item", name="cermet", amount=19.8404096904},
      },
      results = {
        {type="item", name="light-n", amount=10},
      },
    },
    ["p-dope"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=200},
        {type="fluid", name="methane", amount=515.955212779},
        {type="fluid", name="nitrogen", amount=200},
        {type="item", name="salt", amount=20},
      },
      results = {
        {type="item", name="ammonium-chloride", amount=2},
        {type="item", name="sodium-carbonate", amount=1},
      },
    },
    ["p2s5-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="phosphate-rock", amount=5},
        {type="item", name="warm-stone-brick", amount=1.47402901263},
      },
      results = {
        {type="item", name="p2s5", amount=1},
        {type="item", name="pyrite", amount=2},
      },
    },
    ["uranium-fuel-cell"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="boron-trioxide", amount=168.020162404},
        {type="item", name="u-235", amount=3},
      },
      results = {
        {type="item", name="uranium-fuel-cell", amount=1},
      },
    },
    ["fuel-cell-dissolve"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=116.457272395},
        {type="fluid", name="slacked-lime", amount=342.334558703},
        {type="item", name="cellulose", amount=3.03027615998},
        {type="item", name="moondrop-codex", amount=42.9642666718},
      },
      results = {
        {type="fluid", name="sb-phosphate-1", amount=100},
      },
    },
    ["plutonium-fuel-reprocessing"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="earth-flower-sample", amount=0.675972972794},
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
        {type="fluid", name="acetic-acid", amount=1420.24638718},
        {type="fluid", name="sb-phosphate-1", amount=5},
        {type="item", name="starch", amount=18.0981605708},
      },
      results = {
        {type="fluid", name="purex-concentrate-1", amount=100},
        {type="item", name="sb-hpo-pu", amount=10},
      },
    },
    ["plutonium-seperation"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="u-235", amount=1.61166310308},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=250},
        {type="item", name="caged-mukmoux", amount=2.25459953321},
      },
      results = {
        {type="fluid", name="plutonium-peroxide", amount=100},
        {type="fluid", name="sb-phosphate-2", amount=100},
      },
    },
    ["plutonium-shuffle-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=35},
        {type="item", name="inductor2", amount=1.78372067601},
        {type="item", name="pu-239", amount=1},
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
        {type="item", name="sb-hpo-pu", amount=3.32670964807},
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
        {type="fluid", name="phosphoric-acid", amount=626.072827051},
        {type="item", name="nylon", amount=5.58890954117},
        {type="item", name="pu-241", amount=1},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
    },
    ["rayon"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ammonia", amount=50},
        {type="fluid", name="carbon-sulfide", amount=50},
        {type="fluid", name="sulfuric-acid", amount=150},
        {type="item", name="fiber", amount=15},
        {type="item", name="sodium-carbonate", amount=5},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="rayon", amount=5},
      },
    },
    ["battery-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=409.90806366},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="pipe", amount=2.67662538256},
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
        {type="fluid", name="oxygen", amount=409.90806366},
        {type="item", name="chromite-sand", amount=3.92236536677},
        {type="item", name="distilator", amount=0.500901108142},
        {type="item", name="melamine-resin", amount=34.2440380811},
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
        {type="item", name="fecr-alloy", amount=10.43081},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="rayon", amount=2},
        {type="item", name="steel-plate", amount=1},
        {type="item", name="sulfur", amount=20},
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
        {type="item", name="nylon", amount=2},
        {type="item", name="stone-brick", amount=6.79292537313},
        {type="item", name="titanium-plate", amount=4.96667260928},
        {type="item", name="zinc-acetate", amount=1},
      },
      results = {
        {type="item", name="used-nexelit-battery", amount=1},
      },
    },
    ["nexelit-battery-recharge"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="used-nexelit-battery", amount=1},
      },
      results = {
        {type="item", name="nexelit-battery", amount=1},
      },
    },
    ["casein-mixture-03"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hot-air", amount=497.745505873},
        {type="fluid", name="milk", amount=50},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=80},
        {type="fluid", name="waste-water", amount=50},
      },
    },
    ["fish-emulsion"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=100},
        {type="fluid", name="vacuum", amount=320},
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
        {type="fluid", name="bitumen", amount=458.023204713},
        {type="item", name="fawogae", amount=5},
      },
      results = {
        {type="fluid", name="ethanol", amount=100},
      },
    },
    ["syrup-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=1000},
        {type="item", name="fungal-substrate-02", amount=31.0785506504},
        {type="item", name="seeds-extract-01", amount=1},
      },
      results = {
        {type="fluid", name="syrup-01", amount=50},
      },
    },
    ["fertilizer-5"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=10},
        {type="item", name="ammonium-chloride", amount=1},
        {type="item", name="bones", amount=6},
        {type="item", name="fine-powdered-biomass", amount=2},
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
        {type="item", name="ground-sample01", amount=15.899502605},
        {type="item", name="lead-plate", amount=20.5372296309},
        {type="item", name="plastic-bar", amount=5},
      },
      results = {
        {type="item", name="night-vision-equipment", amount=1},
      },
    },
    ["personal-roboport-mk2-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="locomotive", amount=2.3483695453},
        {type="item", name="moss-gen", amount=6.74209902599},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="stone-furnace", amount=17.6781943928},
        {type="item", name="washer", amount=6.99650422258},
      },
      results = {
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
      },
    },
    ["belt-immunity-equipment"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="cobalt-extract", amount=13.7744753035},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="intermetallics", amount=5},
      },
      results = {
        {type="item", name="belt-immunity-equipment", amount=1},
      },
    },
    ["bio-scafold"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=200},
        {type="item", name="bonemeal", amount=5},
        {type="item", name="brain", amount=29.9710527878},
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
        {type="fluid", name="steam", amount=200},
        {type="item", name="skin", amount=1.55711698846},
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
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      ingredients = {
        {type="fluid", name="pressured-water", amount=218.571428571},
        {type="fluid", name="water", amount=300},
        {type="item", name="copper-plate", amount=17.4171533236},
      },
      results = {
        {type="fluid", name="syngas", amount=100},
      },
    },
    ["lignin-to-aromatics"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sand", amount=42.1793468345},
      },
      results = {
        {type="fluid", name="aromatics", amount=150},
      },
    },
    ["tpa"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="boric-acid", amount=409.686381908},
        {type="fluid", name="liquid-nitrogen", amount=50},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="fluid", name="tpa", amount=50},
      },
    },
    ["oleo-gasification"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=329.661943995},
        {type="fluid", name="methanol", amount=1110.01563521},
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
      ingredients = {
        {type="item", name="clay", amount=5},
        {type="item", name="fecr-alloy", amount=3.98580300708},
        {type="item", name="nisi", amount=2},
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
        {type="fluid", name="nitrogen", amount=475.150165667},
        {type="item", name="anemometer-mk01", amount=2.81933163385},
        {type="item", name="engine-unit", amount=33.4968576935},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="nxsb-alloy", amount=3},
        {type="item", name="rotor-mk02", amount=0.717223696304},
        {type="item", name="small-lamp", amount=17.4229777554},
        {type="item", name="small-parts-02", amount=25},
        {type="item", name="steel-plate", amount=20},
        {type="item", name="tower-mk02", amount=0.984010381088},
        {type="item", name="u-238", amount=4.33209138588},
        {type="item", name="utility-box-mk02", amount=1},
        {type="item", name="yaw-drive-mk01", amount=4.20013812591},
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
        {type="fluid", name="sb-58-conc", amount=50},
        {type="fluid", name="vacuum", amount=680},
        {type="item", name="plastic-bar", amount=10},
      },
      results = {
        {type="item", name="sb-oxide", amount=10},
      },
    },
    ["lead-acetate"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=50},
        {type="fluid", name="manure-bacteria", amount=649.293768135},
        {type="item", name="tin-plate", amount=1.86958759011},
      },
      results = {
        {type="item", name="lead-acetate", amount=1},
      },
    },
    ["dowfroth-250"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="ethylene-glycol", amount=100},
        {type="fluid", name="methanol", amount=50},
        {type="item", name="coal-dust", amount=8.5952970572},
      },
      results = {
        {type="fluid", name="dowfroth-250", amount=100},
      },
    },
    ["sb-crushed"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="sand", amount=9.95872936211},
        {type="item", name="sb-grade-03", amount=0.727982049634},
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
        {type="item", name="advanced-circuit", amount=2},
        {type="item", name="nbfe-alloy", amount=1},
        {type="item", name="nickel-plate", amount=1.61898810829},
        {type="item", name="niobium-pipe", amount=44.5992156654},
        {type="item", name="rennea-seeds", amount=7.90106173602},
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
        {type="item", name="lead-plate", amount=26.8497844072},
        {type="item", name="nbfe-alloy", amount=1},
        {type="item", name="small-parts-01", amount=15.4427296032},
        {type="item", name="transport-belt", amount=2},
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
        {type="item", name="coal", amount=4.40430480697},
        {type="item", name="fast-transport-belt", amount=8},
        {type="item", name="nbfe-alloy", amount=5},
        {type="item", name="small-parts-01", amount=77.2136480159},
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
        {type="item", name="boiler", amount=73.9099829759},
        {type="item", name="coal", amount=149.71117874},
        {type="item", name="intermetallics", amount=20},
        {type="item", name="lens", amount=16.4861287358},
        {type="item", name="mechanical-parts-01", amount=2},
        {type="item", name="nexelit-plate", amount=50},
        {type="item", name="niobium-pipe", amount=10},
        {type="item", name="primers", amount=1.30173382605},
        {type="item", name="soil-extractor-mk01", amount=3.52993641393},
        {type="item", name="steel-plate", amount=100},
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
        {type="item", name="centrifuge-mk01", amount=3.87193470789},
        {type="item", name="duralumin", amount=175.856733467},
        {type="item", name="intermetallics", amount=351.290294558},
        {type="item", name="latex", amount=124.139332642},
        {type="item", name="mechanical-parts-01", amount=20.1110660388},
        {type="item", name="mechanical-parts-02", amount=5},
        {type="item", name="nexelit-plate", amount=300},
        {type="item", name="niobium-pipe", amount=50},
        {type="item", name="sic", amount=195.951263508},
        {type="item", name="stainless-steel", amount=100},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk02", amount=1},
      },
    },
    ["py-coal-powerplant-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="coke", amount=542.414016207},
        {type="item", name="duralumin", amount=50},
        {type="item", name="engine-unit", amount=20},
        {type="item", name="iron-stick", amount=187.284232544},
        {type="item", name="py-oil-powerplant-mk01", amount=0.996386753876},
        {type="item", name="py-tank-5000", amount=49.9180557639},
        {type="item", name="self-assembly-monolayer", amount=30},
        {type="item", name="small-parts-02", amount=100},
        {type="item", name="stainless-steel", amount=100},
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
        {type="item", name="advanced-foundry-mk01", amount=15.1809506763},
        {type="item", name="duralumin", amount=112.270727994},
        {type="item", name="eva", amount=50},
        {type="item", name="neuroprocessor", amount=30.9004046199},
        {type="item", name="pipe", amount=281.01088761},
        {type="item", name="self-assembly-monolayer", amount=20},
        {type="item", name="storage-tank", amount=11.7586078143},
        {type="item", name="tar-extractor-mk01", amount=4.83366381884},
        {type="item", name="treated-wood", amount=175.896928441},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk02", amount=1},
      },
    },
    ["tidal-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="anemometer-mk01", amount=8.45799490156},
        {type="item", name="anemometer-mk02", amount=7.05390385837},
        {type="item", name="brake-mk02", amount=3},
        {type="item", name="controler-mk02", amount=3.47527429837},
        {type="item", name="gas-separator-mk01", amount=2.08055394386},
        {type="item", name="mechanical-parts-02", amount=10},
        {type="item", name="niobium-pipe", amount=50},
        {type="item", name="self-assembly-monolayer", amount=15},
        {type="item", name="small-parts-01", amount=653.685645282},
        {type="item", name="small-parts-02", amount=150},
        {type="item", name="steel-chest", amount=4.37273328392},
        {type="item", name="zinc-plate", amount=147.404447054},
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
        {type="item", name="anemometer-mk02", amount=1},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="eva", amount=40},
        {type="item", name="fish-food-02", amount=4.69481928498},
        {type="item", name="gearbox-mk01", amount=22.5278752655},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="glassworks-mk01", amount=0.874444440711},
        {type="item", name="lens", amount=194.399667634},
        {type="item", name="nylon-parts", amount=3123.78247295},
        {type="item", name="rubber", amount=30},
        {type="item", name="steam-engine", amount=193.391968791},
        {type="item", name="yotoi-codex", amount=7.12132532306},
      },
      results = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
    },
    ["hawt-turbine-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="brake-mk02", amount=1.73145377362},
        {type="item", name="controler-mk02", amount=2.64767826117},
        {type="item", name="nacelle-mk02", amount=1},
        {type="item", name="rotor-mk02", amount=1},
        {type="item", name="shaft-mk01", amount=7.22183902592},
        {type="item", name="vane-mk01", amount=8.73006302121},
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
        {type="item", name="agitator-mk01", amount=9.80392044242},
        {type="item", name="anemometer-mk02", amount=19.44956478},
        {type="item", name="brake-mk02", amount=25},
        {type="item", name="carbon-filter", amount=12.8168319429},
        {type="item", name="compost-plant-mk01", amount=0.647844912949},
        {type="item", name="concrete", amount=9853.35878011},
        {type="item", name="earth-potato-sample", amount=2.302361633},
        {type="item", name="electronics-mk02", amount=10.2734355851},
        {type="item", name="nexelit-plate", amount=150},
        {type="item", name="self-assembly-monolayer", amount=100},
        {type="item", name="steel-plate", amount=200},
        {type="item", name="ticl4", amount=190.44754683},
        {type="item", name="tower-mk01", amount=4.00980058567},
        {type="item", name="yotoi-codex", amount=1.52993688396},
      },
      results = {
        {type="item", name="steam-turbine-mk02", amount=1},
      },
    },
    ["jig-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="automated-screener-mk01", amount=1.03458263493},
        {type="item", name="bio-sample", amount=9.33188661665},
        {type="item", name="concrete", amount=127.611620916},
        {type="item", name="duralumin", amount=5.15943833155},
        {type="item", name="electronic-circuit", amount=20},
        {type="item", name="engine-unit", amount=5.10737238345},
        {type="item", name="py-shed-basic", amount=4.32950861554},
        {type="item", name="titanium-plate", amount=164.304247621},
        {type="item", name="washer", amount=1.46603305657},
      },
      results = {
        {type="item", name="jig-mk01", amount=1},
      },
    },
    ["nmf-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=42.1260959106},
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="empty-petri-dish", amount=14.2857142857},
        {type="item", name="iron-plate", amount=228.100105489},
        {type="item", name="latex", amount=8.63247797105},
        {type="item", name="molten-iron-barrel", amount=33.9873316543},
        {type="item", name="py-iron", amount=18.9888138918},
        {type="item", name="quenching-tower", amount=3.20910455942},
        {type="item", name="steel-plate", amount=50},
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
        {type="item", name="automated-screener-mk01", amount=2.72410817495},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="gearbox-mk02", amount=0.639289465475},
        {type="item", name="grade-1-ti", amount=414.21824682},
        {type="item", name="mechanical-parts-02", amount=2},
        {type="item", name="nickel-plate", amount=15.0721413648},
        {type="item", name="py-tank-3000", amount=0.986497262493},
      },
      results = {
        {type="item", name="py-heat-exchanger-mk02", amount=1},
      },
    },
    ["bio-printer-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="graphite", amount=615.468959866},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="limestone", amount=167.719791132},
        {type="item", name="nexelit-plate", amount=25},
        {type="item", name="niobium-powder", amount=37.1932776901},
        {type="item", name="ore-zinc", amount=362.410986775},
        {type="item", name="pipe", amount=434.854374001},
        {type="item", name="vacuum-pump-mk01", amount=2.52865439301},
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
        {type="item", name="chromium", amount=50.5125731638},
        {type="item", name="distilator", amount=2.88831012915},
        {type="item", name="kerogen", amount=108.363333333},
        {type="item", name="manure", amount=32.9631716452},
        {type="item", name="micro-mine-mk01", amount=1.18942655201},
        {type="item", name="small-parts-02", amount=10},
        {type="item", name="stainless-steel", amount=129.846384326},
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
        {type="item", name="bio-sample", amount=32.6914195634},
        {type="item", name="engine-unit", amount=8},
        {type="item", name="intermetallics", amount=43.9112868197},
        {type="item", name="iron-plate", amount=80},
        {type="item", name="lab", amount=335.908337743},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="small-parts-02", amount=25},
        {type="item", name="spore-collector-mk01", amount=1},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=427.450980392},
        {type="fluid", name="oxygen", amount=60},
        {type="item", name="biomass", amount=10},
        {type="item", name="concrete-wall", amount=5.48479517382},
        {type="item", name="filtration-media", amount=1},
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
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fish", amount=12},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="sodium-alginate", amount=3.72621455288},
        {type="item", name="sodium-chlorate", amount=5.0722841512},
      },
      results = {
        {type="fluid", name="waste-water", amount=100},
        {type="item", name="fish-egg", amount=35},
      },
    },
    ["fish-egg-mk03-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="fish-mk03", amount=5},
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
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish-food-02", amount=3},
        {type="item", name="fish-mk02", amount=20},
        {type="item", name="green-refined-concrete", amount=2.575072178},
        {type="item", name="ralesia-codex", amount=1.96873995668},
      },
      results = {
        {type="item", name="fish", amount=6},
        {type="item", name="fish-mk03", amount=0.004},
      },
    },
    ["fish-mk03-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=50},
        {type="fluid", name="water-saline", amount=100},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="filtration-media", amount=5},
        {type="item", name="fish-egg-mk03", amount=10},
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
        {type="fluid", name="methane", amount=1445.02024344},
        {type="fluid", name="water", amount=500},
        {type="item", name="aluminium-plate", amount=7},
      },
      results = {
        {type="item", name="energy-drink", amount=7},
      },
    },
    ["neuroprocessor"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="accumulator", amount=0.562461409321},
        {type="item", name="bio-sample", amount=3},
        {type="item", name="capacitor1", amount=5},
        {type="item", name="capacitor2", amount=2.67517008392},
        {type="item", name="cermet", amount=5},
        {type="item", name="fiberboard", amount=1.80859451272},
        {type="item", name="inductor1", amount=10},
        {type="item", name="lead-plate", amount=3.65545233904},
        {type="item", name="lignin", amount=4.79565912502},
        {type="item", name="nexelit-matrix", amount=5},
        {type="item", name="processed-fatty-acids-barrel", amount=1.99314032105},
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
        {type="item", name="lignin", amount=0.502345945928},
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
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=10},
        {type="fluid", name="steam", amount=644.599729726},
        {type="item", name="biomass", amount=285.379313604},
        {type="item", name="p2s5", amount=4.41207046341},
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
        {type="item", name="bakelite", amount=19.070797961},
        {type="item", name="cermet", amount=5},
        {type="item", name="diesel-canister", amount=1.54010727747},
        {type="item", name="heavy-n", amount=2.76577553691},
        {type="item", name="tin-plate", amount=5},
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
        {type="item", name="heavy-n", amount=4},
        {type="item", name="light-n", amount=4},
        {type="item", name="nisi", amount=2},
        {type="item", name="p-dope", amount=4},
        {type="item", name="pipe", amount=4.21516331415},
        {type="item", name="reo", amount=5},
        {type="item", name="silica-powder", amount=0.507412673683},
        {type="item", name="sodium-hydroxide", amount=19.4549770291},
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
        {type="item", name="agar", amount=0.630985831449},
        {type="item", name="melamine", amount=96.0966730957},
        {type="item", name="vacuum-tube", amount=8.52139238108},
      },
      results = {
        {type="item", name="phenolicboard", amount=5},
      },
    },
    ["resistor2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=161.149932431},
        {type="item", name="bisphenol-a", amount=2.21653176708},
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
      ingredients = {
        {type="item", name="boron-trioxide", amount=23.9436013363},
        {type="item", name="cermet", amount=1.16931985777},
        {type="item", name="ferrite", amount=10},
        {type="item", name="inductor1", amount=5},
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
        {type="item", name="capacitor2", amount=4.66705329218},
        {type="item", name="copper-plate", amount=5},
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
        {type="item", name="crude-cermet", amount=7.09138407622},
        {type="item", name="light-n", amount=5},
        {type="item", name="nylon", amount=1},
        {type="item", name="p-dope", amount=5},
        {type="item", name="ralesia", amount=298.492399772},
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
        {type="item", name="fecr-alloy", amount=24.020020437},
        {type="item", name="heavy-n", amount=0.958994692273},
        {type="item", name="nylon", amount=3},
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
        {type="item", name="capacitor2", amount=5},
        {type="item", name="diode", amount=3},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="inductor2", amount=4},
        {type="item", name="microchip", amount=3},
        {type="item", name="mosfet", amount=5},
        {type="item", name="optical-fiber", amount=2},
        {type="item", name="pcb2", amount=1},
        {type="item", name="phenolicboard", amount=7.77014056941},
        {type="item", name="requester-chest", amount=5.19709370012},
        {type="item", name="tinned-cable", amount=6.29175978573},
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
        {type="item", name="cottongut-mk02", amount=38.3837900817},
        {type="item", name="electronic-circuit", amount=405.672315345},
        {type="item", name="fluid-drill-mk01", amount=4.06145513932},
        {type="item", name="inductor2", amount=67.2279118473},
        {type="item", name="pbsb-alloy", amount=44.5888892756},
        {type="item", name="small-parts-02", amount=100},
        {type="item", name="stainless-steel", amount=50},
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
        {type="item", name="anemometer-mk02", amount=2},
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="chromium", amount=48.0938118437},
        {type="item", name="gearbox-mk02", amount=1.56538734678},
        {type="item", name="lead-plate", amount=46.0010807434},
        {type="item", name="mukmoux-codex", amount=2.59574277916},
        {type="item", name="olefin-plant", amount=4.07717652289},
        {type="item", name="self-assembly-monolayer", amount=40},
      },
      results = {
        {type="item", name="aerial-base", amount=1},
      },
    },
    ["aerial-blimp-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=5939.4770688},
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="aluminium-plate", amount=200},
        {type="item", name="antimony-drill-mk01", amount=5.57861357268},
        {type="item", name="bakelite", amount=89.5216863719},
        {type="item", name="caravan", amount=5.44087605222},
        {type="item", name="controler-mk01", amount=1.63802233408},
        {type="item", name="fawogae-spore", amount=1334.15408875},
        {type="item", name="gearbox-mk02", amount=1.72648242552},
        {type="item", name="mechanical-parts-01", amount=39.5961820339},
        {type="item", name="molybdenum-plate", amount=89.5007423389},
        {type="item", name="neuroprocessor", amount=6.18008092397},
        {type="item", name="nexelit-battery", amount=100},
        {type="item", name="tower-mk02", amount=1.96802076218},
        {type="item", name="utility-box-mk01", amount=9.76889223027},
      },
      results = {
        {type="item", name="aerial-blimp-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="bolts", amount=32.4910704937},
        {type="item", name="electronic-circuit", amount=15},
        {type="item", name="glass", amount=30},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="nuclear-reactor", amount=1},
        {type="item", name="small-parts-01", amount=101.892087072},
        {type="item", name="steel-plate", amount=50},
        {type="item", name="tin-plate", amount=50},
      },
      results = {
        {type="item", name="bhoddos-culture-mk01", amount=1},
      },
    },
    ["cadaveric-arum-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="automated-screener-mk01", amount=0.856602175513},
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="copper-plate", amount=106.47127074},
        {type="item", name="inductor1", amount=170.684481687},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="sugar", amount=8.15467981831},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=1},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="active-carbon", amount=7.88114622802},
        {type="item", name="ceramic", amount=120.921334176},
        {type="item", name="concrete", amount=134.392904321},
        {type="item", name="glass", amount=40},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=137.044091779},
        {type="item", name="py-construction-robot-mk01", amount=0.518285950868},
        {type="item", name="py-warehouse-basic", amount=2.16524571351},
        {type="item", name="steam-engine", amount=5},
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
        {type="item", name="concrete", amount=76.5669725493},
        {type="item", name="duralumin", amount=50},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="incubator-mk01", amount=0.810814248997},
        {type="item", name="lead-plate", amount=13.7489784093},
        {type="item", name="pump", amount=6.04489357567},
        {type="item", name="steel-chest", amount=4.8670583799},
        {type="item", name="steel-plate", amount=20},
      },
      results = {
        {type="item", name="guar-gum-plantation", amount=1},
      },
    },
    ["navens-culture-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="burner-mining-drill", amount=3.12660030693},
        {type="item", name="engine-unit", amount=3.14637138037},
        {type="item", name="gasifier", amount=2},
        {type="item", name="iron-plate", amount=464.831916192},
        {type="item", name="pipe", amount=21.3719614713},
        {type="item", name="rubber", amount=5.37496292489},
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
        {type="item", name="auog-paddock-mk01", amount=3.6663022058},
        {type="item", name="carbon-filter", amount=5.74175630306},
        {type="item", name="copper-plate", amount=69.4557310427},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="kevlar", amount=35.7032352275},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=15},
        {type="item", name="nexelit-plate", amount=68.5203628524},
        {type="item", name="pump", amount=4},
        {type="item", name="small-parts-01", amount=116.448099511},
      },
      results = {
        {type="item", name="ralesia-plantation-mk02", amount=1},
      },
    },
    ["rennea-plantation-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=70.4711674928},
        {type="item", name="cellulose", amount=8.51449736567},
        {type="item", name="duralumin", amount=10.3188766631},
        {type="item", name="electronic-circuit", amount=50},
        {type="item", name="glass", amount=131.82678886},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="skin", amount=45.1163711969},
        {type="item", name="starch", amount=35.8935436828},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="storage-tank", amount=4},
      },
      results = {
        {type="item", name="rennea-plantation-mk01", amount=1},
      },
    },
    ["yotoi-aloe-orchard-mk01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="duralumin", amount=50},
        {type="item", name="inductor1", amount=136.54758535},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=10.311733807},
        {type="item", name="light-oil-barrel", amount=14.5335708209},
        {type="item", name="plastic-bar", amount=40},
        {type="item", name="small-parts-01", amount=15.6792114122},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk01", amount=1},
      },
    },
    ["sponge-culture-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="chromium", amount=12.757951587},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="latex", amount=30},
        {type="item", name="lead-plate", amount=298.940169967},
        {type="item", name="natural-gas-barrel", amount=482.51981253},
        {type="item", name="retorter", amount=2.43405214623},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="small-parts-02", amount=30},
        {type="item", name="stainless-steel", amount=439.663468537},
        {type="item", name="tuuphra-plantation-mk01", amount=1.02063628681},
        {type="item", name="vrauks-food-02", amount=1.71546061077},
      },
      results = {
        {type="item", name="sponge-culture-mk02", amount=1},
      },
    },
    ["cadaveric-arum-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="botanical-nursery", amount=23.2252647676},
        {type="item", name="intermetallics", amount=17.5645147279},
        {type="item", name="latex", amount=10},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=10},
        {type="item", name="nichrome", amount=5.10890382066},
        {type="item", name="small-parts-02", amount=22.6219267907},
        {type="item", name="sponge-culture-mk01", amount=1.33636794135},
        {type="item", name="titanium-plate", amount=50},
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
        {type="item", name="assembling-machine-1", amount=22.7197711408},
        {type="item", name="engine-unit", amount=20},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="moss", amount=2802.95125826},
        {type="item", name="planter-box", amount=7.75674766702},
        {type="item", name="small-lamp", amount=62.2056673166},
        {type="item", name="titanium-plate", amount=42.3823939954},
        {type="item", name="treated-wood", amount=50},
        {type="item", name="underground-belt", amount=3.136994139},
        {type="item", name="xyhiphoe-pool-mk01", amount=0.574586724674},
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
        {type="item", name="evaporator", amount=4.16021780235},
        {type="item", name="explosives", amount=28.9725837462},
        {type="item", name="fwf-mk01", amount=5.67421154759},
        {type="item", name="latex", amount=20},
        {type="item", name="mechanical-parts-01", amount=20.1110660388},
        {type="item", name="niobium-pipe", amount=20},
        {type="item", name="pyrite", amount=552.266138859},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="steel-plate", amount=50},
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
        {type="item", name="duralumin", amount=5.8932958348},
        {type="item", name="ez-ranch-mk01", amount=0.78202842197},
        {type="item", name="fish-food-02", amount=10.9387911988},
        {type="item", name="latex", amount=30},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="self-assembly-monolayer", amount=5},
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
        {type="item", name="cadaveric-arum", amount=18.057733325},
        {type="item", name="concrete", amount=34.1726601353},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="niobium-plate", amount=10},
        {type="item", name="py-shed-basic", amount=6.01883173209},
        {type="item", name="quenching-tower", amount=3.18996014583},
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
        {type="item", name="engine-unit", amount=10},
        {type="item", name="manure-bacteria-barrel", amount=45.0875430958},
        {type="item", name="plastic-bar", amount=20},
        {type="item", name="repair-pack", amount=12.3032549266},
        {type="item", name="seaweed-crop-mk01", amount=0.688655516905},
        {type="item", name="self-assembly-monolayer", amount=7},
        {type="item", name="stone-brick", amount=542.78534674},
        {type="item", name="titanium-plate", amount=296.947590798},
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
        {type="item", name="assembling-machine-2", amount=1.49407371831},
        {type="item", name="bio-sample", amount=4.37430935655},
        {type="item", name="latex", amount=25},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=30},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="stainless-steel", amount=35.436137495},
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
        {type="item", name="duralumin", amount=5.01772645732},
        {type="item", name="electric-engine-unit", amount=4.24561687165},
        {type="item", name="eva", amount=3.43090584924},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="mukmoux-pasture-mk01", amount=1.64116796554},
        {type="item", name="pump", amount=26.5439055596},
        {type="item", name="treated-wood", amount=20},
        {type="item", name="vacuum-pump-mk01", amount=379.285728509},
        {type="item", name="yotoi-aloe-orchard-mk01", amount=0.602444294758},
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
        {type="item", name="copper-plate", amount=70.9808471603},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="gate", amount=4.97191226214},
        {type="item", name="lead-plate", amount=237.863162991},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="mechanical-parts-02", amount=0.637168142832},
        {type="item", name="molybdenum-plate", amount=4.04935848182},
        {type="item", name="moss-farm-mk01", amount=0.687870464076},
        {type="item", name="small-parts-01", amount=118.110862419},
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
        {type="item", name="electric-engine-unit", amount=2.12280843582},
        {type="item", name="glass", amount=227.449133363},
        {type="item", name="lens", amount=12.3567614336},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="small-parts-02", amount=30},
        {type="item", name="steel-plate", amount=40},
        {type="item", name="ulric-corral-mk01", amount=0.504024837757},
        {type="item", name="utility-box-mk01", amount=1.42143585826},
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
        {type="item", name="electric-engine-unit", amount=47.6681953432},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="fwf-mk01", amount=4.83820111856},
        {type="item", name="lignin", amount=998.139407426},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="optical-fiber", amount=13.5220690585},
        {type="item", name="small-parts-01", amount=145.560124388},
        {type="item", name="tin-plate", amount=9.41066452932},
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
        {type="item", name="electronics-mk02", amount=3.4095196188},
        {type="item", name="latex", amount=40},
        {type="item", name="lead-plate", amount=50},
        {type="item", name="navens-culture-mk01", amount=30.531487092},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="small-parts-02", amount=6.6303635836},
        {type="item", name="sodium-alginate", amount=9.76738439857},
        {type="item", name="steam-engine", amount=11.9310137504},
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
        {type="item", name="engine-unit", amount=1},
        {type="item", name="ethylene-glycol-barrel", amount=12.5146064075},
        {type="item", name="plastic-bar", amount=20},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="treated-wood", amount=30},
        {type="item", name="ulric-corral-mk01", amount=0.829176191568},
        {type="item", name="utility-box-mk01", amount=1.42143585826},
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
        {type="item", name="auog-paddock-mk01", amount=0.828903891353},
        {type="item", name="cliff-explosives", amount=2.82825662466},
        {type="item", name="engine-unit", amount=5},
        {type="item", name="gravel", amount=83.5323178488},
        {type="item", name="guar-gum", amount=7.89738395952},
        {type="item", name="latex", amount=30},
        {type="item", name="nexelit-plate", amount=65.7428865355},
        {type="item", name="small-parts-02", amount=30},
        {type="item", name="steam-engine", amount=47.2422592309},
      },
      results = {
        {type="item", name="fwf-mk02", amount=1},
      },
    },
    ["bulk-inserter"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="electronic-circuit", amount=25.500286211},
        {type="item", name="fast-inserter", amount=1},
        {type="item", name="small-parts-02", amount=1},
        {type="item", name="vitreloy", amount=2.09217238292},
      },
      results = {
        {type="item", name="bulk-inserter", amount=1},
      },
    },
    ["assembling-machine-3"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="engine-unit", amount=4.01586610251},
        {type="item", name="fast-inserter", amount=15.1056355273},
        {type="item", name="mechanical-parts-02", amount=5},
        {type="item", name="niobium-pipe", amount=62.9290024507},
      },
      results = {
        {type="item", name="assembling-machine-3", amount=1},
      },
    },
    ["chemical-science-pack"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="methanal", amount=1858.58385887},
        {type="item", name="advanced-circuit", amount=2},
        {type="item", name="explosives", amount=45.8714335253},
        {type="item", name="micro-fiber", amount=82.3052216722},
        {type="item", name="molten-glass-barrel", amount=56.9798609421},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="phenolicboard", amount=20.2306732761},
        {type="item", name="self-assembly-monolayer", amount=2},
        {type="item", name="skin", amount=18.8997995977},
        {type="item", name="small-parts-01", amount=23.1640944048},
      },
      results = {
        {type="item", name="chemical-science-pack", amount=12},
      },
    },
    ["electric-furnace"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="advanced-circuit", amount=5},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="stone-brick", amount=10},
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
        {type="item", name="electric-engine-unit", amount=3},
        {type="item", name="nexelit-plate", amount=20},
        {type="item", name="nichrome", amount=4.3450621403},
        {type="item", name="niobium-plate", amount=10},
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
        {type="item", name="animal-sample-01", amount=16.6729533062},
        {type="item", name="controler-mk02", amount=8.82559420391},
        {type="item", name="duralumin", amount=53.0458793851},
        {type="item", name="eva", amount=6.60572812492},
        {type="item", name="gearbox-mk01", amount=10.2129191613},
        {type="item", name="log", amount=11.5368078558},
        {type="item", name="mechanical-parts-01", amount=62.1440077934},
        {type="item", name="py-tank-3000", amount=1.19312865616},
        {type="item", name="self-assembly-monolayer", amount=10},
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
        {type="item", name="agar", amount=284.392397483},
        {type="item", name="electric-engine-unit", amount=20},
        {type="item", name="leaching-station-mk01", amount=0.771137429847},
        {type="item", name="melamine", amount=1166.52981047},
        {type="item", name="nexelit-plate", amount=131.485773071},
        {type="item", name="niobium-dust", amount=89.0634006093},
        {type="item", name="niobium-pipe", amount=37.7191309927},
        {type="item", name="rubber", amount=20.751024769},
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
        {type="item", name="advanced-circuit", amount=50},
        {type="item", name="guar-gum-plantation", amount=2.06310645134},
        {type="item", name="latex", amount=50},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="neuroprocessor", amount=50},
        {type="item", name="py-tank-4000", amount=6.08870971648},
        {type="item", name="refined-concrete", amount=20.8143499383},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="titanium-plate", amount=39.9656767724},
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
        {type="item", name="agar", amount=34.588073038},
        {type="item", name="copper-cable", amount=82.8562830168},
        {type="item", name="electric-engine-unit", amount=2.37024706951},
        {type="item", name="kicalk-plantation-mk01", amount=1.17071852381},
        {type="item", name="pipe", amount=46.5490459782},
        {type="item", name="self-assembly-monolayer", amount=5},
        {type="item", name="small-parts-02", amount=6.6303635836},
        {type="item", name="stainless-steel", amount=50},
      },
      results = {
        {type="item", name="yotoi-aloe-orchard-mk02", amount=1},
      },
    },
    ["kicalk-seeds-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="nitrobenzene-barrel", amount=27.1974236465},
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
        {type="item", name="kicalk", amount=1.550032637},
        {type="item", name="wood", amount=5},
        {type="item", name="yotoi-leaves", amount=5},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="cu-biomass", amount=1.94488870703},
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
        {type="fluid", name="phytoplankton", amount=50},
        {type="item", name="biomass", amount=15},
        {type="item", name="flask", amount=0.806279248405},
        {type="item", name="fungal-substrate-02", amount=1},
        {type="item", name="ground-sample01", amount=4.33217533782},
        {type="item", name="guts", amount=2.4431914348},
        {type="item", name="raw-fiber", amount=5},
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
        {type="item", name="heavy-oil-canister", amount=5.5844647783},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="salt", amount=30},
      },
    },
    ["psc"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="oxygen", amount=150},
        {type="fluid", name="xenogenic-cells", amount=150},
        {type="item", name="retrovirus", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pressured-air", amount=200},
        {type="item", name="copper-ore", amount=61.269072373},
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
        {type="item", name="chromium", amount=0.784022979117},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=100},
        {type="item", name="seaweed", amount=7.82322936821},
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
        {type="item", name="iron-oxide", amount=15.5325665499},
        {type="item", name="salt", amount=4.81204742807},
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
        {type="item", name="bedding", amount=1},
        {type="item", name="burner-inserter", amount=1.61928364706},
        {type="item", name="salt", amount=5},
        {type="item", name="ulric-cub", amount=6},
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
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="fawogae", amount=3},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="salt", amount=10},
        {type="item", name="silica-powder", amount=3.05831010144},
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
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="salt", amount=5},
        {type="item", name="silica-powder", amount=3.83854745267},
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
        {type="item", name="carbon-black", amount=1.70797263447},
        {type="item", name="saps", amount=24.491140181},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="guar-gum", amount=1.68731242571},
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
        {type="item", name="coarse", amount=10.6174253117},
        {type="item", name="latex", amount=2},
        {type="item", name="sample-cup", amount=6},
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
      ingredients = {
        {type="item", name="bedding", amount=4},
        {type="item", name="moss-gen", amount=6.14117653574},
        {type="item", name="ulric-food-01", amount=4},
        {type="item", name="ulric-mk02", amount=1},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="cobalt-fluoride", amount=1.24305856034},
        {type="item", name="fawogae", amount=15},
        {type="item", name="lignin", amount=23.671803706},
        {type="item", name="manure-bacteria-barrel", amount=1.01195672148},
        {type="item", name="raw-fiber", amount=8},
        {type="item", name="ulric-cub-mk02", amount=4},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["compile-korlex-codex"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="korlex-codex", amount=1},
        {type="item", name="neuroprocessor", amount=1},
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
        {type="item", name="fish", amount=5},
        {type="item", name="industrial-solvent-barrel", amount=0.90195657618},
        {type="item", name="kicalk", amount=1},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="korlex-pup", amount=4},
        {type="item", name="nitrobenzene-barrel", amount=1.51544414948},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=4},
      },
    },
    ["korlex-milk-2"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="ash", amount=10},
        {type="item", name="bhoddos", amount=2},
        {type="item", name="empty-barrel-milk", amount=6},
        {type="item", name="fish", amount=5},
        {type="item", name="korlex-food-01", amount=1},
        {type="item", name="tuuphra", amount=5},
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
        {type="item", name="concrete", amount=42.8132239189},
        {type="item", name="korlex", amount=2},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="rennea", amount=10},
        {type="item", name="salt", amount=10},
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
        {type="item", name="crude-oil-barrel", amount=33.8181240048},
        {type="item", name="small-parts-01", amount=21.0839797682},
        {type="item", name="tuuphra-seeds", amount=10},
        {type="item", name="water-barrel", amount=20},
      },
      results = {
        {type="item", name="barrel", amount=25},
        {type="item", name="korlex-pup", amount=6},
      },
    },
    ["korlex-mk02r"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="psc", amount=100},
        {type="fluid", name="xenogenic-cells", amount=100},
        {type="item", name="alien-sample-02", amount=0.547774494405},
        {type="item", name="animal-sample-01", amount=1},
        {type="item", name="cadaveric-arum-codex", amount=2.31979191385},
        {type="item", name="ferrite", amount=23.1158878872},
        {type="item", name="korlex-mk02", amount=4},
      },
      results = {
        {type="item", name="korlex-mk02", amount=5},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=200},
        {type="item", name="moss", amount=5},
        {type="item", name="sap-tree-mk02", amount=5},
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
        {type="item", name="pipe-to-ground", amount=1.50241949211},
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
        {type="item", name="fertilizer", amount=4},
        {type="item", name="green-refined-concrete", amount=19.3406892048},
        {type="item", name="soil", amount=222.610060856},
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
        {type="fluid", name="pressured-water", amount=3000},
        {type="item", name="blood-meal", amount=5},
        {type="item", name="ppd", amount=0.641495209},
        {type="item", name="saps", amount=2},
        {type="item", name="solder", amount=3.91684992855},
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
        {type="fluid", name="methanal", amount=1811.57372986},
        {type="fluid", name="pressured-water", amount=1000},
        {type="item", name="albumin", amount=1},
        {type="item", name="blood-meal", amount=4},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="glass", amount=16.6976752167},
        {type="item", name="moss", amount=16.2853816428},
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
        {type="fluid", name="pressured-water", amount=3000},
        {type="item", name="blood-meal", amount=6},
        {type="item", name="fish-food-01", amount=2.84447140745},
        {type="item", name="sodium-alginate", amount=9.31553638221},
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
        {type="item", name="electric-engine-unit", amount=2.37024706951},
        {type="item", name="electronic-circuit", amount=54.7968019803},
        {type="item", name="glassworks-mk01", amount=1.8562780354},
        {type="item", name="kerogen", amount=452.380952381},
        {type="item", name="latex", amount=30},
        {type="item", name="neuroprocessor", amount=30},
        {type="item", name="niobium-plate", amount=20},
        {type="item", name="sap-extractor-mk01", amount=21.0153533786},
        {type="item", name="self-assembly-monolayer", amount=6},
        {type="item", name="small-parts-01", amount=5.36542614525},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=1},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="pressured-water", amount=3000},
        {type="item", name="blood-meal", amount=6},
        {type="item", name="fawogae-mk02", amount=1},
        {type="item", name="fish-mk02", amount=1},
        {type="item", name="plastic-bar", amount=39.7612897626},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe-cub", amount=0.7},
        {type="item", name="xyhiphoe-cub-mk02", amount=2.3},
      },
    },
    ["xyhiphoe-mk02-breeder"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=53.3333333333},
        {type="item", name="bhoddos-spore", amount=5},
        {type="item", name="biomass", amount=10},
        {type="item", name="fungal-substrate-02", amount=1},
      },
      results = {
        {type="item", name="bhoddos", amount=5},
      },
    },
    ["bhoddos-sample"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=333.333333333},
        {type="item", name="borax-mine", amount=4.84531634966},
        {type="item", name="boric-acid-barrel", amount=38.1825465461},
        {type="item", name="cdna", amount=3},
        {type="item", name="cobalt-extract", amount=6.85988566059},
        {type="item", name="earth-sunflower-sample", amount=0.506295610643},
        {type="item", name="korlex-food-01", amount=2.11181586325},
        {type="item", name="soot", amount=6.80053266863},
        {type="item", name="ulric-codex", amount=1.64892837483},
      },
      results = {
        {type="item", name="bhoddos", amount=1},
      },
    },
    ["fish-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="ash", amount=10},
        {type="item", name="blood-meal", amount=5},
        {type="item", name="brain", amount=0.902469622244},
        {type="item", name="chitin", amount=1.29885076067},
        {type="item", name="fawogae", amount=10},
        {type="item", name="fish", amount=2},
        {type="item", name="meat", amount=17.1256667702},
        {type="item", name="nexelit-plate", amount=7.88914638426},
        {type="item", name="salt", amount=10},
        {type="item", name="seaweed", amount=5},
        {type="item", name="starch", amount=4},
        {type="item", name="yotoi-fruit", amount=3},
      },
      results = {
        {type="item", name="fish-food-02", amount=5},
      },
    },
    ["naven-coal"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="lead-plate", amount=4.9681887374},
      },
      results = {
        {type="item", name="raw-coal", amount=10},
      },
    },
    ["navens-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=100},
        {type="item", name="chitin", amount=1.06324108883},
        {type="item", name="fertilizer", amount=5},
        {type="item", name="fungal-substrate-02", amount=2},
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
        {type="fluid", name="pressured-water", amount=571.428571429},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="aluminium-plate", amount=80.3186724829},
        {type="item", name="earth-shroom-sample", amount=1},
        {type="item", name="moondrop-mk02", amount=98.5685096548},
        {type="item", name="navens-spore", amount=100},
        {type="item", name="ralesia-codex", amount=23.0119760555},
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
        {type="item", name="fenxsb-alloy", amount=3.80754777211},
        {type="item", name="glass", amount=2},
        {type="item", name="small-lamp", amount=2},
      },
      results = {
        {type="item", name="mukmoux-codex", amount=1},
      },
    },
    ["mukmoux-food-01"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=139.748726874},
        {type="item", name="glass", amount=3.48824839447},
        {type="item", name="moss", amount=5},
        {type="item", name="native-flora", amount=10},
        {type="item", name="salt", amount=10},
        {type="item", name="saps", amount=5},
        {type="item", name="saps-mk03", amount=1.07556868748},
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
        {type="item", name="albumin", amount=1.20674073894},
        {type="item", name="fawogae", amount=30},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="ralesia-seeds", amount=30},
        {type="item", name="water-barrel", amount=15},
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
        {type="item", name="alien-sample01", amount=3.16065050689},
        {type="item", name="cdna", amount=5},
        {type="item", name="earth-cow-sample", amount=1},
        {type="item", name="earth-generic-sample", amount=9.5497237526},
        {type="item", name="tuuphra-mk02", amount=4.06669158943},
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
        {type="item", name="fertilizer", amount=20.4178358178},
        {type="item", name="mukmoux-food-01", amount=2},
        {type="item", name="water-barrel", amount=15},
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
        {type="item", name="empty-gas-canister", amount=5.75067406965},
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
        {type="item", name="acetylene-barrel", amount=2.95144672082},
        {type="item", name="fawogae", amount=15},
        {type="item", name="ralesia-seeds", amount=15},
        {type="item", name="titanium-plate", amount=29.4239226111},
        {type="item", name="xyhiphoe-cub", amount=6.44211689244},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="mukmoux", amount=2},
      },
    },
    ["mukmoux-pasture-mk01"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="duralumin", amount=30},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="soil", amount=500},
        {type="item", name="steel-plate", amount=100},
        {type="item", name="storage-tank", amount=5},
      },
      results = {
        {type="item", name="mukmoux-pasture-mk01", amount=1},
      },
    },
    ["full-render-mukmoux"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="caged-mukmoux", amount=1},
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
        {type="item", name="cellulose", amount=1.25945398722},
        {type="item", name="ceramic", amount=7.7096362621},
        {type="item", name="fe-biomass", amount=1.90571025319},
        {type="item", name="moondrop", amount=10},
        {type="item", name="ralesia-seeds", amount=5},
        {type="item", name="rennea-seeds", amount=10},
        {type="item", name="seaweed", amount=10},
        {type="item", name="wood-seeds", amount=15},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=6},
      },
    },
    ["cottongut-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="artificial-blood", amount=20},
        {type="fluid", name="fetal-serum", amount=50},
        {type="item", name="cottongut-pup", amount=0.883918472968},
        {type="item", name="plasmids", amount=1.39435714851},
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
        {type="item", name="boron-trioxide", amount=3.75989534488},
        {type="item", name="cocoon", amount=1},
        {type="item", name="cottongut-food-02", amount=1},
        {type="item", name="cottongut-mk02", amount=2},
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
        {type="item", name="cottongut-pup-mk02", amount=3.53503212168},
        {type="item", name="moondrop", amount=4},
        {type="item", name="sample-cup", amount=15.1714825028},
        {type="item", name="tuuphra-seeds", amount=5},
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
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut", amount=4},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="fishmeal", amount=1.35302448826},
        {type="item", name="moondrop", amount=2},
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
        {type="item", name="bedding", amount=2.42271858653},
        {type="item", name="cadaveric-arum", amount=1},
        {type="item", name="cottongut-pup-mk01", amount=10.561080796},
        {type="item", name="dried-grods", amount=3},
        {type="item", name="grod", amount=8.08116211596},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
      },
    },
    ["auog-food-02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=139.748726874},
        {type="item", name="ash", amount=10},
        {type="item", name="empty-planter-box", amount=11.9120683233},
        {type="item", name="fawogae", amount=5},
        {type="item", name="moss", amount=10},
        {type="item", name="ore-quartz", amount=10},
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
        {type="item", name="auog-pup", amount=12},
        {type="item", name="bakelite", amount=3.36318066371},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=20},
        {type="item", name="raw-borax", amount=48.9871987331},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-pup", amount=1},
        {type="item", name="casein", amount=2},
        {type="item", name="fawogae-substrate", amount=58.6639304928},
        {type="item", name="starch", amount=3.21915938991},
      },
      results = {
        {type="item", name="auog", amount=0.7},
        {type="item", name="auog-mk02", amount=0.005},
        {type="item", name="charged-auog", amount=0.1},
      },
    },
    ["charged-auog"] = {
      mode = "input-preserved-unmodified",
      science_level = 5,
      ingredients = {
        {type="item", name="auog", amount=1},
        {type="item", name="energy-drink", amount=1},
      },
      results = {
        {type="item", name="charged-auog", amount=1},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog", amount=20.3672204196},
        {type="item", name="auog-food-01", amount=6.79547421365},
        {type="item", name="cermet", amount=6.20520734854},
        {type="item", name="moss", amount=10},
        {type="item", name="saps-mk03", amount=10},
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
        {type="item", name="agar", amount=3.1850625548},
        {type="item", name="bedding", amount=2},
        {type="item", name="carbon-black", amount=2.30643648576},
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
        {type="item", name="auog-food-02", amount=0.882940588303},
        {type="item", name="bedding", amount=3},
        {type="item", name="coal-dust", amount=14.7686170904},
        {type="item", name="eg-si", amount=4.17941029685},
        {type="item", name="moss", amount=10},
        {type="item", name="raw-fiber", amount=15},
        {type="item", name="water-barrel", amount=5},
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
        {type="item", name="auog-food-02", amount=0.882940588303},
        {type="item", name="moss", amount=10},
        {type="item", name="pipe", amount=24.5545160095},
        {type="item", name="raw-fiber", amount=15},
        {type="item", name="silicon", amount=3.51799339229},
        {type="item", name="subcritical-water-barrel", amount=2.62952109595},
        {type="item", name="zogna-bacteria-barrel", amount=0.538770627829},
      },
      results = {
        {type="item", name="auog-pup", amount=12},
        {type="item", name="barrel", amount=5},
      },
    },
    ["auog-recharge"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="fishmeal", amount=1.35302448826},
        {type="item", name="used-auog", amount=4},
      },
      results = {
        {type="item", name="auog", amount=4},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="bedding", amount=4},
        {type="item", name="caged-auog", amount=8.69802934362},
        {type="item", name="hot-syngas-barrel", amount=0.905052325145},
        {type="item", name="natural-gas-barrel", amount=1.1921418289},
        {type="item", name="saps", amount=10},
        {type="item", name="seaweed", amount=10},
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
        {type="fluid", name="water", amount=1000},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="ralesia", amount=2},
        {type="item", name="soil", amount=100},
        {type="item", name="wood-seeds", amount=14.2897097361},
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
        {type="item", name="auog-food-01", amount=2.14007769571},
        {type="item", name="fawogae", amount=5},
        {type="item", name="native-flora", amount=15},
        {type="item", name="propene-barrel", amount=2.27526498979},
        {type="item", name="sodium-sulfate", amount=1.10616877123},
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
        {type="fluid", name="fish-oil", amount=30},
        {type="fluid", name="steam", amount=100},
        {type="item", name="capacitor1", amount=4.5606482514},
        {type="item", name="carbon-sulfide-barrel", amount=0.541110837579},
        {type="item", name="casein", amount=2},
        {type="item", name="grade-2-zinc", amount=1.0296207391},
        {type="item", name="guts", amount=2},
        {type="item", name="moss", amount=10},
        {type="item", name="native-flora", amount=5},
        {type="item", name="ralesia", amount=5},
        {type="item", name="s-biomass", amount=4.46052298135},
        {type="item", name="soil", amount=54.2629378611},
        {type="item", name="ticl4", amount=5.92852107427},
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
        {type="item", name="barrel-milk", amount=2.52580423045},
        {type="item", name="bolts", amount=24.8862670427},
        {type="item", name="btx-barrel", amount=1.80859024736},
        {type="item", name="cocoon", amount=223.561635794},
        {type="item", name="native-flora", amount=15},
        {type="item", name="vrauks-food-02", amount=3},
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
        {type="item", name="cocoon-mk02", amount=6.70955906486},
        {type="item", name="kerogen", amount=73.0777307046},
        {type="item", name="moss", amount=8},
        {type="item", name="native-flora", amount=26.0680429225},
        {type="item", name="saps", amount=20},
        {type="item", name="ulric-food-01", amount=2.51024083585},
        {type="item", name="yotoi", amount=2.37818951098},
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
        {type="item", name="acid-refined-concrete", amount=3.35525033157},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="bedding", amount=4},
        {type="item", name="casein-pulp-01-barrel", amount=0.967756646103},
        {type="item", name="cocoon-mk02", amount=3.87136105077},
        {type="item", name="saps", amount=8},
        {type="item", name="sea-sponge", amount=5},
        {type="item", name="vrauks-food-01", amount=4.3557172114},
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
        {type="item", name="grade-1-chromite", amount=10.9050865389},
        {type="item", name="native-flora", amount=15},
        {type="item", name="pcb2", amount=2.48998146084},
        {type="item", name="pipe", amount=43.2382724946},
        {type="item", name="sand", amount=65.2292191436},
        {type="item", name="vrauks-mk03", amount=2},
        {type="item", name="water-barrel", amount=5},
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
        {type="fluid", name="muddy-sludge", amount=181.743832069},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="bio-sample", amount=10},
        {type="item", name="cdna", amount=3},
        {type="item", name="earth-palmtree-sample", amount=2.57635956116},
        {type="item", name="grade-2-nickel", amount=1.27770534316},
        {type="item", name="sic", amount=2.48693842372},
        {type="item", name="zipir-codex", amount=15.0528222038},
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
        {type="item", name="ore-zinc", amount=3.78306205493},
        {type="item", name="rich-clay", amount=2.39353265615},
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
        {type="item", name="coke", amount=6.4680979215},
        {type="item", name="iron-oxide", amount=5.79631196237},
        {type="item", name="soil", amount=4},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=5},
      },
    },
    ["fawogae-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=53.3333333333},
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
        {type="fluid", name="carbon-dioxide", amount=465.82908958},
        {type="fluid", name="oxygen", amount=150},
        {type="item", name="fawogae", amount=2},
        {type="item", name="fawogae-spore", amount=10},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="wood-seeds", amount=18.4287847178},
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
        {type="fluid", name="carbon-dioxide", amount=890.898133821},
        {type="fluid", name="steam", amount=250},
        {type="item", name="biomass", amount=20},
        {type="item", name="fawogae-spore", amount=45.9303527056},
        {type="item", name="fertilizer", amount=2},
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
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="water", amount=80},
        {type="item", name="clay", amount=11.6685970721},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="fungal-substrate-03", amount=2},
        {type="item", name="yaedols-spores", amount=4},
      },
      results = {
        {type="item", name="yaedols", amount=6},
      },
    },
    ["yaedols-spore-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=155.139847772},
      },
      results = {
        {type="item", name="yaedols-spores-mk02", amount=5},
      },
    },
    ["yaedols-mk02"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      ingredients = {
        {type="fluid", name="vacuum", amount=533.333333333},
        {type="item", name="fungal-substrate-03", amount=5},
        {type="item", name="native-flora", amount=21.3924279656},
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
        {type="fluid", name="carbon-dioxide", amount=186.331635832},
        {type="fluid", name="nitrogen", amount=400},
        {type="item", name="fungal-substrate", amount=2},
        {type="item", name="pink-refined-concrete", amount=33.9893825145},
        {type="item", name="powdered-ralesia-seeds", amount=88.7767102367},
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

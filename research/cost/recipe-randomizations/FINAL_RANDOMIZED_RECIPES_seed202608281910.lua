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
        {type="item", name="raw-coal", amount=8},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=10},
        {type="item", name="copper-plate", amount=1},
      },
      results = {
        {type="item", name="copper-cable", amount=4},
      },
    },
    ["iron-stick"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="iron-plate", amount=1},
        {type="item", name="raw-coal", amount=18},
      },
      results = {
        {type="item", name="iron-stick", amount=5},
      },
    },
    ["iron-gear-wheel"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=5},
        {type="item", name="iron-stick", amount=3},
      },
      results = {
        {type="item", name="iron-gear-wheel", amount=1},
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
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="bolts", amount=4},
        {type="item", name="copper-cable", amount=2},
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="raw-coal", amount=2},
        {type="item", name="stone", amount=3},
      },
      results = {
        {type="item", name="small-parts-01", amount=3},
      },
    },
    ["burner-inserter"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=7},
        {type="item", name="kerogen", amount=37},
        {type="item", name="pipe", amount=4},
      },
      results = {
        {type="item", name="burner-inserter", amount=1},
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
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="steam", amount=56},
      },
      results = {
        {type="item", name="soil", amount=12},
      },
    },
    ["stone-brick"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=2},
      },
      results = {
        {type="item", name="stone-brick", amount=1},
      },
    },
    ["stone-furnace"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=9},
      },
      results = {
        {type="item", name="stone-furnace", amount=2},
      },
    },
    ["transport-belt"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=10},
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
        {type="item", name="boiler", amount=2},
        {type="item", name="kerogen", amount=28},
        {type="item", name="pipe", amount=9},
        {type="item", name="stone", amount=255},
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
        {type="item", name="iron-stick", amount=4},
        {type="item", name="pipe", amount=6},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-furnace", amount=4},
        {type="item", name="transport-belt", amount=21},
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
        {type="item", name="kerogen", amount=53},
        {type="item", name="stone", amount=51},
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
        {type="item", name="iron-stick", amount=2},
        {type="item", name="log", amount=1},
      },
      results = {
        {type="item", name="small-electric-pole", amount=1},
      },
    },
    ["boiler"] = {
      mode = "kept-transformed",
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
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kerogen", amount=101},
        {type="item", name="pipe", amount=2},
        {type="item", name="transport-belt", amount=13},
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
        {type="item", name="pipe", amount=4},
        {type="item", name="stone-furnace", amount=1},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="burner-mining-drill", amount=1},
      },
    },
    ["offshore-pump"] = {
      mode = "kept-pruned-transformed",
      science_level = 0,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="raw-coal", amount=38},
        {type="item", name="stone", amount=65},
      },
      results = {
        {type="item", name="offshore-pump", amount=1},
      },
    },
    ["soil-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 0,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=94},
        {type="item", name="inductor1", amount=13},
        {type="item", name="kerogen", amount=579},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="stone", amount=99},
        {type="item", name="transport-belt", amount=37},
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
        {type="item", name="boiler", amount=8},
        {type="item", name="bolts", amount=34},
        {type="item", name="iron-gear-wheel", amount=13},
        {type="item", name="log", amount=5},
        {type="item", name="pipe", amount=22},
        {type="item", name="transport-belt", amount=22},
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
        {type="item", name="boiler", amount=5},
        {type="item", name="copper-cable", amount=69},
        {type="item", name="iron-ore", amount=345},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="transport-belt", amount=10},
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
        {type="item", name="iron-stick", amount=1},
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
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="soil", amount=5},
        {type="item", name="stone", amount=13},
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
        {type="item", name="transport-belt", amount=9},
      },
      results = {
        {type="item", name="assembling-machine-1", amount=1},
      },
    },
    ["bricks-to-stone"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=1},
        {type="item", name="stone-brick", amount=4},
      },
      results = {
        {type="item", name="stone", amount=8},
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
        {type="item", name="copper-ore", amount=23},
      },
      results = {
        {type="item", name="copper-plate", amount=3},
      },
    },
    ["grade-1-copper-crush"] = {
      mode = "repaired-to-input",
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
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="wood", amount=14},
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
        {type="fluid", name="pressured-water", amount=160},
        {type="item", name="ore-quartz", amount=6},
      },
      results = {
        {type="fluid", name="molten-glass", amount=15},
      },
    },
    ["molten-glass"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="water", amount=1977},
        {type="item", name="empty-planter-box", amount=1},
      },
      results = {
        {type="item", name="glass", amount=8},
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
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="iron-ore", amount=3},
        {type="item", name="stone", amount=2},
      },
      results = {
        {type="item", name="gravel", amount=4},
      },
    },
    ["gun-turret"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=51},
        {type="item", name="offshore-pump", amount=1},
        {type="item", name="transport-belt", amount=10},
      },
      results = {
        {type="item", name="gun-turret", amount=1},
      },
    },
    ["muddy-sludge"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="water", amount=98},
        {type="item", name="iron-ore", amount=11},
        {type="item", name="limestone", amount=5},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=170},
      },
    },
    ["soil-washing"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.606838402424505,
      ingredients = {
        {type="fluid", name="water", amount=744},
        {type="item", name="limestone", amount=8},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=62},
        {type="item", name="sand", amount=6},
      },
    },
    ["pressured-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.288,
      ingredients = {
        {type="fluid", name="water", amount=644},
      },
      results = {
        {type="fluid", name="pressured-water", amount=644},
      },
    },
    ["repair-pack"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="planter-box", amount=4},
        {type="item", name="soil", amount=133},
      },
      results = {
        {type="item", name="repair-pack", amount=3},
      },
    },
    ["seaweed-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="water", amount=145},
      },
      results = {
        {type="item", name="seaweed", amount=7},
      },
    },
    ["shotgun"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="iron-plate", amount=34},
        {type="item", name="pipe-to-ground", amount=2},
      },
      results = {
        {type="item", name="shotgun", amount=2},
      },
    },
    ["submachine-gun"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="copper-ore", amount=10},
        {type="item", name="copper-plate", amount=46},
        {type="item", name="inductor1", amount=4},
        {type="item", name="pipe-to-ground", amount=5},
        {type="item", name="transport-belt", amount=8},
        {type="item", name="underground-belt", amount=1},
      },
      results = {
        {type="item", name="submachine-gun", amount=3},
      },
    },
    ["small-lamp"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="water", amount=375},
        {type="item", name="copper-cable", amount=3},
        {type="item", name="glass", amount=2},
        {type="item", name="iron-stick", amount=2},
        {type="item", name="limestone", amount=22},
        {type="item", name="ore-aluminium", amount=3},
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
        {type="item", name="iron-stick", amount=19},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="stone", amount=347},
      },
      results = {
        {type="item", name="tailings-pond", amount=1},
      },
    },
    ["tin-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="ore-aluminium", amount=32},
        {type="item", name="ore-tin", amount=36},
      },
      results = {
        {type="item", name="tin-plate", amount=7},
      },
    },
    ["acetylene"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.449775251051584,
      ingredients = {
        {type="fluid", name="pressured-water", amount=223},
        {type="item", name="lime", amount=2},
      },
      results = {
        {type="fluid", name="acetylene", amount=46},
        {type="fluid", name="slacked-lime", amount=11},
      },
    },
    ["coal-gas"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2.94376152213681,
      ingredients = {
        {type="item", name="coal", amount=26},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="coal-gas", amount=111},
        {type="fluid", name="tar", amount=139},
        {type="item", name="coke", amount=17},
        {type="item", name="iron-oxide", amount=1},
      },
    },
    ["coal-gas-from-wood"] = {
      mode = "repaired-to-input",
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
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.863027200327536,
      ingredients = {
        {type="fluid", name="pressured-water", amount=339},
        {type="fluid", name="water", amount=101},
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
      energy_required_multiplier = 0.976784561299474,
      ingredients = {
        {type="item", name="kerogen", amount=10},
      },
      results = {
        {type="fluid", name="coal-gas", amount=58},
        {type="fluid", name="tar", amount=29},
        {type="item", name="coal", amount=3},
        {type="item", name="iron-oxide", amount=0.193185165257814},
      },
    },
    ["aluminium-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-aluminium", amount=8},
        {type="item", name="ore-zinc", amount=10},
      },
      results = {
        {type="item", name="aluminium-plate", amount=2},
      },
    },
    ["graphite"] = {
      mode = "input-preserved-untransformed",
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
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="water", amount=780},
      },
      results = {
        {type="item", name="clay", amount=2},
      },
    },
    ["ceramic"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="bolts", amount=11},
        {type="item", name="limestone", amount=1},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="ceramic", amount=8},
      },
    },
    ["duralumin-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="gravel", amount=13},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="ore-nickel", amount=34},
      },
      results = {
        {type="item", name="duralumin", amount=2},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=4},
        {type="item", name="iron-plate", amount=22},
        {type="item", name="iron-stick", amount=25},
        {type="item", name="limestone", amount=105},
        {type="item", name="steam-engine", amount=5},
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
        {type="item", name="sand", amount=212},
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
        {type="fluid", name="carbon-dioxide", amount=16},
        {type="item", name="ore-aluminium", amount=10},
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
        {type="item", name="capacitor1", amount=55},
        {type="item", name="tin-plate", amount=17},
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
        {type="item", name="aluminium-plate", amount=9},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="solder", amount=2},
      },
    },
    ["tar-quenching"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.34598382535032,
      ingredients = {
        {type="fluid", name="hydrogen", amount=172},
        {type="fluid", name="pressured-air", amount=494},
        {type="fluid", name="syngas", amount=548},
        {type="fluid", name="water", amount=1799},
      },
      results = {
        {type="fluid", name="flue-gas", amount=192},
        {type="fluid", name="tailings", amount=639},
        {type="fluid", name="water-saline", amount=319},
        {type="item", name="soot", amount=3},
      },
    },
    ["chlorine"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.953969669937556,
      ingredients = {
        {type="fluid", name="water", amount=2088},
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
      energy_required_multiplier = 1.3525,
      ingredients = {
        {type="fluid", name="water", amount=126},
        {type="item", name="copper-ore", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen", amount=271},
        {type="fluid", name="oxygen", amount=135},
      },
    },
    ["muddy-sludge-void-electrolyzer"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
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
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.03439384717763,
      ingredients = {
        {type="fluid", name="tailings", amount=42},
        {type="fluid", name="water", amount=820},
      },
      results = {
        {type="fluid", name="acidgas", amount=16},
        {type="item", name="tailings-dust", amount=4},
      },
    },
    ["ash-separation"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.85013824857977,
      ingredients = {
        {type="item", name="ash", amount=17},
      },
      results = {
        {type="item", name="coal-dust", amount=1},
        {type="item", name="iron-oxide", amount=0.0873280788675476},
        {type="item", name="soot", amount=0.34931231547019},
      },
    },
    ["soot-separation"] = {
      mode = "repaired-to-input",
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
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.18770726110282,
      ingredients = {
        {type="fluid", name="water", amount=1531},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="limestone", amount=37},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=97},
      },
      results = {
        {type="item", name="sulfur", amount=2},
      },
    },
    ["titanium-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="ore-tin", amount=17},
      },
      results = {
        {type="item", name="titanium-plate", amount=2},
      },
    },
    ["water-from-oxygen-and-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.08666666666667,
      ingredients = {
        {type="fluid", name="oxygen", amount=77},
        {type="fluid", name="pressured-water", amount=357},
        {type="item", name="copper-ore", amount=1},
        {type="item", name="stone-brick", amount=1},
      },
      results = {
        {type="fluid", name="water", amount=326},
      },
    },
    ["zinc-plate-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="ore-lead", amount=11},
        {type="item", name="ore-tin", amount=3},
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
        {type="item", name="sap-seeds", amount=35},
        {type="item", name="sodium-alginate", amount=5},
        {type="item", name="tar-barrel", amount=6},
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
        {type="item", name="engine-unit", amount=2},
        {type="item", name="glass", amount=34},
        {type="item", name="iron-plate", amount=11},
      },
      results = {
        {type="item", name="py-tank-3000", amount=1},
      },
    },
    ["py-tank-4000"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=15},
        {type="item", name="iron-gear-wheel", amount=5},
        {type="item", name="pipe", amount=8},
        {type="item", name="small-parts-01", amount=37},
      },
      results = {
        {type="item", name="py-tank-4000", amount=1},
      },
    },
    ["py-tank-8000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=7},
        {type="item", name="ceramic", amount=83},
        {type="item", name="concrete", amount=102},
        {type="item", name="iron-plate", amount=13},
        {type="item", name="sand", amount=845},
        {type="item", name="seaweed", amount=20},
        {type="item", name="stone-furnace", amount=18},
      },
      results = {
        {type="item", name="py-tank-8000", amount=2},
      },
    },
    ["py-tank-10000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=93},
        {type="item", name="refined-hazard-concrete", amount=116},
        {type="item", name="small-parts-01", amount=71},
        {type="item", name="tin-plate", amount=5},
        {type="item", name="titanium-plate", amount=64},
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
        {type="item", name="copper-cable", amount=549},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="stone-brick", amount=33},
      },
      results = {
        {type="item", name="py-tank-1500", amount=1},
      },
    },
    ["py-tank-6500"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=41},
        {type="item", name="coke", amount=95},
        {type="item", name="copper-cable", amount=76},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="iron-plate", amount=26},
        {type="item", name="lead-plate", amount=39},
      },
      results = {
        {type="item", name="py-tank-6500", amount=3},
      },
    },
    ["py-tank-7000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete", amount=90},
        {type="item", name="limestone", amount=179},
        {type="item", name="refined-hazard-concrete", amount=63},
        {type="item", name="small-parts-01", amount=98},
        {type="item", name="titanium-plate", amount=89},
        {type="item", name="transport-belt", amount=6},
        {type="item", name="wooden-chest", amount=462},
      },
      results = {
        {type="item", name="py-tank-7000", amount=2},
      },
    },
    ["py-tank-5000"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=30},
        {type="item", name="iron-plate", amount=18},
        {type="item", name="py-tank-1000", amount=3},
      },
      results = {
        {type="item", name="py-tank-5000", amount=1},
      },
    },
    ["py-tank-9000"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="gun-turret", amount=3},
        {type="item", name="gunpowder", amount=22},
        {type="item", name="retorter", amount=3},
        {type="item", name="small-electric-pole", amount=185},
      },
      results = {
        {type="item", name="py-tank-9000", amount=2},
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
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="water", amount=377},
        {type="item", name="kerogen", amount=2},
      },
      results = {
        {type="item", name="limestone", amount=10},
      },
    },
    ["gun-powder"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="water-saline", amount=98},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="limestone", amount=35},
        {type="item", name="ore-lead", amount=2},
        {type="item", name="wood", amount=9},
      },
      results = {
        {type="item", name="gunpowder", amount=6},
      },
    },
    ["tar-distilation"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.998623362678949,
      ingredients = {
        {type="fluid", name="water", amount=4115},
      },
      results = {
        {type="fluid", name="aromatics", amount=100},
        {type="fluid", name="carbon-dioxide", amount=100},
        {type="fluid", name="flue-gas", amount=498},
        {type="item", name="rich-clay", amount=1},
      },
    },
    ["treated-wood"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=233},
      },
      results = {
        {type="item", name="treated-wood", amount=1},
      },
    },
    ["calcium-carbide"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="limestone", amount=13},
        {type="item", name="soil", amount=11},
      },
      results = {
        {type="item", name="calcium-carbide", amount=11},
      },
    },
    ["sand-brick"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="item", name="rich-clay", amount=34},
        {type="item", name="sand", amount=23},
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
        {type="fluid", name="pressured-air", amount=4958},
        {type="fluid", name="tar", amount=188},
        {type="fluid", name="water", amount=2539},
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
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=77},
        {type="fluid", name="water", amount=664},
        {type="item", name="native-flora", amount=17},
        {type="item", name="sand", amount=2},
        {type="item", name="stone", amount=16},
        {type="item", name="wood", amount=2},
      },
      results = {
        {type="item", name="moss", amount=24},
      },
    },
    ["Moss-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.25,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=10},
        {type="fluid", name="water", amount=335},
      },
      results = {
        {type="item", name="moss", amount=2},
      },
    },
    ["aromatics-to-plastic"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="aromatics", amount=22},
        {type="fluid", name="water", amount=847},
        {type="item", name="copper-ore", amount=6},
        {type="item", name="graphite", amount=2},
      },
      results = {
        {type="item", name="plastic-bar", amount=1},
      },
    },
    ["log1"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="item", name="log", amount=1},
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
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="moss", amount=7},
        {type="item", name="wood-seeds", amount=1},
      },
      results = {
        {type="item", name="wood-seedling", amount=4},
      },
    },
    ["log2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=113},
        {type="item", name="moss", amount=4},
        {type="item", name="wood-seedling", amount=2},
        {type="item", name="wood-seeds", amount=1},
      },
      results = {
        {type="item", name="log", amount=4},
      },
    },
    ["log3"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="fluid", name="hydrogen", amount=120},
        {type="item", name="ash", amount=39},
        {type="item", name="wood-seedling", amount=3},
      },
      results = {
        {type="item", name="log", amount=7},
      },
    },
    ["steel-plate"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=23},
        {type="item", name="graphite", amount=1},
        {type="item", name="seaweed", amount=5},
      },
      results = {
        {type="item", name="steel-plate", amount=1},
      },
    },
    ["bio-container"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="glass", amount=3},
        {type="item", name="iron-plate", amount=13},
        {type="item", name="stone-brick", amount=23},
        {type="item", name="tin-plate", amount=1},
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
        {type="item", name="iron-gear-wheel", amount=4},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="iron-plate", amount=14},
        {type="item", name="iron-stick", amount=2},
        {type="item", name="plastic-bar", amount=3},
      },
      results = {
        {type="item", name="empty-fuel-canister", amount=2},
      },
    },
    ["shotgun-shell"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="gravel", amount=16},
        {type="item", name="limestone", amount=1},
        {type="item", name="ore-nickel", amount=14},
      },
      results = {
        {type="item", name="shotgun-shell", amount=2},
      },
    },
    ["firearm-magazine"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="copper-ore", amount=9},
        {type="item", name="pipe", amount=5},
        {type="item", name="sand", amount=58},
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
        {type="item", name="assembling-machine-1", amount=6},
        {type="item", name="coal", amount=57},
        {type="item", name="copper-cable", amount=53},
        {type="item", name="copper-plate", amount=55},
        {type="item", name="pipe", amount=50},
      },
      results = {
        {type="item", name="fwf-mk01", amount=1},
      },
    },
    ["moss-farm-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="ash", amount=18},
        {type="item", name="bolts", amount=101},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="burner-mining-drill", amount=7},
        {type="item", name="distilator", amount=2},
        {type="item", name="graphite", amount=12},
        {type="item", name="limestone", amount=28},
        {type="item", name="pipe", amount=98},
        {type="item", name="stone", amount=252},
        {type="item", name="tin-plate", amount=9},
        {type="item", name="transport-belt", amount=18},
        {type="item", name="vacuum-pump-mk01", amount=1},
        {type="item", name="wood", amount=34},
        {type="item", name="wood-seeds", amount=63},
      },
      results = {
        {type="item", name="moss-farm-mk01", amount=4},
      },
    },
    ["sap-extractor-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="ash", amount=49},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="empty-planter-box", amount=2},
        {type="item", name="iron-stick", amount=71},
        {type="item", name="pipe-to-ground", amount=3},
        {type="item", name="small-parts-01", amount=17},
        {type="item", name="stone", amount=1628},
        {type="item", name="stone-furnace", amount=45},
      },
      results = {
        {type="item", name="sap-extractor-mk01", amount=3},
      },
    },
    ["seaweed-crop-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=13},
        {type="item", name="ceramic", amount=6},
        {type="item", name="ore-aluminium", amount=354},
        {type="item", name="sodium-alginate", amount=4},
        {type="item", name="soil", amount=43},
        {type="item", name="transport-belt", amount=11},
        {type="item", name="wooden-chest", amount=43},
      },
      results = {
        {type="item", name="seaweed-crop-mk01", amount=1},
      },
    },
    ["moondrop-greenhouse-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=39},
        {type="item", name="assembling-machine-1", amount=4},
        {type="item", name="copper-plate", amount=65},
        {type="item", name="kerogen", amount=109},
        {type="item", name="pipe", amount=22},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="tin-plate", amount=6},
        {type="item", name="underground-belt", amount=5},
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
        {type="fluid", name="water", amount=200},
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
        {type="item", name="aluminium-plate", amount=55},
        {type="item", name="copper-cable", amount=285},
        {type="item", name="iron-plate", amount=8},
        {type="item", name="lead-plate", amount=7},
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
        {type="item", name="copper-plate", amount=24},
        {type="item", name="iron-plate", amount=86},
        {type="item", name="transport-belt", amount=26},
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
        {type="item", name="iron-plate", amount=42},
        {type="item", name="ore-zinc", amount=60},
        {type="item", name="py-gas-vent", amount=1},
        {type="item", name="steam-engine", amount=8},
        {type="item", name="steel-chest", amount=2},
        {type="item", name="tar-processing-unit", amount=3},
      },
      results = {
        {type="item", name="car", amount=1},
      },
    },
    ["pump"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="lime", amount=12},
        {type="item", name="soil", amount=6},
      },
      results = {
        {type="item", name="small-electric-pole", amount=2},
      },
    },
    ["py-gas-vent"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=131},
        {type="item", name="native-flora", amount=25},
        {type="item", name="transport-belt", amount=10},
      },
      results = {
        {type="item", name="py-gas-vent", amount=1},
      },
    },
    ["py-sinkhole"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=36},
        {type="item", name="graphite", amount=88},
        {type="item", name="limestone", amount=203},
        {type="item", name="log", amount=15},
        {type="item", name="pipe", amount=23},
        {type="item", name="sand", amount=39},
      },
      results = {
        {type="item", name="py-sinkhole", amount=1},
      },
    },
    ["retorter"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="cellulose", amount=13},
        {type="item", name="copper-plate", amount=9},
        {type="item", name="glass", amount=28},
        {type="item", name="iron-plate", amount=23},
        {type="item", name="limestone", amount=671},
        {type="item", name="stone-furnace", amount=11},
      },
      results = {
        {type="item", name="retorter", amount=1},
      },
    },
    ["steel-chest"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-plate", amount=39},
      },
      results = {
        {type="item", name="steel-chest", amount=1},
      },
    },
    ["tree"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="empty-planter-box", amount=3},
        {type="item", name="iron-stick", amount=7},
        {type="item", name="sodium-alginate", amount=5},
      },
      results = {
        {type="item", name="tree-mk01", amount=3},
      },
    },
    ["advanced-foundry-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="empty-planter-box", amount=12},
        {type="item", name="iron-ore", amount=150},
        {type="item", name="iron-plate", amount=15},
        {type="item", name="pipe", amount=17},
        {type="item", name="pipe-to-ground", amount=5},
        {type="item", name="wood", amount=70},
      },
      results = {
        {type="item", name="advanced-foundry-mk01", amount=2},
      },
    },
    ["borax-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="ash", amount=251},
        {type="item", name="distilator", amount=2},
        {type="item", name="hpf", amount=3},
        {type="item", name="inductor1", amount=9},
        {type="item", name="iron-plate", amount=53},
        {type="item", name="moss", amount=113},
        {type="item", name="pipe", amount=61},
        {type="item", name="stone-brick", amount=116},
        {type="item", name="tar-processing-unit", amount=2},
      },
      results = {
        {type="item", name="borax-mine", amount=3},
      },
    },
    ["distilator"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=20},
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="copper-cable", amount=151},
        {type="item", name="copper-ore", amount=122},
        {type="item", name="copper-plate", amount=4},
        {type="item", name="inductor1", amount=2},
        {type="item", name="lab", amount=3},
        {type="item", name="offshore-pump", amount=3},
        {type="item", name="saps", amount=20},
        {type="item", name="transport-belt", amount=28},
      },
      results = {
        {type="item", name="distilator", amount=2},
      },
    },
    ["fluid-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="boiler", amount=2},
        {type="item", name="ceramic", amount=63},
        {type="item", name="copper-cable", amount=61},
        {type="item", name="iron-plate", amount=13},
        {type="item", name="iron-stick", amount=37},
      },
      results = {
        {type="item", name="fluid-drill-mk01", amount=1},
      },
    },
    ["gasifier"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="copper-cable", amount=87},
        {type="item", name="copper-plate", amount=214},
        {type="item", name="distilator", amount=1},
        {type="item", name="inductor1", amount=8},
        {type="item", name="lime", amount=317},
        {type="item", name="moss", amount=34},
        {type="item", name="pipe", amount=23},
        {type="item", name="stone-brick", amount=77},
        {type="item", name="transport-belt", amount=7},
      },
      results = {
        {type="item", name="gasifier", amount=3},
      },
    },
    ["glassworks-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=204},
        {type="item", name="distilator", amount=2},
        {type="item", name="pipe", amount=12},
        {type="item", name="seaweed", amount=64},
        {type="item", name="stone-furnace", amount=56},
        {type="item", name="transport-belt", amount=44},
        {type="item", name="wood-seeds", amount=154},
      },
      results = {
        {type="item", name="glassworks-mk01", amount=3},
      },
    },
    ["hpf"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="bolts", amount=14},
        {type="item", name="iron-stick", amount=5},
        {type="item", name="limestone", amount=231},
        {type="item", name="pipe", amount=17},
        {type="item", name="stone", amount=97},
        {type="item", name="wood", amount=31},
      },
      results = {
        {type="item", name="hpf", amount=2},
      },
    },
    ["jaw-crusher"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=97},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="pipe", amount=27},
        {type="item", name="stone-brick", amount=26},
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
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="burner-mining-drill", amount=10},
        {type="item", name="copper-plate", amount=30},
        {type="item", name="distilator", amount=1},
        {type="item", name="iron-plate", amount=335},
        {type="item", name="stone-brick", amount=595},
        {type="item", name="stone-wall", amount=7},
        {type="item", name="transport-belt", amount=95},
      },
      results = {
        {type="item", name="solid-separator", amount=2},
      },
    },
    ["tar-processing-unit"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=126},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-stick", amount=36},
        {type="item", name="lab", amount=3},
        {type="item", name="small-parts-01", amount=8},
      },
      results = {
        {type="item", name="tar-processing-unit", amount=1},
      },
    },
    ["washer"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bolts", amount=38},
        {type="item", name="copper-cable", amount=147},
        {type="item", name="inductor1", amount=5},
        {type="item", name="limestone", amount=78},
        {type="item", name="pipe", amount=35},
        {type="item", name="py-gas-vent", amount=2},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="stone-furnace", amount=35},
        {type="item", name="wood", amount=79},
        {type="item", name="wooden-chest", amount=29},
      },
      results = {
        {type="item", name="washer", amount=3},
      },
    },
    ["evaporator"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=51},
        {type="item", name="copper-plate", amount=69},
        {type="item", name="hpf", amount=2},
        {type="item", name="inductor1", amount=20},
        {type="item", name="iron-stick", amount=81},
        {type="item", name="lab", amount=7},
        {type="item", name="pipe", amount=14},
        {type="item", name="small-parts-01", amount=6},
        {type="item", name="stone-brick", amount=13},
        {type="item", name="titanium-plate", amount=39},
      },
      results = {
        {type="item", name="evaporator", amount=1},
      },
    },
    ["quenching-tower"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal", amount=53},
        {type="item", name="copper-cable", amount=27},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=21},
        {type="item", name="small-electric-pole", amount=8},
        {type="item", name="stone", amount=57},
        {type="item", name="stone-brick", amount=243},
        {type="item", name="stone-wall", amount=3},
        {type="item", name="underground-belt", amount=18},
        {type="item", name="wood-seeds", amount=411},
        {type="item", name="wpu-mk01", amount=2},
      },
      results = {
        {type="item", name="quenching-tower", amount=2},
      },
    },
    ["clay-pit-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=52},
        {type="item", name="limestone", amount=111},
        {type="item", name="log", amount=3},
        {type="item", name="pipe", amount=4},
        {type="item", name="raw-fiber", amount=6},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="seaweed", amount=145},
        {type="item", name="stone-furnace", amount=51},
        {type="item", name="wooden-chest", amount=4},
      },
      results = {
        {type="item", name="clay-pit-mk01", amount=1},
      },
    },
    ["electronics-factory-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="bolts", amount=64},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="moss", amount=31},
        {type="item", name="offshore-pump", amount=11},
        {type="item", name="raw-borax", amount=348},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="washer", amount=9},
      },
      results = {
        {type="item", name="electronics-factory-mk01", amount=2},
      },
    },
    ["pulp-mill-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="coal", amount=77},
        {type="item", name="small-electric-pole", amount=79},
        {type="item", name="stone", amount=560},
        {type="item", name="stone-wall", amount=29},
        {type="item", name="wood-seeds", amount=507},
        {type="item", name="wpu-mk01", amount=2},
      },
      results = {
        {type="item", name="pulp-mill-mk01", amount=3},
      },
    },
    ["chipshooter-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="copper-plate", amount=198},
        {type="item", name="distilator", amount=1},
        {type="item", name="empty-planter-box", amount=9},
        {type="item", name="gunpowder", amount=16},
        {type="item", name="iron-plate", amount=41},
        {type="item", name="lead-plate", amount=56},
        {type="item", name="ore-lead", amount=487},
        {type="item", name="pipe", amount=73},
        {type="item", name="refined-concrete", amount=13},
        {type="item", name="resistor1", amount=544},
        {type="item", name="soil", amount=215},
        {type="item", name="treated-wood", amount=50},
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
        {type="item", name="copper-ore", amount=2682},
        {type="item", name="iron-ore", amount=729},
        {type="item", name="planter-box", amount=19},
        {type="item", name="processed-iron-ore", amount=296},
        {type="item", name="pulp-mill-mk01", amount=5},
        {type="item", name="soot", amount=32},
      },
      results = {
        {type="item", name="pcb-factory-mk01", amount=1},
      },
    },
    ["anthracene-oil-creosote"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="syngas", amount=120},
      },
      results = {
        {type="fluid", name="creosote", amount=15},
      },
    },
    ["gravel-saline-water"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.22,
      ingredients = {
        {type="fluid", name="water", amount=97},
        {type="item", name="sand", amount=9},
        {type="item", name="stone", amount=7},
      },
      results = {
        {type="fluid", name="water-saline", amount=61},
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
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="water", amount=62},
        {type="item", name="stone", amount=9},
      },
      results = {
        {type="fluid", name="water-saline", amount=45},
      },
    },
    ["biofactory-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="pipe", amount=41},
        {type="item", name="pump", amount=7},
        {type="item", name="py-underflow-valve", amount=1},
        {type="item", name="sodium-hydroxide", amount=496},
      },
      results = {
        {type="item", name="biofactory-mk01", amount=1},
      },
    },
    ["botanical-nursery"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="bolts", amount=28},
        {type="item", name="capacitor1", amount=26},
        {type="item", name="glass", amount=28},
        {type="item", name="hpf", amount=4},
        {type="item", name="lead-plate", amount=22},
        {type="item", name="offshore-pump", amount=5},
        {type="item", name="pipe", amount=38},
        {type="item", name="raw-borax", amount=396},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="stone-brick", amount=279},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="tin-plate", amount=10},
        {type="item", name="washer", amount=4},
      },
      results = {
        {type="item", name="botanical-nursery", amount=4},
      },
    },
    ["creature-chamber-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=21},
        {type="item", name="concrete", amount=691},
        {type="item", name="copper-ore", amount=324},
        {type="item", name="copper-plate", amount=88},
        {type="item", name="incubator-mk01", amount=1},
        {type="item", name="iron-plate", amount=856},
        {type="item", name="micro-mine-mk01", amount=7},
        {type="item", name="pipe", amount=369},
        {type="item", name="pulp-mill-mk01", amount=1},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="py-tank-3000", amount=1},
        {type="item", name="small-lamp", amount=9},
        {type="item", name="soot", amount=10},
        {type="item", name="stone-brick", amount=126},
        {type="item", name="tin-plate", amount=35},
      },
      results = {
        {type="item", name="creature-chamber-mk01", amount=1},
      },
    },
    ["incubator-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=135},
        {type="item", name="glassworks-mk01", amount=3},
        {type="item", name="hazard-concrete", amount=52},
        {type="item", name="lead-plate", amount=27},
        {type="item", name="transport-belt", amount=109},
      },
      results = {
        {type="item", name="incubator-mk01", amount=2},
      },
    },
    ["micro-mine-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="glass", amount=40},
        {type="item", name="inductor1", amount=34},
        {type="item", name="iron-plate", amount=191},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="stone-brick", amount=119},
        {type="item", name="tar-processing-unit", amount=2},
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
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="boiler", amount=33},
        {type="item", name="copper-cable", amount=127},
        {type="item", name="copper-plate", amount=611},
        {type="item", name="electronic-circuit", amount=12},
        {type="item", name="formica", amount=2},
        {type="item", name="gunpowder", amount=162},
        {type="item", name="iron-stick", amount=41},
        {type="item", name="lead-plate", amount=175},
        {type="item", name="pipe", amount=70},
        {type="item", name="refined-concrete", amount=131},
        {type="item", name="solder", amount=2},
        {type="item", name="treated-wood", amount=62},
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
        {type="item", name="cellulose", amount=17},
        {type="item", name="concrete", amount=524},
        {type="item", name="incubator-mk01", amount=3},
        {type="item", name="lead-plate", amount=9},
        {type="item", name="pipe", amount=285},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="small-lamp", amount=7},
        {type="item", name="stone-brick", amount=323},
        {type="item", name="tin-plate", amount=5},
        {type="item", name="treated-wood", amount=8},
      },
      results = {
        {type="item", name="genlab-mk01", amount=1},
      },
    },
    ["research-center-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bolts", amount=294},
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="cellulose", amount=99},
        {type="item", name="clay-pit-mk01", amount=1},
        {type="item", name="concrete", amount=1665},
        {type="item", name="electronic-circuit", amount=54},
        {type="item", name="raw-fiber", amount=54},
        {type="item", name="soil-extractor-mk01", amount=2},
      },
      results = {
        {type="item", name="research-center-mk01", amount=2},
      },
    },
    ["slaughterhouse-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=11},
        {type="item", name="concrete", amount=159},
        {type="item", name="lab", amount=12},
        {type="item", name="lead-plate", amount=41},
        {type="item", name="pipe", amount=22},
        {type="item", name="planter-box", amount=282},
        {type="item", name="pump", amount=3},
        {type="item", name="py-underflow-valve", amount=2},
        {type="item", name="resistor1", amount=73},
        {type="item", name="sodium-hydroxide", amount=628},
        {type="item", name="tailings-dust", amount=90},
        {type="item", name="wooden-chest", amount=53},
      },
      results = {
        {type="item", name="slaughterhouse-mk01", amount=1},
      },
    },
    ["gate"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="glass", amount=8},
        {type="item", name="inductor1", amount=18},
        {type="item", name="lime", amount=2},
        {type="item", name="py-check-valve", amount=1},
        {type="item", name="soot", amount=19},
        {type="item", name="stone-furnace", amount=4},
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
        {type="item", name="wood", amount=3},
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
        {type="item", name="copper-ore", amount=2},
        {type="item", name="stone-furnace", amount=3},
      },
      results = {
        {type="item", name="stone-wall", amount=1},
      },
    },
    ["automated-screener-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=71},
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="boiler", amount=37},
        {type="item", name="concrete", amount=19},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="pipe", amount=120},
        {type="item", name="resistor1", amount=472},
        {type="item", name="soil", amount=1317},
        {type="item", name="tinned-cable", amount=34},
        {type="item", name="titanium-plate", amount=14},
      },
      results = {
        {type="item", name="automated-screener-mk01", amount=1},
      },
    },
    ["vacuum-pump-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=3},
        {type="item", name="kerogen", amount=900},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="underground-belt", amount=5},
      },
      results = {
        {type="item", name="vacuum-pump-mk01", amount=4},
      },
    },
    ["bio-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="flue-gas", amount=944},
        {type="item", name="barrel", amount=4},
        {type="item", name="seaweed", amount=4},
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
        {type="item", name="moss", amount=37},
        {type="item", name="petri-dish", amount=5},
        {type="item", name="petri-dish-bacteria", amount=2},
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
        {type="item", name="bio-sample", amount=8},
        {type="item", name="coal", amount=38},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="pipe", amount=7},
        {type="item", name="sodium-hydroxide", amount=94},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="transport-belt", amount=7},
        {type="item", name="underground-belt", amount=1},
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
        {type="item", name="moss", amount=4},
        {type="item", name="raw-borax", amount=6},
        {type="item", name="seaweed", amount=5},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=5},
      },
    },
    ["vrauks-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=17},
        {type="item", name="copper-cable", amount=14},
        {type="item", name="iron-plate", amount=26},
        {type="item", name="pipe", amount=219},
        {type="item", name="small-lamp", amount=11},
        {type="item", name="transport-belt", amount=10},
      },
      results = {
        {type="item", name="vrauks-codex", amount=1},
      },
    },
    ["vrauks"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=1645},
        {type="item", name="iron-ore", amount=447},
        {type="item", name="petri-dish-bacteria", amount=15},
        {type="item", name="pipe", amount=521},
        {type="item", name="pulp-mill-mk01", amount=3},
        {type="item", name="sodium-hydroxide", amount=61},
        {type="item", name="soot", amount=50},
        {type="item", name="vrauks-codex", amount=2},
      },
      results = {
        {type="item", name="vrauks", amount=2},
      },
    },
    ["vrauks-paddock-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=79},
        {type="item", name="botanical-nursery", amount=2},
        {type="item", name="hazard-concrete", amount=73},
        {type="item", name="inductor1", amount=12},
        {type="item", name="lead-plate", amount=24},
        {type="item", name="py-check-valve", amount=4},
        {type="item", name="refined-concrete", amount=9},
        {type="item", name="tin-plate", amount=49},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="vrauks-paddock-mk01", amount=3},
      },
    },
    ["uncaged-vrauks"] = {
      mode = "input-preserved-unmodified",
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cocoon", amount=16},
        {type="item", name="seaweed", amount=11},
        {type="item", name="sodium-hydroxide", amount=2},
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
        {type="item", name="aluminium-plate", amount=41},
        {type="item", name="bio-container", amount=4},
        {type="item", name="caged-vrauks", amount=3},
        {type="item", name="fawogae-substrate", amount=131},
        {type="item", name="naphthalene-oil-barrel", amount=2},
        {type="item", name="pipe", amount=154},
        {type="item", name="pressured-water-barrel", amount=21},
        {type="item", name="retorter", amount=1},
        {type="item", name="scrude-canister", amount=1},
        {type="item", name="soot", amount=2},
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
        {type="item", name="aluminium-plate", amount=169},
        {type="item", name="fawogae-substrate", amount=68},
        {type="item", name="py-sinkhole", amount=1},
      },
      results = {
        {type="item", name="caravan", amount=1},
      },
    },
    ["concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="fluid", name="water", amount=149},
        {type="item", name="calcium-carbide", amount=11},
        {type="item", name="copper-ore", amount=20},
        {type="item", name="log", amount=1},
        {type="item", name="raw-coal", amount=14},
        {type="item", name="small-electric-pole", amount=1},
        {type="item", name="stone", amount=33},
      },
      results = {
        {type="item", name="concrete", amount=9},
      },
    },
    ["stone-brick-2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pitch", amount=38},
        {type="item", name="gravel", amount=2},
        {type="item", name="stone", amount=4},
      },
      results = {
        {type="item", name="stone-brick", amount=4},
      },
    },
    ["hazard-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="item", name="repair-pack", amount=1},
      },
      results = {
        {type="item", name="hazard-concrete", amount=7},
      },
    },
    ["refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="iron-plate", amount=6},
        {type="item", name="pipe", amount=2},
        {type="item", name="sand", amount=9},
        {type="item", name="stone-brick", amount=19},
      },
      results = {
        {type="item", name="refined-concrete", amount=12},
      },
    },
    ["landfill"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="copper-ore", amount=57},
        {type="item", name="raw-coal", amount=127},
        {type="item", name="small-electric-pole", amount=1},
      },
      results = {
        {type="item", name="landfill", amount=2},
      },
    },
    ["refined-hazard-concrete"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="hazard-concrete", amount=8},
        {type="item", name="repair-pack", amount=1},
      },
      results = {
        {type="item", name="refined-hazard-concrete", amount=14},
      },
    },
    ["outpost"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=26},
        {type="item", name="iron-ore", amount=339},
        {type="item", name="limestone", amount=11},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="small-parts-01", amount=39},
        {type="item", name="stone-brick", amount=60},
        {type="item", name="wood-seeds", amount=16},
      },
      results = {
        {type="item", name="outpost", amount=1},
      },
    },
    ["outpost-fluid"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 6,
      ingredients = {
        {type="item", name="ash", amount=96},
        {type="item", name="distilator", amount=3},
        {type="item", name="iron-ore", amount=1028},
        {type="item", name="ore-tin", amount=192},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="raw-fiber", amount=9},
        {type="item", name="small-parts-01", amount=299},
        {type="item", name="stone-brick", amount=457},
      },
      results = {
        {type="item", name="outpost-fluid", amount=6},
      },
    },
    ["data-array"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="agar", amount=54},
        {type="item", name="aluminium-plate", amount=50},
        {type="item", name="capacitor1", amount=871},
        {type="item", name="concrete", amount=195},
        {type="item", name="glass", amount=348},
        {type="item", name="lead-plate", amount=84},
        {type="item", name="lime", amount=723},
        {type="item", name="pipe", amount=98},
        {type="item", name="pump", amount=6},
        {type="item", name="steam-engine", amount=32},
        {type="item", name="tin-plate", amount=88},
        {type="item", name="treated-wood", amount=11},
      },
      results = {
        {type="item", name="data-array", amount=2},
      },
    },
    ["creamy-latex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="copper-ore", amount=1},
        {type="item", name="moss", amount=3},
        {type="item", name="stone-furnace", amount=2},
      },
      results = {
        {type="fluid", name="creamy-latex", amount=140},
      },
    },
    ["sodium-alginate"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="native-flora", amount=15},
        {type="item", name="sand", amount=5},
        {type="item", name="wood", amount=5},
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
        {type="fluid", name="formic-acid", amount=63},
        {type="fluid", name="oxygen", amount=85},
        {type="item", name="sodium-alginate", amount=2},
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="item", name="latex-slab", amount=1},
      },
    },
    ["sap-seeds"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="sodium-alginate", amount=2},
      },
      results = {
        {type="item", name="sap-seeds", amount=3},
      },
    },
    ["latex"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=323},
        {type="fluid", name="pressured-water", amount=291},
        {type="item", name="latex-slab", amount=1},
        {type="item", name="lime", amount=22},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="item", name="latex", amount=2},
      },
    },
    ["sap-tree"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="offshore-pump", amount=2},
        {type="item", name="sodium-alginate", amount=5},
      },
      results = {
        {type="item", name="sap-tree", amount=2},
      },
    },
    ["py-check-valve"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=10},
        {type="item", name="iron-stick", amount=4},
      },
      results = {
        {type="item", name="py-check-valve", amount=1},
      },
    },
    ["py-underflow-valve"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=19},
        {type="item", name="planter-box", amount=2},
        {type="item", name="refined-hazard-concrete", amount=1},
        {type="item", name="small-electric-pole", amount=1},
        {type="item", name="soil", amount=188},
      },
      results = {
        {type="item", name="py-underflow-valve", amount=1},
      },
    },
    ["py-overflow-valve"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-nickel", amount=26},
        {type="item", name="py-check-valve", amount=1},
        {type="item", name="soot", amount=25},
        {type="item", name="stone-furnace", amount=14},
      },
      results = {
        {type="item", name="py-overflow-valve", amount=2},
      },
    },
    ["py-local-radar"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=8},
        {type="item", name="pipe", amount=14},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="py-local-radar", amount=1},
      },
    },
    ["radar"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=54},
        {type="item", name="concrete", amount=126},
        {type="item", name="copper-plate", amount=8},
        {type="item", name="inductor1", amount=6},
        {type="item", name="soil", amount=101},
        {type="item", name="tree-mk01", amount=1},
      },
      results = {
        {type="item", name="radar", amount=1},
      },
    },
    ["battery-mk00"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="scrude", amount=514},
        {type="item", name="copper-ore", amount=31},
        {type="item", name="iron-plate", amount=37},
        {type="item", name="lead-plate", amount=3},
        {type="item", name="wood", amount=28},
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
        {type="item", name="assembling-machine-1", amount=7},
        {type="item", name="boiler", amount=38},
        {type="item", name="concrete", amount=47},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="soil", amount=1361},
        {type="item", name="tinned-cable", amount=283},
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
        {type="item", name="agar", amount=26},
        {type="item", name="aluminium-plate", amount=9},
        {type="item", name="concrete", amount=58},
        {type="item", name="glass", amount=523},
        {type="item", name="gravel", amount=63},
        {type="item", name="lime", amount=347},
        {type="item", name="small-electric-pole", amount=9},
        {type="item", name="steam-engine", amount=6},
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
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="iron-plate", amount=8},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="inserter", amount=1},
      },
    },
    ["methane-co2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2.7,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=279},
        {type="fluid", name="water", amount=1170},
        {type="item", name="moondrop-seeds", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=108},
      },
    },
    ["methanal"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.86,
      ingredients = {
        {type="fluid", name="water", amount=1751},
        {type="item", name="iron-plate", amount=4},
      },
      results = {
        {type="fluid", name="methanal", amount=43},
      },
    },
    ["capacitor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="clay", amount=1},
        {type="item", name="lead-plate", amount=1},
        {type="item", name="limestone", amount=22},
      },
      results = {
        {type="item", name="capacitor1", amount=3},
      },
    },
    ["inductor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="graphite", amount=2},
        {type="item", name="ore-lead", amount=28},
      },
      results = {
        {type="item", name="inductor1", amount=8},
      },
    },
    ["resistor1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="glass", amount=1},
        {type="item", name="limestone", amount=16},
      },
      results = {
        {type="item", name="resistor1", amount=3},
      },
    },
    ["formica"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanal", amount=54},
        {type="item", name="inductor1", amount=4},
        {type="item", name="lime", amount=11},
        {type="item", name="moondrop", amount=3},
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
        {type="fluid", name="water", amount=403},
        {type="item", name="coke", amount=3},
        {type="item", name="copper-ore", amount=8},
        {type="item", name="pipe", amount=10},
        {type="item", name="stone-brick", amount=4},
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
        {type="item", name="iron-plate", amount=7},
        {type="item", name="moondrop", amount=1},
      },
      results = {
        {type="item", name="pcb1", amount=1},
      },
    },
    ["electronic-circuit"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="battery-mk00", amount=1},
        {type="item", name="coke", amount=29},
        {type="item", name="formica", amount=11},
        {type="item", name="inductor1", amount=4},
        {type="item", name="iron-plate", amount=7},
        {type="item", name="iron-stick", amount=22},
        {type="item", name="landfill", amount=2},
        {type="item", name="solder", amount=3},
      },
      results = {
        {type="item", name="electronic-circuit", amount=7},
      },
    },
    ["olefin-plant"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="capacitor1", amount=162},
        {type="item", name="cellulose", amount=47},
        {type="item", name="electrolyzer-mk01", amount=2},
        {type="item", name="gun-turret", amount=13},
        {type="item", name="py-tank-7000", amount=2},
        {type="item", name="retorter", amount=5},
        {type="item", name="small-electric-pole", amount=321},
      },
      results = {
        {type="item", name="olefin-plant", amount=2},
      },
    },
    ["reformer-mk01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13},
        {type="item", name="bolts", amount=81},
        {type="item", name="cellulose", amount=27},
        {type="item", name="concrete", amount=1184},
        {type="item", name="lime", amount=40},
        {type="item", name="soil-extractor-mk01", amount=4},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="wpu-mk01", amount=1},
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
        {type="item", name="capacitor1", amount=23},
        {type="item", name="pipe", amount=7},
        {type="item", name="soil", amount=43},
      },
      results = {
        {type="item", name="splitter", amount=1},
      },
    },
    ["moondrop-1"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=97},
        {type="item", name="moondrop-seeds", amount=4},
      },
      results = {
        {type="item", name="moondrop", amount=4},
      },
    },
    ["moondrop-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="empty-petri-dish", amount=1},
        {type="item", name="fawogae-substrate", amount=33},
        {type="item", name="moondrop-codex", amount=1},
        {type="item", name="planter-box", amount=1},
      },
      results = {
        {type="item", name="moondrop", amount=5},
      },
    },
    ["moondrop-seeds"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=24},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="fish", amount=5},
        {type="item", name="poorman-wood-fence", amount=10},
        {type="item", name="raw-fiber", amount=4},
        {type="item", name="rich-clay", amount=7},
        {type="item", name="soil", amount=457},
        {type="item", name="stone-wall", amount=7},
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
        {type="item", name="fawogae-substrate", amount=12},
        {type="item", name="flask", amount=4},
      },
      results = {
        {type="item", name="py-science-pack-1", amount=3},
      },
    },
    ["agar"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=99},
        {type="fluid", name="water", amount=767},
        {type="item", name="kerogen", amount=4},
        {type="item", name="seaweed", amount=2},
      },
      results = {
        {type="item", name="agar", amount=1},
      },
    },
    ["cellulose-00"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coal", amount=6},
        {type="item", name="limestone", amount=5},
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
        {type="item", name="gravel", amount=35},
        {type="item", name="wood", amount=8},
      },
      results = {
        {type="item", name="cellulose", amount=2},
      },
    },
    ["coke-co2"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=50},
      },
    },
    ["lime"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.905674300352984,
      ingredients = {
        {type="fluid", name="water", amount=72},
        {type="item", name="ceramic", amount=2},
        {type="item", name="coal", amount=4},
        {type="item", name="soil", amount=7},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=94},
        {type="item", name="lime", amount=9},
      },
    },
    ["dried-meat-01"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="chitin", amount=4},
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
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="petri-dish", amount=2},
        {type="item", name="sand", amount=6},
        {type="item", name="wood", amount=13},
      },
      results = {
        {type="item", name="fawogae-substrate", amount=8},
      },
    },
    ["empty-petri-dish"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=663},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=3},
      },
    },
    ["sand-void-glass"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=8},
        {type="item", name="ore-chromium", amount=2},
      },
      results = {
        {type="fluid", name="molten-glass", amount=10},
      },
    },
    ["stopper"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="methanal", amount=38},
        {type="item", name="coal", amount=2},
        {type="item", name="inductor1", amount=1},
        {type="item", name="latex", amount=1},
        {type="item", name="lime", amount=8},
        {type="item", name="moondrop", amount=5},
      },
      results = {
        {type="item", name="stopper", amount=5},
      },
    },
    ["flask"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="scrude", amount=198},
        {type="fluid", name="steam", amount=369},
        {type="item", name="iron-plate", amount=14},
        {type="item", name="stopper", amount=3},
        {type="item", name="wood", amount=27},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["petri-dish"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cellulose", amount=3},
        {type="item", name="empty-planter-box", amount=4},
      },
      results = {
        {type="item", name="petri-dish", amount=3},
      },
    },
    ["scrude-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.291777777777778,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=195},
        {type="fluid", name="syngas", amount=9},
      },
      results = {
        {type="fluid", name="condensates", amount=73},
        {type="fluid", name="heavy-oil", amount=29},
        {type="fluid", name="light-oil", amount=44},
      },
    },
    ["tar-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.202994942106166,
      ingredients = {
        {type="fluid", name="pressured-air", amount=1162},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=15},
        {type="fluid", name="creosote", amount=5},
        {type="fluid", name="middle-oil", amount=6},
        {type="fluid", name="pitch", amount=29},
      },
    },
    ["heavy-oil-to-kerosene"] = {
      mode = "kept-pruned-transformed",
      science_level = 1,
      energy_required_multiplier = 0.775,
      ingredients = {
        {type="fluid", name="flue-gas", amount=413},
      },
      results = {
        {type="fluid", name="kerosene", amount=31},
      },
    },
    ["pitch-refining"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="pressured-air", amount=2656},
        {type="fluid", name="syngas", amount=202},
      },
      results = {
        {type="fluid", name="anthracene-oil", amount=33},
        {type="fluid", name="hydrogen", amount=11},
        {type="fluid", name="light-oil", amount=22},
        {type="fluid", name="naphthalene-oil", amount=22},
        {type="item", name="coke", amount=11},
      },
    },
    ["tar-refining-tops"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.62,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=139},
        {type="fluid", name="pitch", amount=451},
        {type="item", name="lime", amount=14},
        {type="item", name="soil", amount=18},
      },
      results = {
        {type="fluid", name="carbolic-oil", amount=81},
        {type="fluid", name="light-oil", amount=81},
        {type="fluid", name="naphthalene-oil", amount=162},
      },
    },
    ["anthracene-gasoline-cracking"] = {
      mode = "repaired-to-input",
      science_level = 1,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=185},
      },
      results = {
        {type="fluid", name="gasoline", amount=20},
        {type="item", name="coke", amount=5},
      },
    },
    ["carbolic-oil-creosote"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 1.52,
      ingredients = {
        {type="fluid", name="anthracene-oil", amount=278},
        {type="fluid", name="flue-gas", amount=618},
      },
      results = {
        {type="fluid", name="creosote", amount=76},
      },
    },
    ["kerogen-extraction"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.732,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=75},
        {type="item", name="kerogen", amount=24},
      },
      results = {
        {type="fluid", name="scrude", amount=183},
      },
    },
    ["light-oil-aromatics"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="light-oil", amount=38},
      },
      results = {
        {type="fluid", name="aromatics", amount=38},
        {type="fluid", name="gasoline", amount=19},
      },
    },
    ["naphthalene-oil-creosote"] = {
      mode = "kept-transformed",
      science_level = 1,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="flue-gas", amount=367},
      },
      results = {
        {type="fluid", name="creosote", amount=24},
      },
    },
    ["barrel"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="pipe", amount=9},
      },
      results = {
        {type="item", name="barrel", amount=2},
      },
    },
    ["barrel-machine-mk01"] = {
      mode = "input-preserved-untransformed",
      science_level = 1,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=13},
        {type="item", name="copper-plate", amount=41},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="solder", amount=5},
        {type="item", name="steam-engine", amount=2},
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
        {type="fluid", name="water", amount=6071},
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
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=13},
        {type="item", name="burner-mining-drill", amount=6},
        {type="item", name="pipe", amount=57},
        {type="item", name="resistor1", amount=12},
        {type="item", name="steam-engine", amount=6},
      },
      results = {
        {type="item", name="assembling-machine-2", amount=2},
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
        {type="item", name="biomass", amount=66},
      },
      results = {
        {type="item", name="raw-coal", amount=5},
      },
    },
    ["biomass-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.08,
      ingredients = {
        {type="fluid", name="ammonia", amount=90},
        {type="fluid", name="hot-air", amount=197},
        {type="fluid", name="water-saline", amount=5967},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=432},
      },
    },
    ["chitin-to-geothermal-water"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="steam", amount=454},
        {type="item", name="brain", amount=3},
      },
      results = {
        {type="fluid", name="geothermal-water", amount=48},
      },
    },
    ["he-01"] = {
      mode = "kept-transformed",
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
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="barrel", amount=5},
        {type="item", name="soil", amount=17},
      },
      results = {
        {type="fluid", name="molten-salt", amount=80},
      },
    },
    ["coal-molten-salt-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.766,
      ingredients = {
        {type="fluid", name="water-saline", amount=8934},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=383},
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
      energy_required_multiplier = 0.966,
      ingredients = {
        {type="fluid", name="hot-air", amount=12998},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=483},
      },
    },
    ["borax-washing"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="steam", amount=245},
        {type="item", name="gunpowder", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=130},
        {type="item", name="borax", amount=13},
      },
    },
    ["diborane"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.64,
      ingredients = {
        {type="fluid", name="oxygen", amount=53},
        {type="item", name="limestone", amount=9},
      },
      results = {
        {type="fluid", name="diborane", amount=96},
      },
    },
    ["boric-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.122,
      ingredients = {
        {type="fluid", name="oxygen", amount=238},
        {type="fluid", name="steam", amount=315},
        {type="fluid", name="water", amount=322},
      },
      results = {
        {type="fluid", name="boric-acid", amount=561},
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
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.49992703663908,
      ingredients = {
        {type="fluid", name="creosote", amount=321},
        {type="fluid", name="water", amount=937},
        {type="item", name="moondrop", amount=5},
        {type="item", name="sodium-hydroxide", amount=4},
      },
      results = {
        {type="item", name="nexelit-ore", amount=2},
        {type="item", name="tailings-dust", amount=1},
      },
    },
    ["nexelit-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.777777777777778,
      ingredients = {
        {type="item", name="clean-nexelit", amount=14},
      },
      results = {
        {type="item", name="nexelit-plate", amount=14},
      },
    },
    ["soil-separation-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25999375127694,
      ingredients = {
        {type="item", name="iron-ore", amount=7},
        {type="item", name="lime", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=4},
        {type="item", name="coarse", amount=4},
        {type="item", name="limestone", amount=2},
        {type="item", name="sand", amount=16},
      },
    },
    ["coarse-classification"] = {
      mode = "repaired-to-input",
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
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="iron-stick", amount=4},
        {type="item", name="refined-concrete", amount=2},
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
        {type="fluid", name="hydrogen", amount=129},
        {type="item", name="ceramic", amount=7},
      },
      results = {
        {type="item", name="wood-fence", amount=1},
      },
    },
    ["cool-pressured-steam-2000-to-1000"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.225,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="steam", amount=159},
        {type="fluid", name="water", amount=65},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=445},
      },
    },
    ["jerky-to-phytoplankton"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="water", amount=445},
        {type="item", name="dried-meat", amount=2},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=7},
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
      energy_required_multiplier = 1.08666666666667,
      ingredients = {
        {type="fluid", name="pressured-water", amount=192},
        {type="fluid", name="steam", amount=180},
      },
      results = {
        {type="fluid", name="steam", amount=506},
      },
    },
    ["digosaurus"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=357},
        {type="item", name="raw-fiber", amount=96},
        {type="item", name="tailings-dust", amount=163},
        {type="item", name="vrauks", amount=194},
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
        {type="item", name="pipe", amount=8},
        {type="item", name="transport-belt", amount=3},
      },
      results = {
        {type="item", name="electric-mining-drill", amount=1},
      },
    },
    ["fawogae-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.104416077143045,
      ingredients = {
        {type="item", name="creamy-latex-barrel", amount=1},
        {type="item", name="meat", amount=1},
        {type="item", name="molten-glass-barrel", amount=1},
        {type="item", name="moss-gen", amount=2},
        {type="item", name="pipe", amount=21},
        {type="item", name="small-parts-01", amount=22},
        {type="item", name="sulfur", amount=1},
      },
      results = {
        {type="item", name="fawogae-codex", amount=0.104416077143045},
      },
    },
    ["ralesia-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="ceramic", amount=282},
        {type="item", name="concrete", amount=587},
        {type="item", name="copper-cable", amount=41},
        {type="item", name="pipe", amount=214},
        {type="item", name="soil-extractor-mk01", amount=1},
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
        {type="item", name="anthracene-oil-canister", amount=1},
        {type="item", name="gravel", amount=14},
        {type="item", name="iron-plate", amount=62},
        {type="item", name="naphthalene-oil-barrel", amount=1},
        {type="item", name="pipe", amount=127},
        {type="item", name="pressured-water-barrel", amount=1},
        {type="item", name="stopper", amount=2},
        {type="item", name="transport-belt", amount=12},
      },
      results = {
        {type="item", name="fbreactor-mk01", amount=2},
      },
    },
    ["geothermal-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ceramic", amount=390},
        {type="item", name="distilator", amount=3},
        {type="item", name="fiberboard", amount=47},
        {type="item", name="incubator-mk01", amount=3},
        {type="item", name="middle-oil-barrel", amount=4},
        {type="item", name="raw-fiber", amount=32},
        {type="item", name="storage-tank", amount=2},
      },
      results = {
        {type="item", name="geothermal-plant-mk01", amount=2},
      },
    },
    ["grade-1-lead"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ore-aluminium", amount=7},
      },
      results = {
        {type="item", name="grade-1-lead", amount=1},
      },
    },
    ["lead-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="grade-1-lead", amount=4},
        {type="item", name="grade-1-tin", amount=3},
      },
      results = {
        {type="item", name="lead-plate", amount=12},
      },
    },
    ["grade-1-nickel"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 1.04558476625233,
      ingredients = {
        {type="item", name="ore-tin", amount=7},
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
        {type="item", name="coal", amount=6},
        {type="item", name="grade-1-chromite", amount=2},
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
        {type="item", name="ore-aluminium", amount=8},
      },
      results = {
        {type="item", name="grade-1-ti", amount=2},
        {type="item", name="grade-2-ti", amount=1},
      },
    },
    ["grade-2-ti-crush"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.15471697631255,
      ingredients = {
        {type="item", name="ceramic", amount=1},
      },
      results = {
        {type="item", name="grade-1-ti", amount=0.0773584881562748},
        {type="item", name="stone", amount=0.15471697631255},
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
        {type="item", name="barrel", amount=2},
        {type="item", name="grade-1-ti", amount=14},
        {type="item", name="gravel", amount=4},
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
        {type="item", name="ore-tin", amount=9},
      },
      results = {
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="grade-2-tin", amount=1},
      },
    },
    ["tin-plate-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-tin", amount=14},
      },
      results = {
        {type="item", name="tin-plate", amount=10},
      },
    },
    ["grade-2-crush-tin"] = {
      mode = "repaired-to-input",
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
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.98271004380882,
      ingredients = {
        {type="item", name="iron-gear-wheel", amount=4},
      },
      results = {
        {type="item", name="grade-1-zinc", amount=2},
        {type="item", name="soil", amount=1},
        {type="item", name="stone", amount=0.948716725225885},
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
      energy_required_multiplier = 0.933333333333333,
      ingredients = {
        {type="item", name="brain", amount=1},
        {type="item", name="grade-1-zinc", amount=14},
        {type="item", name="sb-grade-02", amount=6},
      },
      results = {
        {type="item", name="zinc-plate", amount=28},
      },
    },
    ["grenade"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=104},
        {type="item", name="pipe", amount=7},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=256},
        {type="item", name="grade-1-tin", amount=1},
      },
      results = {
        {type="fluid", name="phytoplankton", amount=10},
      },
    },
    ["piercing-rounds-magazine"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="glass", amount=9},
        {type="item", name="shotgun-shell", amount=6},
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
        {type="fluid", name="vacuum", amount=218},
        {type="item", name="ash", amount=3},
        {type="item", name="gravel", amount=4},
      },
      results = {
        {type="item", name="py-asphalt", amount=1},
      },
    },
    ["py-iron-oxide"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="ceramic", amount=2},
        {type="item", name="coarse", amount=8},
      },
      results = {
        {type="item", name="py-iron-oxide", amount=1},
      },
    },
    ["py-limestone"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="pressured-air", amount=708},
        {type="fluid", name="steam", amount=70},
        {type="item", name="gunpowder", amount=2},
        {type="item", name="iron-ore", amount=13},
        {type="item", name="lime", amount=3},
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
        {type="item", name="boiler", amount=1},
        {type="item", name="cocoon", amount=50},
        {type="item", name="copper-plate", amount=8},
        {type="item", name="glass", amount=70},
      },
      results = {
        {type="item", name="py-burner", amount=1},
      },
    },
    ["py-deposit-basic"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=2},
        {type="item", name="grade-1-copper", amount=45},
        {type="item", name="heavy-oil-canister", amount=18},
        {type="item", name="iron-chest", amount=3},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="tinned-cable", amount=4},
        {type="item", name="vacuum-tube", amount=71},
      },
      results = {
        {type="item", name="py-deposit-basic", amount=1},
      },
    },
    ["py-shed-basic"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="automation-science-pack", amount=7},
        {type="item", name="pipe", amount=28},
        {type="item", name="stone", amount=17},
        {type="item", name="wood", amount=12},
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
        {type="item", name="copper-plate", amount=3},
        {type="item", name="formica", amount=1},
        {type="item", name="heavy-oil-canister", amount=16},
        {type="item", name="lead-plate", amount=5},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="tinned-cable", amount=10},
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
        {type="item", name="automation-science-pack", amount=5},
        {type="item", name="cocoon", amount=5},
        {type="item", name="duralumin", amount=38},
        {type="item", name="iron-chest", amount=1},
        {type="item", name="pipe", amount=37},
        {type="item", name="small-parts-01", amount=20},
        {type="item", name="stone", amount=99},
        {type="item", name="wood", amount=9},
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
        {type="item", name="calcium-carbide", amount=20},
        {type="item", name="coke", amount=18},
        {type="item", name="iron-stick", amount=5},
        {type="item", name="lead-plate", amount=20},
        {type="item", name="transport-belt", amount=3},
        {type="item", name="vacuum-tube", amount=1},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="rail", amount=4},
      },
    },
    ["rail-signal"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="hazard-concrete", amount=2},
        {type="item", name="heavy-oil-canister", amount=2},
        {type="item", name="small-parts-01", amount=6},
        {type="item", name="tin-plate", amount=4},
      },
      results = {
        {type="item", name="rail-signal", amount=2},
      },
    },
    ["rail-chain-signal"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tinned-cable", amount=7},
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="item", name="rail-chain-signal", amount=1},
      },
    },
    ["train-stop"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=5},
        {type="item", name="copper-plate", amount=11},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="small-parts-01", amount=38},
        {type="item", name="transport-belt", amount=11},
      },
      results = {
        {type="item", name="train-stop", amount=1},
      },
    },
    ["sb-grade-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.01023330882423,
      ingredients = {
        {type="item", name="grade-1-ti", amount=1},
      },
      results = {
        {type="item", name="iron-oxide", amount=0.309390503602209},
        {type="item", name="sb-grade-01", amount=5},
        {type="item", name="sb-grade-02", amount=3},
        {type="item", name="stone", amount=2},
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
      energy_required_multiplier = 1.91968040370059,
      ingredients = {
        {type="item", name="antimonium-ore", amount=12},
        {type="item", name="grade-1-ti", amount=1},
      },
      results = {
        {type="item", name="sb-grade-02", amount=19},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=20},
        {type="item", name="glass", amount=6},
        {type="item", name="lead-plate", amount=2},
        {type="item", name="refined-hazard-concrete", amount=9},
        {type="item", name="shotgun-shell", amount=4},
      },
      results = {
        {type="item", name="steel-furnace", amount=1},
      },
    },
    ["storage-chest"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="landfill", amount=3},
        {type="item", name="pipe", amount=4},
        {type="item", name="small-parts-01", amount=3},
        {type="item", name="vacuum-tube", amount=16},
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
        {type="item", name="ceramic", amount=120},
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
        {type="item", name="ceramic", amount=52},
        {type="item", name="lens", amount=10},
      },
      results = {
        {type="item", name="blade-mk01", amount=2},
      },
    },
    ["brake-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="fenxsb-alloy", amount=13},
        {type="item", name="glass", amount=50},
        {type="item", name="iron-plate", amount=57},
        {type="item", name="lens", amount=4},
        {type="item", name="nexelit-plate", amount=15},
        {type="item", name="pbsb-alloy", amount=12},
        {type="item", name="pipe", amount=219},
        {type="item", name="py-tank-3000", amount=2},
      },
      results = {
        {type="item", name="brake-mk01", amount=3},
      },
    },
    ["electronics-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=5},
        {type="item", name="formica", amount=6},
        {type="item", name="inductor1", amount=9},
        {type="item", name="naphthalene-oil-canister", amount=2},
        {type="item", name="ore-titanium", amount=6},
        {type="item", name="tin-plate", amount=12},
        {type="item", name="titanium-plate", amount=13},
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
        {type="item", name="lead-plate", amount=29},
        {type="item", name="transport-belt", amount=12},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="shaft-mk01", amount=1},
      },
    },
    ["utility-box-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=25},
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="grade-1-copper", amount=28},
        {type="item", name="pipe", amount=36},
        {type="item", name="planter-box", amount=2},
        {type="item", name="plastic-bar", amount=5},
        {type="item", name="stone-brick", amount=55},
        {type="item", name="tin-plate", amount=66},
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
        {type="item", name="iron-plate", amount=14},
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
        {type="item", name="duralumin", amount=9},
        {type="item", name="guts", amount=3},
        {type="item", name="lime", amount=6},
        {type="item", name="nexelit-plate", amount=198},
      },
      results = {
        {type="item", name="controler-mk01", amount=1},
      },
    },
    ["gearbox-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=18},
        {type="item", name="anemometer-mk01", amount=6},
        {type="item", name="belt", amount=1},
        {type="item", name="ceramic", amount=52},
        {type="item", name="nexelit-plate", amount=24},
        {type="item", name="small-parts-01", amount=7},
      },
      results = {
        {type="item", name="gearbox-mk01", amount=2},
      },
    },
    ["nacelle-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=7},
        {type="item", name="barrel-machine-mk01", amount=5},
        {type="item", name="belt", amount=45},
        {type="item", name="blade-mk01", amount=26},
        {type="item", name="boric-acid-barrel", amount=32},
        {type="item", name="ceramic", amount=102},
        {type="item", name="controler-mk01", amount=5},
        {type="item", name="data-array", amount=2},
        {type="item", name="diborane-barrel", amount=9},
        {type="item", name="electronic-circuit", amount=36},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="fish-oil-barrel", amount=4},
        {type="item", name="gearbox-mk01", amount=8},
        {type="item", name="outpost", amount=3},
        {type="item", name="pbsb-alloy", amount=40},
        {type="item", name="pipe", amount=1015},
        {type="item", name="py-science-pack-1", amount=3},
        {type="item", name="scrude-barrel", amount=16},
        {type="item", name="steam-engine", amount=12},
        {type="item", name="tower-mk01", amount=3},
      },
      results = {
        {type="item", name="nacelle-mk01", amount=3},
      },
    },
    ["tower-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=269},
        {type="item", name="lead-plate", amount=52},
        {type="item", name="steam-engine", amount=1},
      },
      results = {
        {type="item", name="tower-mk01", amount=1},
      },
    },
    ["yaw-drive-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="belt", amount=30},
        {type="item", name="ceramic", amount=48},
        {type="item", name="copper-plate", amount=158},
        {type="item", name="graphite", amount=362},
        {type="item", name="lead-plate", amount=244},
        {type="item", name="pipe", amount=265},
        {type="item", name="small-parts-01", amount=12},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="titanium-plate", amount=51},
        {type="item", name="vacuum-tube", amount=11},
        {type="item", name="vane-mk01", amount=4},
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
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="ceramic", amount=36},
      },
      results = {
        {type="item", name="rotor-mk01", amount=1},
      },
    },
    ["animal-sample-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="steam", amount=2723},
        {type="fluid", name="water-saline", amount=861},
        {type="item", name="anthracene-oil-barrel", amount=5},
        {type="item", name="molten-aluminium-barrel", amount=3},
        {type="item", name="ore-lead", amount=209},
        {type="item", name="py-asphalt", amount=21},
        {type="item", name="py-overflow-valve", amount=5},
        {type="item", name="retrovirus", amount=3},
      },
      results = {
        {type="item", name="animal-sample-01", amount=4},
      },
    },
    ["bio-sample01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="hydrogen", amount=3750},
        {type="item", name="bones", amount=15},
        {type="item", name="chromite-sand", amount=2},
        {type="item", name="iron-stick", amount=6},
        {type="item", name="lime", amount=8},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="petri-dish", amount=2},
        {type="item", name="ralesia", amount=11},
        {type="item", name="urea", amount=2},
        {type="item", name="zinc-plate", amount=7},
      },
      results = {
        {type="item", name="bio-sample01", amount=6},
      },
    },
    ["equipment-chassi"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="creosote", amount=116},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="small-parts-01", amount=7},
        {type="item", name="tin-plate", amount=13},
      },
      results = {
        {type="item", name="equipment-chassi", amount=2},
      },
    },
    ["ground-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="fluid", name="hydrogen", amount=1311},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="sand", amount=2},
      },
      results = {
        {type="item", name="ground-sample01", amount=18},
      },
    },
    ["rich-clay"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="fluid", name="steam", amount=138},
        {type="fluid", name="vacuum", amount=271},
        {type="item", name="ash", amount=4},
        {type="item", name="coal-dust", amount=6},
        {type="item", name="gravel", amount=16},
      },
      results = {
        {type="item", name="rich-clay", amount=11},
      },
    },
    ["sand-casting"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="creosote", amount=17},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="item", name="sand-casting", amount=2},
      },
    },
    ["alien-sample01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="black-liquor", amount=47},
        {type="item", name="calcium-carbide", amount=51},
        {type="item", name="equipment-chassi", amount=4},
        {type="item", name="fish", amount=1},
      },
      results = {
        {type="item", name="alien-sample01", amount=7},
      },
    },
    ["lab-instrument"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=1},
        {type="item", name="belt", amount=14},
        {type="item", name="capacitor1", amount=6},
        {type="item", name="carbolic-oil-canister", amount=1},
        {type="item", name="equipment-chassi", amount=1},
        {type="item", name="gasoline-barrel", amount=7},
        {type="item", name="lens", amount=1},
        {type="item", name="methane-canister", amount=2},
        {type="item", name="pipe", amount=15},
      },
      results = {
        {type="item", name="lab-instrument", amount=2},
      },
    },
    ["grade-1-chromite"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.04853468955712,
      ingredients = {
        {type="item", name="ore-tin", amount=7},
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
        {type="fluid", name="water", amount=558},
        {type="item", name="coke", amount=5},
        {type="item", name="gravel", amount=16},
        {type="item", name="ground-sample01", amount=1},
      },
      results = {
        {type="item", name="chromium", amount=3},
      },
    },
    ["tier-0-chromite-sand"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-nickel", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=3},
      },
    },
    ["medium-electric-pole"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=272},
        {type="item", name="boron-trioxide", amount=2},
        {type="item", name="lime", amount=5},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="stone", amount=18},
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
        {type="item", name="ore-aluminium", amount=4},
        {type="item", name="ore-zinc", amount=7},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-aluminium", amount=2},
      },
    },
    ["molten-aluminium-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="oxygen", amount=181},
        {type="item", name="coke", amount=3},
        {type="item", name="copper-ore", amount=13},
        {type="item", name="limestone", amount=11},
        {type="item", name="sodium-hydroxide", amount=1},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=12},
      },
    },
    ["aluminium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=160},
        {type="fluid", name="steam", amount=617},
      },
      results = {
        {type="item", name="aluminium-plate", amount=80},
      },
    },
    ["hotair-aluminium-plate-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.555555555555556,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=51},
        {type="fluid", name="molten-iron", amount=11},
      },
      results = {
        {type="item", name="aluminium-plate", amount=35},
      },
    },
    ["crushing-quartz"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-tin", amount=3},
        {type="item", name="ore-zinc", amount=3},
      },
      results = {
        {type="item", name="crushed-quartz", amount=2},
        {type="item", name="stone", amount=1},
      },
    },
    ["sand-classification"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.99838650407978,
      ingredients = {
        {type="item", name="ceramic", amount=8},
        {type="item", name="sand", amount=15},
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
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="creosote", amount=12},
        {type="item", name="limestone", amount=1},
        {type="item", name="ore-quartz", amount=12},
      },
      results = {
        {type="fluid", name="molten-glass", amount=42},
      },
    },
    ["hotair-molten-glass"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=96},
        {type="fluid", name="molten-glass", amount=49},
      },
      results = {
        {type="item", name="glass", amount=7},
      },
    },
    ["antimony-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=62},
        {type="item", name="lab", amount=15},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="titanium-plate", amount=59},
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
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="copper-cable", amount=742},
        {type="item", name="inductor1", amount=120},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="lab", amount=3},
        {type="item", name="nexelit-plate", amount=40},
        {type="item", name="plastic-bar", amount=31},
        {type="item", name="py-tank-3000", amount=4},
        {type="item", name="steam-engine", amount=5},
        {type="item", name="steel-plate", amount=24},
        {type="item", name="stone-brick", amount=499},
        {type="item", name="titanium-plate", amount=35},
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
        {type="item", name="bio-container", amount=31},
        {type="item", name="bio-sample", amount=17},
        {type="item", name="fawogae-codex", amount=1},
        {type="item", name="phytoplankton-barrel", amount=359},
        {type="item", name="py-science-pack-1", amount=34},
        {type="item", name="tower-mk01", amount=1},
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
        {type="item", name="capacitor1", amount=60},
        {type="item", name="concrete", amount=714},
        {type="item", name="duralumin", amount=43},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="grade-1-tin", amount=40},
        {type="item", name="inductor1", amount=62},
        {type="item", name="iron-plate", amount=99},
        {type="item", name="latex", amount=99},
        {type="item", name="petri-dish", amount=14},
        {type="item", name="pressured-water-barrel", amount=30},
        {type="item", name="resistor1", amount=1197},
        {type="item", name="titanium-plate", amount=273},
      },
      results = {
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
      },
    },
    ["py-oil-powerplant-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="automated-factory-mk01", amount=2},
        {type="item", name="concrete", amount=405},
        {type="item", name="duralumin", amount=25},
        {type="item", name="engine-unit", amount=9},
        {type="item", name="fluid-drill-mk01", amount=4},
        {type="item", name="glass", amount=1041},
        {type="item", name="grade-1-chromite", amount=132},
        {type="item", name="heavy-oil-barrel", amount=21},
        {type="item", name="inserter", amount=7},
        {type="item", name="latex", amount=181},
        {type="item", name="lead-plate", amount=1794},
        {type="item", name="naphthalene-oil-canister", amount=12},
        {type="item", name="nexelit-plate", amount=754},
        {type="item", name="pcb1", amount=83},
        {type="item", name="pressured-water-barrel", amount=18},
        {type="item", name="resistor1", amount=5614},
        {type="item", name="sap-seeds", amount=46},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="steel-plate", amount=24},
        {type="item", name="titanium-plate", amount=511},
        {type="item", name="tree-mk01", amount=64},
        {type="item", name="upgrader-mk01", amount=1},
        {type="item", name="vane-mk01", amount=7},
      },
      results = {
        {type="item", name="py-oil-powerplant-mk01", amount=3},
      },
    },
    ["steam-turbine-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="engine-unit", amount=4},
        {type="item", name="lead-plate", amount=100},
        {type="item", name="moondrop-codex", amount=7},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="steam-engine", amount=29},
        {type="item", name="steel-plate", amount=62},
        {type="item", name="titanium-plate", amount=238},
        {type="item", name="tower-mk01", amount=1},
        {type="item", name="vane-mk01", amount=17},
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
        {type="item", name="ceramic", amount=1022},
        {type="item", name="concrete", amount=24},
        {type="item", name="controler-mk01", amount=2},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="engine-unit", amount=67},
        {type="item", name="fenxsb-alloy", amount=23},
        {type="item", name="grade-1-tin", amount=172},
        {type="item", name="grade-2-zinc", amount=272},
        {type="item", name="nexelit-plate", amount=285},
        {type="item", name="pbsb-alloy", amount=4},
        {type="item", name="raw-fiber", amount=87},
        {type="item", name="rotor-mk01", amount=2},
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
        {type="item", name="aromatics-canister", amount=6},
        {type="item", name="boric-acid-barrel", amount=151},
        {type="item", name="carbolic-oil-barrel", amount=13},
        {type="item", name="carbon-black", amount=64},
        {type="item", name="cocoon", amount=255},
        {type="item", name="concrete-wall", amount=29},
        {type="item", name="creosote-barrel", amount=6},
        {type="item", name="diborane-barrel", amount=41},
        {type="item", name="display-panel", amount=25},
        {type="item", name="empty-planter-box", amount=80},
        {type="item", name="fawogae-plantation-mk01", amount=1},
        {type="item", name="fish-oil-barrel", amount=48},
        {type="item", name="grade-2-copper", amount=107},
        {type="item", name="grade-3-ti", amount=26},
        {type="item", name="heavy-oil-barrel", amount=31},
        {type="item", name="kerogen", amount=1787},
        {type="item", name="moss-farm-mk01", amount=1},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="sb-grade-02", amount=4144},
        {type="item", name="steel-plate", amount=24},
        {type="item", name="stopper", amount=208},
        {type="item", name="tailings-barrel", amount=10},
        {type="item", name="vacuum-tube", amount=11},
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
        {type="item", name="acetylene-barrel", amount=111},
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="capacitor1", amount=1556},
        {type="item", name="concrete", amount=1744},
        {type="item", name="engine-unit", amount=38},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="iron-plate", amount=2441},
        {type="item", name="moondrop-codex", amount=3},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="steam-engine", amount=44},
        {type="item", name="steel-plate", amount=239},
        {type="item", name="tall-oil-barrel", amount=3},
        {type="item", name="titanium-plate", amount=91},
        {type="item", name="tower-mk01", amount=3},
        {type="item", name="vane-mk01", amount=65},
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
        {type="item", name="inductor1", amount=37},
        {type="item", name="steam-engine", amount=1},
        {type="item", name="vacuum-barrel", amount=1},
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
        {type="item", name="creamy-latex-barrel", amount=1},
        {type="item", name="light-oil-canister", amount=5},
        {type="item", name="lime", amount=21},
        {type="item", name="molten-glass-barrel", amount=4},
        {type="item", name="planter-box", amount=10},
      },
      results = {
        {type="item", name="constant-combinator", amount=2},
      },
    },
    ["decider-combinator"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="guts", amount=29},
        {type="item", name="lime", amount=66},
        {type="item", name="pipe", amount=6},
      },
      results = {
        {type="item", name="decider-combinator", amount=1},
      },
    },
    ["display-panel"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="tinned-cable", amount=4},
        {type="item", name="wood", amount=22},
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="item", name="display-panel", amount=1},
      },
    },
    ["power-switch"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="incubator-mk01", amount=2},
        {type="item", name="middle-oil-barrel", amount=24},
      },
      results = {
        {type="item", name="power-switch", amount=3},
      },
    },
    ["programmable-speaker"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="biomass", amount=61},
        {type="item", name="guts", amount=3},
        {type="item", name="inductor1", amount=22},
        {type="item", name="iron-stick", amount=10},
        {type="item", name="lime", amount=7},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="tinned-cable", amount=39},
      },
      results = {
        {type="item", name="programmable-speaker", amount=3},
      },
    },
    ["selector-combinator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=20894},
        {type="item", name="coal", amount=1932},
        {type="item", name="creamy-latex-barrel", amount=3},
        {type="item", name="duralumin", amount=15},
        {type="item", name="moss-gen", amount=2},
      },
      results = {
        {type="item", name="selector-combinator", amount=1},
      },
    },
    ["fiberboard"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.566666666666667,
      ingredients = {
        {type="fluid", name="water", amount=329},
        {type="item", name="moondrop", amount=2},
        {type="item", name="sodium-hydroxide", amount=1},
        {type="item", name="treated-wood", amount=3},
      },
      results = {
        {type="fluid", name="black-liquor", amount=6},
        {type="fluid", name="tall-oil", amount=9},
        {type="item", name="fiberboard", amount=2},
      },
    },
    ["urea-decomposition"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=318},
        {type="item", name="dried-meat", amount=5},
        {type="item", name="urea", amount=8},
      },
      results = {
        {type="fluid", name="ammonia", amount=30},
        {type="fluid", name="cyanic-acid", amount=30},
      },
    },
    ["black-liquor"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.439791157107328,
      ingredients = {
        {type="fluid", name="black-liquor", amount=34},
        {type="fluid", name="steam", amount=353},
        {type="fluid", name="water", amount=469},
      },
      results = {
        {type="fluid", name="acetone", amount=22},
        {type="fluid", name="aromatics", amount=43},
      },
    },
    ["cyanic-acid-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.41006704114637,
      ingredients = {
        {type="fluid", name="ammonia", amount=143},
        {type="fluid", name="steam", amount=1795},
        {type="item", name="coal", amount=19},
        {type="item", name="urea", amount=5},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=141},
        {type="fluid", name="hydrogen", amount=71},
      },
    },
    ["melamine"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="ammonia", amount=8},
        {type="fluid", name="cyanic-acid", amount=19},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=18},
        {type="fluid", name="muddy-sludge", amount=30},
        {type="item", name="melamine", amount=12},
      },
    },
    ["cooling-water"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.0625,
      ingredients = {
        {type="fluid", name="pressured-water", amount=216},
        {type="fluid", name="steam", amount=37},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="water", amount=425},
      },
    },
    ["flue-gas-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.0133333333333333,
      ingredients = {
        {type="fluid", name="water", amount=5},
      },
      results = {
        {type="fluid", name="flue-gas", amount=2},
      },
    },
    ["flue-gas-3"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.06,
      ingredients = {
        {type="fluid", name="hot-air", amount=48},
        {type="item", name="biomass", amount=6},
        {type="item", name="raw-coal", amount=3},
      },
      results = {
        {type="fluid", name="flue-gas", amount=212},
      },
    },
    ["cracker-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain", amount=1},
        {type="item", name="dried-meat", amount=3},
        {type="item", name="inductor1", amount=5},
        {type="item", name="meat", amount=240},
        {type="item", name="resistor1", amount=232},
        {type="item", name="small-parts-01", amount=11},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="steel-furnace", amount=1},
        {type="item", name="stone-brick", amount=14},
        {type="item", name="stone-furnace", amount=5},
        {type="item", name="zinc-plate", amount=7},
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
        {type="item", name="aluminium-plate", amount=29},
        {type="item", name="ceramic", amount=528},
        {type="item", name="distilator", amount=3},
        {type="item", name="duralumin", amount=72},
        {type="item", name="glass", amount=15},
        {type="item", name="pitch-barrel", amount=5},
      },
      results = {
        {type="item", name="heavy-oil-refinery-mk01", amount=1},
      },
    },
    ["gas-refinery-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=16},
        {type="item", name="copper-plate", amount=182},
        {type="item", name="fiberboard", amount=3},
        {type="item", name="glassworks-mk01", amount=1},
        {type="item", name="intermetallics", amount=19},
        {type="item", name="oxygen-barrel", amount=20},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=54},
        {type="item", name="tailings-barrel", amount=1},
        {type="item", name="tinned-cable", amount=38},
      },
      results = {
        {type="item", name="gas-refinery-mk01", amount=1},
      },
    },
    ["upgrader-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="ceramic", amount=580},
        {type="item", name="eaf-mk01", amount=2},
        {type="item", name="gasifier", amount=2},
        {type="item", name="glass", amount=929},
        {type="item", name="grade-1-chromite", amount=40},
        {type="item", name="iron-plate", amount=353},
        {type="item", name="lead-plate", amount=29},
        {type="item", name="sap-seeds", amount=14},
        {type="item", name="steam-engine", amount=12},
        {type="item", name="tar-processing-unit", amount=9},
        {type="item", name="tinned-cable", amount=273},
        {type="item", name="titanium-plate", amount=22},
        {type="item", name="vitreloy", amount=20},
      },
      results = {
        {type="item", name="upgrader-mk01", amount=3},
      },
    },
    ["earth-bear-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=52},
        {type="item", name="fawogae-codex", amount=3},
        {type="item", name="moss-gen", amount=12},
        {type="item", name="py-science-pack-1", amount=109},
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
        {type="item", name="automation-science-pack", amount=93},
        {type="item", name="bio-sample", amount=27},
        {type="item", name="cottongut-codex", amount=1},
      },
      results = {
        {type="item", name="earth-flower-sample", amount=1},
      },
    },
    ["earth-shroom-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=1368},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="moss-gen", amount=77},
        {type="item", name="phytoplankton-barrel", amount=3},
        {type="item", name="ralesia-codex", amount=2},
      },
      results = {
        {type="item", name="earth-shroom-sample", amount=2},
      },
    },
    ["earth-mouse-sample"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coke", amount=4914},
        {type="item", name="moss-gen", amount=109},
      },
      results = {
        {type="item", name="earth-mouse-sample", amount=1},
      },
    },
    ["molten-iron-05"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=169},
        {type="item", name="iron-ore", amount=7},
        {type="item", name="ore-aluminium", amount=1},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="fluid", name="molten-iron", amount=10},
      },
    },
    ["hotair-iron-plate-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.81333333333333,
      ingredients = {
        {type="fluid", name="molten-iron", amount=189},
        {type="item", name="coarse", amount=3},
      },
      results = {
        {type="item", name="iron-plate", amount=136},
      },
    },
    ["iron-plate-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="fluid", name="molten-iron", amount=17},
        {type="item", name="clay", amount=2},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="item", name="iron-plate", amount=12},
      },
    },
    ["mechanical-parts-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="belt", amount=10},
        {type="item", name="brake-mk01", amount=4},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="electronics-mk01", amount=6},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="pbsb-alloy", amount=13},
        {type="item", name="phytoplankton-barrel", amount=4},
        {type="item", name="pipe", amount=219},
        {type="item", name="steam-engine", amount=6},
      },
      results = {
        {type="item", name="mechanical-parts-01", amount=9},
      },
    },
    ["sb-oxide-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="water", amount=1206},
        {type="item", name="plastic-bar", amount=3},
        {type="item", name="sb-grade-03", amount=6},
      },
      results = {
        {type="item", name="sb-oxide", amount=4},
      },
    },
    ["pbsb-alloy"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="ceramic", amount=8},
        {type="item", name="lead-plate", amount=11},
        {type="item", name="pipe", amount=18},
        {type="item", name="sb-oxide", amount=2},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=3},
      },
    },
    ["battery-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="hydrogen", amount=9187},
        {type="item", name="iron-stick", amount=15},
        {type="item", name="lime", amount=7},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="zinc-plate", amount=7},
      },
      results = {
        {type="item", name="battery-mk01", amount=3},
      },
    },
    ["accumulator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=723},
        {type="item", name="raw-fiber", amount=360},
      },
      results = {
        {type="item", name="accumulator", amount=1},
      },
    },
    ["fenxsb-alloy-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="ceramic", amount=3},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="pipe", amount=7},
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
        {type="item", name="glass", amount=11},
        {type="item", name="iron-plate", amount=8},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="pipe", amount=35},
        {type="item", name="titanium-plate", amount=4},
      },
      results = {
        {type="item", name="vitreloy", amount=2},
      },
    },
    ["intermetallics"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coke", amount=180},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="intermetallics", amount=2},
      },
    },
    ["ball-mill-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=4},
        {type="item", name="cage", amount=1},
        {type="item", name="duralumin", amount=30},
        {type="item", name="gun-turret", amount=4},
        {type="item", name="lead-plate", amount=119},
        {type="item", name="ore-chromium", amount=292},
        {type="item", name="pitch-barrel", amount=1},
        {type="item", name="pitch-canister", amount=1},
        {type="item", name="plastic-bar", amount=16},
        {type="item", name="repair-pack", amount=1},
        {type="item", name="scrude-barrel", amount=1},
        {type="item", name="wood-seedling", amount=14},
      },
      results = {
        {type="item", name="ball-mill-mk01", amount=1},
      },
    },
    ["chemical-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="agar", amount=6},
        {type="item", name="fluid-drill-mk01", amount=1},
        {type="item", name="grade-1-copper", amount=32},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lead-plate", amount=32},
        {type="item", name="lens", amount=7},
        {type="item", name="tinned-cable", amount=34},
        {type="item", name="transport-belt", amount=5},
      },
      results = {
        {type="item", name="chemical-plant-mk01", amount=1},
      },
    },
    ["classifier"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="inductor1", amount=82},
        {type="item", name="iron-plate", amount=23},
        {type="item", name="small-parts-01", amount=58},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="stone", amount=196},
        {type="item", name="underground-belt", amount=5},
      },
      results = {
        {type="item", name="classifier", amount=1},
      },
    },
    ["rectisol"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="acidgas-barrel", amount=2},
        {type="item", name="barrel", amount=22},
        {type="item", name="fiberboard", amount=4},
        {type="item", name="fish", amount=9},
        {type="item", name="gun-turret", amount=8},
        {type="item", name="lime", amount=403},
        {type="item", name="pbsb-alloy", amount=46},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="transport-belt", amount=13},
        {type="item", name="vitreloy", amount=2},
      },
      results = {
        {type="item", name="rectisol", amount=2},
      },
    },
    ["automated-factory-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="gearbox-mk01", amount=4},
        {type="item", name="glass", amount=599},
        {type="item", name="inductor1", amount=158},
        {type="item", name="inserter", amount=13},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="pipe", amount=130},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="automated-factory-mk01", amount=3},
      },
    },
    ["fluid-drill-mk02"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=25},
        {type="item", name="creamy-latex-barrel", amount=9},
        {type="item", name="inductor1", amount=73},
        {type="item", name="lab", amount=6},
        {type="item", name="molten-glass-barrel", amount=38},
        {type="item", name="pipe", amount=221},
        {type="item", name="sap-extractor-mk01", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="soot", amount=39},
        {type="item", name="sulfur", amount=4},
        {type="item", name="titanium-plate", amount=23},
      },
      results = {
        {type="item", name="fluid-drill-mk02", amount=2},
      },
    },
    ["bof-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=7},
        {type="item", name="resistor1", amount=192},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="steel-furnace", amount=1},
        {type="item", name="stone-furnace", amount=14},
      },
      results = {
        {type="item", name="bof-mk01", amount=1},
      },
    },
    ["casting-unit-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=1},
        {type="item", name="duralumin", amount=7},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="grade-2-copper", amount=52},
        {type="item", name="pipe", amount=37},
        {type="item", name="scrude-barrel", amount=1},
        {type="item", name="soot", amount=2},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="stone-furnace", amount=60},
        {type="item", name="tar-barrel", amount=2},
      },
      results = {
        {type="item", name="casting-unit-mk01", amount=1},
      },
    },
    ["eaf-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="distilator", amount=1},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="inductor1", amount=96},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="lead-plate", amount=26},
        {type="item", name="pbsb-alloy", amount=17},
        {type="item", name="planter-box", amount=7},
        {type="item", name="small-parts-01", amount=58},
        {type="item", name="steel-plate", amount=81},
        {type="item", name="stone", amount=1551},
        {type="item", name="tinned-cable", amount=147},
        {type="item", name="underground-belt", amount=5},
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
        {type="item", name="ceramic", amount=242},
        {type="item", name="eaf-mk01", amount=1},
        {type="item", name="gasifier", amount=2},
        {type="item", name="inductor1", amount=34},
        {type="item", name="petri-dish", amount=8},
        {type="item", name="steam-engine", amount=31},
        {type="item", name="tinned-cable", amount=292},
        {type="item", name="wood-fence", amount=12},
      },
      results = {
        {type="item", name="hydroclassifier-mk01", amount=2},
      },
    },
    ["impact-crusher-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="crushed-coal", amount=12},
        {type="item", name="distilator", amount=2},
        {type="item", name="duralumin", amount=34},
        {type="item", name="glass", amount=89},
        {type="item", name="grade-2-copper", amount=16},
        {type="item", name="inductor1", amount=43},
        {type="item", name="pbsb-alloy", amount=5},
        {type="item", name="pipe", amount=197},
        {type="item", name="stone", amount=124},
        {type="item", name="syngas-barrel", amount=4},
        {type="item", name="vrauks", amount=1},
        {type="item", name="washer", amount=2},
      },
      results = {
        {type="item", name="impact-crusher-mk01", amount=1},
      },
    },
    ["scrubber-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-plate", amount=6},
        {type="item", name="crushed-coal", amount=42},
        {type="item", name="duralumin", amount=32},
        {type="item", name="fiberboard", amount=2},
        {type="item", name="lens", amount=2},
        {type="item", name="pipe", amount=753},
        {type="item", name="stone", amount=79},
        {type="item", name="syngas-barrel", amount=15},
        {type="item", name="tinned-cable", amount=4},
      },
      results = {
        {type="item", name="scrubber-mk01", amount=1},
      },
    },
    ["flotation-cell-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="engine-unit", amount=14},
        {type="item", name="lab", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="tinned-cable", amount=38},
        {type="item", name="titanium-plate", amount=47},
      },
      results = {
        {type="item", name="flotation-cell-mk01", amount=2},
      },
    },
    ["cargo-wagon"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="bio-container", amount=1},
        {type="item", name="bolts", amount=23},
        {type="item", name="carbolic-oil-barrel", amount=13},
        {type="item", name="coal-gas-canister", amount=12},
        {type="item", name="copper-cable", amount=444},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="glass", amount=28},
        {type="item", name="grade-2-copper", amount=107},
        {type="item", name="iron-plate", amount=21},
        {type="item", name="poorman-wood-fence", amount=4},
        {type="item", name="processed-iron-ore", amount=104},
        {type="item", name="sand-casting", amount=75},
        {type="item", name="tailings-barrel", amount=10},
        {type="item", name="titanium-plate", amount=47},
        {type="item", name="vacuum-barrel", amount=3},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="cargo-wagon", amount=1},
      },
    },
    ["fluid-wagon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aromatics-canister", amount=1},
        {type="item", name="display-panel", amount=2},
        {type="item", name="heavy-oil-barrel", amount=24},
        {type="item", name="kerogen", amount=444},
        {type="item", name="py-tank-1500", amount=1},
        {type="item", name="sb-grade-02", amount=1029},
        {type="item", name="steel-plate", amount=18},
        {type="item", name="stopper", amount=52},
      },
      results = {
        {type="item", name="fluid-wagon", amount=1},
      },
    },
    ["locomotive"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="brake-mk01", amount=3},
        {type="item", name="capacitor1", amount=29},
        {type="item", name="ceramic", amount=470},
        {type="item", name="chitin", amount=3},
        {type="item", name="formic-acid-barrel", amount=7},
        {type="item", name="gearbox-mk01", amount=6},
        {type="item", name="glass", amount=373},
        {type="item", name="heavy-oil-barrel", amount=2},
        {type="item", name="inductor1", amount=31},
        {type="item", name="inserter", amount=3},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="iron-plate", amount=46},
        {type="item", name="jaw-crusher", amount=2},
        {type="item", name="offshore-pump", amount=52},
        {type="item", name="pipe", amount=206},
        {type="item", name="tailings-barrel", amount=17},
        {type="item", name="utility-box-mk01", amount=2},
        {type="item", name="vrauks-codex", amount=2},
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
        {type="item", name="burner-inserter", amount=2},
        {type="item", name="copper-cable", amount=245},
        {type="item", name="lab", amount=1},
        {type="item", name="plastic-bar", amount=32},
        {type="item", name="steel-plate", amount=21},
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
        {type="item", name="aluminium-plate", amount=55},
        {type="item", name="bolts", amount=13},
        {type="item", name="coke", amount=58},
        {type="item", name="fenxsb-alloy", amount=13},
        {type="item", name="guts", amount=75},
        {type="item", name="inductor1", amount=90},
        {type="item", name="lime", amount=168},
        {type="item", name="nexelit-plate", amount=13},
        {type="item", name="pipe", amount=6},
        {type="item", name="zogna-bacteria-barrel", amount=1},
      },
      results = {
        {type="item", name="fawogae-plantation-mk01", amount=2},
      },
    },
    ["prandium-lab-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="burner-inserter", amount=3},
        {type="item", name="capacitor1", amount=171},
        {type="item", name="coarse", amount=7},
        {type="item", name="copper-plate", amount=55},
        {type="item", name="fiberboard", amount=17},
        {type="item", name="grade-1-tin", amount=15},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="lens", amount=17},
        {type="item", name="nexelit-plate", amount=37},
        {type="item", name="pipe", amount=374},
        {type="item", name="steel-plate", amount=21},
        {type="item", name="tinned-cable", amount=2},
        {type="item", name="titanium-plate", amount=13},
        {type="item", name="treated-wood", amount=23},
        {type="item", name="vane-mk01", amount=5},
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
        {type="item", name="coarse", amount=48},
        {type="item", name="copper-plate", amount=45},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="fiberboard", amount=111},
        {type="item", name="iron-chest", amount=4},
        {type="item", name="lens", amount=13},
        {type="item", name="steel-plate", amount=17},
        {type="item", name="treated-wood", amount=48},
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
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="grade-1-chromite", amount=441},
        {type="item", name="inductor1", amount=546},
        {type="item", name="intermetallics", amount=4},
        {type="item", name="naphthalene-oil-canister", amount=12},
        {type="item", name="offshore-pump", amount=13},
        {type="item", name="pbsb-alloy", amount=6},
        {type="item", name="petri-dish", amount=48},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="sap-extractor-mk01", amount=3},
        {type="item", name="sap-seeds", amount=153},
        {type="item", name="small-electric-pole", amount=205},
        {type="item", name="stone-brick", amount=309},
        {type="item", name="titanium-plate", amount=205},
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
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="duralumin", amount=4},
        {type="item", name="glass", amount=161},
        {type="item", name="inductor1", amount=131},
        {type="item", name="lead-plate", amount=61},
        {type="item", name="pipe", amount=185},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="steel-plate", amount=13},
        {type="item", name="tinned-cable", amount=23},
      },
      results = {
        {type="item", name="heavy-armor", amount=1},
      },
    },
    ["mixer-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=46},
        {type="item", name="intermetallics", amount=6},
        {type="item", name="lead-plate", amount=94},
        {type="item", name="py-tank-6500", amount=1},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="tinned-cable", amount=96},
      },
      results = {
        {type="item", name="mixer-mk01", amount=1},
      },
    },
    ["py-heat-exchanger"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=109},
        {type="item", name="automated-factory-mk01", amount=1},
        {type="item", name="duralumin", amount=16},
        {type="item", name="fish", amount=9},
        {type="item", name="py-tank-7000", amount=1},
        {type="item", name="retrovirus", amount=3},
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
        {type="item", name="aluminium-plate", amount=11},
        {type="item", name="burner-mining-drill", amount=1},
        {type="item", name="ceramic", amount=654},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="pipe", amount=183},
        {type="item", name="soil-extractor-mk01", amount=1},
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
        {type="item", name="aluminium-plate", amount=111},
        {type="item", name="copper-cable", amount=93},
        {type="item", name="electronics-mk01", amount=3},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="grade-1-copper", amount=29},
        {type="item", name="lead-plate", amount=19},
        {type="item", name="lens", amount=47},
        {type="item", name="meat", amount=209},
        {type="item", name="piercing-rounds-magazine", amount=8},
        {type="item", name="pressured-water-barrel", amount=11},
        {type="item", name="sap-extractor-mk01", amount=2},
        {type="item", name="tinned-cable", amount=93},
        {type="item", name="transport-belt", amount=35},
      },
      results = {
        {type="item", name="atomizer-mk01", amount=2},
      },
    },
    ["bio-reactor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=55},
        {type="item", name="boiler", amount=9},
        {type="item", name="duralumin", amount=33},
        {type="item", name="fish", amount=12},
        {type="item", name="mixer-mk01", amount=1},
        {type="item", name="nexelit-plate", amount=397},
        {type="item", name="pbsb-alloy", amount=6},
      },
      results = {
        {type="item", name="bio-reactor-mk01", amount=1},
      },
    },
    ["plankton-farm"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="boiler", amount=27},
        {type="item", name="coal-gas-canister", amount=6},
        {type="item", name="condensates-canister", amount=2},
        {type="item", name="copper-plate", amount=38},
        {type="item", name="duralumin", amount=49},
        {type="item", name="iron-plate", amount=280},
        {type="item", name="lead-plate", amount=17},
        {type="item", name="light-oil-canister", amount=33},
        {type="item", name="oxygen-barrel", amount=13},
        {type="item", name="pump", amount=3},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="tinned-cable", amount=67},
      },
      results = {
        {type="item", name="plankton-farm", amount=2},
      },
    },
    ["spore-collector-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="auog", amount=1},
        {type="item", name="burner-mining-drill", amount=4},
        {type="item", name="carbolic-oil-barrel", amount=1},
        {type="item", name="ceramic", amount=266},
        {type="item", name="concrete", amount=216},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=86},
        {type="item", name="electronic-circuit", amount=11},
        {type="item", name="equipment-chassi", amount=1},
        {type="item", name="gasifier", amount=1},
        {type="item", name="glass", amount=18},
        {type="item", name="gravel", amount=91},
        {type="item", name="intermetallics", amount=5},
        {type="item", name="lab", amount=2},
        {type="item", name="pipe", amount=21},
        {type="item", name="pitch-barrel", amount=6},
      },
      results = {
        {type="item", name="spore-collector-mk01", amount=2},
      },
    },
    ["compost-plant-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=1040},
        {type="item", name="naphthalene-oil-canister", amount=11},
        {type="item", name="offshore-pump", amount=94},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="sap-extractor-mk01", amount=7},
        {type="item", name="sap-seeds", amount=361},
      },
      results = {
        {type="item", name="compost-plant-mk01", amount=2},
      },
    },
    ["oil-boiler-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-codex", amount=1},
        {type="item", name="pipe", amount=68},
        {type="item", name="steel-chest", amount=1},
        {type="item", name="steel-plate", amount=10},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="vitreloy", amount=8},
      },
      results = {
        {type="item", name="oil-boiler-mk01", amount=1},
      },
    },
    ["py-electric-boiler"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=7},
        {type="item", name="capacitor1", amount=16},
        {type="item", name="carbolic-oil-canister", amount=1},
        {type="item", name="ceramic", amount=10},
        {type="item", name="gasoline-barrel", amount=21},
        {type="item", name="methane-canister", amount=20},
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
        {type="item", name="concrete", amount=43},
        {type="item", name="fiberboard", amount=14},
        {type="item", name="lab", amount=1},
        {type="item", name="meat", amount=2},
        {type="item", name="pipe", amount=13},
        {type="item", name="processed-iron-ore", amount=13},
        {type="item", name="rich-clay", amount=2},
        {type="item", name="stone-brick", amount=36},
      },
      results = {
        {type="item", name="rhe", amount=1},
      },
    },
    ["personal-roboport-equipment"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="concrete", amount=108},
        {type="item", name="duralumin", amount=97},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="fiberboard", amount=39},
        {type="item", name="lab", amount=2},
        {type="item", name="soil-extractor-mk01", amount=2},
        {type="item", name="tinned-cable", amount=30},
        {type="item", name="titanium-plate", amount=43},
        {type="item", name="transport-belt", amount=91},
        {type="item", name="washer", amount=6},
      },
      results = {
        {type="item", name="personal-roboport-equipment", amount=2},
      },
    },
    ["portable-gasoline-generator"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=2},
        {type="item", name="gun-turret", amount=1},
        {type="item", name="lime", amount=141},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="quenching-tower", amount=1},
        {type="item", name="scrude-barrel", amount=12},
        {type="item", name="shotgun", amount=1},
        {type="item", name="tar-barrel", amount=55},
        {type="item", name="transport-belt", amount=9},
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
        {type="item", name="gun-turret", amount=2},
        {type="item", name="inductor1", amount=2},
        {type="item", name="ore-chromium", amount=1194},
        {type="item", name="pitch-barrel", amount=3},
        {type="item", name="pitch-canister", amount=1},
        {type="item", name="sb-grade-03", amount=9},
        {type="item", name="zogna-bacteria-barrel", amount=2},
      },
      results = {
        {type="item", name="py-recharge-station-mk01", amount=1},
      },
    },
    ["py-roboport-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog", amount=6},
        {type="item", name="blade-mk01", amount=6},
        {type="item", name="calcium-carbide", amount=67},
        {type="item", name="carbolic-oil-barrel", amount=8},
        {type="item", name="equipment-chassi", amount=3},
        {type="item", name="ore-chromium", amount=28},
        {type="item", name="pipe", amount=88},
      },
      results = {
        {type="item", name="py-roboport-mk01", amount=1},
      },
    },
    ["py-ze"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="burner-mining-drill", amount=3},
        {type="item", name="concrete", amount=67},
        {type="item", name="glass", amount=8},
        {type="item", name="inductor1", amount=22},
        {type="item", name="lead-plate", amount=24},
        {type="item", name="pipe", amount=66},
        {type="item", name="steam-engine", amount=1},
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
        {type="item", name="belt", amount=555},
        {type="item", name="ceramic", amount=436},
        {type="item", name="concrete", amount=86},
        {type="item", name="duralumin", amount=65},
        {type="item", name="electronics-mk01", amount=1},
        {type="item", name="engine-unit", amount=29},
        {type="item", name="evaporator", amount=1},
        {type="item", name="grade-1-tin", amount=230},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="pipe", amount=1192},
        {type="item", name="raw-fiber", amount=117},
        {type="item", name="rotor-mk01", amount=3},
        {type="item", name="titanium-plate", amount=510},
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
        {type="item", name="agar", amount=20},
        {type="item", name="aluminium-plate", amount=85},
        {type="item", name="copper-cable", amount=197},
        {type="item", name="glass", amount=167},
        {type="item", name="grade-1-lead", amount=2},
        {type="item", name="iron-plate", amount=318},
        {type="item", name="meat", amount=74},
        {type="item", name="processed-iron-ore", amount=502},
        {type="item", name="py-tank-1000", amount=2},
        {type="item", name="rich-clay", amount=98},
        {type="item", name="small-parts-01", amount=85},
        {type="item", name="tin-plate", amount=48},
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
        {type="item", name="agar", amount=13},
        {type="item", name="grade-1-lead", amount=5},
        {type="item", name="meat", amount=18},
        {type="item", name="processed-iron-ore", amount=321},
        {type="item", name="py-tank-1000", amount=1},
        {type="item", name="rich-clay", amount=62},
        {type="item", name="transport-belt", amount=6},
        {type="item", name="vitreloy", amount=2},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="generator-1", amount=1},
      },
    },
    ["pyphoon-bay"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="bio-container", amount=2},
        {type="item", name="coal-gas-canister", amount=46},
        {type="item", name="copper-cable", amount=1237},
        {type="item", name="poorman-wood-fence", amount=50},
        {type="item", name="processed-iron-ore", amount=1133},
        {type="item", name="sand-casting", amount=114},
        {type="item", name="sb-grade-02", amount=145},
        {type="item", name="stopper", amount=7},
        {type="item", name="tower-mk01", amount=2},
        {type="item", name="vrauks", amount=2},
      },
      results = {
        {type="item", name="pyphoon-bay", amount=3},
      },
    },
    ["belt"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="bolts", amount=28},
      },
      results = {
        {type="item", name="belt", amount=1},
      },
    },
    ["polybutadiene"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25048889967008,
      ingredients = {
        {type="fluid", name="scrude", amount=215},
        {type="fluid", name="water", amount=966},
        {type="item", name="clean-nexelit", amount=16},
        {type="item", name="titanium-plate", amount=1},
      },
      results = {
        {type="fluid", name="polybutadiene", amount=125},
        {type="fluid", name="steam", amount=1252},
      },
    },
    ["long-handed-inserter"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="carbon-black", amount=12},
        {type="item", name="creamy-latex-barrel", amount=2},
        {type="item", name="display-panel", amount=2},
        {type="item", name="grade-1-zinc", amount=5},
        {type="item", name="lime", amount=69},
        {type="item", name="planter-box", amount=13},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=3},
      },
    },
    ["carbon-black"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="steam", amount=1573},
      },
      results = {
        {type="item", name="carbon-black", amount=3},
      },
    },
    ["engine-unit-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="aluminium-plate", amount=15},
        {type="item", name="belt", amount=2},
        {type="item", name="ceramic", amount=125},
        {type="item", name="iron-plate", amount=13},
        {type="item", name="steam-engine", amount=5},
      },
      results = {
        {type="item", name="engine-unit", amount=4},
      },
    },
    ["transport-belt-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.53333333333333,
      ingredients = {
        {type="fluid", name="molten-glass", amount=136},
        {type="item", name="bolts", amount=11},
        {type="item", name="inductor1", amount=2},
        {type="item", name="pipe", amount=4},
        {type="item", name="rubber", amount=2},
        {type="item", name="stopper", amount=4},
      },
      results = {
        {type="item", name="transport-belt", amount=23},
      },
    },
    ["rubber-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=1716},
        {type="item", name="bolts", amount=10},
        {type="item", name="nexelit-plate", amount=23},
      },
      results = {
        {type="item", name="rubber", amount=1},
      },
    },
    ["depolymerized-organics"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.26,
      ingredients = {
        {type="fluid", name="steam", amount=21454},
        {type="fluid", name="water", amount=29361},
        {type="item", name="dried-meat", amount=1},
      },
      results = {
        {type="fluid", name="depolymerized-organics", amount=126},
      },
    },
    ["subcritical-water-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="water", amount=101},
        {type="item", name="biomass", amount=27},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=40},
      },
    },
    ["electronic-circuit-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 3.6,
      ingredients = {
        {type="item", name="battery-mk01", amount=2},
        {type="item", name="cellulose", amount=12},
        {type="item", name="fiberboard", amount=2},
        {type="item", name="formica", amount=7},
        {type="item", name="inductor1", amount=3},
        {type="item", name="iron-plate", amount=37},
        {type="item", name="naphthalene-oil-canister", amount=2},
        {type="item", name="ore-titanium", amount=12},
        {type="item", name="pcb1", amount=2},
        {type="item", name="pipe", amount=5},
        {type="item", name="small-parts-01", amount=10},
        {type="item", name="solder", amount=4},
        {type="item", name="titanium-plate", amount=29},
      },
      results = {
        {type="item", name="electronic-circuit", amount=18},
      },
    },
    ["formica-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="clay", amount=143},
        {type="item", name="coarse", amount=48},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="formica", amount=8},
      },
    },
    ["hotair-empty-petri-dish"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=293},
        {type="item", name="iron-stick", amount=4},
        {type="item", name="refined-concrete", amount=2},
      },
      results = {
        {type="item", name="empty-petri-dish", amount=4},
      },
    },
    ["hotair-flask"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="molten-glass", amount=42},
        {type="item", name="stopper", amount=3},
      },
      results = {
        {type="item", name="flask", amount=2},
      },
    },
    ["stopper-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="belt", amount=2},
        {type="item", name="bolts", amount=54},
      },
      results = {
        {type="item", name="stopper", amount=4},
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
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.2,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=2367},
        {type="item", name="aluminium-plate", amount=6},
        {type="item", name="bones", amount=13},
        {type="item", name="brain", amount=1},
        {type="item", name="geothermal-water-barrel", amount=2},
        {type="item", name="limestone", amount=6},
        {type="item", name="nexelit-plate", amount=4},
      },
      results = {
        {type="item", name="ore-lead", amount=11},
      },
    },
    ["powdered-ralesia-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="pressured-water", amount=239},
        {type="fluid", name="steam", amount=78},
        {type="fluid", name="vacuum", amount=205},
        {type="item", name="ralesia", amount=6},
        {type="item", name="ralesia-seeds", amount=6},
        {type="item", name="sand", amount=3},
      },
      results = {
        {type="item", name="powdered-ralesia-seeds", amount=1},
      },
    },
    ["water-saline"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="steam", amount=50},
        {type="item", name="limestone", amount=4},
      },
      results = {
        {type="fluid", name="water-saline", amount=76},
      },
    },
    ["starch"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=2},
        {type="item", name="raw-fiber", amount=1},
        {type="item", name="wood", amount=10},
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
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="decider-combinator", amount=1},
        {type="item", name="duralumin", amount=446},
        {type="item", name="heavy-oil-barrel", amount=31},
        {type="item", name="molten-iron-barrel", amount=12},
        {type="item", name="nexelit-plate", amount=4533},
        {type="item", name="pipe", amount=124},
        {type="item", name="pyphoon-bay", amount=4},
        {type="item", name="shaft-mk01", amount=1},
        {type="item", name="titanium-plate", amount=84},
        {type="item", name="vitreloy", amount=15},
      },
      results = {
        {type="item", name="aerial-blimp-mk01", amount=2},
      },
    },
    ["blood-to-iron"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="hydrogen", amount=360},
      },
      results = {
        {type="item", name="iron-ore", amount=4},
      },
    },
    ["fawogae-to-iron"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="fawogae-spore", amount=9},
        {type="item", name="meat", amount=3},
      },
      results = {
        {type="item", name="iron-ore", amount=8},
      },
    },
    ["bone-to-bonemeal-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=285},
        {type="item", name="brain", amount=3},
      },
      results = {
        {type="item", name="bonemeal", amount=5},
      },
    },
    ["bones-to-kerogen"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="kerogen", amount=5},
      },
    },
    ["breed-fish-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.19472838681025,
      ingredients = {
        {type="fluid", name="pressured-water", amount=282},
        {type="fluid", name="steam", amount=871},
        {type="fluid", name="water", amount=257},
        {type="item", name="biomass", amount=8},
        {type="item", name="bolts", amount=19},
        {type="item", name="moondrop", amount=6},
        {type="item", name="nexelit-plate", amount=37},
        {type="item", name="tinned-cable", amount=5},
      },
      results = {
        {type="fluid", name="waste-water", amount=118},
        {type="item", name="fish", amount=12},
      },
    },
    ["breed-fish-egg-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.8419114670331,
      ingredients = {
        {type="fluid", name="pressured-water", amount=5286},
        {type="item", name="fish", amount=25},
      },
      results = {
        {type="fluid", name="waste-water", amount=185},
        {type="item", name="fish-egg", amount=46},
      },
    },
    ["py-construction-robot-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="condensates", amount=1146},
        {type="item", name="ammonia-barrel", amount=1},
        {type="item", name="auog", amount=15},
        {type="item", name="blade-mk01", amount=2},
        {type="item", name="cage", amount=1},
        {type="item", name="caged-auog", amount=1},
        {type="item", name="calcium-carbide", amount=68},
        {type="item", name="carbolic-oil-barrel", amount=20},
        {type="item", name="carbolic-oil-canister", amount=4},
        {type="item", name="equipment-chassi", amount=9},
        {type="item", name="gasoline-canister", amount=1},
        {type="item", name="grade-1-copper", amount=146},
        {type="item", name="latex-slab", amount=8},
        {type="item", name="pipe", amount=88},
        {type="item", name="repair-pack", amount=2},
        {type="item", name="shaft-mk01", amount=3},
        {type="item", name="workers-food", amount=2},
      },
      results = {
        {type="item", name="py-construction-robot-mk01", amount=2},
      },
    },
    ["liquid-manure"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.49,
      ingredients = {
        {type="fluid", name="steam", amount=349},
        {type="fluid", name="water", amount=392},
        {type="item", name="manure", amount=4},
        {type="item", name="raw-coal", amount=1},
      },
      results = {
        {type="fluid", name="liquid-manure", amount=49},
      },
    },
    ["zogna-bacteria"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="limestone", amount=14},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="zogna-bacteria", amount=25},
      },
    },
    ["plasmids"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=4912},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=2},
      },
      results = {
        {type="item", name="plasmids", amount=1},
      },
    },
    ["retrovirus"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="nexelit-plate", amount=7},
        {type="item", name="petri-dish-bacteria", amount=1},
        {type="item", name="stopper", amount=1},
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
        {type="fluid", name="water-saline", amount=1473},
        {type="item", name="bio-sample", amount=8},
        {type="item", name="cellulose", amount=4},
        {type="item", name="empty-petri-dish", amount=17},
        {type="item", name="fawogae-substrate", amount=6},
        {type="item", name="formica", amount=2},
        {type="item", name="lab-instrument", amount=2},
        {type="item", name="ore-lead", amount=45},
        {type="item", name="petri-dish", amount=8},
        {type="item", name="py-asphalt", amount=4},
        {type="item", name="py-gas-vent", amount=8},
        {type="item", name="py-overflow-valve", amount=4},
        {type="item", name="py-shed-basic", amount=1},
        {type="item", name="retrovirus", amount=5},
        {type="item", name="shaft-mk01", amount=4},
        {type="item", name="titanium-plate", amount=11},
      },
      results = {
        {type="item", name="cdna", amount=3},
      },
    },
    ["ralesia-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="automation-science-pack", amount=280},
        {type="item", name="bio-sample", amount=33},
        {type="item", name="cottongut-codex", amount=3},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="fawogae-codex", amount=2},
        {type="item", name="moss-gen", amount=24},
        {type="item", name="retrovirus", amount=21},
      },
      results = {
        {type="item", name="ralesia", amount=6},
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
        {type="item", name="ralesia-seeds", amount=6},
        {type="item", name="sand", amount=9},
      },
      results = {
        {type="item", name="ralesia", amount=7},
      },
    },
    ["cottongut-codex"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ceramic", amount=61},
        {type="item", name="concrete", amount=818},
        {type="item", name="copper-cable", amount=89},
        {type="item", name="inductor1", amount=4},
        {type="item", name="small-parts-01", amount=25},
      },
      results = {
        {type="item", name="cottongut-codex", amount=1},
      },
    },
    ["cottongut-cub-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1.38748554805977,
      ingredients = {
        {type="item", name="cottongut", amount=8},
        {type="item", name="moondrop-seeds", amount=4},
        {type="item", name="ralesia", amount=4},
        {type="item", name="ralesia-seeds", amount=2},
        {type="item", name="water-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cottongut-pup", amount=14},
      },
    },
    ["caged-cottongut-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.85519350241157,
      ingredients = {
        {type="item", name="cocoon-mk02", amount=6},
        {type="item", name="cottongut-pup-mk01", amount=4},
        {type="item", name="moondrop", amount=2},
        {type="item", name="ralesia", amount=2},
        {type="item", name="soil", amount=16},
        {type="item", name="vrauks-food-01", amount=3},
        {type="item", name="water-barrel", amount=5},
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cottongut", amount=11},
      },
    },
    ["cottongut"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-codex", amount=11},
        {type="item", name="earth-bear-sample", amount=2},
        {type="item", name="earth-flower-sample", amount=1},
        {type="item", name="glass", amount=260},
        {type="item", name="retrovirus", amount=15},
        {type="item", name="vrauks", amount=53},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
      },
    },
    ["cottongut-food-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="steam", amount=1030},
        {type="fluid", name="water", amount=263},
        {type="item", name="clay", amount=25},
        {type="item", name="pipe", amount=17},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="ralesia", amount=4},
        {type="item", name="wood", amount=12},
      },
      results = {
        {type="item", name="cottongut-food-01", amount=5},
      },
    },
    ["cottongut-science-red-seeds"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=15833},
        {type="item", name="cottongut-mk01", amount=8},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="solidified-sarcorus", amount=3},
      },
    },
    ["cottongut-pup-mk01-raising"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2.04126219772471,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="cottongut-mk01", amount=4},
        {type="item", name="fish-egg", amount=3},
        {type="item", name="ralesia-seeds", amount=19},
        {type="item", name="sodium-hydroxide", amount=3},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="cottongut-pup", amount=1},
        {type="item", name="cottongut-pup-mk01", amount=9},
      },
    },
    ["cottongut-mature-basic-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cottongut-pup", amount=2},
        {type="item", name="gravel", amount=4},
        {type="item", name="ralesia-seeds", amount=8},
        {type="item", name="vrauks-food-01", amount=3},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=2},
      },
    },
    ["logistic-science-pack"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="item", name="alien-sample01", amount=3},
        {type="item", name="battery-mk01", amount=4},
        {type="item", name="lime", amount=904},
        {type="item", name="solidified-sarcorus", amount=1},
      },
      results = {
        {type="item", name="logistic-science-pack", amount=14},
      },
    },
    ["workers-food"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=7903},
        {type="item", name="aluminium-plate", amount=19},
        {type="item", name="bonemeal", amount=2},
        {type="item", name="brain", amount=4},
        {type="item", name="geothermal-water-barrel", amount=6},
        {type="item", name="limestone", amount=8},
        {type="item", name="nexelit-plate", amount=13},
      },
      results = {
        {type="item", name="workers-food", amount=5},
      },
    },
    ["auog-codex"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="clay", amount=46},
        {type="item", name="concrete", amount=63},
        {type="item", name="copper-cable", amount=70},
        {type="item", name="landfill", amount=11},
        {type="item", name="transport-belt", amount=2},
        {type="item", name="vacuum-tube", amount=8},
      },
      results = {
        {type="item", name="auog-codex", amount=1},
      },
    },
    ["auog-paddock-mk01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hot-air", amount=5569},
        {type="item", name="ground-sample01", amount=38},
        {type="item", name="iron-stick", amount=21},
        {type="item", name="nexelit-plate", amount=66},
        {type="item", name="small-parts-01", amount=8},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="auog-paddock-mk01", amount=1},
      },
    },
    ["auog-pooping-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.02883601600353,
      ingredients = {
        {type="item", name="moss", amount=10},
        {type="item", name="ore-nickel", amount=11},
        {type="item", name="water-barrel", amount=5},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="manure", amount=6},
      },
    },
    ["auog-pup-breeding-1"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.592860904126396,
      ingredients = {
        {type="item", name="moss", amount=5},
        {type="item", name="processed-iron-ore", amount=14},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="auog-pup", amount=2},
        {type="item", name="barrel", amount=3},
      },
    },
    ["auog"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-codex", amount=3},
        {type="item", name="automation-science-pack", amount=80},
        {type="item", name="cdna", amount=5},
        {type="item", name="earth-mouse-sample", amount=2},
        {type="item", name="retrovirus", amount=39},
        {type="item", name="vrauks-codex", amount=4},
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
        {type="fluid", name="steam", amount=106},
        {type="fluid", name="water", amount=480},
        {type="item", name="biomass", amount=9},
        {type="item", name="grade-1-chromite", amount=1},
        {type="item", name="gravel", amount=9},
        {type="item", name="plastic-bar", amount=4},
        {type="item", name="ralesia-seeds", amount=6},
      },
      results = {
        {type="item", name="auog-food-01", amount=4},
      },
    },
    ["auog-maturing-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="molten-iron-barrel", amount=2},
        {type="item", name="ore-titanium", amount=20},
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
        {type="item", name="guts", amount=7},
        {type="item", name="limestone", amount=9},
        {type="item", name="meat", amount=11},
        {type="item", name="raw-fiber", amount=2},
      },
      results = {
        {type="item", name="auog", amount=2},
      },
    },
    ["auog-maturing-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.43448982916518,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="auog-pup", amount=7},
        {type="item", name="molten-iron-barrel", amount=3},
        {type="item", name="ore-titanium", amount=20},
        {type="item", name="seaweed", amount=17},
        {type="item", name="sodium-hydroxide", amount=3},
        {type="item", name="water-saline-barrel", amount=2},
      },
      results = {
        {type="item", name="auog", amount=8},
        {type="item", name="barrel", amount=7},
      },
    },
    ["auog-pooping-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.595083440695939,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="moss", amount=12},
        {type="item", name="ore-tin", amount=16},
        {type="item", name="water-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="manure", amount=5},
      },
    },
    ["auog-pup-breeding-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.37576840797203,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="grade-2-tin", amount=1},
        {type="item", name="ore-tin", amount=10},
        {type="item", name="seaweed", amount=7},
        {type="item", name="water-barrel", amount=8},
      },
      results = {
        {type="item", name="auog-pup", amount=8},
        {type="item", name="barrel", amount=7},
      },
    },
    ["auog-recharge-0"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="gasoline-canister", amount=1},
        {type="item", name="moss", amount=14},
      },
      results = {
        {type="item", name="auog", amount=2},
      },
    },
    ["uncaged-auog"] = {
      mode = "input-preserved-unmodified",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="caged-auog", amount=1},
      },
      results = {
        {type="item", name="auog", amount=1},
        {type="item", name="cage", amount=1},
      },
    },
    ["fertilizer-4"] = {
      mode = "repaired-to-input",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=20},
        {type="item", name="biomass", amount=10},
        {type="item", name="dried-meat", amount=9},
      },
      results = {
        {type="item", name="fertilizer", amount=5},
      },
    },
    ["urea-from-liquid-manure"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="molten-aluminium", amount=3},
        {type="fluid", name="water", amount=5720},
      },
      results = {
        {type="item", name="urea", amount=12},
      },
    },
    ["melamine-resin"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="steam", amount=1322},
        {type="item", name="ceramic", amount=29},
        {type="item", name="raw-fiber", amount=12},
      },
      results = {
        {type="item", name="melamine-resin", amount=15},
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
        {type="item", name="capacitor1", amount=367},
        {type="item", name="earth-bear-sample", amount=1},
        {type="item", name="lime", amount=284},
        {type="item", name="ralesia-codex", amount=2},
        {type="item", name="vrauks", amount=200},
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
        {type="fluid", name="water", amount=1237},
        {type="item", name="grade-1-nickel", amount=2},
      },
      results = {
        {type="item", name="boron-trioxide", amount=3},
      },
    },
    ["coke-coal"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="coal", amount=3},
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
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=716},
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
        {type="fluid", name="carbon-dioxide", amount=335},
        {type="fluid", name="hydrogen", amount=182},
        {type="fluid", name="molten-glass", amount=30},
        {type="item", name="calcium-carbide", amount=8},
      },
      results = {
        {type="item", name="lens", amount=3},
      },
    },
    ["vrauks-2"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.26653923969723,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
        {type="item", name="carbon-dioxide-barrel", amount=5},
        {type="item", name="limestone", amount=13},
        {type="item", name="sodium-alginate", amount=5},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="vrauks", amount=5},
      },
    },
    ["vrauks-food-01"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=79},
        {type="item", name="gravel", amount=14},
        {type="item", name="lime", amount=14},
        {type="item", name="limestone", amount=4},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="petri-dish-bacteria", amount=2},
        {type="item", name="raw-coal", amount=22},
        {type="item", name="small-lamp", amount=1},
        {type="item", name="sodium-hydroxide", amount=1},
      },
      results = {
        {type="item", name="vrauks-food-01", amount=4},
      },
    },
    ["vrauks-cocoon-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 2,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="grade-1-lead", amount=3},
        {type="item", name="moss", amount=26},
        {type="item", name="seaweed", amount=14},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="cocoon", amount=5},
      },
    },
    ["vrauks-mk02"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 2.379807382453,
      ingredients = {
        {type="item", name="caged-vrauks", amount=5},
        {type="item", name="carbon-dioxide-barrel", amount=2},
        {type="item", name="limestone", amount=49},
        {type="item", name="log", amount=2},
        {type="item", name="molten-iron-barrel", amount=2},
        {type="item", name="sodium-alginate", amount=2},
        {type="item", name="soil", amount=99},
        {type="item", name="vrauks-food-01", amount=7},
      },
      results = {
        {type="item", name="barrel", amount=12},
        {type="item", name="vrauks", amount=3},
        {type="item", name="vrauks-mk02", amount=0.012022611489126},
      },
    },
    ["vrauks-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.04268128936639,
      ingredients = {
        {type="item", name="cocoon-mk02", amount=7},
        {type="item", name="sb-grade-03", amount=1},
        {type="item", name="soil", amount=138},
        {type="item", name="vrauks-food-01", amount=3},
        {type="item", name="vrauks-mk02", amount=2},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk02", amount=3},
      },
    },
    ["vrauks-mk02-cocoon"] = {
      mode = "kept-transformed",
      science_level = 2,
      energy_required_multiplier = 1.43495540663515,
      ingredients = {
        {type="item", name="auog-food-01", amount=1},
        {type="item", name="grade-1-lead", amount=3},
        {type="item", name="moss", amount=28},
        {type="item", name="sand-casting", amount=2},
        {type="item", name="seaweed", amount=5},
        {type="item", name="vrauks-food-01", amount=3},
        {type="item", name="vrauks-mk02", amount=2},
        {type="item", name="water-barrel", amount=10},
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
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="grade-1-ti", amount=6},
        {type="item", name="warm-stone-brick", amount=15},
      },
      results = {
        {type="fluid", name="hot-air", amount=210},
        {type="item", name="stone-brick", amount=28},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-ore", amount=3},
        {type="item", name="lead-plate", amount=2},
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
        {type="item", name="aromatics-barrel", amount=5},
        {type="item", name="wood-seedling", amount=16},
      },
      results = {
        {type="item", name="active-provider-chest", amount=1},
      },
    },
    ["buffer-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="kerosene-barrel", amount=3},
        {type="item", name="long-handed-inserter", amount=2},
        {type="item", name="small-parts-01", amount=101},
        {type="item", name="steel-furnace", amount=1},
        {type="item", name="wood-seedling", amount=4},
      },
      results = {
        {type="item", name="buffer-chest", amount=4},
      },
    },
    ["passive-provider-chest"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=15},
        {type="item", name="condensates-barrel", amount=2},
      },
      results = {
        {type="item", name="passive-provider-chest", amount=1},
      },
    },
    ["requester-chest"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bones", amount=1},
        {type="item", name="kerosene-barrel", amount=4},
        {type="item", name="long-handed-inserter", amount=2},
      },
      results = {
        {type="item", name="requester-chest", amount=1},
      },
    },
    ["aromatic-organic"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.95,
      ingredients = {
        {type="item", name="fawogae-spore", amount=10},
        {type="item", name="ralesia-seeds", amount=4},
        {type="item", name="workers-food", amount=1},
      },
      results = {
        {type="fluid", name="aromatics", amount=390},
      },
    },
    ["ash-bone"] = {
      mode = "kept-pruned-transformed",
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=1},
        {type="item", name="raw-fiber", amount=2},
      },
      results = {
        {type="item", name="ash", amount=10},
      },
    },
    ["coal-dust3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="item", name="ralesia-seeds", amount=9},
      },
      results = {
        {type="item", name="coal-dust", amount=19},
      },
    },
    ["fluegas-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="flue-gas", amount=42},
        {type="fluid", name="pressured-air", amount=14},
      },
      results = {
        {type="item", name="ash", amount=1},
      },
    },
    ["grade-3-tin"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=3},
        {type="item", name="grade-2-tin", amount=1},
      },
      results = {
        {type="item", name="grade-3-tin", amount=2},
        {type="item", name="tin-ore-rejects", amount=1},
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
        {type="fluid", name="water", amount=138},
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
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-2-tin", amount=4},
      },
      results = {
        {type="item", name="tin-dust", amount=3},
      },
    },
    ["tin-plate-4"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="grade-2-tin", amount=4},
      },
      results = {
        {type="item", name="tin-plate", amount=6},
      },
    },
    ["molten-tin-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="item", name="coke", amount=11},
        {type="item", name="polybutadiene-barrel", amount=4},
        {type="item", name="sand", amount=14},
      },
      results = {
        {type="fluid", name="molten-tin", amount=23},
      },
    },
    ["hotair-tin-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.936507936507937,
      ingredients = {
        {type="fluid", name="condensates", amount=793},
      },
      results = {
        {type="item", name="tin-plate", amount=59},
      },
    },
    ["tin-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="condensates", amount=210},
        {type="fluid", name="naphthalene-oil", amount=285},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="tin-plate", amount=51},
      },
    },
    ["carbon-filter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="boiler", amount=5},
        {type="item", name="concrete", amount=113},
        {type="item", name="fiberboard", amount=13},
        {type="item", name="grade-3-tin", amount=27},
        {type="item", name="inductor1", amount=51},
        {type="item", name="ore-aluminium", amount=35},
        {type="item", name="pipe", amount=17},
        {type="item", name="stone-furnace", amount=9},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="carbon-filter", amount=3},
      },
    },
    ["fts-reactor"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=14},
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="inductor1", amount=20},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="pipe", amount=30},
        {type="item", name="stone-brick", amount=68},
        {type="item", name="subcritical-water-barrel", amount=3},
        {type="item", name="tin-plate", amount=19},
        {type="item", name="titanium-plate", amount=623},
      },
      results = {
        {type="item", name="fts-reactor", amount=2},
      },
    },
    ["methanol-reactor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=6},
        {type="item", name="copper-cable", amount=132},
        {type="item", name="duralumin", amount=31},
        {type="item", name="inductor1", amount=88},
        {type="item", name="pipe", amount=27},
        {type="item", name="seaweed", amount=144},
        {type="item", name="steel-plate", amount=18},
      },
      results = {
        {type="item", name="methanol-reactor", amount=1},
      },
    },
    ["fluid-separator"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bhoddos-spore", amount=158},
        {type="item", name="bolts", amount=156},
        {type="item", name="evaporator", amount=4},
        {type="item", name="nexelit-plate", amount=250},
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
        {type="item", name="meat", amount=9},
      },
      results = {
        {type="item", name="grade-3-chromite", amount=1},
      },
    },
    ["grade-4-chromite"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.25,
      ingredients = {
        {type="item", name="grade-2-chromite", amount=1},
        {type="item", name="meat", amount=7},
      },
      results = {
        {type="item", name="chromite-rejects", amount=9},
        {type="item", name="grade-4-chromite", amount=9},
      },
    },
    ["grade-3-chromite"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 5,
      ingredients = {
        {type="item", name="grade-1-zinc", amount=6},
      },
      results = {
        {type="item", name="grade-2-chromite", amount=2},
        {type="item", name="grade-3-chromite", amount=5},
      },
    },
    ["tier-2-chromite-sand"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diesel-canister", amount=1},
      },
      results = {
        {type="item", name="chromite-sand", amount=12},
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
      energy_required_multiplier = 0.72,
      ingredients = {
        {type="item", name="calcium-carbide", amount=14},
      },
      results = {
        {type="fluid", name="iron-pulp-01", amount=36},
        {type="fluid", name="iron-slime", amount=36},
      },
    },
    ["grade-2-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=9},
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
        {type="item", name="lime", amount=125},
      },
      results = {
        {type="fluid", name="iron-slime", amount=45},
      },
    },
    ["unslimed-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.990354799702893,
      ingredients = {
        {type="fluid", name="iron-slime", amount=43},
        {type="fluid", name="pressured-steam", amount=1627},
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="ralesia-seeds", amount=3},
        {type="item", name="sand", amount=3},
      },
      results = {
        {type="fluid", name="tailings", amount=94},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["grade-2-crush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-3-iron", amount=1},
        {type="item", name="powdered-biomass", amount=9},
      },
      results = {
        {type="item", name="grade-1-iron", amount=2},
        {type="item", name="gravel", amount=1},
      },
    },
    ["grade-3-iron-processing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-1-iron", amount=4},
        {type="item", name="grade-3-iron", amount=2},
      },
      results = {
        {type="item", name="grade-2-iron", amount=3},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=103},
        {type="item", name="pure-sand", amount=5},
        {type="item", name="unslimed-iron", amount=1},
      },
      results = {
        {type="fluid", name="molten-iron", amount=40},
      },
    },
    ["unslimed-iron-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.993569866468595,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=1207},
      },
      results = {
        {type="fluid", name="tailings", amount=96},
        {type="item", name="unslimed-iron", amount=1},
      },
    },
    ["classify-low-grade"] = {
      mode = "kept-transformed",
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
        {type="fluid", name="slacked-lime", amount=7},
        {type="item", name="grade-2-copper", amount=4},
      },
      results = {
        {type="item", name="grade-3-copper", amount=1},
        {type="item", name="gravel", amount=2},
      },
    },
    ["grade-3-copper"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=82},
        {type="fluid", name="hot-air", amount=281},
        {type="item", name="grade-1-copper", amount=1},
      },
      results = {
        {type="item", name="copper-rejects", amount=2},
        {type="item", name="grade-3-copper", amount=2},
      },
    },
    ["grade-4-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="grade-3-copper", amount=2},
        {type="item", name="powdered-biomass", amount=64},
      },
      results = {
        {type="item", name="grade-4-copper", amount=2},
        {type="item", name="low-grade-rejects", amount=4},
      },
    },
    ["hotair-copper-plate-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.32,
      ingredients = {
        {type="fluid", name="flue-gas", amount=12886},
        {type="fluid", name="water-saline", amount=1326},
        {type="item", name="graphite", amount=2},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=99},
      },
    },
    ["wash-coper-low-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9917322120819,
      ingredients = {
        {type="item", name="methanal-barrel", amount=3},
      },
      results = {
        {type="fluid", name="tailings", amount=195},
        {type="item", name="low-grade-copper", amount=1},
      },
    },
    ["copper-plate-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="flue-gas", amount=6014},
      },
      results = {
        {type="item", name="copper-plate", amount=24},
      },
    },
    ["low-grade-smelting-copper"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=150},
        {type="item", name="low-grade-rejects", amount=6},
        {type="item", name="methanal-barrel", amount=1},
      },
      results = {
        {type="item", name="copper-plate", amount=1},
      },
    },
    ["molten-copper-04"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.57142857142857,
      ingredients = {
        {type="fluid", name="pressured-water", amount=335},
        {type="item", name="grade-2-copper", amount=14},
        {type="item", name="middle-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="molten-copper", amount=33},
      },
    },
    ["coalbed-mk01"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=28},
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="grade-1-ti", amount=46},
        {type="item", name="heavy-armor", amount=1},
        {type="item", name="hydrogen-barrel", amount=219},
        {type="item", name="limestone", amount=29},
        {type="item", name="pitch-barrel", amount=25},
        {type="item", name="sap-extractor-mk01", amount=3},
      },
      results = {
        {type="item", name="coalbed-mk01", amount=2},
      },
    },
    ["lor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=19},
        {type="item", name="bio-container", amount=4},
        {type="item", name="bolts", amount=91},
        {type="item", name="condensates-canister", amount=7},
        {type="item", name="grade-3-tin", amount=4},
        {type="item", name="hot-air-barrel", amount=11},
        {type="item", name="inductor1", amount=7},
        {type="item", name="iron-plate", amount=916},
        {type="item", name="offshore-pump", amount=18},
        {type="item", name="phytoplankton-barrel", amount=1},
        {type="item", name="stone-brick", amount=597},
        {type="item", name="vitreloy", amount=1},
      },
      results = {
        {type="item", name="lor-mk01", amount=1},
      },
    },
    ["natural-gas-derrick-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=2},
        {type="item", name="copper-plate", amount=23},
        {type="item", name="grade-2-zinc", amount=4},
        {type="item", name="grade-3-iron", amount=3},
        {type="item", name="pipe", amount=27},
        {type="item", name="pipe-to-ground", amount=9},
        {type="item", name="plastic-bar", amount=117},
        {type="item", name="steel-chest", amount=2},
        {type="item", name="tin-plate", amount=11},
        {type="item", name="tinned-cable", amount=105},
        {type="item", name="titanium-plate", amount=219},
      },
      results = {
        {type="item", name="natural-gas-derrick-mk01", amount=2},
      },
    },
    ["oil-derrick-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="carbolic-oil-barrel", amount=7},
        {type="item", name="chromium", amount=22},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="grade-1-chromite", amount=8},
        {type="item", name="grade-1-nickel", amount=6},
        {type="item", name="grade-3-tin", amount=2},
        {type="item", name="nexelit-plate", amount=91},
        {type="item", name="ore-nickel", amount=11},
        {type="item", name="ore-tin", amount=50},
        {type="item", name="py-science-pack-1", amount=1},
        {type="item", name="storage-tank", amount=2},
        {type="item", name="subcritical-water-barrel", amount=7},
        {type="item", name="syngas-barrel", amount=26},
        {type="item", name="vitreloy", amount=3},
      },
      results = {
        {type="item", name="oil-derrick-mk01", amount=3},
      },
    },
    ["oil-sand-extractor-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=17},
        {type="item", name="condensates-canister", amount=2},
        {type="item", name="dried-meat", amount=54},
        {type="item", name="grade-1-lead", amount=7},
        {type="item", name="grade-3-chromite", amount=2},
        {type="item", name="hot-air-barrel", amount=24},
        {type="item", name="inductor1", amount=8},
        {type="item", name="iron-plate", amount=240},
        {type="item", name="light-oil-barrel", amount=5},
        {type="item", name="naphthalene-oil-canister", amount=28},
        {type="item", name="offshore-pump", amount=15},
        {type="item", name="py-tank-7000", amount=1},
        {type="item", name="small-parts-01", amount=13},
        {type="item", name="stone-brick", amount=489},
        {type="item", name="titanium-plate", amount=12},
        {type="item", name="workers-food", amount=33},
      },
      results = {
        {type="item", name="oil-sand-extractor-mk01", amount=2},
      },
    },
    ["pumpjack-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=3},
        {type="item", name="concrete", amount=232},
        {type="item", name="fiberboard", amount=3},
        {type="item", name="nexelit-plate", amount=3},
        {type="item", name="ore-aluminium", amount=72},
        {type="item", name="pipe", amount=35},
        {type="item", name="stone-furnace", amount=2},
        {type="item", name="syngas-barrel", amount=1},
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
        {type="item", name="fts-reactor", amount=4},
        {type="item", name="geothermal-water-barrel", amount=130},
        {type="item", name="gun-turret", amount=5},
        {type="item", name="iron-chest", amount=7},
        {type="item", name="iron-plate", amount=238},
        {type="item", name="wood-seedling", amount=311},
      },
      results = {
        {type="item", name="tar-extractor-mk01", amount=3},
      },
    },
    ["coarse-coal"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.999084117975126,
      ingredients = {
        {type="item", name="raw-coal", amount=12},
      },
      results = {
        {type="item", name="coal", amount=4},
        {type="item", name="coal-dust", amount=0.282876241842958},
        {type="item", name="coarse-coal", amount=1},
      },
    },
    ["coarse-coal-to-coal"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="item", name="crushed-coal", amount=7},
        {type="item", name="raw-coal", amount=42},
      },
      results = {
        {type="item", name="coal", amount=7},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="boiler", amount=10},
        {type="item", name="concrete", amount=119},
        {type="item", name="duralumin", amount=5},
        {type="item", name="fertilizer", amount=20},
        {type="item", name="glass", amount=15},
        {type="item", name="grade-2-zinc", amount=1},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="lead-plate", amount=17},
        {type="item", name="nickel-plate", amount=8},
        {type="item", name="pbsb-alloy", amount=10},
        {type="item", name="pipe", amount=16},
        {type="item", name="rail", amount=52},
        {type="item", name="sb-grade-03", amount=8},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="stone-brick", amount=139},
      },
      results = {
        {type="item", name="ez-ranch-mk01", amount=1},
      },
    },
    ["kicalk-plantation-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=261},
        {type="item", name="concrete", amount=88},
        {type="item", name="electronic-circuit", amount=5},
        {type="item", name="fiberboard", amount=4},
        {type="item", name="intermetallics", amount=11},
        {type="item", name="micro-mine-mk01", amount=3},
        {type="item", name="sb-grade-03", amount=4},
      },
      results = {
        {type="item", name="kicalk-plantation-mk01", amount=2},
      },
    },
    ["tuuphra-plantation-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=331},
        {type="item", name="concrete", amount=58},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="intermetallics", amount=2},
        {type="item", name="lead-plate", amount=15},
        {type="item", name="nexelit-plate", amount=216},
        {type="item", name="nickel-plate", amount=27},
        {type="item", name="py-overflow-valve", amount=6},
        {type="item", name="rail", amount=5},
        {type="item", name="sand", amount=51},
        {type="item", name="sb-grade-03", amount=2},
        {type="item", name="small-parts-01", amount=13},
        {type="item", name="stone-brick", amount=13},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk01", amount=1},
      },
    },
    ["yaedols-culture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=13},
        {type="item", name="grade-1-iron", amount=7},
        {type="item", name="grade-3-tin", amount=14},
        {type="item", name="inductor1", amount=597},
        {type="item", name="lead-plate", amount=672},
        {type="item", name="phytoplankton-barrel", amount=4},
        {type="item", name="pipe", amount=68},
        {type="item", name="small-parts-01", amount=73},
        {type="item", name="steam-engine", amount=10},
        {type="item", name="stone-furnace", amount=86},
      },
      results = {
        {type="item", name="yaedols-culture-mk01", amount=1},
      },
    },
    ["crawdad"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=2084},
        {type="item", name="animal-sample-01", amount=37},
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="cdna", amount=6},
        {type="item", name="chromium", amount=1205},
        {type="item", name="oil-sand-extractor-mk01", amount=10},
        {type="item", name="pipe", amount=732},
        {type="item", name="py-science-pack-1", amount=8},
        {type="item", name="sodium-hydroxide", amount=12215},
        {type="item", name="tin-plate", amount=805},
        {type="item", name="treated-wood", amount=44},
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
        {type="item", name="barrel", amount=16},
        {type="item", name="bolts", amount=28},
        {type="item", name="concrete", amount=189},
        {type="item", name="fiberboard", amount=64},
        {type="item", name="moondrop-seeds", amount=14},
        {type="item", name="nexelit-plate", amount=84},
        {type="item", name="sb-grade-03", amount=61},
        {type="item", name="soil-extractor-mk01", amount=1},
        {type="item", name="titanium-plate", amount=22},
      },
      results = {
        {type="item", name="sponge-culture-mk01", amount=1},
      },
    },
    ["crushing-molybdenite"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.590482079850901,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=4},
      },
      results = {
        {type="item", name="crushed-molybdenite", amount=3},
        {type="item", name="stone", amount=1},
      },
    },
    ["duralumin-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="benzene", amount=1046},
        {type="fluid", name="creosote", amount=1108},
        {type="fluid", name="hot-air", amount=9436},
        {type="fluid", name="syngas", amount=230},
        {type="item", name="sand-casting", amount=4},
      },
      results = {
        {type="item", name="duralumin", amount=30},
      },
    },
    ["sncr-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="lime", amount=3},
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
        {type="fluid", name="geothermal-water", amount=231},
        {type="item", name="chromite-sand", amount=1},
        {type="item", name="chromium", amount=1},
        {type="item", name="coke", amount=2},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="empty-comb", amount=3},
      },
    },
    ["fish-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="guts", amount=10},
        {type="item", name="meat", amount=11},
        {type="item", name="mukmoux-fat", amount=4},
        {type="item", name="native-flora", amount=8},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="raw-fiber", amount=9},
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
        {type="fluid", name="kerosene", amount=192},
        {type="fluid", name="molten-glass", amount=88},
        {type="fluid", name="water", amount=1420},
        {type="item", name="lens", amount=4},
      },
      results = {
        {type="item", name="flask", amount=3},
      },
    },
    ["hotair-flask-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="molten-glass", amount=126},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="lens", amount=5},
        {type="item", name="stopper", amount=5},
      },
      results = {
        {type="item", name="flask", amount=6},
      },
    },
    ["grade-2-lead-crusher"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
        {type="item", name="grade-2-copper", amount=2},
        {type="item", name="ore-lead", amount=13},
        {type="item", name="ralesia-seeds", amount=3},
      },
      results = {
        {type="item", name="grade-2-lead", amount=2},
        {type="item", name="stone", amount=2},
      },
    },
    ["grade-2-lead"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ore-lead", amount=60},
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
        {type="fluid", name="pressured-air", amount=247},
        {type="fluid", name="water-saline", amount=99},
        {type="item", name="sap-seeds-mk02", amount=3},
      },
      results = {
        {type="item", name="lead-dust", amount=2},
      },
    },
    ["molten-lead-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.52222222222222,
      ingredients = {
        {type="fluid", name="molten-glass", amount=273},
        {type="item", name="industrial-solvent-barrel", amount=2},
      },
      results = {
        {type="fluid", name="molten-lead", amount=137},
      },
    },
    ["hotair-lead-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.698412698412698,
      ingredients = {
        {type="fluid", name="molten-glass", amount=357},
      },
      results = {
        {type="item", name="lead-plate", amount=44},
      },
    },
    ["lead-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.74,
      ingredients = {
        {type="fluid", name="benzene", amount=788},
      },
      results = {
        {type="item", name="lead-plate", amount=37},
      },
    },
    ["grade-3-zinc"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.599580933591305,
      ingredients = {
        {type="fluid", name="pressured-air", amount=102},
        {type="item", name="grade-1-zinc", amount=3},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=29},
        {type="item", name="grade-3-zinc", amount=3},
      },
    },
    ["molten-zinc-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.45,
      ingredients = {
        {type="fluid", name="oxygen", amount=128},
        {type="item", name="grade-1-zinc", amount=9},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="fluid", name="molten-zinc", amount=29},
      },
    },
    ["zinc-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=6011},
        {type="item", name="coke", amount=4},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=48},
      },
    },
    ["hotair-zinc-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.714285714285714,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=1611},
        {type="fluid", name="phytoplankton", amount=133},
        {type="item", name="grade-1-zinc", amount=1},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="zinc-plate", amount=45},
      },
    },
    ["molten-solder-0"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="hot-air", amount=751},
        {type="fluid", name="pressured-air", amount=1808},
        {type="item", name="calcium-carbide", amount=3},
        {type="item", name="rich-clay", amount=6},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="fluid", name="molten-solder", amount=21},
      },
    },
    ["molten-solder-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.85,
      ingredients = {
        {type="fluid", name="hot-air", amount=120},
        {type="fluid", name="molten-lead", amount=19},
        {type="fluid", name="muddy-sludge", amount=392},
        {type="item", name="ore-lead", amount=3},
        {type="item", name="sap-seeds-mk02", amount=2},
      },
      results = {
        {type="fluid", name="molten-solder", amount=74},
      },
    },
    ["solder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=3679},
        {type="fluid", name="sulfuric-acid", amount=128},
      },
      results = {
        {type="item", name="solder", amount=7},
      },
    },
    ["hotair-solder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.714285714285714,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=4471},
      },
      results = {
        {type="item", name="solder", amount=5},
      },
    },
    ["molten-steel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.37978852929861,
      ingredients = {
        {type="fluid", name="hydrogen", amount=193},
        {type="fluid", name="molten-iron", amount=48},
        {type="item", name="aluminium-plate", amount=5},
        {type="item", name="ash", amount=21},
        {type="item", name="gravel", amount=13},
      },
      results = {
        {type="fluid", name="flue-gas", amount=689},
        {type="fluid", name="molten-steel", amount=69},
      },
    },
    ["hotair-steel-20"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6875,
      ingredients = {
        {type="fluid", name="molten-steel", amount=167},
        {type="item", name="coke", amount=9},
        {type="item", name="sand-casting", amount=2},
      },
      results = {
        {type="item", name="steel-plate", amount=54},
      },
    },
    ["steel-20"] = {
      mode = "repaired-to-input",
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=59},
        {type="item", name="electronic-circuit", amount=29},
        {type="item", name="seaweed", amount=62},
        {type="item", name="tinned-cable", amount=236},
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
        {type="item", name="bolts", amount=68},
        {type="item", name="copper-cable", amount=69},
        {type="item", name="small-parts-01", amount=335},
        {type="item", name="steel-plate", amount=215},
        {type="item", name="tinned-cable", amount=14},
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
        {type="item", name="inductor1", amount=6},
        {type="item", name="tinned-cable", amount=632},
      },
      results = {
        {type="item", name="yaedols-codex", amount=1},
      },
    },
    ["sea-sponge-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-pup", amount=1},
        {type="item", name="burner-inserter", amount=1},
        {type="item", name="copper-cable", amount=48},
        {type="item", name="electronic-circuit", amount=4},
        {type="item", name="empty-comb", amount=6},
        {type="item", name="refined-concrete", amount=21},
        {type="item", name="small-parts-01", amount=448},
      },
      results = {
        {type="item", name="sea-sponge-codex", amount=1},
      },
    },
    ["lard-from-brains"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="bones", amount=48},
        {type="item", name="empty-barrel-milk", amount=3},
        {type="item", name="guts", amount=4},
        {type="item", name="meat", amount=5},
        {type="item", name="mukmoux-fat", amount=2},
        {type="item", name="native-flora", amount=11},
        {type="item", name="raw-fiber", amount=11},
        {type="item", name="yaedols-spores", amount=1},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=13},
      },
    },
    ["leaching-station-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="concrete", amount=22},
        {type="item", name="constant-combinator", amount=1},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="pipe-to-ground", amount=6},
        {type="item", name="py-tank-6500", amount=5},
        {type="item", name="resistor1", amount=122},
        {type="item", name="titanium-plate", amount=57},
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
        {type="item", name="duralumin", amount=7},
        {type="item", name="fish-oil-barrel", amount=1},
        {type="item", name="pbsb-alloy", amount=1},
        {type="item", name="py-tank-1500", amount=2},
        {type="item", name="small-parts-01", amount=11},
        {type="item", name="tar-processing-unit", amount=1},
        {type="item", name="vitreloy", amount=5},
      },
      results = {
        {type="item", name="wet-scrubber-mk01", amount=1},
      },
    },
    ["methanol-from-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.733333333333333,
      ingredients = {
        {type="fluid", name="flue-gas", amount=596},
        {type="item", name="copper-ore", amount=4},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=110},
      },
    },
    ["formamide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.83,
      ingredients = {
        {type="fluid", name="hot-air", amount=1118},
        {type="fluid", name="methanol", amount=100},
        {type="item", name="phosphate-rock", amount=19},
      },
      results = {
        {type="fluid", name="formamide", amount=183},
        {type="fluid", name="methanol", amount=100},
      },
    },
    ["military-science-pack"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="firearm-magazine", amount=2},
        {type="item", name="lead-plate", amount=22},
        {type="item", name="stone-wall", amount=2},
        {type="item", name="tailings-dust", amount=2},
      },
      results = {
        {type="item", name="military-science-pack", amount=2},
      },
    },
    ["niobium-mine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=25},
        {type="item", name="distilator", amount=1},
        {type="item", name="gasifier", amount=2},
        {type="item", name="inductor1", amount=316},
        {type="item", name="pipe", amount=36},
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
        {type="item", name="pbsb-alloy", amount=7},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="item", name="nxsb-alloy", amount=3},
      },
    },
    ["pbsb-alloy-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=13422},
        {type="fluid", name="hot-air", amount=3603},
        {type="item", name="cellulose", amount=4},
        {type="item", name="sb-oxide", amount=2},
      },
      results = {
        {type="item", name="pbsb-alloy", amount=6},
      },
    },
    ["powdered-phosphate-rock"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="phosphate-rock", amount=4},
      },
      results = {
        {type="item", name="powdered-phosphate-rock", amount=2},
        {type="item", name="stone", amount=2},
      },
    },
    ["stone-wool"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="oxygen", amount=143},
        {type="item", name="calcium-carbide", amount=8},
        {type="item", name="syngas-canister", amount=1},
        {type="item", name="zinc-plate", amount=3},
      },
      results = {
        {type="item", name="stone-wool", amount=4},
      },
    },
    ["stone-wool2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="boric-acid", amount=270},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="graphite", amount=1},
        {type="item", name="stone", amount=9},
      },
      results = {
        {type="item", name="stone-wool", amount=2},
      },
    },
    ["zipir-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="electronic-circuit", amount=2},
        {type="item", name="pipe", amount=10},
        {type="item", name="tin-plate", amount=5},
        {type="item", name="wood-seedling", amount=2},
      },
      results = {
        {type="item", name="zipir-codex", amount=1},
      },
    },
    ["zipir-eggs-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.51701810374389,
      ingredients = {
        {type="fluid", name="hot-air", amount=1547},
        {type="item", name="high-distillate-canister", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=109},
        {type="item", name="zipir-eggs", amount=2},
      },
    },
    ["zipir-reef-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=17},
        {type="item", name="bhoddos-spore", amount=17},
        {type="item", name="boiler", amount=21},
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="glass", amount=345},
        {type="item", name="micro-mine-mk01", amount=1},
        {type="item", name="nexelit-plate", amount=66},
        {type="item", name="pipe", amount=101},
        {type="item", name="sap-extractor-mk01", amount=1},
        {type="item", name="secondary-crusher-mk01", amount=1},
        {type="item", name="skin", amount=12},
        {type="item", name="small-parts-01", amount=134},
        {type="item", name="steam-engine", amount=20},
        {type="item", name="washer", amount=12},
        {type="item", name="wood-seedling", amount=8},
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
        {type="item", name="cellulose", amount=36},
        {type="item", name="shotgun-shell", amount=10},
        {type="item", name="zipir-eggs", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=117},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["zipir-a-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.43990602508825,
      ingredients = {
        {type="item", name="cellulose", amount=8},
        {type="item", name="fish", amount=3},
        {type="item", name="light-oil-canister", amount=6},
        {type="item", name="shotgun-shell", amount=6},
        {type="item", name="soil", amount=62},
        {type="item", name="zipir-eggs", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=150},
        {type="item", name="zipir1", amount=1},
      },
    },
    ["arthropod-blood-to-blood"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.79000433630682,
      ingredients = {
        {type="fluid", name="tailings", amount=1786},
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
        {type="item", name="auog", amount=122},
        {type="item", name="bolts", amount=413},
        {type="item", name="concrete", amount=87},
        {type="item", name="copper-plate", amount=250},
        {type="item", name="electronics-mk01", amount=8},
        {type="item", name="gasifier", amount=3},
        {type="item", name="grade-3-iron", amount=26},
        {type="item", name="inductor1", amount=60},
        {type="item", name="kerosene-canister", amount=227},
        {type="item", name="slacked-lime-barrel", amount=127},
        {type="item", name="soil-extractor-mk01", amount=9},
      },
      results = {
        {type="item", name="py-gas-powerplant-mk01", amount=1},
      },
    },
    ["ree-mining-drill-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="assembling-machine-2", amount=2},
        {type="item", name="iron-plate", amount=573},
        {type="item", name="nexelit-plate", amount=97},
        {type="item", name="pipe", amount=159},
      },
      results = {
        {type="item", name="ree-mining-drill-mk01", amount=3},
      },
    },
    ["pyrite-make"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="gravel", amount=11},
        {type="item", name="sand", amount=7},
      },
      results = {
        {type="item", name="pyrite", amount=1},
      },
    },
    ["rich-clay-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="steam", amount=78},
        {type="item", name="soil", amount=52},
      },
      results = {
        {type="item", name="rich-clay", amount=9},
      },
    },
    ["soot-to-aluminium"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.53215923580831,
      ingredients = {
        {type="item", name="cellulose", amount=2},
        {type="item", name="py-asphalt", amount=1},
        {type="item", name="soot", amount=10},
        {type="item", name="stone", amount=17},
        {type="item", name="tar-canister", amount=1},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-aluminium", amount=15},
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
      energy_required_multiplier = 2.00864222742116,
      ingredients = {
        {type="item", name="graphite", amount=4},
        {type="item", name="ore-aluminium", amount=15},
        {type="item", name="tailings-dust", amount=64},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="gold-plate", amount=1},
      },
    },
    ["soot-to-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.499701885837753,
      ingredients = {
        {type="item", name="soot", amount=5},
      },
      results = {
        {type="item", name="ash", amount=0.146690981501281},
        {type="item", name="iron-ore", amount=5},
      },
    },
    ["soot-to-silver"] = {
      mode = "kept-transformed",
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.0509390350894,
      ingredients = {
        {type="item", name="carbon-black", amount=10},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-zinc", amount=8},
      },
    },
    ["tailings-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.42976125532768,
      ingredients = {
        {type="item", name="gravel", amount=21},
        {type="item", name="tailings-dust", amount=14},
      },
      results = {
        {type="item", name="coal-dust", amount=7},
        {type="item", name="rich-dust", amount=3},
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
      energy_required_multiplier = 1.29548128132982,
      ingredients = {
        {type="item", name="carbon-black", amount=3},
        {type="item", name="soot", amount=9},
      },
      results = {
        {type="item", name="ash", amount=1},
        {type="item", name="ore-lead", amount=10},
      },
    },
    ["fetal-serum-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="item", name="guts", amount=5},
        {type="item", name="skin", amount=6},
        {type="item", name="zinc-plate", amount=15},
      },
      results = {
        {type="fluid", name="fetal-serum", amount=51},
      },
    },
    ["salt-ex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.26086956521739,
      ingredients = {
        {type="fluid", name="hot-air", amount=653},
        {type="fluid", name="hydrogen", amount=51},
        {type="fluid", name="oxygen", amount=106},
      },
      results = {
        {type="item", name="salt", amount=29},
      },
    },
    ["sand-washing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.757618991468627,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=95},
        {type="item", name="biomass", amount=2},
        {type="item", name="coarse", amount=5},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=63},
        {type="item", name="pure-sand", amount=6},
      },
    },
    ["acetic-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.78,
      ingredients = {
        {type="fluid", name="pressured-air", amount=390},
        {type="fluid", name="purest-nitrogen-gas", amount=42},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=39},
      },
    },
    ["ammonia-urea"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.51,
      ingredients = {
        {type="item", name="auog", amount=2},
        {type="item", name="bonemeal", amount=2},
        {type="item", name="coke", amount=6},
        {type="item", name="iron-stick", amount=7},
        {type="item", name="stopper", amount=5},
      },
      results = {
        {type="fluid", name="ammonia", amount=151},
      },
    },
    ["organic-solvent2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.72,
      ingredients = {
        {type="fluid", name="flue-gas", amount=390},
        {type="fluid", name="hot-air", amount=778},
        {type="fluid", name="steam", amount=58},
        {type="fluid", name="tailings", amount=192},
        {type="item", name="coal", amount=4},
      },
      results = {
        {type="fluid", name="ammonia", amount=86},
        {type="fluid", name="organic-solvent", amount=172},
      },
    },
    ["phosphorous-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="hydrogen", amount=120},
        {type="item", name="boron-trioxide", amount=1},
        {type="item", name="ceramic", amount=2},
        {type="item", name="limestone", amount=1},
        {type="item", name="stopper", amount=3},
      },
      results = {
        {type="fluid", name="phosphorous-acid", amount=51},
      },
    },
    ["tall-oil-separation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="hot-air", amount=209},
        {type="fluid", name="light-oil", amount=15},
        {type="item", name="limestone", amount=2},
      },
      results = {
        {type="fluid", name="aromatics", amount=14},
        {type="fluid", name="benzene", amount=14},
      },
    },
    ["tar-talloil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.01794869780964,
      ingredients = {
        {type="fluid", name="hot-air", amount=483},
        {type="item", name="gravel", amount=3},
        {type="item", name="sand", amount=2},
      },
      results = {
        {type="fluid", name="aromatics", amount=20},
        {type="fluid", name="light-oil", amount=51},
        {type="fluid", name="tall-oil", amount=51},
      },
    },
    ["fluidize-coke"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.15373890490747,
      ingredients = {
        {type="fluid", name="flue-gas", amount=110},
        {type="item", name="copper-ore", amount=6},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="stone", amount=6},
      },
      results = {
        {type="fluid", name="ammonia", amount=23},
        {type="fluid", name="tall-oil", amount=23},
        {type="fluid", name="tar", amount=35},
      },
    },
    ["methane-py-fertilizer"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="water", amount=69},
        {type="item", name="moondrop-seeds", amount=1},
        {type="item", name="raw-fiber", amount=1},
      },
      results = {
        {type="fluid", name="methane", amount=50},
      },
    },
    ["phosphoric-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=39},
        {type="fluid", name="tailings", amount=168},
        {type="item", name="bolts", amount=1},
        {type="item", name="coal", amount=4},
        {type="item", name="stone", amount=1},
      },
      results = {
        {type="fluid", name="hydrofluoric-acid", amount=5},
        {type="fluid", name="phosphine-gas", amount=5},
        {type="fluid", name="phosphoric-acid", amount=10},
      },
    },
    ["propene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.833412138367491,
      ingredients = {
        {type="fluid", name="pressured-water", amount=145},
        {type="fluid", name="syngas", amount=46},
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
        {type="fluid", name="kerosene", amount=3185},
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
        {type="item", name="graphite", amount=8},
        {type="item", name="ore-aluminium", amount=31},
      },
      results = {
        {type="fluid", name="al-pulp-01", amount=89},
      },
    },
    ["al-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.37,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=244},
        {type="fluid", name="petroleum-gas", amount=560},
        {type="item", name="coke", amount=9},
      },
      results = {
        {type="fluid", name="al-pulp-02", amount=137},
      },
    },
    ["molten-aluminium-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.74,
      ingredients = {
        {type="fluid", name="petroleum-gas", amount=779},
        {type="item", name="borax", amount=2},
        {type="item", name="coke", amount=5},
      },
      results = {
        {type="fluid", name="molten-aluminium", amount=37},
      },
    },
    ["fluorine-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=1282},
        {type="fluid", name="subcritical-water", amount=632},
        {type="item", name="ash", amount=2},
        {type="item", name="cellulose", amount=5},
      },
      results = {
        {type="fluid", name="fluorine-gas", amount=35},
        {type="fluid", name="hydrogen", amount=35},
      },
    },
    ["syngas-distilation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.768874507577201,
      ingredients = {
        {type="fluid", name="flue-gas", amount=452},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=38},
        {type="fluid", name="hydrogen", amount=77},
      },
    },
    ["gas-molten-salt-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.068,
      ingredients = {
        {type="fluid", name="fish-oil", amount=1395},
        {type="fluid", name="tar", amount=765},
        {type="item", name="lime", amount=103},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=534},
      },
    },
    ["wastewater-recovery"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.953333333333333,
      ingredients = {
        {type="fluid", name="ammonia", amount=112},
        {type="fluid", name="waste-water", amount=45},
        {type="item", name="boric-acid-barrel", amount=1},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=143},
      },
    },
    ["glass-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="steam", amount=100},
        {type="item", name="drill-head", amount=1},
        {type="item", name="powdered-aluminium", amount=2},
      },
      results = {
        {type="fluid", name="molten-glass", amount=48},
      },
    },
    ["powdered-quartz"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00928472869687,
      ingredients = {
        {type="fluid", name="ammonia", amount=38},
        {type="item", name="steel-plate", amount=6},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="powdered-quartz", amount=5},
      },
    },
    ["seaweed-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.55,
      ingredients = {
        {type="fluid", name="hot-air", amount=157},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="item", name="seaweed", amount=11},
      },
    },
    ["silver-plate-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.444444444444444,
      ingredients = {
        {type="item", name="grade-3-tin", amount=1},
        {type="item", name="residual-mixture-canister", amount=12},
      },
      results = {
        {type="item", name="silver-plate", amount=4},
      },
    },
    ["sulfur-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="barrel", amount=39},
        {type="item", name="bio-container", amount=91},
        {type="item", name="grade-3-chromite", amount=34},
        {type="item", name="grade-3-tin", amount=39},
        {type="item", name="inductor1", amount=80},
        {type="item", name="light-armor", amount=5},
        {type="item", name="petri-dish", amount=12},
        {type="item", name="phytoplankton-barrel", amount=12},
        {type="item", name="seaweed-crop-mk01", amount=2},
        {type="item", name="tar-processing-unit", amount=1},
      },
      results = {
        {type="item", name="sulfur-mine", amount=1},
      },
    },
    ["albumin-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="kerosene", amount=3913},
        {type="fluid", name="methanal", amount=684},
        {type="item", name="coal-dust", amount=5},
        {type="item", name="skin", amount=4},
        {type="item", name="urea", amount=11},
      },
      results = {
        {type="item", name="albumin", amount=8},
      },
    },
    ["formaldehyde-from-refined-natural-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.432391094436265,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=13},
        {type="fluid", name="muddy-sludge", amount=288},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=42},
        {type="fluid", name="methanal", amount=21},
        {type="fluid", name="molten-salt", amount=13},
      },
    },
    ["powedered-biomass"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="biomass", amount=24},
      },
      results = {
        {type="item", name="powdered-biomass", amount=24},
      },
    },
    ["sugar"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="condensates", amount=659},
        {type="fluid", name="naphthalene-oil", amount=495},
        {type="item", name="graphite", amount=6},
        {type="item", name="hot-air-barrel", amount=1},
      },
      results = {
        {type="item", name="sugar", amount=7},
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
      energy_required_multiplier = 0.448976670792036,
      ingredients = {
        {type="item", name="powdered-biomass", amount=13},
      },
      results = {
        {type="item", name="biomass", amount=1},
        {type="item", name="fine-powdered-biomass", amount=8},
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.56666666666667,
      ingredients = {
        {type="item", name="agar", amount=2},
        {type="item", name="ceramic", amount=1},
        {type="item", name="empty-barrel-milk", amount=1},
        {type="item", name="iron-plate", amount=5},
      },
      results = {
        {type="item", name="dried-biomass", amount=77},
      },
    },
    ["fungal-substrate-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="bonemeal", amount=2},
        {type="item", name="coke", amount=2},
        {type="item", name="iron-stick", amount=18},
        {type="item", name="stopper", amount=4},
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
        {type="item", name="raw-fiber", amount=9},
      },
      results = {
        {type="item", name="biomass", amount=6},
        {type="item", name="fiber", amount=5},
      },
    },
    ["micro-fiber"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="ceramic", amount=10},
        {type="item", name="lubricant-barrel", amount=2},
      },
      results = {
        {type="item", name="micro-fiber", amount=5},
      },
    },
    ["bitumen-to-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="pressured-air", amount=1039},
        {type="fluid", name="propene", amount=38},
      },
      results = {
        {type="item", name="ore-nickel", amount=6},
      },
    },
    ["grade-3-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="acidgas", amount=86},
        {type="item", name="nickel-plate", amount=5},
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
        {type="item", name="refined-natural-gas-canister", amount=2},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
        {type="item", name="sand", amount=2},
      },
    },
    ["grade-4-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=164},
        {type="item", name="soil", amount=14},
        {type="item", name="warmer-stone-brick", amount=8},
      },
      results = {
        {type="item", name="grade-4-nickel", amount=1},
      },
    },
    ["nickel-rejects-recrush"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="gasoline-canister", amount=7},
      },
      results = {
        {type="item", name="grade-1-nickel", amount=1},
      },
    },
    ["molten-nickel-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="steam", amount=195},
        {type="item", name="gasoline-canister", amount=2},
        {type="item", name="pure-sand", amount=4},
        {type="item", name="py-aluminium", amount=2},
      },
      results = {
        {type="fluid", name="molten-nickel", amount=35},
      },
    },
    ["hotair-nickel-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.428571428571429,
      ingredients = {
        {type="fluid", name="oxygen", amount=1421},
        {type="item", name="sand-casting", amount=1},
      },
      results = {
        {type="item", name="nickel-plate", amount=27},
      },
    },
    ["nickel-plate-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.68,
      ingredients = {
        {type="fluid", name="molten-glass", amount=498},
        {type="fluid", name="oxygen", amount=3018},
      },
      results = {
        {type="item", name="nickel-plate", amount=84},
      },
    },
    ["tar-to-nickel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=219},
        {type="fluid", name="pressured-water", amount=352},
      },
      results = {
        {type="item", name="ore-nickel", amount=10},
      },
    },
    ["soda-ash"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.565,
      ingredients = {
        {type="fluid", name="water-saline", amount=106},
        {type="item", name="ash", amount=72},
        {type="item", name="limestone", amount=9},
        {type="item", name="powdered-biomass", amount=5},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="fluid", name="soda-ash", amount=313},
      },
    },
    ["industrial-solvent"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="flue-gas", amount=760},
        {type="fluid", name="sulfuric-acid", amount=135},
        {type="fluid", name="tar", amount=415},
        {type="item", name="sulfur", amount=3},
      },
      results = {
        {type="fluid", name="industrial-solvent", amount=90},
      },
    },
    ["vanabins"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=701},
        {type="fluid", name="steam", amount=2224},
      },
      results = {
        {type="fluid", name="vanabins", amount=100},
      },
    },
    ["blue-liquor"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.605,
      ingredients = {
        {type="fluid", name="crude-oil", amount=1265},
        {type="fluid", name="tailings", amount=2438},
        {type="item", name="grade-2-iron", amount=1},
        {type="item", name="gravel", amount=96},
      },
      results = {
        {type="fluid", name="blue-liquor", amount=321},
      },
    },
    ["vpulp1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=213},
        {type="fluid", name="pressured-water", amount=217},
      },
      results = {
        {type="fluid", name="vpulp1", amount=42},
      },
    },
    ["molybdenum-pulp"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="item", name="capacitor1", amount=29},
      },
      results = {
        {type="fluid", name="molybdenum-pulp", amount=42},
        {type="fluid", name="muddy-sludge", amount=84},
      },
    },
    ["vpulp2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.12,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=25500},
        {type="item", name="gravel", amount=58},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="titanium-plate", amount=21},
      },
      results = {
        {type="fluid", name="vpulp2", amount=112},
      },
    },
    ["molybdenite-pulp"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.88,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=131},
        {type="item", name="iron-ore-dust", amount=3},
      },
      results = {
        {type="fluid", name="molybdenite-pulp", amount=88},
      },
    },
    ["vpulp3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.90254259166285,
      ingredients = {
        {type="fluid", name="lubricant", amount=1307},
        {type="fluid", name="pitch", amount=453},
        {type="fluid", name="water", amount=1907},
      },
      results = {
        {type="fluid", name="vpulp3", amount=43},
        {type="item", name="vanadium-oxide", amount=2},
      },
    },
    ["bitumen-to-asphalt"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="bitumen", amount=4},
        {type="fluid", name="flue-gas", amount=259},
        {type="fluid", name="hot-air", amount=83},
        {type="item", name="stone", amount=1},
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
        {type="item", name="ceramic", amount=4},
        {type="item", name="empty-barrel-milk", amount=1},
        {type="item", name="iron-plate", amount=14},
      },
      results = {
        {type="item", name="py-aluminium", amount=2},
      },
    },
    ["py-coal-tile"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=558},
        {type="fluid", name="medium-distillate", amount=23},
        {type="item", name="chromite-sand", amount=3},
        {type="item", name="chromium", amount=2},
        {type="item", name="medium-electric-pole", amount=1},
        {type="item", name="titanium-plate", amount=15},
      },
      results = {
        {type="item", name="py-coal-tile", amount=2},
      },
    },
    ["py-iron"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=7},
        {type="item", name="coarse-coal", amount=1},
        {type="item", name="processed-iron-ore", amount=2},
      },
      results = {
        {type="item", name="py-iron", amount=4},
      },
    },
    ["py-nexelit"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=2},
        {type="item", name="limestone", amount=3},
      },
      results = {
        {type="item", name="py-nexelit", amount=2},
      },
    },
    ["py-quartz"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="hot-air", amount=129},
        {type="fluid", name="slacked-lime", amount=32},
        {type="item", name="piercing-rounds-magazine", amount=1},
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="item", name="py-quartz", amount=5},
      },
    },
    ["py-steel"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="molten-steel", amount=16},
        {type="item", name="small-parts-01", amount=1},
      },
      results = {
        {type="item", name="py-steel", amount=3},
      },
    },
    ["hydrogen-chloride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.41,
      ingredients = {
        {type="fluid", name="hot-air", amount=158},
        {type="fluid", name="water-saline", amount=226},
        {type="item", name="ore-lead", amount=39},
        {type="item", name="small-lamp", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=141},
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
      energy_required_multiplier = 0.459649337039945,
      ingredients = {
        {type="fluid", name="hot-air", amount=2},
        {type="fluid", name="pressured-air", amount=41},
      },
      results = {
        {type="fluid", name="nitrogen", amount=9},
        {type="fluid", name="oxygen", amount=9},
        {type="fluid", name="purest-nitrogen-gas", amount=28},
      },
    },
    ["hcl-from-guts"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="item", name="guts", amount=10},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=48},
      },
    },
    ["nitrogen"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2.035,
      ingredients = {
        {type="fluid", name="purest-nitrogen-gas", amount=272},
        {type="item", name="methanol-canister", amount=1},
      },
      results = {
        {type="fluid", name="nitrogen", amount=407},
      },
    },
    ["sulfuric-acid-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.42,
      ingredients = {
        {type="fluid", name="acidgas", amount=42},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=21},
      },
    },
    ["zinc-chloride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="oxygen", amount=110},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen", amount=20},
        {type="item", name="zinc-chloride", amount=1},
      },
    },
    ["active-carbon"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=22},
        {type="item", name="rich-clay", amount=13},
        {type="item", name="starch", amount=1},
      },
      results = {
        {type="item", name="active-carbon", amount=6},
      },
    },
    ["co2-organics"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.71,
      ingredients = {
        {type="item", name="biomass", amount=7},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=213},
      },
    },
    ["drill-head"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bolts", amount=3},
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="graphite", amount=1},
        {type="item", name="small-parts-01", amount=7},
        {type="item", name="tin-plate", amount=5},
      },
      results = {
        {type="item", name="drill-head", amount=3},
      },
    },
    ["drill-head-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="tailings", amount=33},
        {type="item", name="calcium-carbide", amount=7},
        {type="item", name="tin-plate", amount=7},
      },
      results = {
        {type="item", name="drill-head", amount=2},
      },
    },
    ["drill-head-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 4.16666666666667,
      ingredients = {
        {type="item", name="lead-plate", amount=11},
        {type="item", name="light-oil-canister", amount=2},
        {type="item", name="nickel-plate", amount=14},
        {type="item", name="steam-engine", amount=2},
        {type="item", name="stone-wall", amount=3},
      },
      results = {
        {type="item", name="drill-head", amount=25},
      },
    },
    ["nichrome"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="lime", amount=5},
        {type="item", name="nickel-plate", amount=11},
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.20737334753928,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=75},
        {type="fluid", name="gasoline", amount=2},
        {type="fluid", name="pressured-water", amount=318},
        {type="item", name="coarse", amount=4},
      },
      results = {
        {type="fluid", name="liquid-nitrogen", amount=6},
        {type="fluid", name="steam", amount=124},
      },
    },
    ["coalbed-gas-to-hydrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.803333333333333,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=570},
        {type="fluid", name="tailings", amount=238},
        {type="item", name="coke", amount=12},
      },
      results = {
        {type="fluid", name="hydrogen", amount=241},
      },
    },
    ["drilling-fluid-0"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.92,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=272},
        {type="item", name="limestone", amount=3},
        {type="item", name="melamine-resin", amount=2},
        {type="item", name="sand-casting", amount=1},
        {type="item", name="warm-stone-brick", amount=3},
      },
      results = {
        {type="fluid", name="drilling-fluid-0", amount=96},
      },
    },
    ["minor-extract-gas-from-coalbed-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.49912212102855,
      ingredients = {
        {type="fluid", name="hot-air", amount=691},
        {type="fluid", name="steam", amount=1409},
        {type="item", name="iron-oxide", amount=3},
        {type="item", name="pure-sand", amount=5},
        {type="item", name="unslimed-iron", amount=1},
      },
      results = {
        {type="fluid", name="coalbed-gas", amount=225},
        {type="fluid", name="water", amount=3744},
      },
    },
    ["pressured-hydrogen"] = {
      mode = "softmax-semantic-substitution",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=5},
        {type="fluid", name="hot-air", amount=154},
        {type="fluid", name="syngas", amount=251},
      },
      results = {
        {type="fluid", name="pressured-hydrogen", amount=50},
        {type="fluid", name="steam", amount=600},
      },
    },
    ["aromatics-2-diesel2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.996666666666667,
      ingredients = {
        {type="fluid", name="light-oil", amount=155},
        {type="fluid", name="pressured-steam", amount=411},
        {type="fluid", name="scrude", amount=258},
        {type="fluid", name="water", amount=616},
        {type="item", name="calcium-carbide", amount=2},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=299},
      },
    },
    ["coalbed-gas-to-acidgas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.68666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=384},
        {type="fluid", name="pressured-water", amount=3046},
        {type="fluid", name="water-saline", amount=195},
        {type="item", name="flask", amount=1},
      },
      results = {
        {type="fluid", name="acidgas", amount=253},
        {type="fluid", name="flue-gas", amount=1518},
      },
    },
    ["coalbed-gas-to-co2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.04,
      ingredients = {
        {type="fluid", name="coal-gas", amount=33},
        {type="fluid", name="water", amount=189},
        {type="fluid", name="water-saline", amount=533},
        {type="item", name="flask", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=312},
      },
    },
    ["coalbed-gas-to-coalgas"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.26,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=504},
        {type="item", name="heavy-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="coal-gas", amount=504},
      },
    },
    ["coalbed-gas-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1669},
        {type="fluid", name="oxygen", amount=325},
        {type="fluid", name="tailings", amount=338},
        {type="item", name="coke", amount=5},
        {type="item", name="methanal-barrel", amount=1},
      },
      results = {
        {type="fluid", name="syngas", amount=340},
      },
    },
    ["natural-gas-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.825042729509776,
      ingredients = {
        {type="fluid", name="condensates", amount=12},
        {type="fluid", name="natural-gas", amount=77},
      },
      results = {
        {type="fluid", name="flue-gas", amount=166},
        {type="fluid", name="syngas", amount=41},
      },
    },
    ["quench-ovengas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.757846716673606,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=77},
      },
      results = {
        {type="fluid", name="flue-gas", amount=757},
        {type="fluid", name="syngas", amount=76},
      },
    },
    ["light-oil_from_syngas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.17295909226333,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1521},
        {type="fluid", name="flue-gas", amount=1154},
        {type="item", name="py-science-pack-1", amount=1},
      },
      results = {
        {type="fluid", name="light-oil", amount=352},
        {type="fluid", name="olefin", amount=176},
        {type="fluid", name="steam", amount=2344},
      },
    },
    ["petgas-from-refsyngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.56,
      ingredients = {
        {type="fluid", name="aromatics", amount=563},
        {type="fluid", name="syngas", amount=696},
        {type="fluid", name="tar", amount=219},
        {type="item", name="nexelit-plate", amount=2},
        {type="item", name="nichrome", amount=1},
      },
      results = {
        {type="fluid", name="olefin", amount=234},
        {type="fluid", name="petroleum-gas", amount=624},
      },
    },
    ["bone-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="syngas", amount=149},
        {type="item", name="bones", amount=4},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=24},
      },
    },
    ["dedicated-oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.748081549763195,
      ingredients = {
        {type="fluid", name="hot-air", amount=393},
        {type="item", name="skin", amount=6},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=187},
        {type="fluid", name="steam", amount=1497},
      },
    },
    ["oleochemicals"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5134271139623,
      ingredients = {
        {type="fluid", name="hot-air", amount=364},
        {type="fluid", name="oxygen", amount=120},
        {type="item", name="mukmoux-fat", amount=19},
        {type="item", name="skin", amount=5},
        {type="item", name="soda-ash-barrel", amount=1},
      },
      results = {
        {type="fluid", name="glycerol", amount=227},
        {type="fluid", name="oleochemicals", amount=454},
        {type="fluid", name="steam", amount=3029},
      },
    },
    ["petgas-methanol"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.65,
      ingredients = {
        {type="fluid", name="pressured-air", amount=3538},
        {type="fluid", name="pressured-water", amount=1066},
        {type="fluid", name="tar", amount=148},
        {type="item", name="niobium-dust", amount=6},
      },
      results = {
        {type="fluid", name="methanol", amount=165},
        {type="fluid", name="petroleum-gas", amount=165},
      },
    },
    ["fish-oil-to-lube"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.04,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=27},
        {type="fluid", name="sulfuric-acid", amount=3},
        {type="item", name="ash", amount=2},
      },
      results = {
        {type="fluid", name="lubricant", amount=4},
      },
    },
    ["olefin-lube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.764,
      ingredients = {
        {type="fluid", name="aromatics", amount=108},
        {type="fluid", name="methanol", amount=452},
      },
      results = {
        {type="fluid", name="lubricant", amount=191},
      },
    },
    ["coal-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.13326682911683,
      ingredients = {
        {type="fluid", name="tailings", amount=106},
        {type="item", name="moondrop-seeds", amount=5},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="coal-slurry", amount=170},
        {type="fluid", name="water", amount=113},
      },
    },
    ["refsyngas-from-filtered-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.871428571428571,
      ingredients = {
        {type="fluid", name="flue-gas", amount=393},
        {type="item", name="empty-petri-dish", amount=1},
      },
      results = {
        {type="fluid", name="refsyngas", amount=61},
      },
    },
    ["fluegas-to-syngas"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coal-gas", amount=389},
        {type="item", name="cellulose", amount=3},
      },
      results = {
        {type="fluid", name="syngas", amount=300},
      },
    },
    ["hydrogen-peroxide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.26,
      ingredients = {
        {type="fluid", name="hot-air", amount=121},
        {type="fluid", name="oxygen", amount=94},
        {type="fluid", name="pressured-steam", amount=1281},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="lime", amount=3},
        {type="item", name="nickel-plate", amount=6},
      },
      results = {
        {type="fluid", name="hydrogen-peroxide", amount=63},
      },
    },
    ["syngas2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.22835943961035,
      ingredients = {
        {type="fluid", name="coal-gas", amount=43},
        {type="fluid", name="flue-gas", amount=370},
        {type="fluid", name="steam", amount=95},
        {type="fluid", name="water", amount=86},
      },
      results = {
        {type="fluid", name="syngas", amount=125},
        {type="fluid", name="tar", amount=37},
        {type="item", name="ash", amount=1},
      },
    },
    ["coal-slurry-fuel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.42,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=2193},
        {type="fluid", name="steam", amount=105},
        {type="item", name="calcium-carbide", amount=13},
      },
      results = {
        {type="fluid", name="aromatics", amount=71},
        {type="fluid", name="benzene", amount=71},
      },
    },
    ["acidgas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.76666666666667,
      ingredients = {
        {type="fluid", name="refsyngas", amount=89},
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="grade-3-tin", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=265},
      },
    },
    ["acidgas-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.467737742970996,
      ingredients = {
        {type="fluid", name="hot-air", amount=65},
        {type="fluid", name="syngas", amount=215},
        {type="item", name="ore-lead", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=14},
        {type="fluid", name="steam", amount=281},
      },
    },
    ["pyrite-burn"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.58266318354794,
      ingredients = {
        {type="item", name="bones", amount=2},
        {type="item", name="grade-2-copper", amount=9},
      },
      results = {
        {type="fluid", name="acidgas", amount=79},
        {type="item", name="iron-oxide", amount=19},
      },
    },
    ["log4"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="fluid", name="steam", amount=315},
      },
      results = {
        {type="item", name="log", amount=1},
      },
    },
    ["log5"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.71428571428571,
      ingredients = {
        {type="fluid", name="hot-air", amount=211},
        {type="fluid", name="oxygen", amount=202},
        {type="fluid", name="steam", amount=218},
        {type="item", name="wood-seedling", amount=6},
      },
      results = {
        {type="item", name="log", amount=12},
      },
    },
    ["log6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="hot-air", amount=141},
        {type="fluid", name="water", amount=1876},
        {type="item", name="coal-dust", amount=11},
        {type="item", name="wooden-chest", amount=6},
      },
      results = {
        {type="item", name="log", amount=6},
      },
    },
    ["wood-seedling-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=1},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="gravel", amount=8},
        {type="item", name="wood-seedling", amount=8},
      },
      results = {
        {type="item", name="wood-seedling-mk02", amount=1},
      },
    },
    ["wood-seeds-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.96356948522976,
      ingredients = {
        {type="fluid", name="tar", amount=417},
        {type="item", name="plasmids", amount=2},
        {type="item", name="tree-mk01", amount=2},
      },
      results = {
        {type="item", name="wood-seeds", amount=1},
        {type="item", name="wood-seeds-mk02", amount=0.00926508443301452},
      },
    },
    ["wood-seeds-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="ralesia", amount=67},
      },
      results = {
        {type="item", name="wood-seeds-mk02", amount=2},
      },
    },
    ["tree-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="polybutadiene", amount=785},
        {type="item", name="empty-planter-box", amount=1},
        {type="item", name="wood-seedling", amount=42},
      },
      results = {
        {type="item", name="tree-mk02", amount=2},
      },
    },
    ["ulric"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=458},
        {type="item", name="bio-sample01", amount=10},
        {type="item", name="coal-dust", amount=656},
        {type="item", name="earth-generic-sample", amount=7},
        {type="item", name="formamide-barrel", amount=93},
        {type="item", name="kicalk-codex", amount=2},
        {type="item", name="ralesia-plantation-mk01", amount=4},
      },
      results = {
        {type="item", name="ulric", amount=3},
      },
    },
    ["ulric-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-cable", amount=64},
        {type="item", name="duralumin", amount=22},
        {type="item", name="empty-comb", amount=2},
        {type="item", name="seaweed", amount=29},
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
        {type="item", name="copper-plate", amount=19},
        {type="item", name="nexelit-plate", amount=5},
        {type="item", name="pipe", amount=23},
        {type="item", name="plastic-bar", amount=248},
        {type="item", name="tin-plate", amount=23},
        {type="item", name="tinned-cable", amount=88},
      },
      results = {
        {type="item", name="ulric-corral-mk01", amount=1},
      },
    },
    ["ulric-food-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.16666666666667,
      ingredients = {
        {type="fluid", name="water", amount=3546},
        {type="item", name="bolts", amount=9},
        {type="item", name="coal-dust", amount=42},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="flue-gas-barrel", amount=3},
        {type="item", name="gravel", amount=13},
        {type="item", name="heavy-oil-barrel", amount=1},
        {type="item", name="meat", amount=3},
        {type="item", name="wooden-chest", amount=3},
      },
      results = {
        {type="item", name="ulric-food-01", amount=13},
      },
    },
    ["ulric-cub-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3.08247626843593,
      ingredients = {
        {type="item", name="middle-oil-barrel", amount=1},
        {type="item", name="processed-iron-ore", amount=24},
        {type="item", name="ralesia", amount=50},
        {type="item", name="raw-fiber", amount=3},
        {type="item", name="tall-oil-barrel", amount=7},
        {type="item", name="water-barrel", amount=15},
      },
      results = {
        {type="item", name="barrel", amount=47},
        {type="item", name="ulric-cub", amount=9},
      },
    },
    ["ulric-manure-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.638433696232636,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=3},
        {type="item", name="ralesia", amount=8},
        {type="item", name="tall-oil-barrel", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="manure", amount=2},
      },
    },
    ["ulric-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.34811594078388,
      ingredients = {
        {type="item", name="iron-plate", amount=10},
        {type="item", name="nitrogen-barrel", amount=1},
        {type="item", name="pipe", amount=3},
        {type="item", name="purest-nitrogen-gas-barrel", amount=4},
        {type="item", name="ralesia", amount=4},
        {type="item", name="small-parts-01", amount=14},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-seeds", amount=47},
      },
      results = {
        {type="item", name="cage", amount=1},
        {type="item", name="ulric", amount=1},
      },
    },
    ["earth-cow-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=23},
        {type="item", name="pipe", amount=279},
        {type="item", name="py-science-pack-1", amount=10},
        {type="item", name="sap-tree", amount=3},
      },
      results = {
        {type="item", name="earth-cow-sample", amount=1},
      },
    },
    ["earth-crustacean-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="melamine", amount=245},
        {type="item", name="pipe", amount=375},
        {type="item", name="py-science-pack-1", amount=27},
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
        {type="item", name="logistic-science-pack", amount=23},
        {type="item", name="moss-gen", amount=23},
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
        {type="item", name="auog", amount=58},
        {type="item", name="automation-science-pack", amount=19},
        {type="item", name="bhoddos-spore", amount=41},
        {type="item", name="bolts", amount=212},
        {type="item", name="copper-plate", amount=303},
        {type="item", name="electronics-mk01", amount=10},
        {type="item", name="gasifier", amount=3},
        {type="item", name="grade-3-iron", amount=12},
        {type="item", name="kerosene-canister", amount=108},
        {type="item", name="moss-gen", amount=2},
        {type="item", name="py-science-pack-1", amount=162},
        {type="item", name="slacked-lime-barrel", amount=19},
        {type="item", name="soil-extractor-mk01", amount=11},
        {type="item", name="yaedols-codex", amount=1},
      },
      results = {
        {type="item", name="earth-potato-sample", amount=2},
      },
    },
    ["earth-sea-sponge-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="kicalk-codex", amount=2},
        {type="item", name="logistic-science-pack", amount=71},
        {type="item", name="moss-gen", amount=28},
        {type="item", name="py-science-pack-1", amount=79},
        {type="item", name="sea-sponge-codex", amount=3},
      },
      results = {
        {type="item", name="earth-sea-sponge-sample", amount=3},
      },
    },
    ["earth-bee-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cdna", amount=2},
        {type="item", name="pipe", amount=1199},
        {type="item", name="py-science-pack-1", amount=65},
        {type="item", name="small-lamp", amount=151},
        {type="item", name="smelter-mk01", amount=1},
        {type="item", name="zipir-codex", amount=58},
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
        {type="item", name="bio-sample", amount=6},
        {type="item", name="pipe", amount=629},
        {type="item", name="small-lamp", amount=92},
        {type="item", name="zipir-codex", amount=14},
      },
      results = {
        {type="item", name="earth-horse-sample", amount=1},
      },
    },
    ["kicalk-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample01", amount=6},
        {type="item", name="ball-mill-mk01", amount=7},
        {type="item", name="cottongut-codex", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=1},
      },
    },
    ["kicalk-fiber"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="warmer-stone-brick", amount=1},
      },
      results = {
        {type="item", name="raw-fiber", amount=4},
      },
    },
    ["kicalk-seeds"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="muddy-sludge-barrel", amount=1},
      },
      results = {
        {type="item", name="kicalk-seeds", amount=6},
      },
    },
    ["kicalk-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4.8,
      ingredients = {
        {type="item", name="ceramic", amount=9},
        {type="item", name="limestone", amount=6},
        {type="item", name="methanol-canister", amount=4},
        {type="item", name="outlet-gas-02-canister", amount=3},
        {type="item", name="tinned-cable", amount=6},
      },
      results = {
        {type="item", name="kicalk", amount=48},
      },
    },
    ["kicalk-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="fluid", name="hot-air", amount=203},
        {type="item", name="limestone", amount=3},
        {type="item", name="methanol-canister", amount=2},
        {type="item", name="tinned-cable", amount=3},
      },
      results = {
        {type="item", name="kicalk", amount=10},
      },
    },
    ["sea-sponge"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=338},
        {type="item", name="cdna", amount=3},
        {type="item", name="grade-3-lead", amount=699},
        {type="item", name="tuuphra-codex", amount=1},
      },
      results = {
        {type="item", name="sea-sponge", amount=2},
      },
    },
    ["sea-sponge-sprouts"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
    },
    ["sea-sponge-processing-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="sap-seeds-mk02", amount=3},
        {type="item", name="sea-sponge", amount=1},
      },
      results = {
        {type="item", name="ore-quartz", amount=18},
      },
    },
    ["sea-sponge-sprouts-processing-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.28571428571429,
      ingredients = {
        {type="item", name="workers-food", amount=1},
      },
      results = {
        {type="item", name="ore-quartz", amount=9},
      },
    },
    ["arthropod-blood-to-organic-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.476923076923077,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=21},
        {type="fluid", name="oxygen", amount=106},
        {type="fluid", name="tailings", amount=79},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=62},
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
      energy_required_multiplier = 0.371428571428571,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=2},
        {type="item", name="coal", amount=3},
        {type="item", name="sand", amount=1},
      },
      results = {
        {type="fluid", name="tar", amount=26},
      },
    },
    ["cobalt-extract"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33236100358959,
      ingredients = {
        {type="fluid", name="aromatics", amount=390},
        {type="fluid", name="methanal", amount=795},
        {type="fluid", name="methanol", amount=204},
        {type="fluid", name="pressured-water", amount=406},
        {type="item", name="green-sic", amount=2},
      },
      results = {
        {type="fluid", name="tailings", amount=65},
        {type="item", name="cobalt-extract", amount=4},
      },
    },
    ["flue-gas-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.68,
      ingredients = {
        {type="fluid", name="pressured-air", amount=898},
        {type="item", name="ash", amount=8},
      },
      results = {
        {type="fluid", name="flue-gas", amount=252},
      },
    },
    ["gasoline"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="aromatics", amount=69},
        {type="fluid", name="steam", amount=81},
        {type="fluid", name="syngas", amount=243},
        {type="item", name="nexelit-plate", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="fluid", name="gasoline", amount=60},
      },
    },
    ["olefin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.785,
      ingredients = {
        {type="fluid", name="steam", amount=651},
        {type="item", name="nexelit-plate", amount=2},
      },
      results = {
        {type="fluid", name="olefin", amount=157},
      },
    },
    ["sea-sponge-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.995259700353323,
      ingredients = {
        {type="fluid", name="slacked-lime", amount=365},
        {type="item", name="btx-canister", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=95},
        {type="item", name="sea-sponge", amount=1},
      },
    },
    ["sulfuric-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="hydrogen-peroxide", amount=21},
        {type="item", name="sulfur", amount=5},
      },
      results = {
        {type="fluid", name="sulfuric-acid", amount=24},
      },
    },
    ["wastewater-filtration"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.78,
      ingredients = {
        {type="fluid", name="kerosene", amount=1364},
        {type="item", name="methanal-barrel", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=178},
      },
    },
    ["agitator-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=68},
        {type="item", name="assembling-machine-2", amount=2},
        {type="item", name="duralumin", amount=12},
        {type="item", name="gasifier", amount=1},
        {type="item", name="inductor1", amount=211},
        {type="item", name="iron-plate", amount=1307},
        {type="item", name="nexelit-plate", amount=27},
        {type="item", name="pipe", amount=44},
        {type="item", name="stone-brick", amount=55},
        {type="item", name="storage-tank", amount=2},
      },
      results = {
        {type="item", name="agitator-mk01", amount=3},
      },
    },
    ["centrifugal-pan-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=26},
        {type="item", name="boiler", amount=33},
        {type="item", name="carbon-dioxide-barrel", amount=22},
        {type="item", name="concrete", amount=86},
        {type="item", name="glass", amount=1360},
        {type="item", name="inductor1", amount=47},
        {type="item", name="nexelit-plate", amount=253},
        {type="item", name="pipe", amount=159},
        {type="item", name="sap-extractor-mk01", amount=6},
        {type="item", name="secondary-crusher-mk01", amount=4},
        {type="item", name="steam-engine", amount=28},
      },
      results = {
        {type="item", name="centrifugal-pan-mk01", amount=3},
      },
    },
    ["compressor-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=44},
        {type="item", name="boiler", amount=14},
        {type="item", name="dirty-syngas-barrel", amount=8},
        {type="item", name="fertilizer", amount=75},
        {type="item", name="glass", amount=17},
        {type="item", name="jaw-crusher", amount=5},
        {type="item", name="pbsb-alloy", amount=37},
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
        {type="item", name="bhoddos-spore", amount=384},
        {type="item", name="bolts", amount=139},
        {type="item", name="btx-barrel", amount=16},
        {type="item", name="concrete", amount=550},
        {type="item", name="evaporator", amount=4},
        {type="item", name="inductor1", amount=204},
        {type="item", name="jaw-crusher", amount=3},
        {type="item", name="methanol-reactor", amount=1},
        {type="item", name="nexelit-plate", amount=69},
        {type="item", name="nichrome", amount=45},
        {type="item", name="titanium-plate", amount=53},
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
        {type="item", name="boiler", amount=12},
        {type="item", name="copper-plate", amount=22},
        {type="item", name="dried-meat", amount=2},
        {type="item", name="duralumin", amount=15},
        {type="item", name="fish-oil-barrel", amount=2},
        {type="item", name="glass", amount=30},
        {type="item", name="grade-2-zinc", amount=12},
        {type="item", name="naphthalene-oil-canister", amount=1},
        {type="item", name="nexelit-plate", amount=48},
        {type="item", name="raw-borax", amount=26},
        {type="item", name="small-parts-01", amount=9},
        {type="item", name="storage-tank", amount=3},
        {type="item", name="vitreloy", amount=11},
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
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="chromium", amount=26},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="nexelit-plate", amount=108},
        {type="item", name="ore-nickel", amount=41},
        {type="item", name="syngas-barrel", amount=12},
        {type="item", name="vitreloy", amount=11},
      },
      results = {
        {type="item", name="thickener-mk01", amount=1},
      },
    },
    ["casein"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methanol", amount=633},
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
        {type="item", name="borax", amount=10},
        {type="item", name="hydrogen-barrel", amount=5},
      },
      results = {
        {type="item", name="green-sic", amount=3},
      },
    },
    ["mixed-ores"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.01385753221916,
      ingredients = {
        {type="item", name="fertilizer", amount=1},
        {type="item", name="grade-2-copper", amount=2},
        {type="item", name="ralesia-seeds", amount=8},
      },
      results = {
        {type="item", name="mixed-ores", amount=5},
        {type="item", name="stone", amount=1},
      },
    },
    ["cobalt-fluoride"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="pressured-air", amount=5071},
        {type="item", name="cobalt-extract", amount=3},
        {type="item", name="ree-concentrate", amount=11},
      },
      results = {
        {type="item", name="cobalt-fluoride", amount=4},
      },
    },
    ["quartz-tube"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=1529},
        {type="item", name="borax", amount=4},
        {type="item", name="calcium-carbide", amount=33},
        {type="item", name="hydrogen-barrel", amount=15},
        {type="item", name="molten-aluminium-barrel", amount=1},
      },
      results = {
        {type="item", name="quartz-tube", amount=5},
      },
    },
    ["sic"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="methanal", amount=41},
        {type="item", name="clean-nexelit", amount=5},
        {type="item", name="empty-barrel-milk", amount=11},
      },
      results = {
        {type="item", name="sic", amount=5},
      },
    },
    ["artificial-blood"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.69,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=783},
        {type="item", name="moondrop-greenhouse-mk01", amount=1},
        {type="item", name="urea", amount=3},
      },
      results = {
        {type="fluid", name="artificial-blood", amount=69},
      },
    },
    ["decalin"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.44,
      ingredients = {
        {type="fluid", name="boric-acid", amount=320},
        {type="fluid", name="carbon-dioxide", amount=2004},
        {type="fluid", name="steam", amount=180},
        {type="item", name="bolts", amount=7},
        {type="item", name="chromium", amount=5},
        {type="item", name="titanium-plate", amount=2},
      },
      results = {
        {type="fluid", name="decalin", amount=72},
      },
    },
    ["flutec-pp6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.61,
      ingredients = {
        {type="fluid", name="molten-glass", amount=228},
        {type="fluid", name="pressured-air", amount=1173},
        {type="item", name="blue-liquor-barrel", amount=3},
        {type="item", name="cobalt-extract", amount=6},
        {type="item", name="ree-concentrate", amount=8},
        {type="item", name="wood-seedling", amount=1},
      },
      results = {
        {type="fluid", name="flutec-pp6", amount=161},
      },
    },
    ["bio-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="hot-residual-mixture", amount=219},
        {type="fluid", name="hydrogen", amount=206},
        {type="fluid", name="nitrogen", amount=230},
        {type="fluid", name="water", amount=439},
        {type="item", name="dried-meat", amount=1},
        {type="item", name="quartz-tube", amount=1},
        {type="item", name="stone-wool", amount=2},
      },
      results = {
        {type="fluid", name="bio-oil", amount=510},
        {type="item", name="quartz-tube", amount=1},
      },
    },
    ["bio-oil-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1075},
      },
      results = {
        {type="item", name="raw-coal", amount=6},
      },
    },
    ["moondrop-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="fluid", name="boric-acid", amount=19},
        {type="fluid", name="steam", amount=205},
        {type="item", name="moondrop-seeds", amount=3},
        {type="item", name="sand", amount=16},
      },
      results = {
        {type="item", name="moondrop", amount=5},
      },
    },
    ["moondrop-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.05040148059822,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=474},
        {type="fluid", name="hydrogen", amount=127},
        {type="item", name="fertilizer", amount=10},
        {type="item", name="grade-2-lead", amount=3},
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-seeds", amount=4},
        {type="item", name="soot", amount=4},
      },
      results = {
        {type="item", name="moondrop", amount=1},
        {type="item", name="moondrop-mk02", amount=0.00525200740299112},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2386},
        {type="fluid", name="pressured-steam", amount=1244},
        {type="fluid", name="steam", amount=796},
        {type="item", name="ash", amount=5},
        {type="item", name="glycerol-barrel", amount=3},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="moondrop-mk02", amount=5},
      },
    },
    ["oleochemicals-bioplastic"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.3,
      ingredients = {
        {type="fluid", name="pressured-water", amount=726},
        {type="fluid", name="scrude", amount=1265},
        {type="fluid", name="sulfuric-acid", amount=265},
        {type="item", name="belt", amount=2},
      },
      results = {
        {type="item", name="plastic-bar", amount=13},
      },
    },
    ["plastic-from-casein"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="hot-air", amount=97},
        {type="item", name="clean-nexelit", amount=32},
        {type="item", name="grade-2-copper", amount=1},
        {type="item", name="ralesia", amount=1},
      },
      results = {
        {type="item", name="plastic-bar", amount=18},
      },
    },
    ["plastic-from-melamine"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.8,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=2},
        {type="item", name="melamine-resin", amount=3},
      },
      results = {
        {type="item", name="plastic-bar", amount=14},
      },
    },
    ["zipir1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cumene", amount=2123},
        {type="fluid", name="drilling-fluid-0", amount=1950},
        {type="item", name="burner-mining-drill", amount=17},
        {type="item", name="cottongut", amount=4},
        {type="item", name="earth-generic-sample", amount=2},
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="lab-instrument", amount=4},
        {type="item", name="nichrome", amount=14},
        {type="item", name="purified-syngas-canister", amount=350},
        {type="item", name="stone-wool", amount=7},
      },
      results = {
        {type="item", name="zipir1", amount=1},
      },
    },
    ["alien-sample-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=4740},
        {type="fluid", name="subcritical-water", amount=49061},
        {type="item", name="caged-vrauks", amount=2},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="grade-4-nickel", amount=10},
        {type="item", name="lab-instrument", amount=1},
        {type="item", name="moondrop-greenhouse-mk01", amount=2},
        {type="item", name="moss", amount=20},
        {type="item", name="pipe", amount=174},
        {type="item", name="plastic-bar", amount=10},
      },
      results = {
        {type="item", name="alien-sample-02", amount=2},
      },
    },
    ["cytostatics"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=313},
        {type="fluid", name="tailings", amount=392},
        {type="item", name="benzene-canister", amount=7},
        {type="item", name="flask", amount=6},
        {type="item", name="retrovirus", amount=16},
        {type="item", name="titanium-plate", amount=25},
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
        {type="fluid", name="hot-air", amount=2437},
        {type="fluid", name="kerosene", amount=622},
        {type="item", name="aluminium-plate", amount=45},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="dna-polymerase", amount=1},
      },
    },
    ["manure-bacteria"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.37,
      ingredients = {
        {type="fluid", name="vacuum", amount=426},
        {type="item", name="cellulose", amount=4},
        {type="item", name="dried-meat", amount=6},
        {type="item", name="petri-dish-bacteria", amount=1},
      },
      results = {
        {type="fluid", name="manure-bacteria", amount=137},
      },
    },
    ["primers"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.42857142857143,
      ingredients = {
        {type="fluid", name="hot-air", amount=1934},
        {type="fluid", name="kerosene", amount=6621},
        {type="item", name="flask", amount=14},
        {type="item", name="ore-tin", amount=42},
        {type="item", name="stopper", amount=16},
      },
      results = {
        {type="item", name="primers", amount=1},
      },
    },
    ["retrovirus-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3.66666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=1480},
        {type="item", name="aluminium-plate", amount=29},
        {type="item", name="cocoon", amount=11},
        {type="item", name="empty-petri-dish", amount=2},
        {type="item", name="lab-instrument", amount=3},
        {type="item", name="stopper", amount=13},
        {type="item", name="vrauks", amount=2},
      },
      results = {
        {type="item", name="retrovirus", amount=11},
      },
    },
    ["cottongut-science-green-seeds"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.62926160915115,
      ingredients = {
        {type="fluid", name="formic-acid", amount=1128},
        {type="item", name="benzene-canister", amount=8},
        {type="item", name="cottongut", amount=39},
        {type="item", name="lab-instrument", amount=5},
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
      energy_required_multiplier = 0.57,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=2104},
        {type="item", name="cellulose", amount=5},
      },
      results = {
        {type="fluid", name="gasoline", amount=57},
      },
    },
    ["tuuphra-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="aluminium-plate", amount=57},
        {type="item", name="bio-sample01", amount=10},
        {type="item", name="cdna", amount=2},
        {type="item", name="grade-3-lead", amount=280},
        {type="item", name="ralesia-codex", amount=1},
        {type="item", name="selector-combinator", amount=7},
        {type="item", name="steel-plate", amount=34},
        {type="item", name="tuuphra-codex", amount=1},
      },
      results = {
        {type="item", name="tuuphra", amount=3},
      },
    },
    ["tuuphra-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="processed-iron-ore", amount=16},
        {type="item", name="tin-ore-rejects", amount=1},
      },
      results = {
        {type="item", name="tuuphra-seeds", amount=12},
      },
    },
    ["tuuphra-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=127},
        {type="fluid", name="pressured-steam", amount=2450},
        {type="item", name="ralesia-seeds", amount=14},
        {type="item", name="sand", amount=14},
      },
      results = {
        {type="item", name="tuuphra", amount=2},
      },
    },
    ["sweet-syrup"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="condensates", amount=1153},
        {type="item", name="graphite", amount=3},
      },
      results = {
        {type="fluid", name="sweet-syrup", amount=48},
      },
    },
    ["a-molasse"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.769957464589459,
      ingredients = {
        {type="item", name="yaedols", amount=7},
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
        {type="item", name="bones", amount=23},
        {type="item", name="condensates-barrel", amount=4},
        {type="item", name="copper-cable", amount=9},
        {type="item", name="small-parts-01", amount=5},
        {type="item", name="steel-plate", amount=61},
      },
      results = {
        {type="item", name="korlex-codex", amount=1},
      },
    },
    ["korlex-food-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="fluid", name="creosote", amount=272},
        {type="item", name="chitin", amount=2},
        {type="item", name="empty-barrel-milk", amount=10},
        {type="item", name="gasoline-canister", amount=3},
        {type="item", name="grade-2-tin", amount=1},
        {type="item", name="powdered-aluminium", amount=1},
        {type="item", name="py-coal-tile", amount=3},
        {type="item", name="sand", amount=25},
        {type="item", name="slacked-lime-barrel", amount=3},
        {type="item", name="tin-plate", amount=3},
        {type="item", name="yaedols", amount=2},
      },
      results = {
        {type="item", name="korlex-food-01", amount=7},
      },
    },
    ["korlex"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=3492},
        {type="item", name="aluminium-plate", amount=96},
        {type="item", name="ball-mill-mk01", amount=2},
        {type="item", name="bio-sample", amount=23},
        {type="item", name="burner-mining-drill", amount=350},
        {type="item", name="cdna", amount=11},
        {type="item", name="coal-dust", amount=215},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="ree-mining-drill-mk01", amount=1},
      },
      results = {
        {type="item", name="korlex", amount=2},
      },
    },
    ["korlex-milk-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.32406096664734,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=1},
        {type="item", name="glycerol-barrel", amount=2},
        {type="item", name="hot-air-barrel", amount=4},
        {type="item", name="lead-plate", amount=13},
        {type="item", name="light-oil-canister", amount=2},
        {type="item", name="yaedols", amount=9},
      },
      results = {
        {type="item", name="barrel", amount=13},
        {type="item", name="barrel-milk", amount=4},
      },
    },
    ["korlex-pup-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.68796229244479,
      ingredients = {
        {type="item", name="artificial-blood-barrel", amount=1},
        {type="item", name="diborane-barrel", amount=5},
        {type="item", name="fish", amount=16},
        {type="item", name="plastic-bar", amount=6},
        {type="item", name="sb-grade-03", amount=28},
        {type="item", name="tall-oil-barrel", amount=3},
        {type="item", name="tinned-cable", amount=5},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=44},
        {type="item", name="korlex-pup", amount=5},
      },
    },
    ["korlex-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=238},
        {type="item", name="grade-3-chromite", amount=6},
        {type="item", name="hot-syngas-barrel", amount=7},
        {type="item", name="refsyngas-barrel", amount=4},
        {type="item", name="water-barrel", amount=9},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=2},
      },
    },
    ["uncaged-korlex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="caged-ulric", amount=7},
      },
      results = {
        {type="item", name="cage", amount=2},
        {type="item", name="korlex", amount=2},
      },
    },
    ["outlet-gas-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.957461201462589,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=384},
        {type="fluid", name="pressured-air", amount=300},
        {type="fluid", name="syngas", amount=837},
      },
      results = {
        {type="fluid", name="outlet-gas-02", amount=96},
        {type="item", name="sulfur", amount=19},
      },
    },
    ["quench-redcoke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.96961122148209,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=119},
        {type="fluid", name="pressured-air", amount=115},
        {type="item", name="fine-powdered-biomass", amount=66},
      },
      results = {
        {type="fluid", name="steam", amount=96},
        {type="item", name="coal-dust", amount=4},
        {type="item", name="coke", amount=29},
      },
    },
    ["redhot-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.81707024631884,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=285},
        {type="item", name="coal", amount=38},
        {type="item", name="sand", amount=3},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=92},
        {type="item", name="redhot-coke", amount=9},
      },
    },
    ["outlet-gas-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.13,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=82},
        {type="fluid", name="hot-air", amount=909},
        {type="fluid", name="steam", amount=262},
        {type="item", name="stone", amount=4},
        {type="item", name="zinc-plate", amount=1},
      },
      results = {
        {type="fluid", name="outlet-gas-01", amount=113},
      },
    },
    ["molybdenum-filtration"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=274},
        {type="item", name="capacitor1", amount=65},
        {type="item", name="tar-barrel", amount=1},
      },
      results = {
        {type="item", name="molybdenum-sulfide", amount=17},
      },
    },
    ["calcinate-bone"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="guts", amount=3},
        {type="item", name="used-auog", amount=1},
      },
      results = {
        {type="item", name="calcinates", amount=7},
      },
    },
    ["molybdenum-concentrate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00218936713537,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=246},
        {type="fluid", name="flue-gas", amount=2558},
        {type="fluid", name="hydrogen", amount=349},
        {type="item", name="iron-ore-dust", amount=2},
      },
      results = {
        {type="fluid", name="muddy-sludge", amount=156},
        {type="item", name="molybdenum-concentrate", amount=10},
      },
    },
    ["molybdenum-oxide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.80096366729639,
      ingredients = {
        {type="item", name="copper-low-dust", amount=6},
        {type="item", name="ralesia", amount=105},
      },
      results = {
        {type="item", name="molybdenum-oxide", amount=18},
        {type="item", name="sulfur", amount=2},
      },
    },
    ["calcinate-separation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 6.95317016551079,
      ingredients = {
        {type="item", name="calcinates", amount=131},
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
      energy_required_multiplier = 1.6666405795653,
      ingredients = {
        {type="item", name="fungal-substrate-02", amount=21},
        {type="item", name="methanol-gas-canister", amount=9},
        {type="item", name="soil", amount=22},
      },
      results = {
        {type="fluid", name="water", amount=16},
        {type="item", name="molybdenum-plate", amount=5},
      },
    },
    ["seaweed-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="capacitor1", amount=3},
        {type="item", name="fungal-substrate-02", amount=16},
        {type="item", name="raw-fiber", amount=3},
      },
      results = {
        {type="item", name="seaweed-mk02", amount=1},
      },
    },
    ["fertilizer-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="methanal", amount=135},
        {type="item", name="coal-dust", amount=8},
        {type="item", name="skin", amount=2},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="fertilizer", amount=6},
      },
    },
    ["fertilizer-3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="water", amount=99},
        {type="item", name="limestone", amount=9},
        {type="item", name="powdered-biomass", amount=5},
        {type="item", name="urea", amount=1},
      },
      results = {
        {type="item", name="fertilizer", amount=5},
      },
    },
    ["fertilizer-fish-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="fish-oil", amount=372},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["formic-acid"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.87,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=1039},
        {type="fluid", name="sulfuric-acid", amount=38},
      },
      results = {
        {type="fluid", name="formic-acid", amount=87},
      },
    },
    ["sap-seeds-mk02-gen"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="empty-planter-box", amount=2},
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="tree-mk01", amount=13},
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
        {type="item", name="bones", amount=4},
      },
      results = {
        {type="item", name="sap-seeds-mk02", amount=2},
      },
    },
    ["sap-tree-mk02-gen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="hydrogen", amount=220},
        {type="fluid", name="syngas", amount=398},
        {type="item", name="bones", amount=26},
        {type="item", name="outlet-gas-01-barrel", amount=4},
        {type="item", name="raw-fiber", amount=6},
        {type="item", name="used-auog", amount=1},
      },
      results = {
        {type="item", name="sap-tree-mk02", amount=2},
      },
    },
    ["casein-pulp-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.44,
      ingredients = {
        {type="fluid", name="hot-air", amount=98},
        {type="fluid", name="subcritical-water", amount=927},
      },
      results = {
        {type="fluid", name="casein-pulp-01", amount=44},
        {type="fluid", name="muddy-sludge", amount=22},
      },
    },
    ["fish-hydrolysate"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.24,
      ingredients = {
        {type="fluid", name="hot-air", amount=1865},
        {type="item", name="fish", amount=10},
      },
      results = {
        {type="fluid", name="fish-hydrolysate", amount=62},
      },
    },
    ["casein-mixture-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.52,
      ingredients = {
        {type="fluid", name="flue-gas", amount=691},
        {type="fluid", name="milk", amount=21},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=26},
        {type="fluid", name="waste-water", amount=26},
      },
    },
    ["casein-pulp-02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.76,
      ingredients = {
        {type="fluid", name="methanal", amount=302},
        {type="fluid", name="steam", amount=141},
        {type="fluid", name="subcritical-water", amount=1277},
      },
      results = {
        {type="fluid", name="casein-pulp-02", amount=88},
      },
    },
    ["casein-mixture-02"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen", amount=525},
        {type="fluid", name="kerosene", amount=804},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=60},
        {type="fluid", name="waste-water", amount=50},
      },
    },
    ["honey-wax"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="raw-fiber", amount=22},
        {type="item", name="refined-natural-gas-barrel", amount=4},
      },
      results = {
        {type="item", name="wax-barrel", amount=3},
      },
    },
    ["sugar-wax"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cellulose", amount=1},
        {type="item", name="coarse-coal", amount=9},
        {type="item", name="dried-meat", amount=5},
        {type="item", name="empty-fuel-canister", amount=1},
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
        {type="item", name="advanced-foundry-mk01", amount=2},
        {type="item", name="inductor1", amount=664},
        {type="item", name="iron-plate", amount=76},
        {type="item", name="lead-plate", amount=89},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="pipe", amount=75},
        {type="item", name="primers", amount=1},
        {type="item", name="sncr-alloy", amount=138},
        {type="item", name="steam-engine", amount=9},
        {type="item", name="steel-plate", amount=175},
        {type="item", name="stone-furnace", amount=91},
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
        {type="item", name="barrel", amount=51},
        {type="item", name="fish-hydrolysate-barrel", amount=12},
        {type="item", name="grade-3-chromite", amount=17},
        {type="item", name="inductor1", amount=152},
        {type="item", name="light-armor", amount=6},
        {type="item", name="niobium-pipe-to-ground", amount=15},
        {type="item", name="stripped-distillate-canister", amount=13},
      },
      results = {
        {type="item", name="rare-earth-mine", amount=1},
      },
    },
    ["subcritical-water-03"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="hot-air", amount=119},
        {type="fluid", name="steam", amount=89},
      },
      results = {
        {type="fluid", name="subcritical-water", amount=96},
      },
    },
    ["wax"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="item", name="empty-comb", amount=10},
      },
      results = {
        {type="fluid", name="wax", amount=38},
      },
    },
    ["wax-honeycomb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.88,
      ingredients = {
        {type="item", name="empty-comb", amount=5},
        {type="item", name="py-nexelit", amount=1},
      },
      results = {
        {type="fluid", name="wax", amount=44},
      },
    },
    ["empty-comb-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.375,
      ingredients = {
        {type="fluid", name="molten-glass", amount=108},
      },
      results = {
        {type="item", name="empty-comb", amount=3},
      },
    },
    ["empty-honeycomb-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="acidgas", amount=546},
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
        {type="item", name="iron-plate", amount=21},
        {type="item", name="pipe", amount=17},
        {type="item", name="small-parts-01", amount=11},
      },
      results = {
        {type="item", name="big-electric-pole", amount=1},
      },
    },
    ["breed-fish-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.60441195279445,
      ingredients = {
        {type="fluid", name="kerosene", amount=1643},
        {type="fluid", name="pressured-water", amount=422},
        {type="fluid", name="water", amount=614},
        {type="item", name="fertilizer", amount=14},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="methanal-barrel", amount=2},
        {type="item", name="seaweed", amount=6},
        {type="item", name="tinned-cable", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=162},
        {type="item", name="fish", amount=32},
      },
    },
    ["breed-fish-egg-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.53644149517301,
      ingredients = {
        {type="fluid", name="hot-air", amount=1656},
        {type="fluid", name="water", amount=1405},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="cellulose", amount=1},
        {type="item", name="fish", amount=15},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="limestone", amount=12},
        {type="item", name="petroleum-gas-canister", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=155},
        {type="item", name="fish-egg", amount=46},
      },
    },
    ["fish-mk02"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.811327594404141,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=56},
        {type="item", name="bio-sample", amount=2},
        {type="item", name="fish", amount=20},
        {type="item", name="light-oil-canister", amount=1},
        {type="item", name="petroleum-gas-canister", amount=3},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="fish", amount=6},
        {type="item", name="fish-mk02", amount=0.00405663797202071},
      },
    },
    ["fish-egg-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.08822472749795,
      ingredients = {
        {type="fluid", name="ammonia", amount=104},
        {type="item", name="al-pulp-02-barrel", amount=3},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="ore-aluminium", amount=20},
        {type="item", name="tinned-cable", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=108},
        {type="item", name="fish-egg", amount=1},
        {type="item", name="fish-egg-mk02", amount=12},
      },
    },
    ["fish-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.855356888615483,
      ingredients = {
        {type="item", name="empty-barrel-milk", amount=1},
        {type="item", name="fish-food-01", amount=5},
        {type="item", name="ore-aluminium", amount=16},
        {type="item", name="seaweed", amount=10},
        {type="item", name="tinned-cable", amount=8},
      },
      results = {
        {type="fluid", name="waste-water", amount=81},
        {type="item", name="fish", amount=1},
        {type="item", name="fish-mk02", amount=6},
      },
    },
    ["cliff-explosives"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=2},
        {type="item", name="diborane-barrel", amount=2},
        {type="item", name="flask", amount=2},
        {type="item", name="sb-grade-03", amount=11},
        {type="item", name="stopper", amount=1},
      },
      results = {
        {type="item", name="cliff-explosives", amount=1},
      },
    },
    ["fast-inserter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="active-provider-chest", amount=1},
        {type="item", name="aromatics-barrel", amount=4},
        {type="item", name="carbon-black", amount=1},
        {type="item", name="fenxsb-alloy", amount=6},
        {type="item", name="fiberboard", amount=23},
        {type="item", name="niobium-plate", amount=4},
        {type="item", name="titanium-plate", amount=17},
        {type="item", name="wood-seedling", amount=109},
      },
      results = {
        {type="item", name="fast-inserter", amount=3},
      },
    },
    ["py-stack-inserter"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="pitch", amount=623},
        {type="item", name="auog-pup", amount=21},
        {type="item", name="burner-inserter", amount=65},
        {type="item", name="empty-comb", amount=38},
        {type="item", name="phytoplankton-barrel", amount=5},
        {type="item", name="shaft-mk01", amount=3},
        {type="item", name="tinned-cable", amount=32},
      },
      results = {
        {type="item", name="py-stack-inserter", amount=2},
      },
    },
    ["flavonoids"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="ash", amount=123},
      },
      results = {
        {type="fluid", name="flavonoids", amount=25},
      },
    },
    ["mo-mine"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="carbon-dioxide-barrel", amount=20},
        {type="item", name="concrete", amount=239},
        {type="item", name="electronic-circuit", amount=8},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="gasifier", amount=4},
        {type="item", name="grade-1-iron", amount=44},
        {type="item", name="inductor1", amount=211},
        {type="item", name="intermetallics", amount=12},
        {type="item", name="pipe", amount=25},
        {type="item", name="small-parts-01", amount=326},
        {type="item", name="steam-engine", amount=3},
        {type="item", name="warmer-stone-brick", amount=298},
      },
      results = {
        {type="item", name="mo-mine", amount=2},
      },
    },
    ["niobium-pipe"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="boric-acid-barrel", amount=3},
        {type="item", name="coal-dust", amount=8},
      },
      results = {
        {type="item", name="niobium-pipe", amount=5},
      },
    },
    ["niobium-pipe-to-ground"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="py-coal-tile", amount=7},
        {type="item", name="slacked-lime-barrel", amount=1},
      },
      results = {
        {type="item", name="niobium-pipe-to-ground", amount=6},
      },
    },
    ["py-logistic-robot-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=47},
        {type="item", name="barrel", amount=51},
        {type="item", name="burner-mining-drill", amount=2},
        {type="item", name="capacitor1", amount=24},
        {type="item", name="carbon-dioxide-barrel", amount=14},
        {type="item", name="copper-plate", amount=6},
        {type="item", name="decider-combinator", amount=1},
        {type="item", name="grade-3-zinc", amount=15},
        {type="item", name="iron-plate", amount=76},
        {type="item", name="molten-solder-barrel", amount=1},
        {type="item", name="nexelit-plate", amount=11},
        {type="item", name="niobium-oxide", amount=4},
        {type="item", name="petroleum-gas-barrel", amount=8},
        {type="item", name="steel-plate", amount=43},
        {type="item", name="stone-brick", amount=7},
        {type="item", name="syngas-barrel", amount=3},
        {type="item", name="tin-plate", amount=8},
        {type="item", name="titanium-plate", amount=665},
        {type="item", name="wood-seeds", amount=26},
      },
      results = {
        {type="item", name="py-logistic-robot-mk01", amount=2},
      },
    },
    ["yaedols-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="fluid", name="pressured-air", amount=522},
        {type="fluid", name="water", amount=839},
        {type="item", name="coal-dust", amount=15},
        {type="item", name="moondrop-seeds", amount=3},
        {type="item", name="raw-fiber", amount=27},
        {type="item", name="scrude-canister", amount=2},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=7},
      },
    },
    ["yaedols-sample"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="cdna", amount=15},
        {type="item", name="earth-bear-sample", amount=3},
        {type="item", name="grade-3-lead", amount=65},
        {type="item", name="kicalk-codex", amount=2},
        {type="item", name="planter-box", amount=42},
      },
      results = {
        {type="item", name="yaedols", amount=4},
      },
    },
    ["anthracene-gasoline-hydrogenation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.48,
      ingredients = {
        {type="fluid", name="hot-air", amount=196},
        {type="fluid", name="hydrogen", amount=38},
      },
      results = {
        {type="fluid", name="gasoline", amount=12},
      },
    },
    ["anthraquinone-from-naphthalene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.57,
      ingredients = {
        {type="fluid", name="pitch", amount=468},
        {type="item", name="tree-mk02", amount=1},
      },
      results = {
        {type="fluid", name="anthraquinone", amount=157},
      },
    },
    ["aromatics-from-naphthalene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.672224032156527,
      ingredients = {
        {type="fluid", name="hot-air", amount=991},
      },
      results = {
        {type="fluid", name="aromatics", amount=27},
        {type="item", name="coke", amount=2},
      },
    },
    ["bitumen-to-heavy-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.12,
      ingredients = {
        {type="fluid", name="bitumen", amount=135},
        {type="fluid", name="oxygen", amount=65},
        {type="fluid", name="pressured-air", amount=100},
        {type="fluid", name="vacuum", amount=729},
        {type="fluid", name="water", amount=1167},
        {type="item", name="graphite", amount=1},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=212},
      },
    },
    ["hot-residual-mixture-to-coke"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.493377094461457,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=261},
        {type="fluid", name="hot-residual-mixture", amount=63},
        {type="fluid", name="residual-mixture", amount=16},
        {type="fluid", name="water", amount=147},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=29},
        {type="item", name="coke", amount=20},
      },
    },
    ["naphthalene-solvent"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.26666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=3007},
        {type="fluid", name="pitch", amount=153},
      },
      results = {
        {type="fluid", name="organic-solvent", amount=38},
      },
    },
    ["natural-gas-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.825,
      ingredients = {
        {type="fluid", name="flue-gas", amount=805},
        {type="fluid", name="hot-air", amount=93},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="fluid", name="raw-gas", amount=33},
      },
    },
    ["oil-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.55,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=39},
        {type="fluid", name="molten-steel", amount=1},
      },
      results = {
        {type="fluid", name="crude-oil", amount=22},
      },
    },
    ["rubber-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="bolts", amount=10},
        {type="item", name="empty-comb", amount=1},
        {type="item", name="latex", amount=2},
        {type="item", name="subcritical-water-barrel", amount=2},
        {type="item", name="syngas-canister", amount=4},
        {type="item", name="tall-oil-barrel", amount=3},
      },
      results = {
        {type="item", name="rubber", amount=6},
      },
    },
    ["rubber-from-oleochemicals"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=397},
        {type="item", name="belt", amount=26},
        {type="item", name="green-sic", amount=1},
        {type="item", name="latex", amount=1},
        {type="item", name="mukmoux-fat", amount=1},
      },
      results = {
        {type="item", name="rubber", amount=4},
      },
    },
    ["tar-01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=61},
        {type="item", name="pipe", amount=2},
      },
      results = {
        {type="fluid", name="tar", amount=105},
      },
    },
    ["ticl4"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2.25,
      ingredients = {
        {type="fluid", name="chlorine", amount=30},
        {type="item", name="coal-dust", amount=7},
        {type="item", name="drill-head", amount=3},
        {type="item", name="pipe", amount=4},
        {type="item", name="powdered-aluminium", amount=2},
      },
      results = {
        {type="item", name="ticl4", amount=9},
      },
    },
    ["methane-to-methanol5"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.713333333333333,
      ingredients = {
        {type="fluid", name="methane", amount=64},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=107},
      },
    },
    ["methane-to-methanol6"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.09666666666667,
      ingredients = {
        {type="fluid", name="hot-air", amount=183},
        {type="fluid", name="methane", amount=483},
        {type="item", name="bolts", amount=8},
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=329},
      },
    },
    ["naphtha-to-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.515,
      ingredients = {
        {type="fluid", name="coal-gas", amount=125},
        {type="fluid", name="water", amount=1839},
        {type="item", name="gravel", amount=2},
      },
      results = {
        {type="fluid", name="syngas", amount=206},
      },
    },
    ["reheat-coke-gas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.76,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=95},
        {type="fluid", name="hot-molten-salt", amount=38},
      },
      results = {
        {type="fluid", name="coke-oven-gas", amount=95},
        {type="fluid", name="molten-salt", amount=38},
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5503481388322,
      ingredients = {
        {type="item", name="carbon-black", amount=3},
        {type="item", name="grade-2-copper", amount=1},
        {type="item", name="grade-2-tin", amount=4},
      },
      results = {
        {type="fluid", name="hot-air", amount=466},
        {type="item", name="stone-brick", amount=31},
      },
    },
    ["aromatics-2-diesel"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.888571428571429,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=2510},
        {type="fluid", name="scrude", amount=420},
        {type="fluid", name="water", amount=285},
        {type="item", name="tuuphra-seeds", amount=1},
      },
      results = {
        {type="fluid", name="diesel", amount=311},
      },
    },
    ["aromatics-2-petgas2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.38,
      ingredients = {
        {type="fluid", name="boric-acid", amount=128},
        {type="item", name="bolts", amount=7},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=114},
      },
    },
    ["bio-oil-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.66229722627551,
      ingredients = {
        {type="fluid", name="bio-oil", amount=230},
        {type="fluid", name="geothermal-water", amount=6882},
      },
      results = {
        {type="fluid", name="condensates", amount=250},
        {type="fluid", name="low-distillate", amount=83},
        {type="fluid", name="medium-distillate", amount=83},
      },
    },
    ["low-distillate-to-btx"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.36,
      ingredients = {
        {type="fluid", name="tailings", amount=202},
      },
      results = {
        {type="fluid", name="btx", amount=36},
      },
    },
    ["medium-distillate-to-high-distillate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="olefin", amount=843},
        {type="fluid", name="water", amount=752},
        {type="item", name="dried-meat", amount=1},
      },
      results = {
        {type="fluid", name="high-distillate", amount=170},
      },
    },
    ["medium-distillate-to-stripped-distillate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.34,
      ingredients = {
        {type="fluid", name="olefin", amount=107},
        {type="fluid", name="tailings", amount=565},
        {type="fluid", name="water", amount=758},
        {type="item", name="dried-meat", amount=1},
        {type="item", name="sncr-alloy", amount=1},
      },
      results = {
        {type="fluid", name="stripped-distillate", amount=134},
      },
    },
    ["low-distillate-to-coal-gas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.27,
      ingredients = {
        {type="fluid", name="low-distillate", amount=42},
        {type="fluid", name="tailings", amount=423},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="coal-gas", amount=254},
      },
    },
    ["stripped-distillate-to-benzene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.966666666666667,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=2447},
        {type="item", name="bolts", amount=9},
      },
      results = {
        {type="fluid", name="benzene", amount=145},
      },
    },
    ["stripped-distillate-to-cumene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="boric-acid", amount=1457},
        {type="fluid", name="flue-gas", amount=1440},
        {type="item", name="bolts", amount=8},
        {type="item", name="methane-barrel", amount=1},
      },
      results = {
        {type="fluid", name="cumene", amount=300},
      },
    },
    ["stripped-distillate-to-gasoline"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.945,
      ingredients = {
        {type="fluid", name="flue-gas", amount=3708},
        {type="item", name="bolts", amount=7},
      },
      results = {
        {type="fluid", name="gasoline", amount=189},
      },
    },
    ["stripped-distillate-to-methanol"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.37333333333333,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=502},
        {type="fluid", name="subcritical-water", amount=795},
        {type="item", name="iron-ore-dust", amount=1},
      },
      results = {
        {type="fluid", name="methanol", amount=206},
      },
    },
    ["fluorine-to-olefins"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.78,
      ingredients = {
        {type="fluid", name="creosote", amount=688},
        {type="fluid", name="flue-gas", amount=861},
      },
      results = {
        {type="fluid", name="naphtha", amount=39},
        {type="fluid", name="olefin", amount=78},
      },
    },
    ["high-distillate-condensing"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7577325228516,
      ingredients = {
        {type="fluid", name="coal-gas", amount=398},
        {type="fluid", name="pressured-water", amount=335},
        {type="fluid", name="water", amount=2283},
        {type="fluid", name="water-saline", amount=922},
        {type="item", name="gravel", amount=2},
      },
      results = {
        {type="fluid", name="condensed-distillate", amount=88},
        {type="fluid", name="naphtha", amount=263},
      },
    },
    ["natural-gas-refining"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7525900966816,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=399},
        {type="fluid", name="flue-gas", amount=1371},
        {type="fluid", name="steam", amount=457},
        {type="item", name="ash", amount=8},
        {type="item", name="glycerol-barrel", amount=2},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="condensates", amount=175},
        {type="fluid", name="naphtha", amount=88},
        {type="fluid", name="natural-gas", amount=438},
      },
    },
    ["refined-natural-gas-to-condensates"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.7,
      ingredients = {
        {type="fluid", name="refined-natural-gas", amount=115},
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
      energy_required_multiplier = 1.32,
      ingredients = {
        {type="fluid", name="chlorine", amount=306},
        {type="fluid", name="condensed-distillate", amount=42},
        {type="fluid", name="geothermal-water", amount=892},
      },
      results = {
        {type="fluid", name="gasoline", amount=33},
        {type="fluid", name="petroleum-gas", amount=66},
      },
    },
    ["low-distillate-to-heavy-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.924008667301689,
      ingredients = {
        {type="fluid", name="pressured-water", amount=4909},
        {type="fluid", name="water-saline", amount=35},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=185},
        {type="fluid", name="residual-oil", amount=46},
        {type="fluid", name="steam", amount=556},
      },
    },
    ["naphtha-2-tall-oil"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.97,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2211},
      },
      results = {
        {type="fluid", name="tall-oil", amount=97},
      },
    },
    ["bitumen-comb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.00639550243254,
      ingredients = {
        {type="item", name="offshore-pump", amount=1},
      },
      results = {
        {type="fluid", name="bitumen", amount=51},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["raw-gas"] = {
      mode = "repaired-to-input",
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
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.67,
      ingredients = {
        {type="fluid", name="methanal", amount=1094},
        {type="fluid", name="water", amount=460},
        {type="item", name="ash", amount=4},
        {type="item", name="sand", amount=10},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=167},
      },
    },
    ["bio-oil-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.491774069605343,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=325},
        {type="fluid", name="refsyngas", amount=189},
      },
      results = {
        {type="fluid", name="condensates", amount=78},
        {type="item", name="ash", amount=1},
        {type="item", name="raw-coal", amount=10},
      },
    },
    ["bitumen-refining"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.88931877426559,
      ingredients = {
        {type="fluid", name="hydrogen", amount=182},
        {type="fluid", name="methane", amount=730},
        {type="fluid", name="pressured-air", amount=562},
        {type="fluid", name="steam", amount=3497},
      },
      results = {
        {type="fluid", name="condensates", amount=47},
        {type="fluid", name="high-distillate", amount=47},
        {type="fluid", name="low-distillate", amount=189},
        {type="fluid", name="medium-distillate", amount=142},
        {type="fluid", name="residual-mixture", amount=472},
      },
    },
    ["crude-from-manure"] = {
      mode = "repaired-to-input",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=771},
      },
      results = {
        {type="fluid", name="scrude", amount=70},
        {type="fluid", name="steam", amount=50},
        {type="fluid", name="tailings", amount=50},
        {type="item", name="soot", amount=3},
      },
    },
    ["hot-residual-mixture"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.53,
      ingredients = {
        {type="fluid", name="boric-acid", amount=196},
        {type="item", name="coal-dust", amount=9},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=53},
      },
    },
    ["oil-refining"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.44,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=10},
        {type="fluid", name="water-saline", amount=418},
      },
      results = {
        {type="fluid", name="condensates", amount=55},
        {type="fluid", name="high-distillate", amount=55},
        {type="fluid", name="low-distillate", amount=44},
        {type="fluid", name="medium-distillate", amount=44},
        {type="fluid", name="residual-mixture", amount=22},
      },
    },
    ["residual-mixture-distillation"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.29732236389092,
      ingredients = {
        {type="fluid", name="boric-acid", amount=646},
        {type="fluid", name="residual-mixture", amount=85},
        {type="fluid", name="water", amount=271},
        {type="item", name="coal-dust", amount=11},
      },
      results = {
        {type="fluid", name="hot-residual-mixture", amount=32},
        {type="fluid", name="residual-oil", amount=65},
        {type="item", name="coke", amount=52},
      },
    },
    ["used-comb-oil-recycling"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.09542278604344,
      ingredients = {
        {type="item", name="empty-fuel-canister", amount=2},
      },
      results = {
        {type="fluid", name="bitumen", amount=27},
        {type="fluid", name="residual-oil", amount=55},
      },
    },
    ["used-comb-to-residual-mixture"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.38333333333333,
      ingredients = {
        {type="item", name="empty-comb", amount=6},
        {type="item", name="empty-fuel-canister", amount=4},
      },
      results = {
        {type="fluid", name="residual-mixture", amount=83},
      },
    },
    ["arqad-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=1},
        {type="item", name="copper-cable", amount=32},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="inductor1", amount=2},
        {type="item", name="pipe", amount=5},
        {type="item", name="tin-plate", amount=3},
      },
      results = {
        {type="item", name="arqad-codex", amount=1},
      },
    },
    ["arqad-egg-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.706219588715155,
      ingredients = {
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="btx-barrel", amount=3},
        {type="item", name="filled-comb", amount=43},
        {type="item", name="wax-barrel", amount=4},
      },
      results = {
        {type="item", name="arqad-egg", amount=7},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=10},
      },
    },
    ["arqad-filled-comb-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.41272706827531,
      ingredients = {
        {type="item", name="empty-comb", amount=9},
        {type="item", name="subcritical-water-barrel", amount=1},
        {type="item", name="syngas-canister", amount=2},
        {type="item", name="tall-oil-barrel", amount=3},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="filled-comb", amount=7},
      },
    },
    ["arqad-filled-honeycomb-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="py-nexelit", amount=5},
        {type="item", name="ulric", amount=1},
      },
      results = {
        {type="item", name="honeycomb", amount=3},
      },
    },
    ["arqad"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.16181100908667,
      ingredients = {
        {type="fluid", name="coke-oven-gas", amount=1558},
        {type="item", name="bio-sample", amount=22},
        {type="item", name="cdna", amount=5},
        {type="item", name="drilling-fluid-0-barrel", amount=40},
        {type="item", name="oil-sand-extractor-mk01", amount=3},
        {type="item", name="pipe", amount=60},
        {type="item", name="py-science-pack-1", amount=6},
      },
      results = {
        {type="item", name="arqad", amount=1},
        {type="item", name="arqad-egg", amount=12},
      },
    },
    ["arqad-egg-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.33175022436919,
      ingredients = {
        {type="item", name="arqad", amount=9},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="portable-gasoline-generator", amount=1},
        {type="item", name="ralesia", amount=11},
        {type="item", name="ralesia-seeds", amount=24},
        {type="item", name="tall-oil-barrel", amount=4},
      },
      results = {
        {type="item", name="arqad-egg", amount=20},
        {type="item", name="arqad-queen", amount=1},
        {type="item", name="barrel", amount=17},
      },
    },
    ["arqad-hive-mk01"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aromatics-canister", amount=17},
        {type="item", name="chromium", amount=78},
        {type="item", name="concrete", amount=20},
        {type="item", name="fts-reactor", amount=1},
        {type="item", name="geothermal-water-barrel", amount=13},
        {type="item", name="gun-turret", amount=4},
        {type="item", name="iron-chest", amount=5},
        {type="item", name="iron-plate", amount=207},
        {type="item", name="lead-plate", amount=22},
        {type="item", name="methanol-reactor", amount=1},
        {type="item", name="scrude-canister", amount=4},
        {type="item", name="small-parts-01", amount=76},
        {type="item", name="steam-engine", amount=14},
        {type="item", name="washer", amount=1},
        {type="item", name="wood-seedling", amount=93},
      },
      results = {
        {type="item", name="arqad-hive-mk01", amount=2},
      },
    },
    ["arqad-egg-nests-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="caged-vrauks", amount=1},
        {type="item", name="honeycomb", amount=35},
        {type="item", name="steel-plate", amount=6},
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
      energy_required_multiplier = 1.73100512199944,
      ingredients = {
        {type="item", name="accumulator", amount=1},
        {type="item", name="caged-vrauks", amount=10},
        {type="item", name="constant-combinator", amount=2},
        {type="item", name="grade-3-copper", amount=18},
        {type="item", name="intermetallics", amount=1},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="plastic-bar", amount=26},
        {type="item", name="py-tank-6500", amount=7},
        {type="item", name="raw-fiber", amount=42},
        {type="item", name="resistor1", amount=24},
        {type="item", name="tinned-cable", amount=24},
      },
      results = {
        {type="item", name="arqad-maggot", amount=52},
        {type="item", name="cage", amount=17},
        {type="item", name="used-comb", amount=9},
      },
    },
    ["arqad-queen-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2606475333083,
      ingredients = {
        {type="item", name="arqad", amount=3},
        {type="item", name="btx-barrel", amount=2},
        {type="item", name="filled-comb", amount=25},
        {type="item", name="low-grade-copper", amount=2},
        {type="item", name="vitreloy", amount=1},
        {type="item", name="wax-barrel", amount=1},
      },
      results = {
        {type="item", name="arqad-queen", amount=0.0126666314752253},
        {type="item", name="barrel", amount=10},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["caged-arqad-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6052423366537,
      ingredients = {
        {type="item", name="auog-food-01", amount=16},
        {type="item", name="btx-barrel", amount=5},
        {type="item", name="condensates-canister", amount=1},
        {type="item", name="filled-comb", amount=3},
        {type="item", name="honeycomb", amount=2},
        {type="item", name="iron-gear-wheel", amount=606},
        {type="item", name="molten-aluminium-barrel", amount=13},
        {type="item", name="ralesia-seeds", amount=13},
      },
      results = {
        {type="item", name="arqad", amount=12},
        {type="item", name="barrel", amount=16},
        {type="item", name="used-comb", amount=2},
      },
    },
    ["caged-arqad-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.679904588853902,
      ingredients = {
        {type="item", name="btx-barrel", amount=9},
        {type="item", name="iron-gear-wheel", amount=353},
      },
      results = {
        {type="item", name="arqad", amount=2},
        {type="item", name="barrel", amount=7},
        {type="item", name="used-comb", amount=1},
      },
    },
    ["honey-comb"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.177082046459599,
      ingredients = {
        {type="item", name="empty-comb", amount=2},
        {type="item", name="iron-gear-wheel", amount=10},
      },
      results = {
        {type="fluid", name="arqad-honey", amount=42},
        {type="item", name="empty-honeycomb", amount=1},
      },
    },
    ["hotair-empty-honeycomb-2"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.7,
      ingredients = {
        {type="fluid", name="molten-glass", amount=246},
        {type="fluid", name="slacked-lime", amount=199},
      },
      results = {
        {type="item", name="empty-honeycomb", amount=17},
      },
    },
    ["bitumen-to-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.74,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=1469},
        {type="fluid", name="pressured-air", amount=1134},
        {type="fluid", name="propene", amount=16},
      },
      results = {
        {type="fluid", name="nitrogen", amount=348},
      },
    },
    ["bitumen-to-sulfur"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="pressured-air", amount=99},
        {type="fluid", name="steam", amount=502},
      },
      results = {
        {type="item", name="sulfur", amount=4},
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
      energy_required_multiplier = 0.87,
      ingredients = {
        {type="fluid", name="oxygen", amount=21},
        {type="fluid", name="steam", amount=106},
        {type="fluid", name="vacuum", amount=1900},
        {type="fluid", name="water", amount=400},
      },
      results = {
        {type="fluid", name="dirty-syngas", amount=87},
      },
    },
    ["hot-syngas-cooldown"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.928247983177376,
      ingredients = {
        {type="fluid", name="hot-syngas", amount=97},
      },
      results = {
        {type="fluid", name="steam", amount=279},
        {type="fluid", name="syngas", amount=464},
      },
    },
    ["quenching-dirty-syngas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.776986395764257,
      ingredients = {
        {type="fluid", name="acetone", amount=412},
        {type="fluid", name="hot-air", amount=355},
        {type="fluid", name="water", amount=904},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="fluid", name="flue-gas", amount=3147},
        {type="fluid", name="purified-syngas", amount=315},
        {type="item", name="soot", amount=6},
      },
    },
    ["scrubbing-purified-syngas"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.899886274349393,
      ingredients = {
        {type="fluid", name="purified-syngas", amount=85},
        {type="fluid", name="water", amount=340},
      },
      results = {
        {type="fluid", name="hot-syngas", amount=85},
        {type="item", name="soot", amount=2},
      },
    },
    ["oil-sand-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.75,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=171},
        {type="fluid", name="muddy-sludge", amount=116},
        {type="fluid", name="pressured-water", amount=413},
        {type="fluid", name="syngas", amount=51},
        {type="item", name="lead-plate", amount=1},
        {type="item", name="tall-oil-canister", amount=1},
      },
      results = {
        {type="fluid", name="oil-sand-slurry", amount=175},
      },
    },
    ["bitumen-froth"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.68,
      ingredients = {
        {type="fluid", name="oil-sand-slurry", amount=208},
        {type="fluid", name="pressured-air", amount=331},
        {type="item", name="petroleum-gas-barrel", amount=1},
      },
      results = {
        {type="fluid", name="bitumen-froth", amount=168},
        {type="fluid", name="tailings", amount=168},
      },
    },
    ["btx-to-benzene"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.095,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=132},
        {type="fluid", name="refined-natural-gas", amount=114},
        {type="fluid", name="water", amount=377},
        {type="fluid", name="water-saline", amount=171},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="fluid", name="benzene", amount=219},
      },
    },
    ["btx-to-methane"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.19,
      ingredients = {
        {type="fluid", name="hot-air", amount=196},
        {type="fluid", name="pressured-air", amount=7545},
        {type="fluid", name="pressured-water", amount=1852},
        {type="fluid", name="refined-natural-gas", amount=15},
        {type="item", name="wood-seeds", amount=2},
      },
      results = {
        {type="fluid", name="methane", amount=357},
      },
    },
    ["aromatics-to-petgas"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.5625,
      ingredients = {
        {type="fluid", name="syngas", amount=95},
        {type="fluid", name="water", amount=616},
        {type="item", name="ore-lead", amount=1},
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=45},
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
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=637},
        {type="fluid", name="flue-gas", amount=1514},
        {type="fluid", name="hot-air", amount=406},
        {type="fluid", name="lubricant", amount=177},
        {type="fluid", name="methane", amount=333},
      },
      results = {
        {type="item", name="explosives", amount=3},
      },
    },
    ["filtration-media"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cellulose", amount=9},
        {type="item", name="pipe", amount=8},
        {type="item", name="py-asphalt", amount=9},
        {type="item", name="stone", amount=13},
        {type="item", name="tar-canister", amount=2},
      },
      results = {
        {type="item", name="filtration-media", amount=5},
      },
    },
    ["niobium-dust"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.40529661538798,
      ingredients = {
        {type="item", name="pressured-water-barrel", amount=2},
        {type="item", name="transport-belt", amount=4},
      },
      results = {
        {type="item", name="gravel", amount=3},
        {type="item", name="niobium-dust", amount=14},
      },
    },
    ["stone-distilation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1.59611010446826,
      ingredients = {
        {type="item", name="ceramic", amount=2},
        {type="item", name="lubricant-barrel", amount=1},
        {type="item", name="stone", amount=53},
      },
      results = {
        {type="fluid", name="tailings", amount=159},
        {type="fluid", name="tar", amount=159},
        {type="item", name="coarse", amount=16},
        {type="item", name="tailings-dust", amount=16},
      },
    },
    ["milling-ree"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="stopper", amount=2},
      },
      results = {
        {type="item", name="gravel", amount=2},
        {type="item", name="rare-earth-dust", amount=3},
      },
    },
    ["rare-earth-beneficiation"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.467460284655682,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1195},
        {type="fluid", name="creosote", amount=142},
        {type="item", name="coke", amount=2},
        {type="item", name="ralesia", amount=13},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=117},
        {type="fluid", name="steam", amount=939},
        {type="item", name="rich-dust", amount=2},
        {type="item", name="sand", amount=5},
      },
    },
    ["milling-molybdenite"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-1-chromite", amount=2},
      },
      results = {
        {type="item", name="gravel", amount=1},
        {type="item", name="molybdenite-dust", amount=10},
      },
    },
    ["ree-float"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.630883212737699,
      ingredients = {
        {type="fluid", name="tar", amount=206},
        {type="item", name="fine-powdered-biomass", amount=2},
        {type="item", name="niobium-dust", amount=3},
      },
      results = {
        {type="fluid", name="rare-earth-mud", amount=64},
        {type="item", name="zinc-plate", amount=3},
      },
    },
    ["ree-slurry"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.32,
      ingredients = {
        {type="fluid", name="hot-molten-salt", amount=36},
        {type="fluid", name="kerosene", amount=558},
        {type="fluid", name="muddy-sludge", amount=816},
        {type="fluid", name="water", amount=4134},
      },
      results = {
        {type="fluid", name="ree-slurry", amount=132},
        {type="fluid", name="tailings", amount=132},
      },
    },
    ["ree-solution"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.389997661957098,
      ingredients = {
        {type="fluid", name="chlorine", amount=135},
      },
      results = {
        {type="fluid", name="ree-solution", amount=39},
        {type="item", name="uranium-ore", amount=0.0387321248633894},
      },
    },
    ["crusher-ree"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="item", name="oil-sand", amount=6},
        {type="item", name="tinned-cable", amount=2},
      },
      results = {
        {type="item", name="rare-earth-powder", amount=6},
        {type="item", name="stone", amount=6},
      },
    },
    ["ree-concentrate2"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 0.753567205221368,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=510},
        {type="fluid", name="hot-air", amount=990},
      },
      results = {
        {type="item", name="chromite-sand", amount=8},
        {type="item", name="ree-concentrate", amount=15},
      },
    },
    ["ree-concentrate1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.38816377006692,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=356},
        {type="fluid", name="hot-air", amount=691},
        {type="fluid", name="organic-solvent", amount=357},
      },
      results = {
        {type="item", name="iron-oxide", amount=8},
        {type="item", name="ree-concentrate", amount=14},
      },
    },
    ["reo"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-barrel", amount=5},
      },
      results = {
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="reo", amount=5},
      },
    },
    ["ree-concentrate3"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="creosote", amount=376},
        {type="fluid", name="light-oil", amount=233},
        {type="fluid", name="ree-solution", amount=77},
        {type="item", name="ralesia", amount=34},
      },
      results = {
        {type="item", name="copper-ore", amount=8},
        {type="item", name="ree-concentrate", amount=32},
      },
    },
    ["xyhiphoe-codex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="shaft-mk01", amount=5},
        {type="item", name="tinned-cable", amount=8},
      },
      results = {
        {type="item", name="xyhiphoe-codex", amount=1},
      },
    },
    ["xyhiphoe-cub-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.44572802732369,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=5149},
        {type="fluid", name="hot-air", amount=416},
        {type="fluid", name="pressured-water", amount=429},
        {type="fluid", name="water", amount=3952},
        {type="item", name="acetylene-canister", amount=1},
        {type="item", name="ash", amount=6},
        {type="item", name="fish", amount=7},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="lime", amount=3},
        {type="item", name="molten-copper-barrel", amount=1},
        {type="item", name="moss", amount=25},
      },
      results = {
        {type="fluid", name="waste-water", amount=911},
        {type="item", name="xyhiphoe-cub", amount=6},
      },
    },
    ["xyhiphoe-pool-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="aluminium-plate", amount=23},
        {type="item", name="bolts", amount=125},
        {type="item", name="concrete", amount=1263},
        {type="item", name="distilator", amount=1},
        {type="item", name="duralumin", amount=14},
        {type="item", name="engine-unit", amount=8},
        {type="item", name="fiberboard", amount=111},
        {type="item", name="intermetallics", amount=8},
        {type="item", name="iron-plate", amount=1017},
        {type="item", name="kicalk-plantation-mk01", amount=2},
        {type="item", name="nexelit-plate", amount=250},
        {type="item", name="py-overflow-valve", amount=1},
        {type="item", name="sb-grade-03", amount=107},
        {type="item", name="stopper", amount=20},
        {type="item", name="wood-seedling", amount=11},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk01", amount=3},
      },
    },
    ["xyhiphoe"] = {
      mode = "kept-pruned-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="drilling-fluid-0", amount=1741},
        {type="fluid", name="oxygen", amount=6368},
        {type="item", name="battery-mk00", amount=12},
        {type="item", name="bio-sample01", amount=2},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="hpf", amount=4},
        {type="item", name="nichrome", amount=5},
        {type="item", name="retrovirus", amount=7},
        {type="item", name="sodium-hydroxide", amount=268},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
      },
    },
    ["xyhiphoe-1"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.8718242817133,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=131},
        {type="fluid", name="water", amount=10913},
        {type="item", name="fish", amount=21},
        {type="item", name="lime", amount=3},
        {type="item", name="molten-copper-barrel", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=354},
        {type="item", name="xyhiphoe", amount=2},
      },
    },
    ["niobium-concentrate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.40245235725075,
      ingredients = {
        {type="fluid", name="vacuum", amount=1758},
        {type="item", name="stopper", amount=5},
      },
      results = {
        {type="item", name="niobium-concentrate", amount=14},
        {type="item", name="sand", amount=3},
      },
    },
    ["nbfe-alloy"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="oil-sand", amount=46},
        {type="item", name="steel-plate", amount=5},
      },
      results = {
        {type="item", name="nbfe-alloy", amount=2},
      },
    },
    ["niobium-oxide"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="hydrogen", amount=550},
        {type="fluid", name="vacuum", amount=3306},
      },
      results = {
        {type="item", name="niobium-oxide", amount=8},
      },
    },
    ["niobium-plate"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="niobium-dust", amount=14},
        {type="item", name="oil-sand", amount=8},
        {type="item", name="sb-grade-02", amount=12},
        {type="item", name="steel-plate", amount=1},
      },
      results = {
        {type="item", name="niobium-plate", amount=5},
      },
    },
    ["niobium-complex"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 1.72,
      ingredients = {
        {type="fluid", name="organic-solvent", amount=86},
        {type="fluid", name="oxygen", amount=394},
        {type="item", name="grade-2-chromite", amount=1},
        {type="item", name="rail-signal", amount=1},
      },
      results = {
        {type="fluid", name="niobium-complex", amount=172},
      },
    },
    ["niobium-powder"] = {
      mode = "kept-transformed",
      science_level = 3,
      energy_required_multiplier = 0.811828452829751,
      ingredients = {
        {type="item", name="transport-belt", amount=5},
      },
      results = {
        {type="item", name="niobium-powder", amount=4},
        {type="item", name="stone", amount=2},
      },
    },
    ["hydrogen-chloride-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=704},
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
        {type="fluid", name="flue-gas", amount=928},
      },
      results = {
        {type="fluid", name="pressured-air", amount=240},
      },
    },
    ["refsyngas-from-meth-canister"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1.11308052922057,
      ingredients = {
        {type="fluid", name="flue-gas", amount=456},
        {type="item", name="grade-3-nickel", amount=1},
      },
      results = {
        {type="fluid", name="acidgas", amount=70},
        {type="fluid", name="carbon-dioxide", amount=23},
        {type="fluid", name="refsyngas", amount=116},
        {type="fluid", name="water", amount=35},
        {type="item", name="empty-gas-canister", amount=1},
      },
    },
    ["vanadium-pulp-3-void"] = {
      mode = "input-preserved-untransformed",
      science_level = 3,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="coalbed-gas", amount=50},
        {type="fluid", name="middle-oil", amount=1744},
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
        {type="item", name="clean-nexelit", amount=6},
        {type="item", name="inductor1", amount=25},
        {type="item", name="py-iron", amount=1},
        {type="item", name="redhot-coke", amount=4},
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
        {type="item", name="py-iron", amount=2},
        {type="item", name="ulric-food-01", amount=4},
      },
      results = {
        {type="item", name="flamethrower", amount=1},
      },
    },
    ["rocket-launcher"] = {
      mode = "kept-pruned-transformed",
      science_level = 4,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=758},
        {type="item", name="clean-nexelit", amount=17},
        {type="item", name="fish-oil-barrel", amount=2},
        {type="item", name="inductor1", amount=9},
        {type="item", name="kerosene-barrel", amount=1},
        {type="item", name="redhot-coke", amount=11},
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
        {type="fluid", name="steam", amount=1711},
        {type="item", name="grade-2-nickel", amount=2},
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
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="sulfuric-acid-barrel", amount=3},
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
        {type="item", name="capacitor1", amount=27},
        {type="item", name="fish-oil-barrel", amount=1},
        {type="item", name="pump", amount=5},
        {type="item", name="py-iron", amount=44},
        {type="item", name="slacked-lime-barrel", amount=1},
        {type="item", name="small-parts-01", amount=7},
        {type="item", name="sulfuric-acid-barrel", amount=1},
        {type="item", name="ulric-food-01", amount=36},
      },
      results = {
        {type="item", name="flamethrower-turret", amount=2},
      },
    },
    ["land-mine"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="coalbed-gas-canister", amount=5},
        {type="item", name="sulfuric-acid-barrel", amount=2},
      },
      results = {
        {type="item", name="land-mine", amount=5},
      },
    },
    ["py-science-pack-2"] = {
      mode = "kept-transformed",
      science_level = 4,
      energy_required_multiplier = 1.88888888888889,
      ingredients = {
        {type="fluid", name="steam", amount=775092},
        {type="fluid", name="water-saline", amount=7660},
        {type="item", name="casein", amount=35},
        {type="item", name="cdna", amount=4},
        {type="item", name="coalbed-gas-canister", amount=38},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="grade-2-nickel", amount=267},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="solidified-sarcorus", amount=3},
        {type="item", name="stone-brick", amount=565},
        {type="item", name="stopper", amount=16},
        {type="item", name="zipir1", amount=2},
      },
      results = {
        {type="item", name="py-science-pack-2", amount=34},
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
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="bonemeal", amount=7},
        {type="item", name="guts", amount=4},
      },
      results = {
        {type="item", name="copper-ore", amount=20},
      },
    },
    ["meat-and-gut-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25714285714286,
      ingredients = {
        {type="fluid", name="flue-gas", amount=831},
        {type="fluid", name="oxygen", amount=715},
        {type="item", name="bonemeal", amount=1},
        {type="item", name="guts", amount=5},
        {type="item", name="meat", amount=2},
      },
      results = {
        {type="item", name="copper-ore", amount=44},
      },
    },
    ["tuuphra-to-copper"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.45,
      ingredients = {
        {type="item", name="tuuphra", amount=6},
      },
      results = {
        {type="item", name="copper-ore", amount=29},
      },
    },
    ["yaedols-to-copper"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.875,
      ingredients = {
        {type="item", name="propene-canister", amount=2},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="copper-ore", amount=7},
      },
    },
    ["blood-to-urea"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.9,
      ingredients = {
        {type="fluid", name="blood", amount=170},
        {type="item", name="fiberboard", amount=1},
      },
      results = {
        {type="item", name="urea", amount=19},
      },
    },
    ["btx-to-ethylene"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1.13,
      ingredients = {
        {type="fluid", name="btx", amount=113},
        {type="fluid", name="steam", amount=226},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="fluid", name="ethylene", amount=113},
      },
    },
    ["ceramic-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="calcium-carbide", amount=1},
        {type="item", name="sodium-hydroxide", amount=1},
        {type="item", name="soil", amount=13},
      },
      results = {
        {type="item", name="ceramic", amount=5},
      },
    },
    ["crude-cermet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="item", name="crushed-molybdenite", amount=1},
        {type="item", name="melamine", amount=5},
        {type="item", name="ore-nickel", amount=2},
        {type="item", name="sodium-hydroxide", amount=2},
        {type="item", name="soil", amount=27},
      },
      results = {
        {type="item", name="crude-cermet", amount=8},
      },
    },
    ["cermet"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="lubricant", amount=75},
        {type="item", name="ash", amount=4},
        {type="item", name="crude-cermet", amount=3},
      },
      results = {
        {type="item", name="cermet", amount=2},
      },
    },
    ["concrete-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.95,
      ingredients = {
        {type="fluid", name="boric-acid", amount=386},
        {type="item", name="cellulose", amount=4},
        {type="item", name="stone-brick", amount=5},
      },
      results = {
        {type="item", name="concrete", amount=19},
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
        {type="fluid", name="sulfuric-acid", amount=123},
        {type="item", name="sodium-hydroxide", amount=13},
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
        {type="item", name="yaedols-spores", amount=1},
      },
      results = {
        {type="item", name="sulfur", amount=7},
      },
    },
    ["fish-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.85,
      ingredients = {
        {type="fluid", name="fish-oil", amount=48},
        {type="fluid", name="flue-gas", amount=2725},
      },
      results = {
        {type="item", name="iron-ore", amount=37},
      },
    },
    ["meat-to-iron"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.1,
      ingredients = {
        {type="item", name="meat", amount=5},
      },
      results = {
        {type="item", name="iron-ore", amount=11},
      },
    },
    ["p2s5"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="vpulp3", amount=9},
        {type="item", name="crushed-oil-sand", amount=4},
        {type="item", name="tuuphra", amount=8},
      },
      results = {
        {type="item", name="iron-ore", amount=10},
      },
    },
    ["trits-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coalbed-gas-canister", amount=3},
        {type="item", name="electronic-circuit", amount=5},
      },
      results = {
        {type="item", name="trits-codex", amount=1},
      },
    },
    ["trits-reef-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample01", amount=4},
        {type="item", name="carbolic-oil-barrel", amount=12},
        {type="item", name="coalbed-gas-barrel", amount=1},
        {type="item", name="coke", amount=106},
        {type="item", name="concrete", amount=379},
        {type="item", name="formica", amount=5},
        {type="item", name="grade-3-zinc", amount=55},
        {type="item", name="lead-plate", amount=45},
        {type="item", name="light-oil-canister", amount=19},
        {type="item", name="natural-gas-derrick-mk01", amount=1},
        {type="item", name="pure-sand", amount=117},
        {type="item", name="py-steel", amount=12},
        {type="item", name="small-parts-01", amount=49},
        {type="item", name="subcritical-water-barrel", amount=4},
        {type="item", name="titanium-plate", amount=109},
        {type="item", name="transport-belt", amount=23},
        {type="item", name="workers-food", amount=2},
        {type="item", name="zipir-codex", amount=8},
      },
      results = {
        {type="item", name="trits-reef-mk01", amount=1},
      },
    },
    ["trits"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="fetal-serum", amount=698},
        {type="item", name="alien-sample-02", amount=4},
        {type="item", name="cocoon-mk02", amount=72},
        {type="item", name="cytostatics", amount=6},
        {type="item", name="earth-palmtree-sample", amount=4},
        {type="item", name="planter-box", amount=160},
        {type="item", name="zipir-codex", amount=11},
      },
      results = {
        {type="item", name="trits", amount=3},
      },
    },
    ["trits-cub-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.47940893412215,
      ingredients = {
        {type="fluid", name="water-saline", amount=243},
        {type="item", name="filtration-media", amount=4},
        {type="item", name="moondrop", amount=2},
        {type="item", name="moondrop-mk02", amount=1},
        {type="item", name="niobium-plate", amount=2},
        {type="item", name="photophore", amount=3},
        {type="item", name="salt", amount=54},
        {type="item", name="sea-sponge-sprouts-mk02", amount=1},
        {type="item", name="sodium-hydroxide", amount=8},
      },
      results = {
        {type="fluid", name="waste-water", amount=419},
        {type="item", name="trits-pup", amount=3},
      },
    },
    ["trits-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.4926122476739,
      ingredients = {
        {type="fluid", name="steam", amount=1663},
        {type="fluid", name="water", amount=20052},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish", amount=3},
        {type="item", name="moondrop", amount=12},
        {type="item", name="nylon-parts", amount=27},
        {type="item", name="pure-sand", amount=52},
        {type="item", name="sodium-silicate", amount=4},
        {type="item", name="trits-pup", amount=2},
        {type="item", name="wood-seeds", amount=56},
      },
      results = {
        {type="fluid", name="waste-water", amount=614},
        {type="item", name="trits", amount=5},
      },
    },
    ["glass-core"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="silver-plate", amount=3},
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
        {type="item", name="silver-plate", amount=3},
      },
      results = {
        {type="item", name="glass-core", amount=2},
      },
    },
    ["guar-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="arqad-codex", amount=6},
        {type="item", name="bio-sample01", amount=18},
        {type="item", name="cottongut-codex", amount=1},
        {type="item", name="cytostatics", amount=5},
        {type="item", name="earth-crustacean-sample", amount=20},
        {type="item", name="earth-sea-sponge-sample", amount=1},
        {type="item", name="tuuphra-codex", amount=3},
      },
      results = {
        {type="item", name="guar", amount=3},
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
      energy_required_multiplier = 2.1,
      ingredients = {
        {type="fluid", name="steam", amount=83},
        {type="item", name="coarse", amount=2},
        {type="item", name="coke", amount=4},
        {type="item", name="gravel", amount=10},
        {type="item", name="ore-nickel", amount=1},
        {type="item", name="pure-sand", amount=3},
        {type="item", name="sand", amount=2},
        {type="item", name="tuuphra-seeds", amount=2},
      },
      results = {
        {type="item", name="guar", amount=21},
      },
    },
    ["acid-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=8},
        {type="item", name="phosphate-rock", amount=1},
        {type="item", name="refined-concrete", amount=2},
        {type="item", name="refined-hazard-concrete", amount=1},
      },
      results = {
        {type="item", name="acid-refined-concrete", amount=4},
      },
    },
    ["black-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="carbon-black", amount=1},
        {type="item", name="refined-hazard-concrete", amount=2},
      },
      results = {
        {type="item", name="black-refined-concrete", amount=3},
      },
    },
    ["blue-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="acetylene-barrel", amount=1},
        {type="item", name="refined-hazard-concrete", amount=3},
        {type="item", name="warmer-stone-brick", amount=4},
      },
      results = {
        {type="item", name="blue-refined-concrete", amount=7},
      },
    },
    ["cyan-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=28},
        {type="item", name="anthracene-oil-barrel", amount=1},
      },
      results = {
        {type="item", name="cyan-refined-concrete", amount=7},
      },
    },
    ["orange-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="fine-powdered-biomass", amount=5},
        {type="item", name="niobium-concentrate", amount=1},
        {type="item", name="pipe", amount=5},
        {type="item", name="powdered-quartz", amount=1},
      },
      results = {
        {type="item", name="orange-refined-concrete", amount=5},
      },
    },
    ["purple-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="vpulp3", amount=5},
        {type="item", name="crushed-oil-sand", amount=2},
      },
      results = {
        {type="item", name="purple-refined-concrete", amount=3},
      },
    },
    ["brown-refined-concrete"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="phosphate-rock", amount=2},
        {type="item", name="pyrite", amount=2},
        {type="item", name="stripped-distillate-canister", amount=1},
      },
      results = {
        {type="item", name="brown-refined-concrete", amount=5},
      },
    },
    ["green-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="nitrogen-barrel", amount=2},
        {type="item", name="warmer-stone-brick", amount=3},
      },
      results = {
        {type="item", name="green-refined-concrete", amount=7},
      },
    },
    ["pink-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="item", name="refined-concrete", amount=4},
      },
      results = {
        {type="item", name="pink-refined-concrete", amount=1},
      },
    },
    ["red-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="pressured-air", amount=1508},
        {type="item", name="hazard-concrete", amount=2},
        {type="item", name="phosphate-rock", amount=12},
      },
      results = {
        {type="item", name="red-refined-concrete", amount=5},
      },
    },
    ["yellow-refined-concrete"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="fine-powdered-biomass", amount=9},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="yellow-refined-concrete", amount=2},
      },
    },
    ["ipod"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromite-sand", amount=1545},
        {type="item", name="concrete", amount=9},
        {type="item", name="creosote-barrel", amount=33},
        {type="item", name="fiberboard", amount=27},
        {type="item", name="grade-3-zinc", amount=2},
        {type="item", name="hydrofluoric-acid-barrel", amount=1},
        {type="item", name="kerogen", amount=66},
        {type="item", name="lab", amount=1},
        {type="item", name="molten-steel-barrel", amount=1},
        {type="item", name="niobium-complex-barrel", amount=8},
        {type="item", name="niobium-pipe", amount=43},
        {type="item", name="pipe", amount=59},
        {type="item", name="sea-sponge-sprouts", amount=6},
        {type="item", name="tin-plate", amount=7},
        {type="item", name="transport-belt", amount=31},
        {type="item", name="vane-mk01", amount=2},
      },
      results = {
        {type="item", name="ipod", amount=1},
      },
    },
    ["kicalk-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.55,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=142},
        {type="fluid", name="water", amount=262},
        {type="item", name="biomass", amount=5},
        {type="item", name="fertilizer", amount=2},
        {type="item", name="glass", amount=3},
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="melamine", amount=1},
        {type="item", name="pure-sand", amount=6},
        {type="item", name="raw-fiber", amount=12},
      },
      results = {
        {type="item", name="kicalk", amount=11},
      },
    },
    ["kicalk-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.41762191800437,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=133},
        {type="fluid", name="oxygen", amount=76},
        {type="fluid", name="steam", amount=207},
        {type="fluid", name="water", amount=628},
        {type="item", name="biomass", amount=12},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="glass", amount=6},
        {type="item", name="iron-oxide", amount=4},
        {type="item", name="kicalk", amount=2},
        {type="item", name="kicalk-seeds", amount=4},
        {type="item", name="melamine", amount=3},
        {type="item", name="pure-sand", amount=6},
        {type="item", name="raw-fiber", amount=28},
        {type="item", name="small-lamp", amount=2},
        {type="item", name="stone-wool", amount=1},
      },
      results = {
        {type="item", name="kicalk", amount=1},
        {type="item", name="kicalk-mk02", amount=0.00708810959002183},
        {type="item", name="kicalk-seeds-mk02", amount=0.0283524383600873},
      },
    },
    ["kicalk-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.799529113654261,
      ingredients = {
        {type="fluid", name="flutec-pp6", amount=66},
        {type="item", name="boron-trioxide", amount=3},
        {type="item", name="kicalk-seeds-mk02", amount=3},
        {type="item", name="small-lamp", amount=5},
      },
      results = {
        {type="item", name="kicalk-mk02", amount=4},
        {type="item", name="kicalk-seeds", amount=1},
        {type="item", name="kicalk-seeds-mk02", amount=1},
      },
    },
    ["meat-to-phosphate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="water", amount=1190},
        {type="item", name="brain", amount=1},
        {type="item", name="guts", amount=6},
      },
      results = {
        {type="item", name="phosphate-rock", amount=5},
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
        {type="fluid", name="waste-water", amount=2118},
        {type="item", name="molten-glass-barrel", amount=190},
        {type="item", name="moss-gen", amount=862},
        {type="item", name="retrovirus", amount=288},
        {type="item", name="solder", amount=475},
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
        {type="fluid", name="water-saline", amount=2301},
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="p2s5", amount=50},
      },
      results = {
        {type="item", name="py-logo-15tiles", amount=2},
      },
    },
    ["rail-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="flue-gas-barrel", amount=6},
        {type="item", name="grade-2-ti", amount=2},
        {type="item", name="hot-syngas-barrel", amount=1},
        {type="item", name="hydrogen-barrel", amount=1},
      },
      results = {
        {type="item", name="rail", amount=16},
      },
    },
    ["resorcinol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="chromium", amount=5},
        {type="item", name="powdered-phosphate-rock", amount=2},
      },
      results = {
        {type="item", name="resorcinol", amount=2},
      },
    },
    ["sample-cup"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="phosphate-rock", amount=3},
      },
      results = {
        {type="item", name="sample-cup", amount=2},
      },
    },
    ["sea-sponge-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.00116961574301,
      ingredients = {
        {type="fluid", name="chlorine", amount=432},
        {type="fluid", name="phytoplankton", amount=97},
        {type="fluid", name="zogna-bacteria", amount=19},
        {type="item", name="sea-sponge", amount=2},
        {type="item", name="sea-sponge-sprouts", amount=2},
      },
      results = {
        {type="fluid", name="water-saline", amount=50},
        {type="item", name="sea-sponge", amount=1},
        {type="item", name="sea-sponge-mk02", amount=0.00501787282092441},
      },
    },
    ["sea-sponge-sprouts-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 1.13333333333333,
      ingredients = {
        {type="fluid", name="oxygen", amount=206},
        {type="fluid", name="slacked-lime", amount=63},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="salt", amount=3},
      },
      results = {
        {type="item", name="seaweed", amount=34},
      },
    },
    ["seaweed-mk03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=193},
        {type="item", name="auog", amount=13},
        {type="item", name="molybdenum-pulp-barrel", amount=2},
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
        {type="fluid", name="geothermal-water", amount=3980},
        {type="item", name="coke", amount=29},
        {type="item", name="limestone", amount=3},
        {type="item", name="log", amount=1},
        {type="item", name="niobium-plate", amount=1},
        {type="item", name="powdered-biomass", amount=5},
        {type="item", name="tuuphra-seeds", amount=8},
      },
      results = {
        {type="item", name="tuuphra", amount=7},
      },
    },
    ["tuuphra-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.03610599236667,
      ingredients = {
        {type="fluid", name="geothermal-water", amount=2682},
        {type="item", name="coke", amount=61},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="limestone", amount=18},
        {type="item", name="log", amount=1},
        {type="item", name="manure", amount=6},
        {type="item", name="rich-clay", amount=23},
        {type="item", name="sb-grade-02", amount=29},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="tuuphra-seeds", amount=16},
      },
      results = {
        {type="item", name="tuuphra", amount=1},
        {type="item", name="tuuphra-mk02", amount=0.00518052996183335},
      },
    },
    ["tuuphra-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.727272727272727,
      ingredients = {
        {type="fluid", name="ammonia", amount=345},
        {type="fluid", name="propene", amount=606},
        {type="item", name="calcium-carbide", amount=102},
        {type="item", name="ree-concentrate", amount=1},
        {type="item", name="tuuphra", amount=6},
        {type="item", name="tuuphra-mk02", amount=1},
      },
      results = {
        {type="item", name="tuuphra-mk02", amount=5},
      },
    },
    ["xenogenic-from-bonemeal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.764705882352941,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=455},
        {type="item", name="mukmoux-fat", amount=3},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=65},
      },
    },
    ["xenogenic-from-bones"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="water", amount=1789},
        {type="item", name="bones", amount=3},
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=60},
      },
    },
    ["xenogenic-from-brains"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=42},
        {type="item", name="bones", amount=5},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=16},
      },
    },
    ["xenogenic-from-chitin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.957142857142857,
      ingredients = {
        {type="item", name="bones", amount=19},
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
        {type="fluid", name="pressured-air", amount=805},
        {type="item", name="chitin", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=25},
      },
    },
    ["xenogenic-from-guts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.775,
      ingredients = {
        {type="fluid", name="water", amount=616},
        {type="item", name="bonemeal", amount=7},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=31},
      },
    },
    ["xenogenic-from-skin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.88333333333333,
      ingredients = {
        {type="item", name="bonemeal", amount=14},
        {type="item", name="brain", amount=2},
        {type="item", name="coke", amount=11},
        {type="item", name="niobium-concentrate", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=113},
      },
    },
    ["xenogenic-from-meat"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.433333333333333,
      ingredients = {
        {type="fluid", name="water", amount=488},
        {type="item", name="guts", amount=1},
      },
      results = {
        {type="fluid", name="xenogenic-cells", amount=13},
      },
    },
    ["Moss-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.41666666666667,
      ingredients = {
        {type="fluid", name="steam", amount=177},
        {type="item", name="chromium", amount=1},
        {type="item", name="lime", amount=6},
        {type="item", name="powdered-phosphate-rock", amount=4},
        {type="item", name="stone", amount=19},
      },
      results = {
        {type="item", name="moss", amount=34},
      },
    },
    ["moss-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.19908173202536,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=307},
        {type="item", name="brown-refined-concrete", amount=1},
        {type="item", name="fungal-substrate", amount=6},
        {type="item", name="saps", amount=3},
        {type="item", name="seaweed", amount=9},
      },
      results = {
        {type="item", name="moss-mk02", amount=0.0239816346405072},
      },
    },
    ["moss-mk02r"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=159},
        {type="item", name="cellulose", amount=19},
        {type="item", name="cottongut", amount=8},
        {type="item", name="moss-mk02", amount=2},
        {type="item", name="retrovirus", amount=9},
      },
      results = {
        {type="item", name="moss-mk02", amount=4},
      },
    },
    ["biomass-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8125,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=2796},
        {type="item", name="grade-3-ti", amount=2},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=325},
      },
    },
    ["coal-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.848,
      ingredients = {
        {type="fluid", name="chloroethanol", amount=210},
        {type="fluid", name="coalbed-gas", amount=3796},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=924},
      },
    },
    ["fatty-acids-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.88,
      ingredients = {
        {type="fluid", name="flue-gas", amount=472},
        {type="fluid", name="organic-solvent", amount=68},
        {type="item", name="chromium", amount=2},
        {type="item", name="seaweed", amount=77},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=44},
      },
    },
    ["oleochemicals-to-fatty-acids"] = {
      mode = "input-preserved-untransformed",
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
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.86,
      ingredients = {
        {type="fluid", name="tar", amount=269},
        {type="item", name="clean-nexelit", amount=2},
        {type="item", name="pyrite", amount=7},
        {type="item", name="yaedols", amount=4},
      },
      results = {
        {type="fluid", name="perylene", amount=43},
      },
    },
    ["geo-he-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.88,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=255},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=66},
      },
    },
    ["oil-molten-salt-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.406,
      ingredients = {
        {type="fluid", name="cumene", amount=2262},
        {type="fluid", name="vacuum", amount=119344},
      },
      results = {
        {type="fluid", name="hot-molten-salt", amount=703},
      },
    },
    ["organic-acid-anhydride"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.15,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=140},
        {type="fluid", name="flue-gas", amount=4192},
        {type="fluid", name="phosphoric-acid", amount=42},
        {type="item", name="bones", amount=1},
        {type="item", name="pyrite", amount=9},
      },
      results = {
        {type="fluid", name="organic-acid-anhydride", amount=115},
      },
    },
    ["processed-fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="fatty-acids", amount=41},
        {type="fluid", name="flue-gas", amount=1501},
      },
      results = {
        {type="fluid", name="processed-fatty-acids", amount=40},
      },
    },
    ["middle-processed-lard"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.402672595709209,
      ingredients = {
        {type="fluid", name="pressured-air", amount=147},
        {type="fluid", name="water", amount=411},
        {type="item", name="bones", amount=1},
        {type="item", name="calcium-carbide", amount=3},
      },
      results = {
        {type="fluid", name="middle-processed-lard", amount=8},
        {type="fluid", name="steam", amount=210},
        {type="fluid", name="tar", amount=21},
      },
    },
    ["he-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="fluid", name="water-saline", amount=2493},
      },
      results = {
        {type="fluid", name="molten-salt", amount=96},
        {type="fluid", name="pressured-steam", amount=72},
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
      energy_required_multiplier = 1.52,
      ingredients = {
        {type="item", name="albumin", amount=7},
        {type="item", name="brain", amount=25},
        {type="item", name="chitin", amount=1},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="meat", amount=26},
        {type="item", name="raw-fiber", amount=17},
        {type="item", name="sodium-hydroxide", amount=20},
        {type="item", name="urea", amount=2},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=76},
      },
    },
    ["fatty-acids"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.614285714285714,
      ingredients = {
        {type="fluid", name="industrial-solvent", amount=21},
        {type="fluid", name="middle-processed-lard", amount=38},
      },
      results = {
        {type="fluid", name="fatty-acids", amount=43},
      },
    },
    ["carbon-sulfide"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="fluid", name="propene", amount=23},
        {type="item", name="coal", amount=2},
        {type="item", name="sulfur", amount=10},
      },
      results = {
        {type="fluid", name="carbon-sulfide", amount=46},
      },
    },
    ["ech"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.766666666666667,
      ingredients = {
        {type="fluid", name="flue-gas", amount=2515},
        {type="fluid", name="oxygen", amount=691},
      },
      results = {
        {type="fluid", name="ech", amount=23},
      },
    },
    ["etching"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.986666666666667,
      ingredients = {
        {type="fluid", name="ethylene", amount=310},
        {type="fluid", name="hydrogen-peroxide", amount=38},
        {type="fluid", name="subcritical-water", amount=321},
        {type="item", name="bones", amount=6},
        {type="item", name="sap-tree", amount=2},
      },
      results = {
        {type="fluid", name="etching", amount=148},
      },
    },
    ["ethylene"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="methane", amount=44},
        {type="fluid", name="pressured-air", amount=223},
        {type="item", name="iron-oxide", amount=2},
      },
      results = {
        {type="fluid", name="ethylene", amount=54},
        {type="fluid", name="water", amount=45},
      },
    },
    ["guts-to-acetic-acid"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.11666666666667,
      ingredients = {
        {type="item", name="bonemeal", amount=2},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="guts", amount=19},
        {type="item", name="py-quartz", amount=3},
      },
      results = {
        {type="fluid", name="acetic-acid", amount=67},
      },
    },
    ["meat-to-cyanic"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.0026509173324141,
      ingredients = {
        {type="fluid", name="water-saline", amount=2},
      },
      results = {
        {type="fluid", name="cyanic-acid", amount=0.132545866620705},
      },
    },
    ["methane-methanal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.22,
      ingredients = {
        {type="fluid", name="methane", amount=29},
        {type="fluid", name="muddy-sludge", amount=100},
        {type="fluid", name="pressured-water", amount=99},
        {type="fluid", name="water", amount=488},
        {type="item", name="crushed-molybdenite", amount=1},
      },
      results = {
        {type="fluid", name="methanal", amount=122},
      },
    },
    ["nitrobenzene"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.26,
      ingredients = {
        {type="fluid", name="ammonia", amount=13},
        {type="fluid", name="benzene", amount=47},
        {type="fluid", name="propene", amount=49},
        {type="fluid", name="sulfuric-acid", amount=77},
        {type="item", name="coal", amount=11},
        {type="item", name="sulfur", amount=7},
      },
      results = {
        {type="fluid", name="nitrobenzene", amount=126},
      },
    },
    ["propene-to-acetone"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.88,
      ingredients = {
        {type="fluid", name="pressured-air", amount=97},
        {type="fluid", name="propene", amount=48},
        {type="item", name="chromite-sand", amount=2},
        {type="item", name="copper-plate", amount=2},
      },
      results = {
        {type="fluid", name="acetone", amount=44},
      },
    },
    ["ethylene-from-fruit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.94,
      ingredients = {
        {type="item", name="yotoi", amount=5},
        {type="item", name="yotoi-fruit", amount=10},
      },
      results = {
        {type="fluid", name="ethylene", amount=97},
      },
    },
    ["fuelrod-mk01-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=69},
        {type="item", name="ferrite", amount=2},
        {type="item", name="melamine", amount=25},
        {type="item", name="molybdenum-plate", amount=16},
        {type="item", name="pu-242", amount=3},
        {type="item", name="tin-plate", amount=7},
      },
      results = {
        {type="item", name="fuelrod-mk01", amount=2},
      },
    },
    ["grade-1-u"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 5,
      ingredients = {
        {type="fluid", name="water", amount=1118},
        {type="item", name="uranium-ore", amount=19},
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
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="grade-1-u", amount=3},
        {type="item", name="uranium-ore", amount=7},
      },
      results = {
        {type="item", name="powdered-u", amount=4},
        {type="item", name="sand", amount=2},
      },
    },
    ["u-pulp-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.61,
      ingredients = {
        {type="item", name="uranium-ore", amount=80},
      },
      results = {
        {type="fluid", name="u-pulp-01", amount=61},
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
      energy_required_multiplier = 0.55,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=223},
        {type="item", name="uranium-ore", amount=7},
      },
      results = {
        {type="fluid", name="u-pulp-02", amount=55},
      },
    },
    ["u-pulp-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="hydrogen", amount=344},
        {type="fluid", name="sulfuric-acid", amount=90},
        {type="fluid", name="tall-oil", amount=479},
        {type="item", name="uranium-ore", amount=180},
      },
      results = {
        {type="fluid", name="u-pulp-03", amount=102},
      },
    },
    ["u-rich-pulp"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=1859},
        {type="item", name="processed-iron-ore", amount=12},
      },
      results = {
        {type="item", name="yellow-cake", amount=8},
      },
    },
    ["cladded-core"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aramid", amount=3},
        {type="item", name="chromium", amount=4},
        {type="item", name="glass-core", amount=2},
        {type="item", name="ppd", amount=2},
      },
      results = {
        {type="item", name="cladded-core", amount=2},
      },
    },
    ["cladding"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=59},
        {type="fluid", name="nitrobenzene", amount=49},
        {type="item", name="glass", amount=4},
      },
      results = {
        {type="item", name="cladding", amount=1},
      },
    },
    ["copper-coating"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water-saline", amount=159},
        {type="item", name="cladded-core", amount=1},
        {type="item", name="copper-plate", amount=7},
      },
      results = {
        {type="item", name="copper-coating", amount=2},
      },
    },
    ["filtration-media-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=252},
        {type="item", name="active-carbon", amount=3},
        {type="item", name="cellulose", amount=2},
        {type="item", name="lime", amount=14},
        {type="item", name="stone", amount=33},
        {type="item", name="wood", amount=39},
      },
      results = {
        {type="item", name="filtration-media", amount=3},
      },
    },
    ["iron-oxide"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="nitrobenzene", amount=20},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="iron-oxide", amount=4},
      },
    },
    ["kevlar"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="tpa", amount=38},
        {type="item", name="bisphenol-a", amount=3},
        {type="item", name="blood-meal", amount=7},
        {type="item", name="cladding", amount=2},
        {type="item", name="nylon-parts", amount=23},
      },
      results = {
        {type="item", name="kevlar", amount=8},
      },
    },
    ["kevlar-coating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="cladded-core", amount=2},
        {type="item", name="copper-plate", amount=13},
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
        {type="item", name="chromium", amount=1},
        {type="item", name="cladding", amount=1},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="lens", amount=2},
        {type="item", name="pipe", amount=13},
        {type="item", name="rubber", amount=9},
      },
      results = {
        {type="item", name="lab-instrument", amount=3},
      },
    },
    ["optical-fiber"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4.33333333333333,
      ingredients = {
        {type="item", name="nbfe-coating", amount=3},
        {type="item", name="niobium-plate", amount=33},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="photophore", amount=2},
        {type="item", name="sodium-bisulfate", amount=8},
      },
      results = {
        {type="item", name="optical-fiber", amount=13},
      },
    },
    ["slacked-lime"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="item", name="calcium-carbide", amount=9},
        {type="item", name="soil", amount=9},
      },
      results = {
        {type="fluid", name="slacked-lime", amount=58},
      },
    },
    ["ppd"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="hydrogen-chloride", amount=221},
        {type="fluid", name="organic-solvent", amount=50},
        {type="fluid", name="tall-oil", amount=604},
        {type="item", name="iron-stick", amount=12},
        {type="item", name="pyrite", amount=1},
        {type="item", name="seaweed", amount=177},
      },
      results = {
        {type="item", name="ppd", amount=10},
      },
    },
    ["lime-from-shell"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=191},
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="lime", amount=20},
      },
    },
    ["nbfe-coating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="niobium-plate", amount=1},
      },
      results = {
        {type="item", name="nbfe-coating", amount=1},
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.807676913567962,
      ingredients = {
        {type="item", name="chromite-sand", amount=3},
        {type="item", name="coke", amount=5},
        {type="item", name="grade-1-ti", amount=2},
        {type="item", name="pipe", amount=2},
        {type="item", name="sodium-hydroxide", amount=5},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=24},
        {type="item", name="sodium-bisulfate", amount=0.809021209965123},
      },
    },
    ["starch-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="fiberboard", amount=1},
        {type="item", name="guar", amount=13},
        {type="item", name="powdered-phosphate-rock", amount=4},
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="item", name="biomass", amount=3},
        {type="item", name="starch", amount=6},
      },
    },
    ["aramid"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="aromatics", amount=1183},
        {type="item", name="molybdenum-sulfide", amount=8},
        {type="item", name="moondrop-seeds-mk02", amount=1},
        {type="item", name="p2s5", amount=3},
        {type="item", name="salt", amount=11},
        {type="item", name="titanium-plate", amount=13},
      },
      results = {
        {type="item", name="aramid", amount=6},
      },
    },
    ["sodium-sulfate"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.98340054790816,
      ingredients = {
        {type="item", name="sodium-bisulfate", amount=1},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=37},
        {type="item", name="sodium-sulfate", amount=1},
      },
    },
    ["starch-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.30052595230365,
      ingredients = {
        {type="item", name="clay", amount=7},
        {type="item", name="coke", amount=12},
        {type="item", name="formica", amount=1},
        {type="item", name="powdered-ralesia-seeds", amount=1},
        {type="item", name="sodium-bisulfate", amount=3},
      },
      results = {
        {type="item", name="biomass", amount=12},
        {type="item", name="starch", amount=23},
      },
    },
    ["casein-melamine"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=48},
        {type="item", name="casein", amount=5},
      },
      results = {
        {type="item", name="melamine", amount=10},
      },
    },
    ["fecr-alloy"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="methane", amount=52},
        {type="fluid", name="pressured-air", amount=84},
        {type="item", name="chromite-sand", amount=2},
        {type="item", name="coke", amount=8},
        {type="item", name="iron-oxide", amount=2},
        {type="item", name="pipe", amount=1},
      },
      results = {
        {type="item", name="fecr-alloy", amount=2},
      },
    },
    ["phenol-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="powdered-biomass", amount=2463},
      },
      results = {
        {type="item", name="phenol", amount=6},
      },
    },
    ["silicon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="fluid", name="syngas", amount=241},
        {type="item", name="chromium", amount=2},
        {type="item", name="coal-dust", amount=19},
        {type="item", name="sand", amount=25},
        {type="item", name="tinned-cable", amount=1},
      },
      results = {
        {type="item", name="silicon", amount=18},
      },
    },
    ["sodium-silicate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="syngas", amount=514},
        {type="item", name="chromium", amount=5},
        {type="item", name="tinned-cable", amount=3},
      },
      results = {
        {type="item", name="sodium-silicate", amount=1},
      },
    },
    ["bisphenol-a"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="acetone", amount=24},
        {type="fluid", name="water", amount=2037},
        {type="item", name="powdered-phosphate-rock", amount=12},
      },
      results = {
        {type="item", name="bisphenol-a", amount=2},
      },
    },
    ["melamine-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="phenol", amount=10},
      },
      results = {
        {type="item", name="melamine", amount=18},
      },
    },
    ["phenol-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="powdered-quartz", amount=2},
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
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="biomass", amount=37},
        {type="item", name="bisphenol-a", amount=3},
        {type="item", name="phenol", amount=9},
        {type="item", name="zinc-acetate", amount=1},
      },
      results = {
        {type="item", name="bakelite", amount=7},
      },
    },
    ["epoxy"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="ech", amount=23},
        {type="item", name="bakelite", amount=11},
        {type="item", name="chromium", amount=3},
        {type="item", name="coke", amount=10},
      },
      results = {
        {type="item", name="epoxy", amount=6},
      },
    },
    ["nylon2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.16666666666667,
      ingredients = {
        {type="fluid", name="ammonia", amount=256},
        {type="fluid", name="carbon-dioxide", amount=450},
        {type="fluid", name="chlorine", amount=48},
        {type="fluid", name="nitrogen", amount=450},
        {type="item", name="chromium", amount=2},
        {type="item", name="nichrome", amount=1},
      },
      results = {
        {type="item", name="nylon", amount=7},
      },
    },
    ["blood-meal"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="blood", amount=77},
        {type="item", name="fiberboard", amount=2},
      },
      results = {
        {type="item", name="blood-meal", amount=1},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=517},
        {type="fluid", name="pressured-water", amount=1117},
        {type="item", name="bisphenol-a", amount=1},
        {type="item", name="blood-meal", amount=3},
        {type="item", name="chromium", amount=2},
      },
      results = {
        {type="item", name="nylon", amount=5},
      },
    },
    ["boric-acid-hcl"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.85401859439404,
      ingredients = {
        {type="fluid", name="boric-acid", amount=230},
        {type="item", name="sodium-hydroxide", amount=4},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=64},
        {type="fluid", name="tailings", amount=171},
      },
    },
    ["manure-to-nitrogen"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="coal-gas-canister", amount=1},
        {type="item", name="manure", amount=8},
        {type="item", name="wood", amount=10},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="fluid", name="nitrogen", amount=100},
      },
    },
    ["mibc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.99,
      ingredients = {
        {type="fluid", name="acetone", amount=40},
        {type="fluid", name="nitrobenzene", amount=10},
        {type="fluid", name="propene", amount=55},
        {type="fluid", name="syngas", amount=645},
        {type="item", name="chromite-sand", amount=19},
        {type="item", name="low-grade-copper", amount=1},
      },
      results = {
        {type="fluid", name="mibc", amount=398},
      },
    },
    ["trichlorosilane"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.58,
      ingredients = {
        {type="fluid", name="water-saline", amount=119},
        {type="item", name="silicon", amount=4},
      },
      results = {
        {type="fluid", name="hydrogen", amount=58},
        {type="fluid", name="trichlorosilane", amount=29},
      },
    },
    ["eg-si"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.476910411751891,
      ingredients = {
        {type="fluid", name="pressured-water", amount=356},
        {type="fluid", name="pure-trichlorosilane", amount=21},
      },
      results = {
        {type="fluid", name="hydrogen-chloride", amount=45},
        {type="item", name="eg-si", amount=1},
      },
    },
    ["grade-4-ti"] = {
      mode = "kept-transformed",
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
        {type="fluid", name="purified-ti-pulp", amount=42},
        {type="item", name="ti-enriched-dust", amount=6},
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
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="heavy-oil", amount=100},
        {type="item", name="gravel", amount=2},
        {type="item", name="powdered-ti", amount=2},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=40},
      },
    },
    ["molten-titanium-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.18627450980392,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=21},
        {type="fluid", name="perylene", amount=21},
        {type="item", name="high-grade-ti-powder", amount=1},
      },
      results = {
        {type="fluid", name="molten-titanium", amount=605},
      },
    },
    ["powdered-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.947049483586547,
      ingredients = {
        {type="fluid", name="mibc", amount=90},
        {type="item", name="grade-3-ti", amount=4},
      },
      results = {
        {type="fluid", name="tailings", amount=36},
        {type="fluid", name="ti-pulp-03", amount=54},
        {type="item", name="powdered-ti", amount=2},
      },
    },
    ["titanium-plate-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.15,
      ingredients = {
        {type="item", name="sand-casting", amount=4},
      },
      results = {
        {type="item", name="titanium-plate", amount=3},
      },
    },
    ["titanium-plate-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.39455782312925,
      ingredients = {
        {type="fluid", name="molten-glass", amount=157},
        {type="item", name="grade-3-ti", amount=45},
        {type="item", name="silver-plate", amount=5},
      },
      results = {
        {type="item", name="titanium-plate", amount=205},
      },
    },
    ["purified-ti-pulp"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.48,
      ingredients = {
        {type="fluid", name="mibc", amount=133},
        {type="fluid", name="sulfuric-acid", amount=145},
        {type="fluid", name="ti-pulp-03", amount=77},
        {type="item", name="grade-3-ti", amount=6},
        {type="item", name="p2s5", amount=1},
      },
      results = {
        {type="fluid", name="purified-ti-pulp", amount=74},
        {type="fluid", name="ti-overflow-waste", amount=37},
      },
    },
    ["ti-enriched-dust"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 1.02,
      ingredients = {
        {type="fluid", name="molten-steel", amount=101},
        {type="item", name="cobalt-fluoride", amount=1},
        {type="item", name="fecr-alloy", amount=3},
        {type="item", name="low-grade-rejects", amount=1},
        {type="item", name="nickel-plate", amount=6},
        {type="item", name="niobium-plate", amount=3},
        {type="item", name="phosphate-rock", amount=4},
      },
      results = {
        {type="fluid", name="molten-stainless-steel", amount=51},
      },
    },
    ["hotair-stainless-steel"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.30769230769231,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=114},
        {type="item", name="anemometer-mk01", amount=1},
        {type="item", name="aramid", amount=1},
        {type="item", name="fecr-alloy", amount=1},
      },
      results = {
        {type="item", name="stainless-steel", amount=17},
      },
    },
    ["stainless-steel"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=73},
        {type="fluid", name="molten-steel", amount=142},
        {type="item", name="aramid", amount=1},
        {type="item", name="fecr-alloy", amount=10},
        {type="item", name="nickel-plate", amount=3},
        {type="item", name="niobium-plate", amount=1},
      },
      results = {
        {type="item", name="stainless-steel", amount=12},
      },
    },
    ["guar-gum"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="item", name="guar", amount=31},
        {type="item", name="moondrop-seeds", amount=82},
      },
      results = {
        {type="item", name="guar-gum", amount=5},
      },
    },
    ["long-handed-inserter-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.866666666666667,
      ingredients = {
        {type="item", name="fawogae-spore", amount=25},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="nichrome", amount=1},
        {type="item", name="nylon-parts", amount=4},
        {type="item", name="olefin-barrel", amount=2},
        {type="item", name="pipe", amount=28},
        {type="item", name="plastic-bar", amount=17},
        {type="item", name="slacked-lime-barrel", amount=1},
        {type="item", name="soda-ash-barrel", amount=32},
        {type="item", name="tin-dust", amount=17},
      },
      results = {
        {type="item", name="long-handed-inserter", amount=13},
      },
    },
    ["small-parts-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="belt", amount=4},
        {type="item", name="duralumin", amount=2},
        {type="item", name="fiber", amount=12},
        {type="item", name="graphite", amount=2},
        {type="item", name="nylon-parts", amount=9},
        {type="item", name="pipe", amount=5},
        {type="item", name="powdered-ralesia-seeds", amount=5},
        {type="item", name="refined-concrete", amount=5},
        {type="item", name="refined-hazard-concrete", amount=8},
        {type="item", name="stainless-steel", amount=2},
        {type="item", name="stone", amount=9},
      },
      results = {
        {type="item", name="small-parts-02", amount=9},
      },
    },
    ["fast-inserter-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="steam", amount=15640},
        {type="item", name="anemometer-mk01", amount=8},
        {type="item", name="belt", amount=4},
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="kevlar", amount=11},
        {type="item", name="niobium-pipe-to-ground", amount=24},
        {type="item", name="vane-mk01", amount=3},
      },
      results = {
        {type="item", name="fast-inserter", amount=21},
      },
    },
    ["fast-transport-belt-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.13333333333333,
      ingredients = {
        {type="item", name="bolts", amount=125},
        {type="item", name="diesel-barrel", amount=20},
        {type="item", name="fish", amount=11},
        {type="item", name="lead-plate", amount=47},
        {type="item", name="naphthalene-oil-barrel", amount=5},
        {type="item", name="niobium-pipe", amount=96},
        {type="item", name="transport-belt", amount=21},
        {type="item", name="vrauks", amount=1},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=17},
      },
    },
    ["rotor"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="shaft-mk01", amount=3},
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
        {type="item", name="iron-stick", amount=128},
        {type="item", name="melamine", amount=7},
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
        {type="item", name="electronic-circuit", amount=6},
        {type="item", name="iron-stick", amount=28},
        {type="item", name="niobium-pipe", amount=80},
        {type="item", name="rotor", amount=2},
        {type="item", name="stator", amount=2},
      },
      results = {
        {type="item", name="electric-engine-unit", amount=5},
      },
    },
    ["nexelit-power-pole"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="fiber", amount=3},
        {type="item", name="powdered-ralesia-seeds", amount=4},
        {type="item", name="refined-hazard-concrete", amount=19},
      },
      results = {
        {type="item", name="nexelit-power-pole", amount=3},
      },
    },
    ["anemometer-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bakelite", amount=8},
        {type="item", name="bisphenol-a", amount=30},
        {type="item", name="cermet", amount=1},
        {type="item", name="diesel-barrel", amount=2},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="melamine", amount=12},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="anemometer-mk02", amount=1},
      },
    },
    ["blade-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="jaw-crusher", amount=1},
        {type="item", name="nexelit-plate", amount=30},
        {type="item", name="nxsb-alloy", amount=22},
        {type="item", name="salt", amount=164},
      },
      results = {
        {type="item", name="blade-mk02", amount=3},
      },
    },
    ["brake-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=4},
        {type="item", name="bisphenol-a", amount=17},
        {type="item", name="eg-si", amount=2},
        {type="item", name="lead-plate", amount=28},
        {type="item", name="niobium-oxide", amount=4},
        {type="item", name="niobium-pipe", amount=10},
        {type="item", name="salt", amount=81},
        {type="item", name="shaft-mk02", amount=1},
        {type="item", name="sodium-bisulfate", amount=44},
        {type="item", name="sugar", amount=4},
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
        {type="item", name="bisphenol-a", amount=60},
        {type="item", name="blade-mk02", amount=1},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=12},
        {type="item", name="eva", amount=79},
        {type="item", name="multiblade-turbine-mk01", amount=4},
        {type="item", name="powdered-quartz", amount=136},
        {type="item", name="used-nexelit-battery", amount=20},
      },
      results = {
        {type="item", name="controler-mk02", amount=3},
      },
    },
    ["electronics-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="battery-mk01", amount=4},
        {type="item", name="capacitor1", amount=183},
        {type="item", name="cermet", amount=125},
        {type="item", name="diode", amount=11},
        {type="item", name="formica", amount=15},
        {type="item", name="inductor2", amount=10},
        {type="item", name="industrial-solvent-barrel", amount=1},
        {type="item", name="melamine", amount=167},
        {type="item", name="optical-fiber", amount=3},
        {type="item", name="pcb1", amount=29},
        {type="item", name="pcb2", amount=2},
        {type="item", name="phenol", amount=47},
        {type="item", name="phenolicboard", amount=27},
        {type="item", name="resistor2", amount=22},
        {type="item", name="transistor", amount=37},
      },
      results = {
        {type="item", name="electronics-mk02", amount=4},
      },
    },
    ["gearbox-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=8},
        {type="item", name="bisphenol-a", amount=5},
        {type="item", name="diesel-barrel", amount=6},
        {type="item", name="engine-unit", amount=16},
        {type="item", name="fish", amount=3},
        {type="item", name="niobium-pipe", amount=6},
        {type="item", name="salt", amount=70},
        {type="item", name="sb-oxide", amount=10},
        {type="item", name="shaft-mk02", amount=5},
        {type="item", name="sodium-bisulfate", amount=38},
        {type="item", name="sugar", amount=8},
        {type="item", name="titanium-plate", amount=19},
        {type="item", name="tower-mk01", amount=1},
      },
      results = {
        {type="item", name="gearbox-mk02", amount=1},
      },
    },
    ["hotair-shaft-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=3},
        {type="item", name="sand", amount=24},
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
        {type="item", name="cladded-core", amount=5},
        {type="item", name="molybdenum-plate", amount=2},
      },
      results = {
        {type="item", name="vane-mk02", amount=2},
      },
    },
    ["shaft-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="molten-stainless-steel", amount=73},
        {type="item", name="aluminium-plate", amount=54},
        {type="item", name="grade-4-nickel", amount=1},
        {type="item", name="lead-plate", amount=21},
        {type="item", name="niobium-plate", amount=5},
        {type="item", name="vane-mk01", amount=1},
      },
      results = {
        {type="item", name="shaft-mk02", amount=1},
      },
    },
    ["utility-box-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=9},
        {type="item", name="bio-container", amount=40},
        {type="item", name="electronic-circuit", amount=158},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="engine-unit", amount=1},
        {type="item", name="epoxy", amount=23},
        {type="item", name="niobium-pipe", amount=46},
        {type="item", name="pump", amount=5},
        {type="item", name="tuuphra-mk02", amount=2},
      },
      results = {
        {type="item", name="utility-box-mk02", amount=3},
      },
    },
    ["vane-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="zinc-chloride", amount=156},
      },
      results = {
        {type="item", name="vane-mk02", amount=1},
      },
    },
    ["nacelle-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anemometer-mk02", amount=5},
        {type="item", name="controler-mk01", amount=19},
        {type="item", name="dowfroth-250-barrel", amount=13},
        {type="item", name="earth-palmtree-sample", amount=1},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="fish-food-01", amount=4},
        {type="item", name="intermetallics", amount=29},
        {type="item", name="moss-mk02", amount=1},
        {type="item", name="nexelit-plate", amount=158},
        {type="item", name="solder", amount=38},
        {type="item", name="stopper", amount=16},
        {type="item", name="ti-rejects", amount=437},
        {type="item", name="vane-mk01", amount=40},
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
        {type="item", name="anemometer-mk01", amount=9},
        {type="item", name="controler-mk01", amount=4},
        {type="item", name="glass", amount=356},
        {type="item", name="sncr-alloy", amount=4},
        {type="item", name="ticl4", amount=72},
      },
      results = {
        {type="item", name="rotor-mk02", amount=1},
      },
    },
    ["tower-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="eg-si", amount=217},
        {type="item", name="engine-unit", amount=11},
        {type="item", name="niobium-oxide", amount=463},
        {type="item", name="rotor-mk01", amount=1},
        {type="item", name="shaft-mk02", amount=7},
        {type="item", name="sodium-hydroxide", amount=336},
      },
      results = {
        {type="item", name="tower-mk02", amount=2},
      },
    },
    ["yaw-drive-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="brake-mk02", amount=1},
        {type="item", name="carbon-black", amount=182},
        {type="item", name="controler-mk01", amount=3},
        {type="item", name="eg-si", amount=89},
        {type="item", name="electronic-circuit", amount=22},
        {type="item", name="engine-unit", amount=7},
        {type="item", name="explosives", amount=27},
        {type="item", name="fast-transport-belt", amount=38},
        {type="item", name="gunpowder", amount=660},
        {type="item", name="intermetallics", amount=3},
        {type="item", name="niobium-oxide", amount=190},
        {type="item", name="sb-oxide", amount=4},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="sodium-hydroxide", amount=138},
        {type="item", name="zinc-acetate", amount=19},
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
        {type="item", name="grade-4-ti", amount=190},
        {type="item", name="vinyl-acetate-barrel", amount=39},
        {type="item", name="yotoi-aloe-orchard-mk01", amount=3},
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
        {type="item", name="carbolic-oil-barrel", amount=51},
        {type="item", name="crucible", amount=105},
        {type="item", name="grade-4-ti", amount=76},
        {type="item", name="multiblade-turbine-mk01", amount=13},
        {type="item", name="py-science-pack-1", amount=3},
        {type="item", name="yotoi-aloe-orchard-mk01", amount=3},
      },
      results = {
        {type="item", name="productivity-module", amount=1},
      },
    },
    ["speed-module"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brake-mk02", amount=4},
        {type="item", name="earth-cow-sample", amount=2},
        {type="item", name="eva", amount=5},
        {type="item", name="retorter", amount=18},
        {type="item", name="tower-mk01", amount=1},
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
        {type="item", name="bio-sample", amount=2},
        {type="item", name="electronic-circuit", amount=21},
        {type="item", name="p2s5", amount=8},
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
        {type="item", name="bio-sample", amount=4},
        {type="item", name="electronic-circuit", amount=42},
        {type="item", name="p2s5", amount=43},
      },
      results = {
        {type="item", name="cadaveric-arum-codex", amount=1},
      },
    },
    ["navens-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="electronics-mk02", amount=12},
        {type="item", name="engine-unit", amount=6},
        {type="item", name="sb-hpo-pu", amount=4},
        {type="item", name="small-parts-02", amount=810},
        {type="item", name="storage-tank", amount=7},
      },
      results = {
        {type="item", name="navens-codex", amount=2},
      },
    },
    ["rennea-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=62},
        {type="item", name="electronic-circuit", amount=21},
        {type="item", name="inductor1", amount=227},
        {type="item", name="soda-ash-barrel", amount=3},
        {type="item", name="sodium-hydroxide", amount=163},
        {type="item", name="transport-belt", amount=19},
      },
      results = {
        {type="item", name="rennea-codex", amount=2},
      },
    },
    ["grod-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-sample", amount=3},
        {type="item", name="chromium", amount=7},
        {type="item", name="electronic-circuit", amount=10},
        {type="item", name="inductor1", amount=279},
        {type="item", name="p2s5", amount=33},
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
        {type="item", name="coalbed-gas-canister", amount=5},
        {type="item", name="electronic-circuit", amount=9},
        {type="item", name="inductor1", amount=287},
        {type="item", name="lead-plate", amount=8},
        {type="item", name="pipe", amount=19},
      },
      results = {
        {type="item", name="yotoi-codex", amount=1},
      },
    },
    ["earth-jute-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=1389},
        {type="item", name="chitin", amount=18},
        {type="item", name="chromium", amount=216},
        {type="item", name="earth-generic-sample", amount=1},
        {type="item", name="py-science-pack-1", amount=63},
        {type="item", name="utility-box-mk01", amount=1},
        {type="item", name="zipir-codex", amount=12},
      },
      results = {
        {type="item", name="earth-jute-sample", amount=1},
      },
    },
    ["earth-sunflower-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="alien-sample01", amount=25},
        {type="item", name="bio-sample", amount=31},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="logistic-science-pack", amount=137},
        {type="item", name="py-science-pack-1", amount=56},
        {type="item", name="yotoi-codex", amount=1},
      },
      results = {
        {type="item", name="earth-sunflower-sample", amount=2},
      },
    },
    ["earth-tropical-tree-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample", amount=61},
        {type="item", name="kicalk-codex", amount=1},
        {type="item", name="py-science-pack-1", amount=335},
      },
      results = {
        {type="item", name="earth-tropical-tree-sample", amount=2},
      },
    },
    ["cadaveric-arum-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-codex", amount=5},
        {type="item", name="cadaveric-arum-codex", amount=3},
        {type="item", name="cladding", amount=10},
        {type="item", name="cytostatics", amount=5},
        {type="item", name="dna-polymerase", amount=22},
        {type="item", name="earth-bee-sample", amount=1},
        {type="item", name="earth-crustacean-sample", amount=3},
        {type="item", name="earth-sea-sponge-sample", amount=2},
        {type="item", name="primers", amount=16},
        {type="item", name="retrovirus", amount=7},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=4},
      },
    },
    ["cadaveric-arum-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.625,
      ingredients = {
        {type="item", name="rennea", amount=2},
      },
      results = {
        {type="item", name="cadaveric-arum-seeds", amount=5},
      },
    },
    ["cadaveric-arum-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="tar", amount=440},
        {type="item", name="cadaveric-arum-seeds", amount=7},
        {type="item", name="coal-dust", amount=3},
        {type="item", name="phenol", amount=2},
      },
      results = {
        {type="item", name="cadaveric-arum", amount=6},
      },
    },
    ["cadaveric-acidgas-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.47285451007657,
      ingredients = {
        {type="item", name="rennea", amount=2},
      },
      results = {
        {type="fluid", name="acidgas", amount=140},
        {type="item", name="cadaveric-arum-seeds", amount=3},
      },
    },
    ["grod-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-sample01", amount=12},
        {type="item", name="cytostatics", amount=8},
        {type="item", name="glass", amount=165},
        {type="item", name="tuuphra-codex", amount=5},
      },
      results = {
        {type="item", name="grod", amount=2},
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
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.833333333333333,
      ingredients = {
        {type="item", name="grod", amount=4},
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
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="steam", amount=171},
        {type="item", name="grod-seeds", amount=4},
        {type="item", name="ore-tin", amount=2},
        {type="item", name="sand", amount=5},
      },
      results = {
        {type="item", name="grod", amount=4},
      },
    },
    ["rennea-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="alien-sample-02", amount=10},
        {type="item", name="alien-sample01", amount=13},
        {type="item", name="cytostatics", amount=7},
        {type="item", name="earth-sunflower-sample", amount=2},
        {type="item", name="earth-tropical-tree-sample", amount=1},
        {type="item", name="mukmoux-codex", amount=2},
        {type="item", name="sodium-hydroxide", amount=546},
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
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=59},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="iron-ore", amount=10},
        {type="item", name="moondrop-seeds", amount=3},
        {type="item", name="raw-fiber", amount=13},
        {type="item", name="rennea-seeds", amount=4},
      },
      results = {
        {type="item", name="rennea", amount=5},
      },
    },
    ["bhoddos-to-ti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="item", name="bhoddos", amount=1},
      },
      results = {
        {type="item", name="ore-titanium", amount=5},
      },
    },
    ["blood-to-zinc"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="blood", amount=52},
        {type="item", name="meat", amount=1},
      },
      results = {
        {type="item", name="ore-zinc", amount=12},
      },
    },
    ["fish-oil-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1277},
      },
      results = {
        {type="item", name="ore-tin", amount=4},
      },
    },
    ["fish-to-tin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.96,
      ingredients = {
        {type="item", name="fish", amount=10},
      },
      results = {
        {type="item", name="ore-tin", amount=24},
      },
    },
    ["grod-to-zinc"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="dried-grods", amount=4},
        {type="item", name="grod", amount=2},
      },
      results = {
        {type="item", name="ore-zinc", amount=5},
      },
    },
    ["meat-to-chromium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3.73333333333333,
      ingredients = {
        {type="fluid", name="blood", amount=160},
        {type="item", name="brain", amount=1},
      },
      results = {
        {type="item", name="ore-chromium", amount=56},
      },
    },
    ["navens-to-tin"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="yotoi-fruit", amount=1},
      },
      results = {
        {type="item", name="ore-chromium", amount=10},
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.77,
      ingredients = {
        {type="fluid", name="pressured-steam", amount=200},
        {type="fluid", name="vacuum", amount=79},
      },
      results = {
        {type="fluid", name="pressured-steam", amount=277},
      },
    },
    ["rennea-cu"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.705073071592178,
      ingredients = {
        {type="item", name="rennea-seeds", amount=4},
      },
      results = {
        {type="fluid", name="waste-water", amount=37},
        {type="item", name="cu-biomass", amount=7},
      },
    },
    ["tuuphra-nacl"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.813153200381718,
      ingredients = {
        {type="fluid", name="tar", amount=128},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=42},
        {type="item", name="nacl-biomass", amount=8},
      },
    },
    ["grod-sn"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.10743546510914,
      ingredients = {
        {type="fluid", name="tar", amount=268},
        {type="item", name="grod", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=56},
        {type="item", name="sn-biomass", amount=11},
      },
    },
    ["navens-fe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.641898344326195,
      ingredients = {
        {type="fluid", name="tar", amount=202},
        {type="item", name="navens", amount=1},
        {type="item", name="seaweed", amount=2},
      },
      results = {
        {type="fluid", name="waste-water", amount=33},
        {type="item", name="fe-biomass", amount=5},
      },
    },
    ["yotoi-fe"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.32225367573914,
      ingredients = {
        {type="fluid", name="btx", amount=14},
        {type="fluid", name="tailings", amount=319},
        {type="item", name="yotoi", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=65},
        {type="item", name="fe-biomass", amount=20},
      },
    },
    ["moondrop-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="steam", amount=348},
        {type="fluid", name="vacuum", amount=85},
        {type="item", name="drill-head", amount=1},
        {type="item", name="fertilizer", amount=4},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="powdered-biomass", amount=6},
        {type="item", name="py-asphalt", amount=3},
        {type="item", name="raw-fiber", amount=2},
      },
      results = {
        {type="item", name="moondrop", amount=12},
      },
    },
    ["moonshine-fueloil-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="fluid", name="methane", amount=103},
        {type="item", name="moondrop-mk02", amount=2},
        {type="item", name="moondrop-seeds-mk02", amount=1},
        {type="item", name="sn-biomass", amount=9},
      },
      results = {
        {type="item", name="moondrop-fueloil", amount=45},
      },
    },
    ["ethylene-chlorohydrin"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.29,
      ingredients = {
        {type="fluid", name="water-saline", amount=176},
        {type="item", name="gold-plate", amount=3},
        {type="item", name="silver-plate", amount=1},
      },
      results = {
        {type="fluid", name="ethylene-chlorohydrin", amount=129},
      },
    },
    ["moonshine-fueloil-pressing-1"] = {
      mode = "kept-transformed",
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.05,
      ingredients = {
        {type="fluid", name="ethylene-chlorohydrin", amount=42},
        {type="fluid", name="hydrogen-chloride", amount=1229},
      },
      results = {
        {type="fluid", name="chloroethanol", amount=105},
      },
    },
    ["ethylene-glycol"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.426666666666667,
      ingredients = {
        {type="fluid", name="chloroethanol", amount=42},
        {type="item", name="ground-sample01", amount=3},
      },
      results = {
        {type="fluid", name="ethylene-glycol", amount=64},
      },
    },
    ["ferrite"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=9},
        {type="item", name="chromium", amount=19},
        {type="item", name="iron-oxide", amount=15},
        {type="item", name="iron-stick", amount=115},
        {type="item", name="melamine", amount=6},
        {type="item", name="zinc-plate", amount=4},
      },
      results = {
        {type="item", name="ferrite", amount=4},
      },
    },
    ["lead-container"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="niobium-plate", amount=31},
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="sodium-bisulfate", amount=3},
      },
      results = {
        {type="item", name="lead-container", amount=1},
      },
    },
    ["nexelit-matrix"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="bakelite", amount=5},
        {type="item", name="chromium", amount=1},
      },
      results = {
        {type="item", name="nexelit-matrix", amount=3},
      },
    },
    ["nuclear-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bakelite", amount=8},
        {type="item", name="cermet", amount=12},
        {type="item", name="nylon-parts", amount=30},
        {type="item", name="pu-241", amount=3},
        {type="item", name="ree-concentrate", amount=25},
        {type="item", name="tin-plate", amount=9},
      },
      results = {
        {type="item", name="nuclear-sample", amount=2},
      },
    },
    ["sodium-chlorate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="boric-acid", amount=100},
        {type="fluid", name="steam", amount=62},
        {type="item", name="ore-nickel", amount=6},
      },
      results = {
        {type="item", name="sodium-chlorate", amount=5},
      },
    },
    ["steam-heating"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.2541036091453,
      ingredients = {
        {type="fluid", name="steam", amount=2254},
        {type="item", name="fuelrod-mk01", amount=1},
      },
      results = {
        {type="fluid", name="steam", amount=2254},
      },
    },
    ["tuuphra-to-mo"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.2,
      ingredients = {
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="molybdenum-ore", amount=1},
      },
    },
    ["plutonium-fuel-cell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="crude-oil-barrel", amount=6},
        {type="item", name="duralumin", amount=7},
        {type="item", name="molten-zinc-barrel", amount=2},
        {type="item", name="pu-242", amount=3},
        {type="item", name="repair-pack", amount=6},
        {type="item", name="u-pulp-03-barrel", amount=13},
      },
      results = {
        {type="item", name="mox-fuel-cell", amount=2},
      },
    },
    ["crmoni"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="aromatics", amount=178},
        {type="item", name="chromite-sand", amount=17},
        {type="item", name="molybdenum-plate", amount=5},
        {type="item", name="molybdenum-sulfide", amount=10},
        {type="item", name="nickel-plate", amount=4},
        {type="item", name="salt", amount=13},
        {type="item", name="titanium-plate", amount=6},
      },
      results = {
        {type="item", name="crmoni", amount=3},
      },
    },
    ["nbalti"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="niobium-complex", amount=11},
        {type="item", name="aluminium-plate", amount=2},
        {type="item", name="glass", amount=2},
        {type="item", name="niobium-oxide", amount=2},
        {type="item", name="sand", amount=3},
        {type="item", name="titanium-plate", amount=8},
      },
      results = {
        {type="item", name="nbalti", amount=2},
      },
    },
    ["ptcda"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="organic-acid-anhydride", amount=97},
        {type="fluid", name="perylene", amount=97},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="item", name="ptcda", amount=1},
      },
    },
    ["self-assembly-monolayer"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="lead-acetate", amount=5},
        {type="item", name="nbalti", amount=2},
        {type="item", name="ptcda", amount=2},
        {type="item", name="rayon", amount=7},
        {type="item", name="sb-crushed", amount=14},
        {type="item", name="vitreloy", amount=4},
      },
      results = {
        {type="item", name="self-assembly-monolayer", amount=4},
      },
    },
    ["brain-cartridge-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="dirty-syngas", amount=1019},
        {type="item", name="bones", amount=18},
        {type="item", name="brain", amount=14},
        {type="item", name="dried-meat", amount=5},
      },
      results = {
        {type="item", name="brain-cartridge-01", amount=1},
      },
    },
    ["vat-brain"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="brain", amount=12},
        {type="item", name="cobalt-fluoride", amount=3},
        {type="item", name="crushed-quartz", amount=16},
        {type="item", name="grade-1-ti", amount=44},
        {type="item", name="middle-oil-barrel", amount=4},
        {type="item", name="nitrobenzene-barrel", amount=12},
        {type="item", name="self-assembly-monolayer", amount=10},
        {type="item", name="workers-food", amount=2},
        {type="item", name="zogna-bacteria-barrel", amount=3},
      },
      results = {
        {type="item", name="vat-brain", amount=1},
      },
    },
    ["mk02-locomotive"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel", amount=241},
        {type="item", name="blade-mk02", amount=12},
        {type="item", name="brake-mk02", amount=1},
        {type="item", name="carbolic-oil-barrel", amount=45},
        {type="item", name="coal-slurry-barrel", amount=133},
        {type="item", name="cobalt-fluoride", amount=173},
        {type="item", name="crude-cermet", amount=1196},
        {type="item", name="diborane-barrel", amount=81},
        {type="item", name="grade-2-lead", amount=225},
        {type="item", name="korlex-pup", amount=1},
        {type="item", name="medium-electric-pole", amount=27},
        {type="item", name="middle-oil-barrel", amount=233},
        {type="item", name="ore-quartz", amount=1397},
        {type="item", name="outlet-gas-01-barrel", amount=12},
        {type="item", name="petroleum-gas-canister", amount=72},
        {type="item", name="powdered-aluminium", amount=64},
        {type="item", name="psc-barrel", amount=3},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="ree-slurry-barrel", amount=4},
        {type="item", name="shotgun-shell", amount=106},
        {type="item", name="sic", amount=48},
        {type="item", name="small-parts-01", amount=276},
        {type="item", name="submachine-gun", amount=4},
        {type="item", name="titanium-plate", amount=166},
        {type="item", name="transport-belt", amount=186},
        {type="item", name="vinyl-acetate-barrel", amount=72},
      },
      results = {
        {type="item", name="mk02-locomotive", amount=2},
      },
    },
    ["mk02-wagon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="steam", amount=4748},
        {type="item", name="anemometer-mk01", amount=2},
        {type="item", name="aromatics-barrel", amount=3},
        {type="item", name="belt", amount=10},
        {type="item", name="bio-oil-barrel", amount=12},
        {type="item", name="brake-mk01", amount=2},
        {type="item", name="carbon-dioxide-barrel", amount=11},
        {type="item", name="carbon-sulfide-barrel", amount=43},
        {type="item", name="casein-pulp-01-barrel", amount=94},
        {type="item", name="fluid-drill-mk01", amount=2},
        {type="item", name="grade-1-iron", amount=8},
        {type="item", name="grade-2-lead", amount=2},
        {type="item", name="grade-2-nickel", amount=46},
        {type="item", name="kevlar", amount=3},
        {type="item", name="molten-stainless-steel-barrel", amount=1},
        {type="item", name="molten-titanium-barrel", amount=5},
        {type="item", name="niobium-pipe-to-ground", amount=7},
        {type="item", name="niobium-plate", amount=7},
        {type="item", name="py-steel", amount=15},
        {type="item", name="steel-chest", amount=2},
        {type="item", name="vane-mk01", amount=21},
        {type="item", name="vinyl-acetate-barrel", amount=1},
      },
      results = {
        {type="item", name="mk02-wagon", amount=1},
      },
    },
    ["mk02-fluid-wagon"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="brake-mk02", amount=3},
        {type="item", name="cobalt-fluoride", amount=60},
        {type="item", name="heavy-oil-canister", amount=25},
        {type="item", name="middle-oil-barrel", amount=209},
        {type="item", name="ore-quartz", amount=1248},
        {type="item", name="powdered-aluminium", amount=57},
        {type="item", name="psc-barrel", amount=10},
        {type="item", name="py-tank-3000", amount=3},
        {type="item", name="shotgun-shell", amount=297},
        {type="item", name="titanium-plate", amount=464},
        {type="item", name="transport-belt", amount=521},
        {type="item", name="u-pulp-03-barrel", amount=4},
        {type="item", name="vane-mk01", amount=5},
      },
      results = {
        {type="item", name="mk02-fluid-wagon", amount=3},
      },
    },
    ["glycerol2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.44,
      ingredients = {
        {type="fluid", name="pressured-air", amount=460},
        {type="item", name="brain", amount=1},
        {type="item", name="coke", amount=6},
      },
      results = {
        {type="fluid", name="glycerol", amount=22},
      },
    },
    ["oleochemicals-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.29,
      ingredients = {
        {type="fluid", name="boric-acid", amount=282},
        {type="item", name="cellulose", amount=2},
        {type="item", name="powdered-biomass", amount=685},
        {type="item", name="rennea", amount=1},
        {type="item", name="sporopollenin", amount=5},
      },
      results = {
        {type="fluid", name="oleochemicals", amount=258},
      },
    },
    ["sea-sponge-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33190768872845,
      ingredients = {
        {type="fluid", name="phytoplankton", amount=28},
        {type="fluid", name="zogna-bacteria", amount=64},
        {type="item", name="sea-sponge-sprouts", amount=1},
      },
      results = {
        {type="fluid", name="water-saline", amount=63},
        {type="item", name="sea-sponge", amount=4},
      },
    },
    ["silicon-wafer"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.50087305378625,
      ingredients = {
        {type="item", name="coke", amount=10},
        {type="item", name="eg-si", amount=5},
        {type="item", name="gunpowder", amount=4},
        {type="item", name="powdered-quartz", amount=1},
        {type="item", name="sodium-bisulfate", amount=4},
      },
      results = {
        {type="fluid", name="flue-gas", amount=160},
        {type="item", name="silicon-wafer", amount=3},
      },
    },
    ["heat-exchanger"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="grade-2-iron", amount=7},
        {type="item", name="moondrop-seeds-mk02", amount=12},
        {type="item", name="syngas-canister", amount=2},
      },
      results = {
        {type="item", name="heat-exchanger", amount=1},
      },
    },
    ["heat-pipe"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="grade-4-nickel", amount=31},
        {type="item", name="iron-plate", amount=38},
        {type="item", name="shaft-mk01", amount=2},
      },
      results = {
        {type="item", name="heat-pipe", amount=3},
      },
    },
    ["nuclear-reactor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bulk-inserter", amount=8},
        {type="item", name="caged-mukmoux", amount=182},
        {type="item", name="condensates-canister", amount=7134},
        {type="item", name="engine-unit", amount=4384},
        {type="item", name="glass", amount=9115},
        {type="item", name="leaching-station-mk01", amount=2},
        {type="item", name="light-oil-canister", amount=341},
        {type="item", name="molten-lead-barrel", amount=225},
        {type="item", name="moss-mk02", amount=149},
        {type="item", name="perylene-barrel", amount=54},
        {type="item", name="tall-oil-barrel", amount=648},
        {type="item", name="tidal-mk01", amount=2},
        {type="item", name="vrauks", amount=88},
        {type="item", name="vrauks-mk02", amount=12},
      },
      results = {
        {type="item", name="nuclear-reactor", amount=2},
      },
    },
    ["steam-turbine"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="copper-low-dust", amount=2},
        {type="item", name="fish-mk02", amount=2},
        {type="item", name="iron-pulp-01-barrel", amount=21},
        {type="item", name="nylon", amount=2},
        {type="item", name="tin-plate", amount=14},
        {type="item", name="transport-belt", amount=97},
        {type="item", name="ulric-mk02-dna-sample", amount=1},
      },
      results = {
        {type="item", name="steam-turbine", amount=1},
      },
    },
    ["zinc-acetate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1087},
        {type="item", name="grade-1-ti", amount=1},
        {type="item", name="zinc-plate", amount=10},
      },
      results = {
        {type="item", name="zinc-acetate", amount=1},
      },
    },
    ["heavy-n"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.5,
      ingredients = {
        {type="fluid", name="sb-pulp-02", amount=82},
        {type="item", name="ree-concentrate", amount=31},
        {type="item", name="silicon-wafer", amount=5},
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
        {type="fluid", name="etching", amount=20},
        {type="fluid", name="phosphine-gas", amount=19},
        {type="item", name="bisphenol-a", amount=6},
        {type="item", name="zinc-acetate", amount=1},
      },
      results = {
        {type="item", name="light-n", amount=8},
      },
    },
    ["p-dope"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="item", name="silicon-wafer", amount=6},
        {type="item", name="zinc-acetate", amount=2},
      },
      results = {
        {type="item", name="p-dope", amount=9},
      },
    },
    ["ammonium-chloride"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="ammonia", amount=95},
        {type="fluid", name="nitrogen", amount=121},
        {type="item", name="sodium-chlorate", amount=9},
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
        {type="fluid", name="cyanic-acid", amount=3},
        {type="item", name="phosphate-rock", amount=4},
        {type="item", name="sulfur", amount=4},
      },
      results = {
        {type="item", name="p2s5", amount=1},
        {type="item", name="pyrite", amount=2},
      },
    },
    ["uranium-fuel-cell"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="engine-unit", amount=1},
        {type="item", name="methanol-reactor", amount=2},
        {type="item", name="molten-zinc-barrel", amount=2},
        {type="item", name="nxsb-alloy", amount=16},
        {type="item", name="u-pulp-03-barrel", amount=34},
      },
      results = {
        {type="item", name="uranium-fuel-cell", amount=3},
      },
    },
    ["fuel-cell-dissolve"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.87,
      ingredients = {
        {type="item", name="long-handed-inserter", amount=31},
        {type="item", name="multiblade-turbine-mk01", amount=59},
      },
      results = {
        {type="fluid", name="sb-phosphate-1", amount=87},
      },
    },
    ["plutonium-fuel-reprocessing"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.42292645301828,
      ingredients = {
        {type="item", name="anemometer-mk01", amount=6},
        {type="item", name="controler-mk01", amount=6},
        {type="item", name="crude-oil-barrel", amount=116},
        {type="item", name="glass", amount=77},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=20},
        {type="item", name="u-238", amount=14},
      },
    },
    ["antimony-phosphate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="acetic-acid", amount=1088},
        {type="fluid", name="ammonia", amount=519},
        {type="fluid", name="propene", amount=2328},
        {type="fluid", name="zogna-bacteria", amount=160},
        {type="item", name="calcium-carbide", amount=49},
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="tuuphra", amount=3},
      },
      results = {
        {type="fluid", name="purex-concentrate-1", amount=120},
        {type="item", name="sb-hpo-pu", amount=12},
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
      energy_required_multiplier = 1.53,
      ingredients = {
        {type="fluid", name="ammonia", amount=3156},
        {type="fluid", name="flue-gas", amount=4207},
        {type="fluid", name="hydrogen-peroxide", amount=241},
        {type="item", name="sb-hpo-pu", amount=4},
      },
      results = {
        {type="fluid", name="plutonium-peroxide", amount=153},
        {type="fluid", name="sb-phosphate-2", amount=153},
      },
    },
    ["plutonium-shuffle-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=78},
        {type="item", name="plutonium-oxide", amount=12},
        {type="item", name="pu-241", amount=1},
      },
      results = {
        {type="item", name="pu-238", amount=4},
        {type="item", name="pu-242", amount=4},
      },
    },
    ["plutonium-shuffle-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=65},
        {type="item", name="plutonium-oxide", amount=1},
        {type="item", name="sb-hpo-pu", amount=5},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=26},
        {type="item", name="pu-242", amount=3},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-241", amount=1},
      },
    },
    ["plutonium-shuffle-4"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=16},
        {type="item", name="plutonium-oxide", amount=4},
        {type="item", name="pu-242", amount=1},
      },
      results = {
        {type="item", name="pu-239", amount=1},
        {type="item", name="pu-240", amount=1},
      },
    },
    ["rayon"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=62},
        {type="fluid", name="vacuum", amount=1394},
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="capacitor1", amount=7},
        {type="item", name="raw-fiber", amount=14},
        {type="item", name="sodium-sulfate", amount=5},
        {type="item", name="tinned-cable", amount=27},
        {type="item", name="urea", amount=10},
      },
      results = {
        {type="item", name="rayon", amount=7},
      },
    },
    ["battery-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="item", name="pbsb-alloy", amount=12},
        {type="item", name="rayon", amount=1},
      },
      results = {
        {type="item", name="battery-mk01", amount=4},
      },
    },
    ["battery-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=2},
        {type="item", name="p2s5", amount=4},
        {type="item", name="pbsb-alloy", amount=2},
        {type="item", name="rayon", amount=5},
      },
      results = {
        {type="item", name="battery-mk01", amount=8},
      },
    },
    ["nas-battery"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="nxsb-alloy", amount=1},
        {type="item", name="rayon", amount=2},
        {type="item", name="salt", amount=374},
        {type="item", name="sulfur", amount=52},
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
        {type="item", name="nylon-parts", amount=19},
        {type="item", name="pure-sand", amount=15},
        {type="item", name="sodium-silicate", amount=1},
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
        {type="fluid", name="subcritical-water", amount=3244},
        {type="item", name="washer", amount=1},
      },
      results = {
        {type="item", name="nexelit-battery", amount=3},
      },
    },
    ["casein-mixture-03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.37626568619611,
      ingredients = {
        {type="fluid", name="flue-gas", amount=1655},
        {type="fluid", name="milk", amount=21},
        {type="fluid", name="sulfuric-acid", amount=96},
        {type="item", name="zinc-plate", amount=6},
      },
      results = {
        {type="fluid", name="casein-mixture", amount=110},
        {type="fluid", name="waste-water", amount=69},
      },
    },
    ["fish-emulsion"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.486930422189217,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=812},
        {type="item", name="manure", amount=1},
      },
      results = {
        {type="fluid", name="fish-emulsion", amount=19},
        {type="fluid", name="fish-oil", amount=7},
        {type="item", name="fishmeal", amount=5},
      },
    },
    ["b-molasse"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33,
      ingredients = {
        {type="fluid", name="a-molasse", amount=38},
        {type="fluid", name="flue-gas", amount=559},
        {type="fluid", name="zogna-bacteria", amount=17},
        {type="item", name="filtration-media", amount=1},
      },
      results = {
        {type="fluid", name="b-molasse", amount=133},
      },
    },
    ["ethanol"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.16,
      ingredients = {
        {type="fluid", name="b-molasse", amount=82},
        {type="fluid", name="zogna-bacteria", amount=14},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="fluid", name="ethanol", amount=116},
      },
    },
    ["syrup-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.34,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=357},
        {type="fluid", name="pressured-air", amount=7658},
        {type="item", name="cellulose", amount=10},
        {type="item", name="dried-meat", amount=6},
        {type="item", name="lignin", amount=20},
        {type="item", name="retrovirus", amount=1},
        {type="item", name="sodium-hydroxide", amount=1},
      },
      results = {
        {type="fluid", name="syrup-01", amount=67},
      },
    },
    ["fertilizer-5"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.26666666666667,
      ingredients = {
        {type="fluid", name="zogna-bacteria", amount=10},
        {type="item", name="bones", amount=6},
        {type="item", name="ore-tin", amount=11},
        {type="item", name="pyrite", amount=4},
        {type="item", name="urea", amount=26},
      },
      results = {
        {type="item", name="fertilizer", amount=19},
      },
    },
    ["fertilizer-fish-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33333333333333,
      ingredients = {
        {type="fluid", name="subcritical-water", amount=5930},
        {type="item", name="nexelit-plate", amount=9},
      },
      results = {
        {type="item", name="fertilizer", amount=4},
      },
    },
    ["fertilizer-fish-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="coke", amount=8},
        {type="item", name="cottongut-food-01", amount=13},
        {type="item", name="kicalk", amount=9},
        {type="item", name="log", amount=1},
        {type="item", name="nickel-rejects", amount=3},
      },
      results = {
        {type="item", name="fertilizer", amount=3},
      },
    },
    ["split-yellowcake"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.944444444444444,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=148},
        {type="item", name="cladding", amount=1},
        {type="item", name="lens", amount=2},
        {type="item", name="pipe", amount=4},
        {type="item", name="rubber", amount=3},
        {type="item", name="yellow-cake", amount=6},
      },
      results = {
        {type="item", name="u-235", amount=1},
        {type="item", name="u-238", amount=8},
      },
    },
    ["plutonium"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="plutonium-peroxide", amount=145},
        {type="item", name="pu-242", amount=1},
      },
      results = {
        {type="item", name="plutonium-oxide", amount=15},
      },
    },
    ["night-vision-equipment"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=30},
        {type="item", name="slacked-lime-barrel", amount=1},
        {type="item", name="tin-dust", amount=18},
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
        {type="item", name="al-pulp-02-barrel", amount=16},
        {type="item", name="bisphenol-a", amount=21},
        {type="item", name="blade-mk02", amount=2},
        {type="item", name="electronic-circuit", amount=87},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="fish-egg-mk02", amount=58},
        {type="item", name="long-handed-inserter", amount=4},
        {type="item", name="oxygen-barrel", amount=1308},
        {type="item", name="powdered-quartz", amount=46},
        {type="item", name="py-ze", amount=2},
      },
      results = {
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
      },
    },
    ["belt-immunity-equipment"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bio-oil-canister", amount=16},
        {type="item", name="btx-barrel", amount=75},
        {type="item", name="fiberboard", amount=4},
        {type="item", name="gearbox-mk01", amount=3},
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
        {type="item", name="brain", amount=30},
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
        {type="fluid", name="water", amount=512},
        {type="item", name="bones", amount=2},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=2},
      },
    },
    ["print-bonemeal"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="fluid", name="psc", amount=46},
        {type="item", name="chitin", amount=15},
      },
      results = {
        {type="item", name="bonemeal", amount=3},
      },
    },
    ["print-bones"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="psc", amount=37},
        {type="item", name="bio-scafold", amount=1},
      },
      results = {
        {type="item", name="bones", amount=3},
      },
    },
    ["print-brain"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="bio-scafold", amount=2},
      },
      results = {
        {type="item", name="brain", amount=3},
      },
    },
    ["print-fat"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.2,
      ingredients = {
        {type="item", name="bio-scafold", amount=1},
        {type="item", name="bones", amount=5},
        {type="item", name="brain", amount=48},
      },
      results = {
        {type="item", name="mukmoux-fat", amount=11},
      },
    },
    ["print-guts"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.83333333333333,
      ingredients = {
        {type="fluid", name="pressured-air", amount=46221},
        {type="item", name="bio-scafold", amount=2},
      },
      results = {
        {type="item", name="guts", amount=11},
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.81,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=135},
        {type="item", name="cellulose", amount=4},
      },
      results = {
        {type="fluid", name="syngas", amount=81},
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
      energy_required_multiplier = 1.26,
      ingredients = {
        {type="fluid", name="liquid-nitrogen", amount=38},
        {type="item", name="cobalt-extract", amount=2},
        {type="item", name="iron-plate", amount=3},
        {type="item", name="nickel-plate", amount=2},
        {type="item", name="nisi", amount=1},
        {type="item", name="sic", amount=1},
        {type="item", name="silicon", amount=3},
      },
      results = {
        {type="fluid", name="tpa", amount=63},
      },
    },
    ["oleo-gasification"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.31564205816555,
      ingredients = {
        {type="fluid", name="oleochemicals", amount=290},
        {type="fluid", name="pressured-water", amount=1395},
      },
      results = {
        {type="fluid", name="aromatics", amount=263},
        {type="fluid", name="tar", amount=395},
      },
    },
    ["crucible"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="ceramic", amount=6},
        {type="item", name="quartz-tube", amount=4},
        {type="item", name="sodium-silicate", amount=1},
      },
      results = {
        {type="item", name="crucible", amount=3},
      },
    },
    ["eva"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=27},
        {type="fluid", name="vinyl-acetate", amount=21},
      },
      results = {
        {type="item", name="eva", amount=3},
      },
    },
    ["mechanical-parts-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.33333333333333,
      ingredients = {
        {type="item", name="aluminium-plate", amount=137},
        {type="item", name="anemometer-mk02", amount=1},
        {type="item", name="automated-factory-mk01", amount=4},
        {type="item", name="brake-mk01", amount=8},
        {type="item", name="controler-mk01", amount=17},
        {type="item", name="dowfroth-250-barrel", amount=4},
        {type="item", name="duralumin", amount=117},
        {type="item", name="earth-palmtree-sample", amount=1},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="engine-unit", amount=3},
        {type="item", name="eva", amount=200},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="intermetallics", amount=25},
        {type="item", name="ppd", amount=12},
        {type="item", name="shaft-mk01", amount=2},
        {type="item", name="ti-rejects", amount=124},
        {type="item", name="tower-mk01", amount=11},
        {type="item", name="vane-mk01", amount=90},
      },
      results = {
        {type="item", name="mechanical-parts-02", amount=14},
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
      energy_required_multiplier = 1.2,
      ingredients = {
        {type="fluid", name="sb-58-conc", amount=21},
        {type="fluid", name="sb-pulp-02", amount=151},
        {type="item", name="ree-concentrate", amount=22},
        {type="item", name="silicon-wafer", amount=1},
        {type="item", name="zinc-chloride", amount=8},
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
        {type="fluid", name="ammonia", amount=690},
        {type="fluid", name="flue-gas", amount=920},
        {type="item", name="lead-plate", amount=4},
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
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="calcium-carbide", amount=9},
        {type="item", name="sb-grade-02", amount=8},
      },
      results = {
        {type="item", name="sb-crushed", amount=1},
      },
    },
    ["sb-dust"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="calcium-carbide", amount=5},
        {type="item", name="sb-grade-02", amount=30},
        {type="item", name="sb-grade-03", amount=3},
      },
      results = {
        {type="item", name="sb-dust", amount=2},
        {type="item", name="sb-grade-04", amount=1},
      },
    },
    ["sb-pulp-01"] = {
      mode = "kept-pruned-transformed",
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
      energy_required_multiplier = 0.82,
      ingredients = {
        {type="fluid", name="dowfroth-250", amount=48},
        {type="fluid", name="sb-pulp-01", amount=77},
      },
      results = {
        {type="fluid", name="sb-58-conc", amount=8},
        {type="fluid", name="sb-pulp-02", amount=42},
      },
    },
    ["fast-splitter"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bio-container", amount=9},
        {type="item", name="brain", amount=3},
        {type="item", name="duralumin", amount=7},
        {type="item", name="electronic-circuit", amount=36},
        {type="item", name="grade-3-zinc", amount=5},
        {type="item", name="tailings-barrel", amount=25},
        {type="item", name="tuuphra-mk02", amount=3},
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
        {type="fluid", name="water", amount=1590},
        {type="item", name="aluminium-plate", amount=13},
        {type="item", name="lead-plate", amount=39},
        {type="item", name="niobium-plate", amount=3},
        {type="item", name="transport-belt", amount=2},
      },
      results = {
        {type="item", name="fast-transport-belt", amount=2},
      },
    },
    ["fast-underground-belt"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="diesel-barrel", amount=36},
        {type="item", name="fish", amount=60},
        {type="item", name="naphthalene-oil-barrel", amount=29},
        {type="item", name="vrauks", amount=4},
      },
      results = {
        {type="item", name="fast-underground-belt", amount=2},
      },
    },
    ["neutron-absorber-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="coalbed-gas-barrel", amount=49},
        {type="item", name="condensates-canister", amount=7},
        {type="item", name="drill-head", amount=8},
        {type="item", name="grade-4-ti", amount=71},
        {type="item", name="lab", amount=21},
        {type="item", name="molten-steel-barrel", amount=6},
        {type="item", name="ore-chromium", amount=205},
        {type="item", name="small-parts-01", amount=146},
        {type="item", name="stone-furnace", amount=17},
        {type="item", name="subcritical-water-barrel", amount=41},
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
        {type="item", name="bulk-inserter", amount=11},
        {type="item", name="caged-mukmoux", amount=79},
        {type="item", name="condensates-canister", amount=1217},
        {type="item", name="creosote-barrel", amount=198},
        {type="item", name="electric-engine-unit", amount=10},
        {type="item", name="molten-lead-barrel", amount=38},
        {type="item", name="moss-mk02", amount=204},
        {type="item", name="tall-oil-barrel", amount=282},
        {type="item", name="tidal-mk01", amount=1},
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
        {type="item", name="carbolic-oil-canister", amount=187},
        {type="item", name="coal-gas-canister", amount=169},
        {type="item", name="condensates-canister", amount=183},
        {type="item", name="fish-egg-mk03", amount=2},
        {type="item", name="fish-emulsion-barrel", amount=184},
        {type="item", name="intermetallics", amount=213},
        {type="item", name="kerosene-canister", amount=32},
        {type="item", name="medium-electric-pole", amount=36},
        {type="item", name="molten-lead-barrel", amount=6},
        {type="item", name="molten-stainless-steel-barrel", amount=14},
        {type="item", name="moss-mk02", amount=4},
        {type="item", name="purest-nitrogen-gas-barrel", amount=3411},
        {type="item", name="py-oil-powerplant-mk01", amount=1},
        {type="item", name="ticl4", amount=79},
        {type="item", name="trichlorosilane-barrel", amount=161},
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
        {type="item", name="albumin", amount=59},
        {type="item", name="anthracene-oil-canister", amount=2246},
        {type="item", name="bitumen-barrel", amount=262},
        {type="item", name="capacitor2", amount=149},
        {type="item", name="concentrated-ti", amount=210},
        {type="item", name="kerosene-canister", amount=1048},
        {type="item", name="low-grade-copper", amount=337},
        {type="item", name="mechanical-parts-01", amount=36},
        {type="item", name="molybdenum-pulp-barrel", amount=151},
        {type="item", name="petri-dish-bacteria", amount=231},
        {type="item", name="pitch-barrel", amount=348},
        {type="item", name="productivity-module", amount=1},
        {type="item", name="py-heat-exchanger", amount=3},
        {type="item", name="py-tank-5000", amount=1},
        {type="item", name="sea-sponge-codex", amount=1},
        {type="item", name="tuuphra", amount=95},
        {type="item", name="xyhiphoe-cub-mk02", amount=5},
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
        {type="item", name="advanced-circuit", amount=60},
        {type="item", name="albumin", amount=1221},
        {type="item", name="bulk-inserter", amount=5},
        {type="item", name="eg-si", amount=1031},
        {type="item", name="fatty-acids-canister", amount=428},
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
        {type="item", name="research-center-mk01", amount=3},
        {type="item", name="rhe", amount=4},
        {type="item", name="vrauks-mk03", amount=2},
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
        {type="item", name="bio-printer-mk01", amount=2},
        {type="item", name="brake-mk02", amount=6},
        {type="item", name="casein-mixture-barrel", amount=41},
        {type="item", name="cooling-tower-mk01", amount=18},
        {type="item", name="fish-food-01", amount=53},
        {type="item", name="grade-1-chromite", amount=255},
        {type="item", name="mechanical-parts-01", amount=19},
        {type="item", name="middle-oil-canister", amount=61},
        {type="item", name="rare-earth-powder", amount=922},
        {type="item", name="solder", amount=466},
        {type="item", name="stopper", amount=194},
      },
      results = {
        {type="item", name="vawt-turbine-mk02", amount=1},
      },
    },
    ["hawt-turbine-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=11},
        {type="item", name="anemometer-mk02", amount=1},
        {type="item", name="brake-mk02", amount=2},
        {type="item", name="carbolic-oil-barrel", amount=27},
        {type="item", name="chloroethanol-barrel", amount=2},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="cottongut", amount=1084},
        {type="item", name="crucible", amount=7},
        {type="item", name="earth-cow-sample", amount=4},
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="multiblade-turbine-mk01", amount=3},
        {type="item", name="natural-gas-derrick-mk01", amount=3},
        {type="item", name="retorter", amount=11},
        {type="item", name="vane-mk01", amount=6},
      },
      results = {
        {type="item", name="hawt-turbine-mk02", amount=1},
      },
    },
    ["steam-turbine-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="albumin", amount=140},
        {type="item", name="coal-gas-canister", amount=628},
        {type="item", name="cottongut-pup-mk02", amount=382},
        {type="item", name="electronics-mk02", amount=5},
        {type="item", name="fish-emulsion-barrel", amount=683},
        {type="item", name="intermetallics", amount=790},
        {type="item", name="leaching-station-mk01", amount=26},
        {type="item", name="light-oil-canister", amount=1417},
        {type="item", name="liquid-manure-barrel", amount=57},
        {type="item", name="medium-electric-pole", amount=132},
        {type="item", name="molten-stainless-steel-barrel", amount=51},
        {type="item", name="niobium-pipe", amount=1556},
        {type="item", name="perylene-barrel", amount=569},
        {type="item", name="purest-nitrogen-gas-barrel", amount=12647},
        {type="item", name="py-oil-powerplant-mk01", amount=3},
        {type="item", name="research-center-mk01", amount=1},
        {type="item", name="sand", amount=9298},
        {type="item", name="sb-phosphate-2-barrel", amount=3},
        {type="item", name="trichlorosilane-barrel", amount=234},
        {type="item", name="vrauks", amount=933},
        {type="item", name="vrauks-mk02", amount=125},
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
        {type="item", name="anthraquinone-barrel", amount=2},
        {type="item", name="bisphenol-a", amount=13},
        {type="item", name="clean-nexelit", amount=108},
        {type="item", name="coalbed-gas-barrel", amount=21},
        {type="item", name="condensates-canister", amount=3},
        {type="item", name="display-panel", amount=11},
        {type="item", name="fenxsb-alloy", amount=1},
        {type="item", name="fiberboard", amount=4},
        {type="item", name="fish-egg-mk02", amount=17},
        {type="item", name="grade-4-ti", amount=10},
        {type="item", name="lab", amount=5},
        {type="item", name="molten-steel-barrel", amount=3},
        {type="item", name="ore-chromium", amount=87},
        {type="item", name="small-parts-01", amount=58},
        {type="item", name="stone-furnace", amount=18},
        {type="item", name="subcritical-water-barrel", amount=62},
        {type="item", name="tall-oil-canister", amount=137},
        {type="item", name="transport-belt", amount=47},
      },
      results = {
        {type="item", name="jig-mk01", amount=1},
      },
    },
    ["nmf-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="aluminium-plate", amount=42},
        {type="item", name="duralumin", amount=25},
        {type="item", name="ethylene-barrel", amount=16},
        {type="item", name="fiberboard", amount=103},
        {type="item", name="flora-collector-mk01", amount=2},
        {type="item", name="inductor1", amount=243},
        {type="item", name="iron-plate", amount=60},
        {type="item", name="muddy-sludge-barrel", amount=22},
        {type="item", name="niobium-pipe-to-ground", amount=2},
        {type="item", name="plastic-bar", amount=90},
        {type="item", name="residual-oil-canister", amount=2},
        {type="item", name="sb-grade-02", amount=56},
        {type="item", name="stone-brick", amount=31},
        {type="item", name="tar-processing-unit", amount=5},
        {type="item", name="titanium-plate", amount=41},
        {type="item", name="transport-belt", amount=24},
      },
      results = {
        {type="item", name="nmf-mk01", amount=1},
      },
    },
    ["py-heat-exchanger-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=5423},
        {type="item", name="carbolic-oil-canister", amount=89},
        {type="item", name="kerosene-canister", amount=331},
        {type="item", name="petri-dish-bacteria", amount=178},
        {type="item", name="productivity-module", amount=1},
        {type="item", name="py-heat-exchanger", amount=1},
        {type="item", name="vanabins-barrel", amount=4},
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
        {type="item", name="creosote-barrel", amount=40},
        {type="item", name="fiberboard", amount=263},
        {type="item", name="kerogen", amount=204},
        {type="item", name="lab", amount=4},
        {type="item", name="niobium-pipe", amount=39},
        {type="item", name="pipe", amount=183},
        {type="item", name="tin-plate", amount=23},
        {type="item", name="vane-mk01", amount=15},
      },
      results = {
        {type="item", name="bio-printer-mk01", amount=1},
      },
    },
    ["botanical-nursery-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="al-pulp-02-barrel", amount=50},
        {type="item", name="botanical-nursery", amount=1},
        {type="item", name="dirty-syngas-canister", amount=28},
        {type="item", name="intermetallics", amount=22},
        {type="item", name="pcb1", amount=2},
        {type="item", name="ree-concentrate", amount=29},
        {type="item", name="rubber", amount=16},
        {type="item", name="sulfur-mine", amount=1},
        {type="item", name="tar-canister", amount=11},
        {type="item", name="vpulp3-barrel", amount=1},
      },
      results = {
        {type="item", name="botanical-nursery-mk02", amount=1},
      },
    },
    ["spore-collector-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=20},
        {type="item", name="blue-refined-concrete", amount=320},
        {type="item", name="botanical-nursery", amount=2},
        {type="item", name="crushed-quartz", amount=99},
        {type="item", name="geothermal-water-barrel", amount=128},
        {type="item", name="mixer-mk01", amount=13},
        {type="item", name="pure-trichlorosilane-barrel", amount=77},
        {type="item", name="sea-sponge-sprouts", amount=16},
      },
      results = {
        {type="item", name="spore-collector-mk02", amount=1},
      },
    },
    ["breed-fish-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.13432071043163,
      ingredients = {
        {type="fluid", name="water", amount=3797},
        {type="item", name="albumin", amount=1},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg-mk02", amount=2},
        {type="item", name="fishmeal", amount=5},
        {type="item", name="glass", amount=21},
        {type="item", name="kicalk", amount=1},
        {type="item", name="sodium-hydroxide", amount=9},
      },
      results = {
        {type="fluid", name="waste-water", amount=114},
        {type="item", name="fish", amount=34},
      },
    },
    ["breed-fish-egg-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.19839979439562,
      ingredients = {
        {type="fluid", name="hot-air", amount=126},
        {type="fluid", name="oxygen", amount=1037},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish", amount=8},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="fish-mk02", amount=1},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="fluid", name="waste-water", amount=119},
        {type="item", name="fish-egg", amount=42},
      },
    },
    ["fish-egg-mk03-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.455395305016906,
      ingredients = {
        {type="item", name="casein-pulp-01-barrel", amount=8},
        {type="item", name="fast-transport-belt", amount=1},
        {type="item", name="fish-mk02", amount=123},
        {type="item", name="multiblade-turbine-mk01", amount=4},
        {type="item", name="oxygen-barrel", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=48},
        {type="item", name="fish-egg-mk02", amount=1},
        {type="item", name="fish-egg-mk03", amount=5},
      },
    },
    ["fish-mk03"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4999706772746,
      ingredients = {
        {type="fluid", name="sulfuric-acid", amount=168},
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="cellulose", amount=63},
        {type="item", name="cocoon-mk02", amount=4},
        {type="item", name="cottongut", amount=28},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fish-food-02", amount=2},
        {type="item", name="fish-mk02", amount=16},
        {type="item", name="retrovirus", amount=29},
      },
      results = {
        {type="item", name="fish", amount=9},
        {type="item", name="fish-mk03", amount=0.00599958424819363},
      },
    },
    ["fish-mk03-breeder"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1.07785600167193,
      ingredients = {
        {type="fluid", name="fish-hydrolysate", amount=51},
        {type="fluid", name="oxygen", amount=218},
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="aluminium-plate", amount=21},
        {type="item", name="fish-egg-mk03", amount=10},
        {type="item", name="fish-food-01", amount=2},
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
      energy_required_multiplier = 0.285714285714286,
      ingredients = {
        {type="fluid", name="steam", amount=106},
        {type="item", name="coke", amount=4},
        {type="item", name="limestone", amount=1},
        {type="item", name="nexelit-plate", amount=16},
        {type="item", name="tuuphra-seeds", amount=1},
      },
      results = {
        {type="item", name="energy-drink", amount=2},
      },
    },
    ["neuroprocessor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="bio-sample", amount=1},
        {type="item", name="brain", amount=2},
        {type="item", name="crude-cermet", amount=22},
        {type="item", name="electronic-circuit", amount=36},
        {type="item", name="nexelit-matrix", amount=5},
        {type="item", name="optical-fiber", amount=9},
        {type="item", name="p2s5", amount=3},
        {type="item", name="pcb1", amount=1},
        {type="item", name="pcb2", amount=1},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="item", name="neuroprocessor", amount=3},
      },
    },
    ["nisi"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="water", amount=1108},
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
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="fluid", name="al-pulp-01", amount=9},
        {type="fluid", name="vacuum", amount=417},
        {type="item", name="aluminium-plate", amount=4},
        {type="item", name="capacitor1", amount=2},
        {type="item", name="tinned-cable", amount=8},
      },
      results = {
        {type="item", name="capacitor2", amount=2},
      },
    },
    ["microchip"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.333333333333333,
      ingredients = {
        {type="item", name="bakelite", amount=11},
        {type="item", name="bisphenol-a", amount=2},
        {type="item", name="copper-cable", amount=51},
        {type="item", name="melamine", amount=7},
        {type="item", name="tin-plate", amount=4},
      },
      results = {
        {type="item", name="microchip", amount=1},
      },
    },
    ["mosfet"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="fluid", name="hot-air", amount=450},
        {type="item", name="bakelite", amount=28},
        {type="item", name="cermet", amount=12},
        {type="item", name="cobalt-fluoride", amount=2},
        {type="item", name="copper-cable", amount=21},
        {type="item", name="green-sic", amount=1},
        {type="item", name="heavy-n", amount=3},
        {type="item", name="melamine", amount=20},
        {type="item", name="ree-concentrate", amount=12},
        {type="item", name="tin-plate", amount=2},
      },
      results = {
        {type="item", name="mosfet", amount=5},
      },
    },
    ["phenolicboard"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.6,
      ingredients = {
        {type="fluid", name="water", amount=11845},
        {type="item", name="moondrop-seeds", amount=2},
        {type="item", name="p2s5", amount=1},
        {type="item", name="phenol", amount=19},
        {type="item", name="powdered-phosphate-rock", amount=70},
        {type="item", name="resistor1", amount=21},
      },
      results = {
        {type="item", name="phenolicboard", amount=8},
      },
    },
    ["resistor2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="bakelite", amount=2},
        {type="item", name="fecr-alloy", amount=5},
        {type="item", name="phenol", amount=7},
        {type="item", name="resistor1", amount=5},
      },
      results = {
        {type="item", name="resistor2", amount=6},
      },
    },
    ["inductor2"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="ferrite", amount=10},
        {type="item", name="inductor1", amount=5},
        {type="item", name="melamine-resin", amount=5},
        {type="item", name="tin-plate", amount=34},
      },
      results = {
        {type="item", name="inductor2", amount=5},
      },
    },
    ["pcb2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="fluid", name="etching", amount=24},
        {type="item", name="copper-low-dust", amount=1},
        {type="item", name="nylon", amount=2},
        {type="item", name="phenolicboard", amount=2},
        {type="item", name="tin-plate", amount=4},
      },
      results = {
        {type="item", name="pcb2", amount=2},
      },
    },
    ["transistor"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bakelite", amount=9},
        {type="item", name="heavy-n", amount=6},
        {type="item", name="lead-plate", amount=9},
        {type="item", name="melamine", amount=14},
        {type="item", name="niobium-pipe", amount=7},
        {type="item", name="nylon-parts", amount=5},
        {type="item", name="silicon-wafer", amount=2},
      },
      results = {
        {type="item", name="transistor", amount=5},
      },
    },
    ["diode"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bakelite", amount=11},
        {type="item", name="cermet", amount=2},
        {type="item", name="heavy-n", amount=1},
        {type="item", name="nylon-parts", amount=14},
        {type="item", name="ree-concentrate", amount=4},
      },
      results = {
        {type="item", name="diode", amount=4},
      },
    },
    ["advanced-circuit"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="battery-mk01", amount=5},
        {type="item", name="capacitor1", amount=249},
        {type="item", name="cermet", amount=21},
        {type="item", name="copper-plate", amount=24},
        {type="item", name="formica", amount=20},
        {type="item", name="inductor2", amount=2},
        {type="item", name="optical-fiber", amount=2},
        {type="item", name="pcb1", amount=5},
        {type="item", name="pcb2", amount=1},
        {type="item", name="phenolicboard", amount=36},
        {type="item", name="resistor2", amount=11},
      },
      results = {
        {type="item", name="advanced-circuit", amount=4},
      },
    },
    ["uranium-mining-drill"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="gearbox-mk02", amount=1},
        {type="item", name="high-distillate-canister", amount=112},
        {type="item", name="hydrocyclone-mk01", amount=1},
        {type="item", name="industrial-solvent-barrel", amount=166},
        {type="item", name="kicalk", amount=369},
        {type="item", name="moondrop-codex", amount=5},
        {type="item", name="moondrop-greenhouse-mk01", amount=3},
        {type="item", name="niobium-mine", amount=3},
        {type="item", name="niobium-oxide", amount=389},
        {type="item", name="oil-boiler-mk01", amount=13},
        {type="item", name="steam-turbine-mk01", amount=2},
        {type="item", name="yotoi-aloe-orchard-mk01", amount=2},
      },
      results = {
        {type="item", name="uranium-mining-drill", amount=2},
      },
    },
    ["aerial-base"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=3},
        {type="item", name="bio-printer-mk01", amount=1},
        {type="item", name="brake-mk02", amount=1},
        {type="item", name="casein-mixture-barrel", amount=20},
        {type="item", name="cooling-tower-mk01", amount=3},
        {type="item", name="electronics-mk02", amount=1},
        {type="item", name="eva", amount=12},
        {type="item", name="fish-food-01", amount=65},
        {type="item", name="lab-instrument", amount=11},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="middle-oil-canister", amount=29},
        {type="item", name="moondrop-mk02", amount=170},
        {type="item", name="pump", amount=3},
        {type="item", name="rare-earth-powder", amount=445},
        {type="item", name="sap-tree-mk03", amount=10},
        {type="item", name="self-assembly-monolayer", amount=32},
        {type="item", name="solder", amount=575},
        {type="item", name="stopper", amount=239},
        {type="item", name="tower-mk01", amount=2},
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
        {type="fluid", name="chlorine", amount=255},
        {type="item", name="caravan", amount=5},
        {type="item", name="casein-pulp-02-barrel", amount=1033},
        {type="item", name="chromite-rejects", amount=569},
        {type="item", name="electronic-circuit", amount=128},
        {type="item", name="ethylene-glycol-barrel", amount=148},
        {type="item", name="ez-ranch-mk01", amount=2},
        {type="item", name="fetal-serum-barrel", amount=11},
        {type="item", name="gearbox-mk02", amount=2},
        {type="item", name="organic-acid-anhydride-barrel", amount=37},
        {type="item", name="purified-syngas-barrel", amount=41},
        {type="item", name="shaft-mk01", amount=3},
        {type="item", name="syrup-01-barrel", amount=8},
        {type="item", name="tower-mk02", amount=2},
        {type="item", name="xyhiphoe-cub-mk02", amount=4},
      },
      results = {
        {type="item", name="aerial-blimp-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
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
        {type="item", name="fiberboard", amount=310},
        {type="item", name="flora-collector-mk01", amount=4},
        {type="item", name="hydrocyclone-mk01", amount=3},
        {type="item", name="iron-plate", amount=542},
        {type="item", name="plastic-bar", amount=261},
        {type="item", name="py-logo-15tiles", amount=2},
      },
      results = {
        {type="item", name="cadaveric-arum-mk01", amount=3},
      },
    },
    ["grods-swamp-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=52},
        {type="item", name="carbon-dioxide-barrel", amount=19},
        {type="item", name="chromium", amount=104},
        {type="item", name="electronic-circuit", amount=8},
        {type="item", name="iron-stick", amount=102},
        {type="item", name="korlex-codex", amount=1},
        {type="item", name="korlex-food-01", amount=16},
        {type="item", name="nexelit-plate", amount=288},
        {type="item", name="niobium-pipe", amount=284},
        {type="item", name="ore-quartz", amount=231},
        {type="item", name="petri-dish", amount=5},
        {type="item", name="py-aluminium", amount=17},
        {type="item", name="rotor", amount=3},
        {type="item", name="stator", amount=1},
        {type="item", name="stone-wool", amount=41},
      },
      results = {
        {type="item", name="grods-swamp-mk01", amount=2},
      },
    },
    ["guar-gum-plantation"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=3},
        {type="item", name="brain", amount=1},
        {type="item", name="concrete", amount=317},
        {type="item", name="fenxsb-alloy", amount=39},
        {type="item", name="fiberboard", amount=13},
        {type="item", name="flora-collector-mk01", amount=1},
        {type="item", name="kicalk", amount=26},
        {type="item", name="manure-bacteria-barrel", amount=3},
        {type="item", name="medium-distillate-canister", amount=9},
        {type="item", name="pipe-to-ground", amount=3},
        {type="item", name="residual-oil-canister", amount=17},
        {type="item", name="sb-grade-02", amount=420},
        {type="item", name="steel-plate", amount=17},
      },
      results = {
        {type="item", name="guar-gum-plantation", amount=1},
      },
    },
    ["navens-culture-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="aluminium-plate", amount=210},
        {type="item", name="carbon-dioxide-barrel", amount=39},
        {type="item", name="engine-unit", amount=120},
        {type="item", name="gasoline-barrel", amount=11},
        {type="item", name="lead-plate", amount=92},
        {type="item", name="mechanical-parts-01", amount=3},
        {type="item", name="tailings-barrel", amount=1738},
        {type="item", name="washer", amount=3},
      },
      results = {
        {type="item", name="navens-culture-mk01", amount=2},
      },
    },
    ["ralesia-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="coal-gas-canister", amount=107},
        {type="item", name="cocoon-mk03", amount=3},
        {type="item", name="compressor-mk01", amount=10},
        {type="item", name="empty-barrel-milk", amount=359},
        {type="item", name="fawogae-mk02", amount=13},
        {type="item", name="fish-food-01", amount=21},
        {type="item", name="korlex-codex-mk02", amount=9},
        {type="item", name="low-grade-rejects", amount=107},
        {type="item", name="molten-aluminium-barrel", amount=5},
        {type="item", name="ore-quartz", amount=786},
        {type="item", name="personal-roboport-mk2-equipment", amount=1},
        {type="item", name="prandium-lab-mk01", amount=1},
        {type="item", name="seeds-extract-01", amount=104},
        {type="item", name="shaft-mk02", amount=3},
        {type="item", name="soda-ash-barrel", amount=108},
        {type="item", name="ti-pulp-03-barrel", amount=8},
        {type="item", name="vrauks", amount=109},
      },
      results = {
        {type="item", name="ralesia-plantation-mk02", amount=2},
      },
    },
    ["rennea-plantation-mk01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="bisphenol-a", amount=5},
        {type="item", name="clean-nexelit", amount=14},
        {type="item", name="coke", amount=1017},
        {type="item", name="concrete", amount=459},
        {type="item", name="creosote-barrel", amount=9},
        {type="item", name="fiberboard", amount=7},
        {type="item", name="gasifier", amount=2},
        {type="item", name="lab", amount=1},
        {type="item", name="lead-plate", amount=55},
        {type="item", name="niobium-pipe", amount=9},
        {type="item", name="pipe", amount=16},
        {type="item", name="pure-sand", amount=360},
        {type="item", name="py-steel", amount=14},
        {type="item", name="small-parts-01", amount=55},
        {type="item", name="tall-oil-canister", amount=6},
        {type="item", name="titanium-plate", amount=336},
        {type="item", name="zipir-codex", amount=10},
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
        {type="item", name="aluminium-plate", amount=364},
        {type="item", name="assembling-machine-1", amount=2},
        {type="item", name="bio-oil-canister", amount=56},
        {type="item", name="btx-barrel", amount=32},
        {type="item", name="gearbox-mk01", amount=1},
        {type="item", name="grenade", amount=11},
        {type="item", name="inductor1", amount=8},
        {type="item", name="iron-chest", amount=5},
        {type="item", name="nexelit-plate", amount=92},
        {type="item", name="sic", amount=8},
        {type="item", name="stone-brick", amount=426},
        {type="item", name="titanium-plate", amount=221},
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
        {type="item", name="auog-pup", amount=26},
        {type="item", name="bitumen-canister", amount=27},
        {type="item", name="blood-barrel", amount=135},
        {type="item", name="compressor-mk01", amount=9},
        {type="item", name="electronic-circuit", amount=32},
        {type="item", name="fish-food-01", amount=19},
        {type="item", name="hazard-concrete", amount=185},
        {type="item", name="korlex-codex-mk02", amount=8},
        {type="item", name="low-grade-rejects", amount=97},
        {type="item", name="molten-lead-barrel", amount=4},
        {type="item", name="nylon", amount=29},
        {type="item", name="ore-quartz", amount=1825},
        {type="item", name="prandium-lab-mk01", amount=2},
        {type="item", name="soda-ash-barrel", amount=788},
        {type="item", name="ti-pulp-03-barrel", amount=7},
        {type="item", name="xyhiphoe-cub-mk02", amount=1},
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
        {type="item", name="concrete", amount=109},
        {type="item", name="condensed-distillate-canister", amount=16},
        {type="item", name="copper-low-dust", amount=166},
        {type="item", name="depolymerized-organics-barrel", amount=42},
        {type="item", name="electronics-mk02", amount=2},
        {type="item", name="fawogae-mk02", amount=185},
        {type="item", name="fish-emulsion-barrel", amount=3},
        {type="item", name="niobium-oxide", amount=200},
        {type="item", name="niobium-pipe", amount=118},
        {type="item", name="outpost", amount=2},
        {type="item", name="sb-hpo-pu", amount=40},
        {type="item", name="steam-engine", amount=5},
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
        {type="item", name="auog-paddock-mk01", amount=5},
        {type="item", name="cage", amount=6},
        {type="item", name="creosote-barrel", amount=68},
        {type="item", name="gasoline-canister", amount=145},
        {type="item", name="grade-4-nickel", amount=40},
        {type="item", name="lead-acetate", amount=11},
        {type="item", name="molten-aluminium-barrel", amount=112},
        {type="item", name="organic-acid-anhydride-barrel", amount=30},
        {type="item", name="phosphorous-acid-barrel", amount=22},
        {type="item", name="py-roboport-mk01", amount=1},
        {type="item", name="trits-reef-mk01", amount=1},
        {type="item", name="vacuum-barrel", amount=59},
        {type="item", name="wood-fence", amount=24},
      },
      results = {
        {type="item", name="grods-swamp-mk02", amount=1},
      },
    },
    ["guar-gum-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-hive-mk01", amount=1},
        {type="item", name="brain", amount=70},
        {type="item", name="casein-pulp-01-barrel", amount=169},
        {type="item", name="crushed-quartz", amount=235},
        {type="item", name="fast-transport-belt", amount=42},
        {type="item", name="korlex-pup", amount=81},
        {type="item", name="nitrobenzene-barrel", amount=72},
        {type="item", name="py-check-valve", amount=137},
        {type="item", name="stripped-distillate-barrel", amount=38},
        {type="item", name="xyhiphoe-mk02", amount=7},
        {type="item", name="zogna-bacteria-barrel", amount=40},
      },
      results = {
        {type="item", name="guar-gum-plantation-mk02", amount=2},
      },
    },
    ["kicalk-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=53},
        {type="item", name="car", amount=2},
        {type="item", name="coarse-coal", amount=5737},
        {type="item", name="electric-engine-unit", amount=2},
        {type="item", name="fish-emulsion-barrel", amount=17},
        {type="item", name="industrial-solvent-barrel", amount=10},
        {type="item", name="molten-steel-barrel", amount=26},
      },
      results = {
        {type="item", name="kicalk-plantation-mk02", amount=1},
      },
    },
    ["moondrop-greenhouse-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cermet", amount=21},
        {type="item", name="depolymerized-organics-barrel", amount=2},
        {type="item", name="inductor2", amount=2},
        {type="item", name="moondrop-codex", amount=4},
        {type="item", name="moondrop-greenhouse-mk01", amount=2},
        {type="item", name="niobium-mine", amount=1},
        {type="item", name="oil-boiler-mk01", amount=10},
        {type="item", name="pcb1", amount=5},
        {type="item", name="perylene-barrel", amount=2},
        {type="item", name="phenolicboard", amount=5},
      },
      results = {
        {type="item", name="moondrop-greenhouse-mk02", amount=2},
      },
    },
    ["moss-farm-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arqad", amount=1},
        {type="item", name="bitumen-canister", amount=118},
        {type="item", name="blood-barrel", amount=14},
        {type="item", name="coal-gas-canister", amount=10},
        {type="item", name="cottongut-mk01", amount=5},
        {type="item", name="electric-engine-unit", amount=2},
        {type="item", name="electronic-circuit", amount=139},
        {type="item", name="empty-barrel-milk", amount=32},
        {type="item", name="iron-chest", amount=62},
        {type="item", name="molten-lead-barrel", amount=17},
        {type="item", name="mukmoux-calf", amount=64},
        {type="item", name="offshore-pump", amount=28},
        {type="item", name="petri-dish", amount=25},
        {type="item", name="seaweed-crop-mk01", amount=1},
        {type="item", name="seeds-extract-01", amount=9},
        {type="item", name="self-assembly-monolayer", amount=4},
        {type="item", name="titanium-plate", amount=29},
        {type="item", name="u-pulp-02-barrel", amount=12},
      },
      results = {
        {type="item", name="moss-farm-mk02", amount=1},
      },
    },
    ["navens-culture-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="cu-biomass", amount=94},
        {type="item", name="data-array", amount=9},
        {type="item", name="earth-sea-sponge-sample", amount=2},
        {type="item", name="fish-egg-mk02", amount=142},
        {type="item", name="industrial-solvent-barrel", amount=13},
        {type="item", name="kicalk", amount=92},
        {type="item", name="molten-lead-barrel", amount=445},
        {type="item", name="moondrop-mk02", amount=44},
        {type="item", name="moss-farm-mk02", amount=1},
        {type="item", name="rotor", amount=18},
        {type="item", name="steam-engine", amount=24},
      },
      results = {
        {type="item", name="navens-culture-mk02", amount=2},
      },
    },
    ["rennea-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-paddock-mk01", amount=3},
        {type="item", name="bio-oil-canister", amount=169},
        {type="item", name="caged-ulric", amount=17},
        {type="item", name="casting-unit-mk01", amount=1},
        {type="item", name="cumene-barrel", amount=248},
        {type="item", name="korlex-codex-mk02", amount=36},
        {type="item", name="natural-gas-barrel", amount=68},
        {type="item", name="petroleum-gas-canister", amount=60},
        {type="item", name="sb-grade-04", amount=363},
        {type="item", name="seaweed-mk02", amount=35},
        {type="item", name="sulfuric-acid-barrel", amount=137},
      },
      results = {
        {type="item", name="rennea-plantation-mk02", amount=1},
      },
    },
    ["sap-extractor-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=40},
        {type="item", name="cumene-barrel", amount=6},
        {type="item", name="ferrite", amount=14},
        {type="item", name="fetal-serum-barrel", amount=1},
        {type="item", name="grade-2-u", amount=61},
        {type="item", name="iron-gear-wheel", amount=35},
        {type="item", name="lab", amount=3},
        {type="item", name="molten-aluminium-barrel", amount=8},
        {type="item", name="neuroprocessor", amount=18},
        {type="item", name="organic-acid-anhydride-barrel", amount=1},
        {type="item", name="pcb1", amount=102},
        {type="item", name="pitch-barrel", amount=27},
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
        {type="item", name="auog-paddock-mk01", amount=1},
        {type="item", name="bio-oil-canister", amount=1338},
        {type="item", name="btx-canister", amount=352},
        {type="item", name="cottongut-food-01", amount=45},
        {type="item", name="ferrite", amount=5},
        {type="item", name="grade-2-u", amount=175},
        {type="item", name="intermetallics", amount=7},
        {type="item", name="iron-gear-wheel", amount=99},
        {type="item", name="kerosene-barrel", amount=4},
        {type="item", name="lab", amount=3},
        {type="item", name="pcb1", amount=36},
        {type="item", name="py-steel", amount=20},
        {type="item", name="sb-grade-01", amount=221},
        {type="item", name="shaft-mk02", amount=4},
        {type="item", name="storage-tank", amount=1},
      },
      results = {
        {type="item", name="seaweed-crop-mk02", amount=1},
      },
    },
    ["tuuphra-plantation-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="anthracene-oil-canister", amount=65},
        {type="item", name="condensed-distillate-canister", amount=90},
        {type="item", name="copper-low-dust", amount=909},
        {type="item", name="molten-solder-barrel", amount=9},
        {type="item", name="niobium-pipe", amount=206},
        {type="item", name="sb-hpo-pu", amount=218},
        {type="item", name="sponge-culture-mk01", amount=1},
        {type="item", name="steam-engine", amount=8},
      },
      results = {
        {type="item", name="tuuphra-plantation-mk02", amount=1},
      },
    },
    ["bhoddos-culture-mk02"] = {
      mode = "repaired-to-input",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="advanced-circuit", amount=15},
        {type="item", name="cottongut", amount=549},
        {type="item", name="latex-slab", amount=43},
        {type="item", name="naphtha-barrel", amount=11},
        {type="item", name="nuclear-reactor", amount=1},
        {type="item", name="pressured-water-barrel", amount=22},
        {type="item", name="ptcda", amount=9},
        {type="item", name="steam-engine", amount=4},
        {type="item", name="tin-ore-rejects", amount=12},
        {type="item", name="yaedols-mk02", amount=1},
      },
      results = {
        {type="item", name="bhoddos-culture-mk02", amount=1},
      },
    },
    ["fawogae-plantation-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="acid-refined-concrete", amount=56},
        {type="item", name="auog-paddock-mk01", amount=1},
        {type="item", name="coarse-coal", amount=135},
        {type="item", name="cumene-barrel", amount=44},
        {type="item", name="electronics-mk02", amount=3},
        {type="item", name="sulfuric-acid-barrel", amount=25},
      },
      results = {
        {type="item", name="fawogae-plantation-mk02", amount=1},
      },
    },
    ["fwf-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad", amount=2},
        {type="item", name="bitumen-canister", amount=109},
        {type="item", name="blood-barrel", amount=34},
        {type="item", name="electronic-circuit", amount=1026},
        {type="item", name="fluorine-gas-barrel", amount=3},
        {type="item", name="molten-aluminium-barrel", amount=23},
        {type="item", name="molten-lead-barrel", amount=16},
        {type="item", name="offshore-pump", amount=65},
        {type="item", name="rare-earth-mine", amount=1},
      },
      results = {
        {type="item", name="fwf-mk02", amount=2},
      },
    },
    ["bulk-inserter"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="engine-unit", amount=9},
        {type="item", name="gearbox-mk01", amount=2},
        {type="item", name="long-handed-inserter", amount=10},
        {type="item", name="pipe", amount=66},
        {type="item", name="vitreloy", amount=5},
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
        {type="item", name="caged-auog", amount=8},
        {type="item", name="korlex-codex-mk02", amount=18},
        {type="item", name="long-handed-inserter", amount=49},
        {type="item", name="sea-sponge", amount=10},
      },
      results = {
        {type="item", name="assembling-machine-3", amount=1},
      },
    },
    ["chemical-science-pack"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.58333333333333,
      ingredients = {
        {type="item", name="advanced-circuit", amount=2},
        {type="item", name="engine-unit", amount=2},
        {type="item", name="mox-fuel-cell", amount=2},
        {type="item", name="optical-fiber", amount=21},
        {type="item", name="rubber", amount=9},
        {type="item", name="self-assembly-monolayer", amount=4},
        {type="item", name="shaft-mk02", amount=5},
        {type="item", name="small-parts-01", amount=12},
        {type="item", name="transistor", amount=2},
      },
      results = {
        {type="item", name="chemical-science-pack", amount=19},
      },
    },
    ["electric-furnace"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="tailings-barrel", amount=1566},
      },
      results = {
        {type="item", name="electric-furnace", amount=2},
      },
    },
    ["megadar"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="pipe", amount=146},
        {type="item", name="small-parts-02", amount=451},
        {type="item", name="storage-tank", amount=1},
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
        {type="item", name="advanced-circuit", amount=11},
        {type="item", name="albumin", amount=726},
        {type="item", name="anemometer-mk02", amount=2},
        {type="item", name="bulk-inserter", amount=3},
        {type="item", name="carbolic-oil-canister", amount=792},
        {type="item", name="eg-si", amount=613},
        {type="item", name="empty-gas-canister", amount=793},
        {type="item", name="fatty-acids-canister", amount=81},
        {type="item", name="fish-egg-mk03", amount=9},
        {type="item", name="kerosene-canister", amount=278},
        {type="item", name="navens-codex", amount=1},
        {type="item", name="py-biomass-powerplant-mk01", amount=1},
        {type="item", name="research-center-mk01", amount=5},
        {type="item", name="rhe", amount=6},
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
        {type="item", name="capacitor2", amount=692},
        {type="item", name="car", amount=1},
        {type="item", name="coarse-coal", amount=3978},
        {type="item", name="electric-engine-unit", amount=1},
        {type="item", name="fish-emulsion-barrel", amount=11},
        {type="item", name="industrial-solvent-barrel", amount=7},
        {type="item", name="iron-plate", amount=441},
        {type="item", name="korlex-codex-mk02", amount=1},
        {type="item", name="liquid-nitrogen-barrel", amount=19},
        {type="item", name="mechanical-parts-01", amount=1},
        {type="item", name="molten-steel-barrel", amount=18},
        {type="item", name="natural-gas-barrel", amount=3},
        {type="item", name="stainless-steel", amount=10},
        {type="item", name="thickener-mk01", amount=1},
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
        {type="item", name="auog-pup", amount=197},
        {type="item", name="blood-barrel", amount=988},
        {type="item", name="blue-refined-concrete", amount=176},
        {type="item", name="botanical-nursery", amount=3},
        {type="item", name="condensates-canister", amount=201},
        {type="item", name="crushed-quartz", amount=435},
        {type="item", name="empty-honeycomb", amount=147},
        {type="item", name="fawogae-mk02", amount=10},
        {type="item", name="geothermal-water-barrel", amount=221},
        {type="item", name="hazard-concrete", amount=1384},
        {type="item", name="mixer-mk01", amount=7},
        {type="item", name="nylon", amount=1755},
        {type="item", name="pure-trichlorosilane-barrel", amount=132},
        {type="item", name="sea-sponge-sprouts", amount=69},
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
        {type="item", name="auog-paddock-mk01", amount=2},
        {type="item", name="auog-pup-mk02", amount=2},
        {type="item", name="cage", amount=19},
        {type="item", name="creosote-barrel", amount=213},
        {type="item", name="gasoline-canister", amount=451},
        {type="item", name="korlex-mk02", amount=2},
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
        {type="item", name="kicalk-mk02", amount=2},
        {type="item", name="kicalk-seeds-mk02", amount=4},
        {type="item", name="small-lamp", amount=3},
      },
      results = {
        {type="item", name="kicalk-seeds-mk02", amount=7},
      },
    },
    ["yotoi-fiber"] = {
      mode = "kept-transformed",
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
        {type="item", name="kicalk", amount=3},
        {type="item", name="log", amount=1},
        {type="item", name="yotoi", amount=5},
      },
      results = {
        {type="item", name="bedding", amount=4},
      },
    },
    ["cu-biomass-extraction"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.551452611524068,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="nacl-biomass", amount=15},
      },
      results = {
        {type="item", name="biomass", amount=3},
        {type="item", name="copper-ore", amount=11},
      },
    },
    ["fe-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.951452611524068,
      ingredients = {
        {type="item", name="fe-biomass", amount=10},
      },
      results = {
        {type="item", name="biomass", amount=5},
        {type="item", name="iron-ore", amount=19},
      },
    },
    ["fungal-substrate-03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.9,
      ingredients = {
        {type="fluid", name="tar", amount=655},
        {type="item", name="fine-powdered-biomass", amount=6},
        {type="item", name="fungal-substrate-02", amount=1},
        {type="item", name="gravel", amount=7},
        {type="item", name="petri-dish", amount=1},
        {type="item", name="powdered-biomass", amount=86},
        {type="item", name="skin", amount=3},
        {type="item", name="tuuphra-seeds", amount=4},
      },
      results = {
        {type="item", name="fungal-substrate-03", amount=9},
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
      energy_required_multiplier = 1.26,
      ingredients = {
        {type="fluid", name="pressured-air", amount=16953},
        {type="fluid", name="pressured-water", amount=2025},
        {type="item", name="dried-meat", amount=14},
        {type="item", name="powdered-biomass", amount=58},
        {type="item", name="retrovirus", amount=1},
      },
      results = {
        {type="fluid", name="carbon-dioxide", amount=63},
        {type="fluid", name="psc", amount=63},
      },
    },
    ["s-biomass-extraction"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.4,
      ingredients = {
        {type="item", name="s-biomass", amount=4},
      },
      results = {
        {type="item", name="biomass", amount=2},
        {type="item", name="sulfur", amount=4},
      },
    },
    ["sn-biomass-extraction"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.735600317127535,
      ingredients = {
        {type="item", name="nacl-biomass", amount=6},
      },
      results = {
        {type="item", name="biomass", amount=4},
        {type="item", name="ore-tin", amount=11},
      },
    },
    ["sodium-carbonate-1"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 3.99820210614576,
      ingredients = {
        {type="item", name="clay", amount=11},
        {type="item", name="coke", amount=19},
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
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="item", name="rennea", amount=8},
        {type="item", name="rennea-seeds", amount=13},
      },
      results = {
        {type="item", name="sporopollenin", amount=9},
      },
    },
    ["vinyl-acetate"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.960290862938007,
      ingredients = {
        {type="fluid", name="processed-fatty-acids", amount=97},
        {type="item", name="chromite-sand", amount=10},
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
      energy_required_multiplier = 1.625,
      ingredients = {
        {type="fluid", name="steam", amount=109},
        {type="item", name="cellulose", amount=3},
        {type="item", name="fine-powdered-biomass", amount=87},
        {type="item", name="gunpowder", amount=1},
      },
      results = {
        {type="item", name="lignin", amount=13},
      },
    },
    ["seeds-extract-01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="fluid", name="tar", amount=569},
        {type="item", name="cocoon", amount=9},
        {type="item", name="dried-grods", amount=5},
        {type="item", name="rennea", amount=5},
        {type="item", name="rennea-seeds", amount=11},
        {type="item", name="seaweed", amount=13},
      },
      results = {
        {type="item", name="seeds-extract-01", amount=7},
      },
    },
    ["yotoi-cellulose"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="lubricant", amount=135},
        {type="item", name="ash", amount=7},
        {type="item", name="salt", amount=9},
        {type="item", name="yotoi", amount=4},
      },
      results = {
        {type="item", name="cellulose", amount=5},
      },
    },
    ["ulric-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.31866838776927,
      ingredients = {
        {type="item", name="bedding", amount=3},
        {type="item", name="caged-ulric", amount=2},
        {type="item", name="manure", amount=2},
        {type="item", name="ralesia", amount=21},
        {type="item", name="refined-natural-gas-barrel", amount=6},
        {type="item", name="salt", amount=10},
        {type="item", name="ulric-food-01", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=11},
        {type="item", name="ulric", amount=14},
      },
    },
    ["ulric-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.636524401728838,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="cottongut-food-01", amount=5},
        {type="item", name="fawogae", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=9},
        {type="item", name="ulric-cub", amount=4},
      },
    },
    ["ulric-manure-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.29570210953738,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="fawogae", amount=1},
        {type="item", name="ralesia", amount=13},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="salt", amount=5},
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="manure", amount=8},
      },
    },
    ["ulric-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.69724796477601,
      ingredients = {
        {type="item", name="auog-food-02", amount=4},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="fertilizer", amount=3},
        {type="item", name="fishmeal", amount=2},
        {type="item", name="grade-1-tin", amount=1},
        {type="item", name="kicalk", amount=1},
        {type="item", name="olefin-barrel", amount=5},
        {type="item", name="ralesia", amount=1},
        {type="item", name="salt", amount=7},
        {type="item", name="ulric", amount=2},
        {type="item", name="vrauks-food-01", amount=1},
        {type="item", name="water-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=12},
        {type="item", name="ulric", amount=1},
        {type="item", name="ulric-mk02", amount=0.00828841957446482},
      },
    },
    ["ulric-mk02-dna-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="energy-drink", amount=1},
        {type="item", name="latex-slab", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="ulric", amount=86},
        {type="item", name="ulric-food-01", amount=3},
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
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
      results = {
        {type="item", name="ulric-mk02-dna-sample", amount=6},
        {type="item", name="used-ulric-mk02", amount=1},
      },
    },
    ["ulric-mk02-breeding"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="energy-drink", amount=4},
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="bof-mk01", amount=4},
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
        {type="item", name="barrel-milk", amount=2},
        {type="item", name="lignin", amount=28},
        {type="item", name="ralesia", amount=13},
        {type="item", name="ulric-cub-mk02", amount=4},
      },
      results = {
        {type="item", name="empty-barrel-milk", amount=2},
        {type="item", name="ulric-mk02", amount=1},
      },
    },
    ["compile-korlex-codex"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="duralumin", amount=32},
        {type="item", name="engine-unit", amount=4},
        {type="item", name="long-handed-inserter", amount=1},
        {type="item", name="vitreloy", amount=1},
        {type="item", name="zipir-codex", amount=1},
      },
      results = {
        {type="item", name="korlex-codex-mk02", amount=1},
      },
    },
    ["korlex-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.75,
      ingredients = {
        {type="item", name="bedding", amount=1},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="caged-korlex", amount=2},
        {type="item", name="empty-barrel-milk", amount=14},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="phenolicboard", amount=1},
        {type="item", name="tuuphra-seeds", amount=8},
      },
      results = {
        {type="item", name="barrel", amount=6},
        {type="item", name="korlex", amount=3},
      },
    },
    ["korlex-milk-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.65631066963562,
      ingredients = {
        {type="fluid", name="tar", amount=2374},
        {type="item", name="bhoddos-spore", amount=7},
        {type="item", name="cobalt-extract", amount=1},
        {type="item", name="fungal-substrate-02", amount=3},
        {type="item", name="gravel", amount=10},
        {type="item", name="kicalk", amount=2},
        {type="item", name="korlex-food-01", amount=2},
        {type="item", name="olefin-barrel", amount=9},
        {type="item", name="petri-dish", amount=4},
        {type="item", name="powdered-biomass", amount=39},
        {type="item", name="seaweed", amount=63},
        {type="item", name="tuuphra", amount=2},
        {type="item", name="tuuphra-seeds", amount=48},
      },
      results = {
        {type="item", name="barrel", amount=26},
        {type="item", name="barrel-milk", amount=16},
      },
    },
    ["korlex-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.33735700914629,
      ingredients = {
        {type="fluid", name="hydrogen", amount=518},
        {type="fluid", name="water-saline", amount=3574},
        {type="item", name="albumin", amount=1},
        {type="item", name="fish-food-01", amount=1},
        {type="item", name="korlex", amount=2},
        {type="item", name="lignin", amount=24},
        {type="item", name="nylon-parts", amount=20},
        {type="item", name="raw-gas-canister", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="rennea-seeds", amount=18},
        {type="item", name="silicon", amount=18},
      },
      results = {
        {type="item", name="barrel", amount=8},
        {type="item", name="korlex", amount=1},
        {type="item", name="korlex-mk02", amount=0.00669812360114494},
      },
    },
    ["korlex-pup-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66446933452926,
      ingredients = {
        {type="item", name="bedding", amount=3},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="caged-korlex", amount=2},
        {type="item", name="carbon-sulfide-barrel", amount=1},
        {type="item", name="empty-barrel-milk", amount=5},
        {type="item", name="fine-powdered-biomass", amount=33},
        {type="item", name="fish", amount=21},
        {type="item", name="fish-hydrolysate-barrel", amount=12},
        {type="item", name="grade-2-nickel", amount=1},
        {type="item", name="naphtha-barrel", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=8},
        {type="item", name="tuuphra", amount=3},
        {type="item", name="tuuphra-seeds", amount=23},
      },
      results = {
        {type="item", name="barrel", amount=41},
        {type="item", name="korlex-pup", amount=10},
      },
    },
    ["korlex-mk02r"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="gasoline", amount=930},
        {type="item", name="chitin", amount=106},
        {type="item", name="earth-generic-sample", amount=3},
        {type="item", name="kevlar", amount=5},
        {type="item", name="korlex-mk02", amount=4},
        {type="item", name="utility-box-mk01", amount=2},
      },
      results = {
        {type="item", name="korlex-mk02", amount=5},
      },
    },
    ["sap-seeds-mk03-gen"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="sap-tree", amount=9},
        {type="item", name="saps-mk03", amount=3},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=1},
      },
    },
    ["sap-seeds-mk03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="bio-oil-canister", amount=3},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="seaweed", amount=15},
      },
      results = {
        {type="item", name="sap-seeds-mk03", amount=5},
      },
    },
    ["sap-tree-mk03-gen"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=1408},
        {type="fluid", name="muddy-sludge", amount=168},
        {type="item", name="brain", amount=1},
        {type="item", name="fertilizer", amount=1},
        {type="item", name="mukmoux-fat", amount=9},
        {type="item", name="niobium-concentrate", amount=8},
      },
      results = {
        {type="item", name="sap-tree-mk03", amount=1},
      },
    },
    ["xyhiphoe-2"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.64036443411828,
      ingredients = {
        {type="fluid", name="steam", amount=2722},
        {type="fluid", name="tailings", amount=1332},
        {type="item", name="albumin", amount=10},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="native-flora", amount=22},
        {type="item", name="silicon", amount=10},
        {type="item", name="xyhiphoe-cub", amount=3},
      },
      results = {
        {type="fluid", name="waste-water", amount=311},
        {type="item", name="xyhiphoe", amount=2},
      },
    },
    ["xyhiphoe-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.723383207146583,
      ingredients = {
        {type="fluid", name="water-saline", amount=800},
        {type="item", name="fish-food-01", amount=2},
        {type="item", name="meat", amount=1},
        {type="item", name="nylon-parts", amount=36},
        {type="item", name="raw-gas-canister", amount=1},
        {type="item", name="silicon", amount=10},
      },
      results = {
        {type="fluid", name="waste-water", amount=479},
        {type="item", name="xyhiphoe-cub", amount=5},
      },
    },
    ["xyhiphoe-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.342321059370173,
      ingredients = {
        {type="fluid", name="oxygen", amount=163},
        {type="fluid", name="water-saline", amount=189},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="fishmeal", amount=5},
        {type="item", name="lignin", amount=1},
        {type="item", name="nylon-parts", amount=2},
        {type="item", name="xyhiphoe", amount=1},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=0.00171160529685087},
      },
    },
    ["xyhiphoe-pool-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="battery-mk00", amount=119},
        {type="item", name="data-array", amount=5},
        {type="item", name="duralumin", amount=62},
        {type="item", name="fish-egg-mk02", amount=10},
        {type="item", name="fish-oil-barrel", amount=33},
        {type="item", name="korlex-codex-mk02", amount=19},
        {type="item", name="light-oil-canister", amount=559},
        {type="item", name="molten-lead-barrel", amount=254},
        {type="item", name="oil-boiler-mk01", amount=1},
        {type="item", name="ore-quartz", amount=575},
        {type="item", name="rotor", amount=1},
        {type="item", name="sb-grade-04", amount=971},
        {type="item", name="sb-pulp-01-barrel", amount=68},
        {type="item", name="scrude-canister", amount=37},
        {type="item", name="solder", amount=47},
        {type="item", name="stopper", amount=20},
      },
      results = {
        {type="item", name="xyhiphoe-pool-mk02", amount=2},
      },
    },
    ["xyhiphoe-cub-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.442329042758564,
      ingredients = {
        {type="item", name="crude-oil-barrel", amount=7},
        {type="item", name="fish-egg-mk02", amount=2},
        {type="item", name="lime", amount=26},
        {type="item", name="saps", amount=53},
        {type="item", name="xyhiphoe", amount=8},
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
        {type="item", name="blood-meal", amount=92},
      },
      results = {
        {type="item", name="xyhiphoe", amount=1},
        {type="item", name="xyhiphoe-mk02", amount=1},
      },
    },
    ["bhoddos-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="bhoddos", amount=5},
        {type="item", name="fungal-substrate-02", amount=2},
        {type="item", name="residual-mixture-canister", amount=1},
      },
      results = {
        {type="item", name="bhoddos", amount=15},
      },
    },
    ["bhoddos-sample"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="alien-sample01", amount=5},
        {type="item", name="arqad-codex", amount=1},
        {type="item", name="cladding", amount=2},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="dna-polymerase", amount=12},
        {type="item", name="earth-sea-sponge-sample", amount=1},
      },
      results = {
        {type="item", name="bhoddos", amount=1},
      },
    },
    ["fish-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="item", name="albumin", amount=4},
        {type="item", name="chitin", amount=1},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="gunpowder", amount=1},
        {type="item", name="meat", amount=6},
        {type="item", name="melamine", amount=12},
        {type="item", name="powdered-biomass", amount=24},
        {type="item", name="purest-nitrogen-gas-barrel", amount=1},
        {type="item", name="raw-fiber", amount=4},
        {type="item", name="sodium-hydroxide", amount=13},
        {type="item", name="urea", amount=4},
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
      energy_required_multiplier = 0.571428571428571,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=2},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="fungal-substrate-03", amount=1},
        {type="item", name="py-quartz", amount=2},
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
        {type="fluid", name="acetic-acid", amount=5777},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="earth-mouse-sample", amount=1},
        {type="item", name="moss-gen", amount=185},
        {type="item", name="navens-codex", amount=1},
        {type="item", name="retrovirus", amount=496},
        {type="item", name="solder", amount=817},
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
        {type="item", name="aluminium-plate", amount=14},
        {type="item", name="electronic-circuit", amount=11},
        {type="item", name="sodium-hydroxide", amount=6},
      },
      results = {
        {type="item", name="mukmoux-codex", amount=1},
      },
    },
    ["mukmoux-food-01"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="water-saline", amount=1115},
        {type="item", name="boiler", amount=1},
        {type="item", name="grade-1-lead", amount=1},
        {type="item", name="molybdenite-dust", amount=48},
        {type="item", name="silicon", amount=14},
        {type="item", name="sodium-hydroxide", amount=4},
        {type="item", name="soil", amount=20},
        {type="item", name="vrauks-food-01", amount=1},
      },
      results = {
        {type="item", name="mukmoux-food-01", amount=5},
      },
    },
    ["mukmoux-manure-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.208211160429611,
      ingredients = {
        {type="item", name="raw-fiber", amount=35},
        {type="item", name="refined-natural-gas-barrel", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="manure", amount=1},
        {type="item", name="manure-bacteria-barrel", amount=0.208491555208167},
      },
    },
    ["mukmoux"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="fluid", name="oxygen", amount=22951},
        {type="item", name="alien-sample-02", amount=5},
        {type="item", name="cytostatics", amount=2},
        {type="item", name="dna-polymerase", amount=1},
        {type="item", name="earth-generic-sample", amount=4},
        {type="item", name="korlex-codex", amount=1},
        {type="item", name="planter-box", amount=23},
        {type="item", name="retrovirus", amount=61},
        {type="item", name="titanium-plate", amount=54},
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
        {type="item", name="fawogae-spore", amount=9},
        {type="item", name="ralesia", amount=36},
        {type="item", name="raw-fiber", amount=9},
        {type="item", name="refined-natural-gas-barrel", amount=12},
        {type="item", name="salt", amount=194},
      },
      results = {
        {type="item", name="barrel", amount=21},
        {type="item", name="mukmoux-calf", amount=3},
      },
    },
    ["mukmoux-1"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="cage", amount=4},
        {type="item", name="caged-mukmoux", amount=3},
        {type="item", name="fawogae-spore", amount=13},
        {type="item", name="ralesia", amount=28},
        {type="item", name="refined-natural-gas-barrel", amount=4},
        {type="item", name="salt", amount=172},
      },
      results = {
        {type="item", name="barrel", amount=15},
        {type="item", name="mukmoux", amount=5},
      },
    },
    ["mukmoux-pasture-mk01"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="arthropod-blood-barrel", amount=13},
        {type="item", name="brain", amount=4},
        {type="item", name="controler-mk01", amount=1},
        {type="item", name="medium-distillate-canister", amount=14},
        {type="item", name="residual-oil-canister", amount=26},
        {type="item", name="sb-grade-02", amount=252},
        {type="item", name="subcritical-water-barrel", amount=4},
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
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.66666666666667,
      ingredients = {
        {type="fluid", name="manure-bacteria", amount=123},
        {type="item", name="fawogae", amount=6},
        {type="item", name="filtration-media", amount=2},
        {type="item", name="guar", amount=5},
        {type="item", name="hot-syngas-barrel", amount=1},
        {type="item", name="iron-ore", amount=8},
        {type="item", name="log", amount=3},
        {type="item", name="moondrop", amount=5},
        {type="item", name="nickel-plate", amount=4},
        {type="item", name="raw-fiber", amount=11},
        {type="item", name="rennea", amount=3},
        {type="item", name="rennea-seeds", amount=10},
        {type="item", name="sodium-alginate", amount=1},
      },
      results = {
        {type="item", name="cottongut-food-02", amount=10},
      },
    },
    ["cottongut-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.99631042308843,
      ingredients = {
        {type="fluid", name="blood", amount=374},
        {type="fluid", name="fetal-serum", amount=64},
        {type="fluid", name="zogna-bacteria", amount=63},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="retrovirus", amount=5},
        {type="item", name="sea-sponge-sprouts-mk02", amount=4},
      },
      results = {
        {type="item", name="cottongut-mk01", amount=1},
        {type="item", name="cottongut-mk02", amount=0.00943288230755309},
      },
    },
    ["cottongut-pup-mk02-raising"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.2987012987013,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="cottongut-food-01", amount=3},
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="filtration-media", amount=1},
        {type="item", name="fish-egg", amount=1},
        {type="item", name="fish-egg-mk02", amount=1},
        {type="item", name="fishmeal", amount=1},
        {type="item", name="kicalk-seeds", amount=7},
        {type="item", name="native-flora", amount=32},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=2},
        {type="item", name="cottongut-pup-mk02", amount=5},
      },
    },
    ["caged-cottongut-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.784485866112296,
      ingredients = {
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-mk01", amount=3},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="tuuphra", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=2},
        {type="item", name="cottongut", amount=7},
      },
    },
    ["cottongut-cub-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.05794501795796,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1},
        {type="item", name="auog-food-02", amount=1},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="iron-pulp-01-barrel", amount=1},
        {type="item", name="raw-fiber", amount=9},
        {type="item", name="sic", amount=10},
        {type="item", name="yotoi-fruit", amount=31},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="cottongut-pup", amount=17},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["cottongut-mature-basic-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2,
      ingredients = {
        {type="item", name="arqad-honey-barrel", amount=1},
        {type="item", name="bhoddos", amount=1},
        {type="item", name="cottongut-mk01", amount=2},
        {type="item", name="cottongut-pup-mk01", amount=13},
        {type="item", name="fish-food-02", amount=1},
        {type="item", name="grod", amount=4},
        {type="item", name="moondrop", amount=9},
        {type="item", name="rennea-seeds", amount=5},
        {type="item", name="sic", amount=3},
        {type="item", name="yotoi-fruit", amount=9},
      },
      results = {
        {type="item", name="cottongut-mk02", amount=4},
      },
    },
    ["auog-food-02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.4,
      ingredients = {
        {type="item", name="kicalk", amount=3},
        {type="item", name="melamine", amount=3},
        {type="item", name="oil-sand-slurry-barrel", amount=1},
        {type="item", name="quartz-tube", amount=3},
        {type="item", name="raw-fiber", amount=7},
        {type="item", name="saps", amount=4},
        {type="item", name="sic", amount=7},
        {type="item", name="sodium-hydroxide", amount=2},
        {type="item", name="sodium-sulfate", amount=1},
      },
      results = {
        {type="item", name="auog-food-02", amount=7},
      },
    },
    ["auog-maturing-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3.49255344738619,
      ingredients = {
        {type="item", name="auog-food-02", amount=2},
        {type="item", name="bedding", amount=8},
        {type="item", name="blood-barrel", amount=1},
        {type="item", name="caged-auog", amount=3},
        {type="item", name="casein", amount=2},
        {type="item", name="cocoon-mk02", amount=10},
        {type="item", name="empty-fuel-canister", amount=17},
        {type="item", name="grade-1-copper", amount=13},
        {type="item", name="kicalk", amount=8},
        {type="item", name="refined-natural-gas-barrel", amount=7},
        {type="item", name="vrauks-food-02", amount=2},
      },
      results = {
        {type="item", name="auog", amount=28},
        {type="item", name="barrel", amount=17},
      },
    },
    ["auog-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.40450916608325,
      ingredients = {
        {type="fluid", name="arthropod-blood", amount=115},
        {type="item", name="auog-pup", amount=1},
        {type="item", name="casein", amount=2},
        {type="item", name="dried-meat", amount=19},
        {type="item", name="energy-drink", amount=1},
        {type="item", name="guts", amount=3},
      },
      results = {
        {type="item", name="auog", amount=1},
        {type="item", name="auog-mk02", amount=0.00663710729462252},
        {type="item", name="charged-auog", amount=0.13274214589245},
      },
    },
    ["charged-auog"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 4,
      ingredients = {
        {type="item", name="ammonia-barrel", amount=5},
        {type="item", name="propene-canister", amount=7},
      },
      results = {
        {type="item", name="charged-auog", amount=4},
      },
    },
    ["auog-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.20186387861795,
      ingredients = {
        {type="item", name="auog-food-01", amount=7},
        {type="item", name="bedding", amount=7},
        {type="item", name="charged-auog", amount=5},
        {type="item", name="cottongut-food-01", amount=1},
        {type="item", name="cottongut-mk01", amount=7},
        {type="item", name="moondrop-seeds", amount=21},
        {type="item", name="moss", amount=10},
        {type="item", name="naphtha-barrel", amount=1},
        {type="item", name="refined-natural-gas-barrel", amount=1},
        {type="item", name="tuuphra", amount=3},
        {type="item", name="used-comb", amount=2},
      },
      results = {
        {type="item", name="auog-pup-mk02", amount=6},
        {type="item", name="barrel", amount=4},
      },
    },
    ["auog-mk02-recharge"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="barrel-milk", amount=3},
        {type="item", name="bof-mk01", amount=3},
        {type="item", name="cottongut-food-01", amount=2},
        {type="item", name="saps", amount=14},
      },
      results = {
        {type="item", name="auog-mk02", amount=5},
      },
    },
    ["auog-pooping-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.768894040930706,
      ingredients = {
        {type="item", name="grade-1-copper", amount=1},
        {type="item", name="kicalk", amount=2},
        {type="item", name="low-distillate-barrel", amount=1},
        {type="item", name="moss", amount=16},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="wood-seeds-mk02", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="manure", amount=8},
      },
    },
    ["auog-pup-breeding-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 3,
      ingredients = {
        {type="item", name="auog-food-02", amount=3},
        {type="item", name="bedding", amount=9},
        {type="item", name="kicalk", amount=15},
        {type="item", name="moss", amount=14},
        {type="item", name="native-flora", amount=34},
        {type="item", name="niobium-complex-barrel", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=9},
        {type="item", name="stone-wool", amount=3},
        {type="item", name="wood-seeds-mk02", amount=2},
      },
      results = {
        {type="item", name="auog-pup", amount=36},
        {type="item", name="barrel", amount=15},
      },
    },
    ["auog-recharge"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog-food-01", amount=3},
        {type="item", name="bedding", amount=1},
        {type="item", name="yotoi-leaves", amount=25},
      },
      results = {
        {type="item", name="auog", amount=4},
      },
    },
    ["auog-pup-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="auog", amount=6},
        {type="item", name="auog-food-01", amount=5},
        {type="item", name="auog-pup-mk02", amount=3},
        {type="item", name="barrel-milk", amount=1},
        {type="item", name="lignin", amount=18},
        {type="item", name="molybdenum-pulp-barrel", amount=1},
        {type="item", name="moss", amount=26},
      },
      results = {
        {type="item", name="auog-mk02", amount=3},
        {type="item", name="barrel", amount=3},
        {type="item", name="empty-barrel-milk", amount=2},
      },
    },
    ["ralesia-2"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.36,
      ingredients = {
        {type="item", name="coke", amount=1},
        {type="item", name="fertilizer", amount=7},
        {type="item", name="gravel", amount=5},
        {type="item", name="limestone", amount=1},
        {type="item", name="moondrop-seeds", amount=8},
        {type="item", name="pure-sand", amount=5},
        {type="item", name="py-asphalt", amount=1},
        {type="item", name="ralesia-seeds", amount=10},
      },
      results = {
        {type="item", name="ralesia", amount=34},
      },
    },
    ["ralesia-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.747880796759334,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=408},
        {type="fluid", name="oxygen", amount=131},
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-seeds", amount=7},
        {type="item", name="sand", amount=47},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="ralesia", amount=1},
        {type="item", name="ralesia-mk02", amount=0.00373940398379667},
      },
    },
    ["ralesia-seeds-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.25,
      ingredients = {
        {type="item", name="caged-ulric", amount=1},
        {type="item", name="ralesia", amount=9},
        {type="item", name="ralesia-mk02", amount=4},
        {type="item", name="refined-natural-gas-barrel", amount=1},
        {type="item", name="salt", amount=4},
        {type="item", name="ulric-food-01", amount=1},
      },
      results = {
        {type="item", name="ralesia-seeds-mk02", amount=10},
      },
    },
    ["ralesia-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.76280626215328,
      ingredients = {
        {type="fluid", name="hydrogen", amount=271},
        {type="item", name="fawogae", amount=78},
        {type="item", name="fawogae-spore", amount=45},
        {type="item", name="ralesia-seeds-mk02", amount=4},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=2},
        {type="item", name="ralesia-mk02", amount=7},
        {type="item", name="ralesia-seeds-mk02", amount=1},
      },
    },
    ["vrauks-cocoon-3"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.04379580854755,
      ingredients = {
        {type="item", name="fertilizer", amount=3},
        {type="item", name="fishmeal", amount=2},
        {type="item", name="grade-1-tin", amount=3},
        {type="item", name="vrauks-food-01", amount=3},
        {type="item", name="water-barrel", amount=6},
      },
      results = {
        {type="item", name="barrel", amount=4},
        {type="item", name="cocoon", amount=21},
      },
    },
    ["vrauks-food-02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="fluid", name="cyanic-acid", amount=59},
        {type="fluid", name="fish-oil", amount=54},
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="casein", amount=6},
        {type="item", name="dried-grods", amount=1},
        {type="item", name="hazard-concrete", amount=1},
        {type="item", name="log", amount=3},
        {type="item", name="mukmoux-fat", amount=5},
        {type="item", name="resistor1", amount=4},
        {type="item", name="sn-biomass", amount=5},
        {type="item", name="sodium-hydroxide", amount=15},
        {type="item", name="sugar", amount=2},
      },
      results = {
        {type="item", name="vrauks-food-02", amount=9},
      },
    },
    ["vrauks-mk03"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.96128857903277,
      ingredients = {
        {type="item", name="alien-sample-02", amount=2},
        {type="item", name="bedding", amount=18},
        {type="item", name="cocoon-mk02", amount=62},
        {type="item", name="fishmeal", amount=11},
        {type="item", name="sea-sponge-mk02", amount=3},
        {type="item", name="vrauks-food-02", amount=4},
      },
      results = {
        {type="item", name="barrel", amount=10},
        {type="item", name="vrauks-mk02", amount=5},
        {type="item", name="vrauks-mk03", amount=0.00778100937050193},
      },
    },
    ["vrauks-3"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.12100587896248,
      ingredients = {
        {type="item", name="auog-food-01", amount=2},
        {type="item", name="cocoon-mk02", amount=9},
        {type="item", name="cottongut-food-02", amount=1},
        {type="item", name="empty-fuel-canister", amount=6},
        {type="item", name="vrauks-food-02", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=3},
        {type="item", name="vrauks", amount=9},
      },
    },
    ["vrauks-mk03-breeder"] = {
      mode = "softmax-semantic-substitution",
      science_level = 5,
      energy_required_multiplier = 1.05241200641898,
      ingredients = {
        {type="item", name="alien-sample-02", amount=1},
        {type="item", name="bedding", amount=4},
        {type="item", name="cocoon-mk03", amount=1},
        {type="item", name="fishmeal", amount=5},
        {type="item", name="processed-iron-ore", amount=7},
        {type="item", name="refined-natural-gas-barrel", amount=3},
        {type="item", name="sea-sponge-mk02", amount=1},
        {type="item", name="vrauks-mk03", amount=1},
        {type="item", name="waste-water-barrel", amount=1},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="vrauks-mk03", amount=2},
      },
    },
    ["vrauks-mk03-cocoon"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1.0876485927556,
      ingredients = {
        {type="item", name="energy-drink", amount=2},
        {type="item", name="grade-1-tin", amount=2},
        {type="item", name="kevlar-coating", amount=1},
        {type="item", name="niobium-plate", amount=6},
        {type="item", name="propene-canister", amount=2},
        {type="item", name="refined-natural-gas-barrel", amount=2},
        {type="item", name="sea-sponge", amount=5},
        {type="item", name="vrauks-food-01", amount=2},
        {type="item", name="vrauks-mk03", amount=2},
      },
      results = {
        {type="item", name="barrel", amount=5},
        {type="item", name="cocoon-mk03", amount=6},
        {type="item", name="vrauks-mk03", amount=2},
      },
    },
    ["yotoi-sample"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="item", name="cottongut-codex", amount=5},
        {type="item", name="cytostatics", amount=1},
        {type="item", name="earth-sunflower-sample", amount=4},
      },
      results = {
        {type="item", name="yotoi", amount=5},
      },
    },
    ["yotoi-leaves"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.8,
      ingredients = {
        {type="fluid", name="molten-titanium", amount=9},
        {type="item", name="rennea", amount=1},
      },
      results = {
        {type="item", name="yotoi-leaves", amount=9},
      },
    },
    ["yotoi-seeds"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.666666666666667,
      ingredients = {
        {type="item", name="yotoi", amount=3},
      },
      results = {
        {type="item", name="yotoi-seeds", amount=2},
      },
    },
    ["yotoi-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 2.5,
      ingredients = {
        {type="fluid", name="tailings", amount=266},
        {type="item", name="clean-nexelit", amount=2},
        {type="item", name="soil", amount=20},
        {type="item", name="yotoi", amount=2},
        {type="item", name="yotoi-fruit", amount=5},
      },
      results = {
        {type="item", name="yotoi", amount=12},
      },
    },
    ["yotoi-fruit-1"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.6,
      ingredients = {
        {type="fluid", name="water", amount=91},
        {type="item", name="coke", amount=6},
        {type="item", name="gravel", amount=5},
      },
      results = {
        {type="item", name="yotoi-fruit", amount=3},
      },
    },
    ["fawogae-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.26666666666667,
      ingredients = {
        {type="fluid", name="water", amount=172},
        {type="item", name="fungal-substrate", amount=1},
        {type="item", name="yaedols-spores", amount=2},
      },
      results = {
        {type="item", name="fawogae", amount=19},
      },
    },
    ["fawogae-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.74248231494246,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=330},
        {type="fluid", name="water", amount=949},
        {type="item", name="fawogae", amount=1},
        {type="item", name="fertilizer", amount=12},
        {type="item", name="limestone", amount=46},
        {type="item", name="purple-refined-concrete", amount=2},
        {type="item", name="ralesia", amount=2},
        {type="item", name="ralesia-seeds", amount=8},
        {type="item", name="sand", amount=17},
        {type="item", name="yaedols", amount=1},
      },
      results = {
        {type="item", name="fawogae", amount=1},
        {type="item", name="fawogae-mk02", amount=0.00871241157471232},
      },
    },
    ["fawogae-mk02-breeder"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="fluid", name="muddy-sludge", amount=300},
        {type="item", name="fawogae", amount=3},
        {type="item", name="fawogae-spore-mk02", amount=9},
        {type="item", name="fertilizer", amount=1},
      },
      results = {
        {type="item", name="fawogae-mk02", amount=2},
      },
    },
    ["fawogae-spore-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.8,
      ingredients = {
        {type="item", name="fawogae", amount=23},
      },
      results = {
        {type="item", name="fawogae-spore-mk02", amount=4},
      },
    },
    ["yaedols-2"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 1.5,
      ingredients = {
        {type="item", name="albumin", amount=1},
        {type="item", name="coke", amount=30},
        {type="item", name="fawogae", amount=5},
        {type="item", name="kicalk", amount=10},
        {type="item", name="log", amount=1},
        {type="item", name="nickel-rejects", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=9},
      },
    },
    ["yaedols-spore-mk02"] = {
      mode = "kept-pruned-transformed",
      science_level = 5,
      energy_required_multiplier = 1,
      ingredients = {
        {type="item", name="yaedols-mk02", amount=1},
      },
      results = {
        {type="item", name="yaedols-spores-mk02", amount=5},
      },
    },
    ["yaedols-mk02"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.905344317351987,
      ingredients = {
        {type="fluid", name="carbon-dioxide", amount=529},
        {type="item", name="albumin", amount=2},
        {type="item", name="coal-gas-canister", amount=1},
        {type="item", name="wood", amount=9},
        {type="item", name="yaedols", amount=2},
      },
      results = {
        {type="item", name="yaedols", amount=1},
        {type="item", name="yaedols-mk02", amount=0.00452672158675994},
      },
    },
    ["yaedols-mk02-breeder"] = {
      mode = "kept-transformed",
      science_level = 5,
      energy_required_multiplier = 0.888888888888889,
      ingredients = {
        {type="item", name="mixed-ores", amount=58},
        {type="item", name="ulric", amount=2},
        {type="item", name="yaedols-mk02", amount=2},
        {type="item", name="yaedols-spores", amount=608},
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
        {type="item", name="chloroethanol-barrel", amount=4},
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

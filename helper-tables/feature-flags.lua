-- Shared by data and control stages so prototype setup and runtime bonuses agree.
local experiments = require("helper-tables/experimental-flags")
local features = {}
features.unified_preview = settings.startup["propertyrandomizer-unified-preview"].value
features.dev_unified = features.unified_preview or settings.startup["propertyrandomizer-dev-unified"].value
-- Preview cannot enable parked combat mutations or their expensive scoring.
features.damage_types = experiments.military_resistances == true and features.dev_unified
    and settings.startup["propertyrandomizer-unified-damage-types"].value == true
return features

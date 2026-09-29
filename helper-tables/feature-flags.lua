-- Shared by data and control stages so prototype setup and runtime bonuses agree.
local features = {}
features.unified_preview = settings.startup["propertyrandomizer-unified-preview"].value
features.dev_unified = features.unified_preview or settings.startup["propertyrandomizer-dev-unified"].value
return features

local spec = require("src/config/spec")

randomizations = {}

-- These are helpers used by the rest of the numerical randomizations
require("src/randomizations/helpers/energy")
require("src/randomizations/helpers/trigger")

log("Gathering graph randomizations (if applicable)")

-- Graph randomizations

require("src/legacy/randomizations/item")
require("src/legacy/randomizations/recipe")
require("src/legacy/randomizations/recipe-tech-unlock")
require("src/legacy/randomizations/technology")

log("Gathering misc randomizations")

-- Misc randomizations
require("src/randomizations/misc/beacon-profiles")
require("src/randomizations/misc/ammo-categories")
require("src/randomizations/misc/capsule-actions")
require("src/randomizations/misc/damage-types")
-- TODO
require("src/randomizations/misc/equipment-shapes")
require("src/randomizations/misc/fluid-boxes")
require("src/randomizations/misc/gui")
require("src/randomizations/misc/item-fuels")
require("src/randomizations/misc/locale")
require("src/randomizations/misc/map-gen-preset")
require("src/randomizations/misc/module-effects")
require("src/randomizations/misc/offsets")
require("src/randomizations/misc/sizes")
require("src/randomizations/misc/sound")
require("src/randomizations/misc/visual")

log("Gathering numerical randomizations")

-- Require the numerical randomizations
require("src/randomizations/numerical/active-trigger")
require("src/randomizations/numerical/entity")
require("src/randomizations/numerical/equipment")
require("src/randomizations/numerical/equipment-grid")
require("src/randomizations/numerical/fluid")
require("src/randomizations/numerical/item")
require("src/randomizations/numerical/recipe")
require("src/randomizations/numerical/space-location")
require("src/randomizations/numerical/technology")
require("src/randomizations/numerical/tile")

log("Gathering fixes")

-- Fixes (executed later)
require("src/randomizations/rebuild/init")

-- Validate randomizations

log("Validating randomizations if implemented")

for id, _ in pairs(randomizations) do
    if spec[id] == nil then
        -- Defined randomization is not added to spec!
        -- CRITICAL TODO: Add randomizations to spec!
        -- error("Randomizations not added to spec " .. id)
    end
end
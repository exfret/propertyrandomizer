local spec = require("helper-tables/spec")

randomizations = {}

-- These are helpers used by the rest of the numerical randomizations
require("randomizations/helper/energy")
require("randomizations/helper/linked")
require("randomizations/helper/trigger")

log("Gathering planetary randomizations")

-- Planetary randomizations are very first because they're hardcoded and sensitive to initial conditions
require("randomizations/planetary/tile")

log("Gathering graph randomizations (if applicable)")

-- Graph randomizations
require("randomizations/graph/item")
require("randomizations/graph/recipe")
require("randomizations/graph/recipe-tech-unlock")
require("randomizations/graph/technology")

log("Gathering misc randomizations")

-- Misc randomizations
require("misc/beacon-profiles")
require("randomizations/misc/capsule-actions")
-- TODO
require("randomizations/misc/equipment-shapes")
require("randomizations/misc/fluid-boxes")
require("randomizations/misc/gui")
require("randomizations/misc/item-fuels")
require("randomizations/misc/locale")
require("randomizations/misc/offsets")
require("randomizations/misc/sizes")
require("randomizations/misc/sound")
require("randomizations/misc/visual")

log("Gathering numerical randomizations")

-- Require the numerical randomizations
require("randomizations/numerical/entity")
require("randomizations/numerical/equipment")
require("randomizations/numerical/equipment-grid")
require("randomizations/numerical/fluid")
require("randomizations/numerical/item")
require("randomizations/numerical/technology")
require("randomizations/numerical/tile")

log("Gathering fixes")

-- Fixes (executed later)
require("randomizations/fixes")

-- Validate randomizations

log("Validating randomizations if implemented")

for id, _ in pairs(randomizations) do
    if spec[id] == nil then
        -- Defined randomization is not added to spec!
        -- CRITICAL TODO: Add randomizations to spec!
        -- error("Randomizations not added to spec " .. id)
    end
end
local spec = require("helper-tables/spec")

randomizations = {}

-- These are helpers used by the rest of the numerical randomizations
require("helper/energy")
require("helper/linked")
require("helper/trigger")

log("Gathering graph randomizations (if applicable)")

-- Graph randomizations
if randomization_info.options.build_graph then
    require("graph/item-minable")
    require("graph/item")
    require("graph/recipe")
end

log("Gathering misc randomizations")

-- Misc randomizations
-- TODO
--require("misc/beacon-profiles")
require("misc/equipment-shapes")
require("misc/fluid-boxes")
require("misc/gui")
require("misc/locale")
require("misc/offsets")
require("misc/sizes")
require("misc/sound")
require("misc/visual")

log("Gathering numerical randomizations")

-- Require the numerical randomizations
require("numerical/entity")
require("numerical/equipment")
require("numerical/equipment-grid")
require("numerical/fluid")
require("numerical/item")
require("numerical/technology")
require("numerical/tile")

log("Gathering fixes")

-- Fixes (executed later)
require("fixes")

-- Validate randomizations

log("Validating randomizations if implemented")

for id, _ in pairs(randomizations) do
    if spec[id] == nil then
        -- Defined randomization is not added to spec!
        -- CRITICAL TODO: Add randomizations to spec!
        -- error("Randomizations not added to spec " .. id)
    end
end
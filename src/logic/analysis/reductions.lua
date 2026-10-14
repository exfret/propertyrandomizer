-- Whether logic.build reduces the graph without changing what any node left gets in a sort:
--   * pass-through nodes left out (src/logic/analysis/pass-through.lua), with recipe unlocks (src/logic/analysis/unlock-contraction.lua)
--   * technology-only recipe unlocks share their existing technology OR, retaining its alternatives and empty locks
--   * one recipe-category node per category list and set of crafters (lutils.group_rcats, src/prototypes/lookup/3-compound.lua)
--   * recipe production goes straight into items where no trigger needs a separate crafting node (src/logic/builders/item-craft.lua)
--   * building supply shares the entity-build-architecture OR (src/logic/analysis/entity-build-item.lua)
-- The both-ways check (src/logic/analysis/reduction-check.lua) builds every graph with this off too, and compares
local build_supply = require("src/logic/analysis/entity-build-item")
local item_craft = require("src/logic/builders/item-craft")
local pass_through = require("src/logic/analysis/pass-through")

return {
    enabled = true,
    expand_all = function(graph)
        return build_supply.expand_all(graph) + item_craft.expand_all(graph) + pass_through.expand_all(graph)
    end,
}

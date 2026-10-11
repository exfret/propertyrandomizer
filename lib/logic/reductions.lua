-- Whether logic.build reduces the graph without changing what any node left gets in a sort:
--   * pass-through nodes left out (lib/logic/pass-through.lua), with recipe unlocks (lib/logic/unlock-contraction.lua)
--   * one recipe-category node per category list and set of crafters (lutils.group_rcats, lib/lookup/3-compound.lua)
--   * recipe production goes straight into items where no trigger needs a separate crafting node (lib/logic/item-craft.lua)
-- The both-ways check (lib/logic/reduction-check.lua) builds every graph with this off too, and compares
local item_craft = require("lib/logic/item-craft")
local pass_through = require("lib/logic/pass-through")

return {
    enabled = true,
    expand_all = function(graph)
        return item_craft.expand_all(graph) + pass_through.expand_all(graph)
    end,
}

-- Whether logic.build reduces the graph without changing what any node left gets in a sort:
--   * pass-through nodes left out (lib/logic/pass-through.lua), with recipe unlocks (lib/logic/unlock-contraction.lua)
--   * one recipe-category node per category list and set of crafters (lutils.group_rcats, lib/lookup/3-compound.lua)
-- The both-ways check (lib/logic/reduction-check.lua) builds every graph with this off too, and compares
return {
    enabled = true,
}

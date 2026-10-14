-- Replay the transaction, debt, and context regressions with selective
-- invalidation enabled, including changes outside the entity handler.
arg = {"cached-rewires"}
dofile("tests/unit/randomizations/unified/skeleton/test-promotion.lua")

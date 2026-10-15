-- Stops the count instrument-data.lua started, and logs it for dev/run-tests.py
debug.sethook()
log("PRCOUNT data samples=" .. prcount.samples .. " interval=" .. prcount.interval)

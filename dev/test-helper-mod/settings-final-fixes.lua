-- Unhides the randomizer's hidden settings so a test's mod-settings.dat can set them
-- A hidden setting with forced_value always takes that value, whatever mod-settings.dat says
-- Settings the test doesn't set still get their default_value, so unhiding all of them changes nothing else
for _, prototypes in pairs(data.raw) do
    for name, prototype in pairs(prototypes) do
        if prototype.setting_type ~= nil and string.find(name, "propertyrandomizer-", 1, true) == 1 then
            prototype.hidden = false
            prototype.forced_value = nil
        end
    end
end

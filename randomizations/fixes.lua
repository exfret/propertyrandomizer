-- File for any last-minute fixes in the randomization process that may be needed

randomizations.fixes = function()
    -- Fix electric pole supply area to be at least as large as distribution range
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        if electric_pole.maximum_wire_distance == nil then
            electric_pole.maximum_wire_distance = 0
        end

        electric_pole.maximum_wire_distance = math.max(electric_pole.maximum_wire_distance, 2 * electric_pole.supply_area_distance)
    end
end
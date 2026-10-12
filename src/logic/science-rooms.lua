-- The rooms each science pack belongs to, the only ones graph randomization keeps it in (the user, 2026-10-10: red, green and blue on the starting planet, each planet's own science on its planet, and making utility science on Fulgora isn't needed)
-- A pack the starting planet accepts a recipe of (in vanilla the packs with no surface conditions: red, green, blue, military, production and utility) belongs to the starting planet alone
-- Any other pack belongs to the rooms accepting its recipes' surface conditions: metallurgic science to Vulcanus, space and promethium science to space platforms, a planet copy's pack to its copy (src/prototypes/duplicates/dupe-planets.lua locks those)
-- A pack no recipe makes (like space science in the base game, a rocket launch's result) belongs to the starting planet too
-- A pack's recipes are the visible ones making it as their main product, as src/prototypes/duplicates/dupe.lua's item_recipes counts them, so recycling, which gives a pack back, isn't one
-- Plain Lua, so tests/unit/logic/test-science-rooms.lua can test it outside the game; src/logic/builders/concrete.lua gives each science pack's item node its rooms

local science_rooms = {}

-- The item a recipe makes as its main product: main_product when given, else its only result, or nil
local function main_product(recipe)
    if recipe.main_product ~= nil then
        return recipe.main_product
    end
    if recipe.results ~= nil and #recipe.results == 1 and recipe.results[1].type == "item" then
        return recipe.results[1].name
    end
    return nil
end

-- packs: set of science pack names (like dutils.lab_inputs()); recipes: every recipe (like the logic's lookups.recipes, by name); start_room: the starting planet's room key; accepting(recipe): the rooms accepting a recipe's surface conditions, as room key --> true
-- Returns pack name --> (room key --> true), for every pack
science_rooms.of_packs = function(packs, recipes, start_room, accepting)
    local rooms_of = {}
    local has_recipe = {}
    for _, recipe in pairs(recipes) do
        local product = main_product(recipe)
        if recipe.hidden ~= true and product ~= nil and packs[product] ~= nil then
            has_recipe[product] = true
            if rooms_of[product] == nil or rooms_of[product][start_room] == nil then
                local accepted = accepting(recipe)
                if accepted[start_room] ~= nil then
                    rooms_of[product] = { [start_room] = true }
                else
                    rooms_of[product] = rooms_of[product] or {}
                    for room_key, _ in pairs(accepted) do
                        rooms_of[product][room_key] = true
                    end
                end
            end
        end
    end
    for pack_name, _ in pairs(packs) do
        if has_recipe[pack_name] == nil then
            rooms_of[pack_name] = { [start_room] = true }
        end
    end
    return rooms_of
end

return science_rooms

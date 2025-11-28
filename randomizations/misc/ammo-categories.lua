local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

-- Put stuff in shuffle-able lists
local ammos = {}
for _, ammo in pairs(data.raw["ammo"]) do
    table.insert(ammos, ammo)
end

-- Gather the things that can shoot ammo
local ammo_users = {}
local ammo_user_classes = { "ammo-turret", "gun" }
for _, class in pairs(ammo_user_classes) do
    for _, ammo_user in pairs(data.raw[class]) do
        local ap = ammo_user.attack_parameters
        if ap.ammo_categories == nil then
            ap.ammo_categories = { ap.ammo_category }
        end
        ap.ammo_category = nil
        table.insert(ammo_users, ammo_user)
    end
end

-- Find which ammo_categories we're working with
local shootable_ammo_category_set = {}
for _, ammo in pairs(ammos) do
    shootable_ammo_category_set[ammo.ammo_category] = true
end

-- Put them in a shuffle-able list too
local shootable_ammo_category_list = {}
for ammo_category, _ in pairs(shootable_ammo_category_set) do
    table.insert(shootable_ammo_category_list, ammo_category)
end

randomizations.ammo_categories = function(id)

    -- Assign completely random ammo categories to everything
    for _, ammo in pairs(ammos) do
        local key = rng.key({ id = id, prototype = ammo })
        ammo.ammo_category = shootable_ammo_category_list[rng.int(key, #shootable_ammo_category_list)]
    end
    for _, ammo_user in pairs(ammo_users) do
        local ap = ammo_user.attack_parameters
        local key = rng.key({ id = id, prototype = ammo_user })
        for i = 1, #ap.ammo_categories do
            ap.ammo_categories[i] = shootable_ammo_category_list[rng.int(key, #shootable_ammo_category_list)]
        end
    end

    -- Make sure all ammo categories appear at least once, and have at least one ammo and one user
    local key = rng.key({id = id})
    rng.shuffle(key, ammos)
    rng.shuffle(key, ammo_users)
    rng.shuffle(key, shootable_ammo_category_list)
    for i, ammo_category in pairs(shootable_ammo_category_list) do
        ammos[i].ammo_category = ammo_category
        ammo_users[i].attack_parameters.ammo_categories[1] = ammo_category
    end

    -- Add stuff to descriptions
    for _, ammo in pairs(ammos) do
        ammo.localised_description = {"", locale_utils.find_localised_description(ammo), "\n[color=red](Creative weapon specification)[/color]"}
    end
    for _, ammo_user in pairs(ammo_users) do
        ammo_user.localised_description = {"", locale_utils.find_localised_description(ammo_user), "\n[color=red](Creative ammo specification)[/color]"}
    end
end
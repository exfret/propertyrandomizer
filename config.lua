local constants = require("helper-tables/constants")
local features = require("helper-tables/feature-flags")
local spec = require("helper-tables/spec")

config = {}

----------------------------------------------------------------------
-- Manual config
----------------------------------------------------------------------

-- Valid levels are "none", "minimal", "default", and "verbose"
-- Currently not implemented yet
randomization_info.options.logging = "default"

----------------------------------------------------------------------
-- Extracting from settings
----------------------------------------------------------------------

-- Make default 23 since that's my favorite number
config.seed = 23 + settings.startup["propertyrandomizer-seed"].value

if settings.startup["propertyrandomizer-dupes"].value then
    config.dupes = true
end
if settings.startup["propertyrandomizer-test-unit"].value then
    config.unit_test = true
end

config.graph = {}
if settings.startup["propertyrandomizer-technology"].value then
    config.graph.technology = true
end
if settings.startup["propertyrandomizer-recipe"].value then
    config.graph.recipe = true
end
if settings.startup["propertyrandomizer-recipe-science-pack"].value then
    config.only_randomize_science_recipes = true
end
if settings.startup["propertyrandomizer-recipe-tech-unlock"].value then
    config.graph.recipe_tech_unlock = true
end
if settings.startup["propertyrandomizer-recipe-tech-unlock-duplicates"].value then
    config.duplicate_recipe_tech_unlocks = true
end
if settings.startup["propertyrandomizer-item"].value then
    config.graph.item = true
end

local handler_ids = require("helper-tables/handler-ids")
config.unified = {}
for _, id in pairs(handler_ids) do
    config.unified[id] = settings.startup["propertyrandomizer-unified-" .. id].value
end

config.misc = {}
if settings.startup["propertyrandomizer-icon"].value then
    config.misc.icon = true
end
if settings.startup["propertyrandomizer-sound"].value then
    config.misc.sound = true
end
if settings.startup["propertyrandomizer-gui"].value then
    config.misc.gui = true
end
if settings.startup["propertyrandomizer-locale"].value then
    config.misc.locale = true
end
config.misc.colors = settings.startup["propertyrandomizer-colors"].value

-- The Fleishman algorithm is deprecated (it has no bounds), so the numerical-algorithm setting is hidden and ignored
config.numerical_algorithm = "exfret-random-walk"
config.technology_delinearization = settings.startup["propertyrandomizer-unified-technology-delinearization"].value
-- The unified preview turns on the new unified version: entity randomization with biters, the planetary changes other than lightning and freezing, the tech tree rebuild, and the unified randomizations still in development (config.dev_unified below)
-- Their own settings are hidden for now (tests still set them one at a time), and so are lightning's and freezing's, which are off
config.unified_preview = features.unified_preview
config.tech_tree_rebuild = config.unified_preview or settings.startup["propertyrandomizer-tech-tree-rebuild"].value
-- It isn't made to work with the old graph randomizations (config.graph), so it turns off the ones that are on, and the randomizer panel says which
if config.unified_preview then
    -- The old recipe randomization's science-pack-only option goes too, since unified recipe randomization prices with the same cost code (randomizations/graph/recipe-cost.lua)
    config.only_randomize_science_recipes = nil
    if next(config.graph) ~= nil then
        local turned_off = {}
        for key, _ in pairs(config.graph) do
            table.insert(turned_off, (string.gsub(key, "_", " ")))
        end
        table.sort(turned_off)
        config.graph = {}
        local message = "The unified preview isn't compatible with the old graph randomizations, so it turned off these: " .. table.concat(turned_off, ", ") .. "."
        log(message)
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] " .. message)
    end
end
-- Whether entity randomization is on, which logic needs to know before randomization (for its supply mechanics, see lib/logic/entity-supply.lua)
config.entity_randomization = config.unified_preview or settings.startup["propertyrandomizer-unified-entity"].value
-- Whether entity randomization can change what unit spawners spawn (and so what biters drop or are)
config.entity_biters = config.unified_preview or settings.startup["propertyrandomizer-unified-entity-biters"].value
-- Whether enemies spawned away from their home planet are rebalanced: spawners keep them in their home numbers, and they take their new planet's strength (randomizations/graph/unified/handler-helpers/military.lua)
config.military_rebalance = settings.startup["propertyrandomizer-military-rebalance"].value
config.planetary_oceans = config.unified_preview or settings.startup["propertyrandomizer-planetary-oceans"].value
config.planetary_resources = config.unified_preview or settings.startup["propertyrandomizer-planetary-resources"].value
config.planetary_lightning = settings.startup["propertyrandomizer-planetary-lightning"].value
config.planetary_freezing = settings.startup["propertyrandomizer-planetary-freezing"].value
config.planetary_locks = config.unified_preview or settings.startup["propertyrandomizer-planetary-locks"].value
-- Planet rewards (randomizations/planetary/rewards.lua), a work in progress (notes/wip.txt): planets' special machines and other rewards move to other planets
config.planetary_rewards = settings.startup["propertyrandomizer-planetary-rewards"].value
-- Work in progress, off by default: outside superposed mode, each planet's science moves into the special machine that arrived there instead of the move being reverted
config.planetary_rewards_rehome = settings.startup["propertyrandomizer-planetary-rewards-rehome"].value
-- Only these reward bundles move (bundle ids, which are technology names, comma-separated; a development aid for testing one move at a time): empty for all
config.planetary_rewards_only = {}
for name in string.gmatch(settings.startup["propertyrandomizer-planetary-rewards-only"].value, "[^,%s]+") do
    config.planetary_rewards_only[name] = true
end
-- A new random graph of space connections (randomizations/planetary/connections.lua); the duplicates' planet copies come with it, so the copies aren't just hung beside their originals
config.planetary_connections = config.dupes or settings.startup["propertyrandomizer-planetary-connections"].value
-- Whether any planetary stage is on (randomizations/planetary/execute.lua), planet rewards included
config.planetary = config.planetary_oceans or config.planetary_resources or config.planetary_lightning or config.planetary_freezing or config.planetary_locks or config.planetary_rewards or config.planetary_connections

config.item_new_num_retries = settings.startup["propertyrandomizer-item-retries"].value
config.item_percent_randomized = settings.startup["propertyrandomizer-item-percent"].value / 100

config.unified_num_retries = settings.startup["propertyrandomizer-unified-retries"].value
-- Whether the unified randomizations still in development run (see settings.lua): in the unified preview, or when the test helper explicitly enables the dev setting
config.dev_unified = features.dev_unified
-- Whether the planetary stages that are on run in superposed mode (randomizations/planetary/execute.lua): the game before them stays in the logic as debt for unified randomization to pay, and what's still owed is settled after each of its attempts
-- Only with the unified randomizations in development, which are what pays and settles the debt; without them the stages repair their own changes as usual
config.planetary_superposed = config.dev_unified and settings.startup["propertyrandomizer-planetary-superposed"].value
-- The planetary fix pass (randomizations/planetary/fix-pass.lua), a work in progress, off by default (user, 2026-09-30: wanted it in the checkout to test): each planetary stage it can repair (oceans, resources, lightning, freezing) moves without its own repairs, then a deterministic pass repairs what it broke by changing what unified's handlers change, planet copies allowed; if that isn't enough, the stage is undone and runs the old way, with its own repairs (the user: "try fixes through prereq shuffle methods first and then the old way")
-- It also brings the research trigger handler (randomizations/graph/unified/handlers/tech-triggers.lua), and the planetary check's rocket rule with delivered machines and without recipe categories as goals (randomizations/planetary/check.lua)
-- Only with the unified randomizations in development, whose handlers it uses, and never with superposed mode
config.planetary_fix_pass = config.dev_unified and not config.planetary_superposed and settings.startup["propertyrandomizer-planetary-fix-pass"].value
-- Whether the fix pass may give a shared recipe a planet variant (a copy) when nothing fits everywhere (user, 2026-09-30: "Copies are fine for now I suppose, but keep track of how many")
config.fixpass_variants = true
-- Whether unified item randomization moves fluids too: items and fluids trade positions, and an identity keeps its form while the position takes it (see lib/item-fluid.lua)
-- In development, so it's on with the other unified randomizations still in development (config.dev_unified); everything it touches behaves as before it while this is false
config.item_fluids = config.dev_unified
-- Whether planets get random names mixed from the vanilla planets' names (lib/planet-names.lua): with planetary randomization, the unified randomizations in development and the duplicates all on (user, 2026-09-30)
config.planet_names = config.dupes and config.planetary and config.dev_unified
-- Whether every planet but the starting one gets a random tint (lib/planet-tints.lua), copies included: with the random names, so the planets are disguised together
config.planet_tints = config.planet_names

config.bias_setting = settings.startup["propertyrandomizer-bias"].value
config.chaos_setting = settings.startup["propertyrandomizer-chaos"].value

----------------------------------------------------------------------
-- Whether unified recipe randomization changes recipes' shapes: how many ingredients they take and how many of those are fluids, favoring fluids (see lib/recipe-shape.lua and notes/recipe-shape-plan.md)
-- In development, so it's on with the other unified randomizations still in development (config.dev_unified), since 2026-09-30 with the user's go-ahead after the isolated runs in the plan's status section; everything it touches behaves as before it while this is false
config.recipe_shapes = config.dev_unified
-- Presets
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Parsing
----------------------------------------------------------------------

local setting_values = constants.setting_values

randomizations_to_perform = {}
for id, rand_info in pairs(spec) do
    if rand_info.category == "numerical" then
        local order = 10
        if rand_info.order ~= nil then
            order = rand_info.order
        end

        if randomizations_to_perform[order] == nil then
            randomizations_to_perform[order] = {}
        end
        local order_group = randomizations_to_perform[order]

        if rand_info.setting == "none" then
            order_group[id] = false
        elseif type(rand_info.setting) == "table" then

            if setting_values[settings.startup[rand_info.setting.name].value] >= setting_values[rand_info.setting.val] then
                order_group[id] = true
            else
                order_group[id] = false
            end
        elseif type(rand_info.setting) == "string" then
            if settings.startup[rand_info.setting].value then
                order_group[id] = true
            else
                order_group[id] = false
            end
        else
            -- Setting key not set by mistake
            error()
        end
    end
end

local function parse_property(prop_spec, data_raw_to_use)
    local prot_start = string.find(prop_spec, "%[")
    local prot_end = string.find(prop_spec, "%]")
    if prot_start == nil or prot_end == nil then
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Override params that (should) include prototype not formatted with [ or ] like ...[top-level-class=prot-name]... (no spaces), and so was skipped: " .. prop_spec)
        return false
    end
    local prot_spec = string.sub(prop_spec, prot_start + 1, prot_end - 1)
    local equals_sep = string.find(prot_spec, "=")
    if equals_sep == nil then
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Override params that (should) include prototype not formatted with = like ...[top-level-class=prot-name]... (no spaces), and so was skipped: " .. prop_spec)
        return false
    end
    local top_class_name = string.sub(prot_spec, 1, equals_sep - 1)
    local prot_name = string.sub(prot_spec, equals_sep + 1, -1)
    -- Find the prototype
    if defines.prototypes[top_class_name] == nil then
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] " ..  top_class_name .. " is not a valid top-level class name; override skipped.")
        return false
    end
    local prot
    for class, _ in pairs(defines.prototypes[top_class_name]) do
        if data_raw_to_use[class] ~= nil and data_raw_to_use[class][prot_name] ~= nil then
            prot = data_raw_to_use[class][prot_name]
            break
        end
    end
    if prot == nil then
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] There is no prototype with top level class " .. top_class_name .. " and name " .. prot_name .. "; override skipped.")
        return false
    end
    local prop_part = string.sub(prop_spec, prot_end + 1, -1)
    -- Special props
    if prop_part == "" then
        return {
            tbl = prot,
            prop = "ALL",
        }
    end
    if prop_part == ".NUMERICAL" then
        return {
            tbl = prot,
            prop = "NUMERICAL",
        }
    end
    local curr_tbl = prot
    local last_tbl
    local last_prop
    for prop_key in string.gmatch(prop_part, "([^.]+)") do
        if type(curr_tbl) ~= "table" then
            table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Attempt was made to index into non table value with override containing following property spec, so that override was skipped: " .. prop_spec)
            return false
        end

        last_tbl = curr_tbl
        curr_tbl = curr_tbl[tonumber(prop_key) or prop_key]
        last_prop = tonumber(prop_key) or prop_key
    end
    if last_tbl == nil then
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] No properties specified in following property spec, so that override was skipped: " .. prop_spec)
        return false
    end
    return {
        tbl = last_tbl,
        prop = last_prop,
    }
end

local function parse_value(val_spec, old_val, new_val)
    -- First, test for string
    if string.sub(val_spec, 1, 1) == "\"" and string.sub(val_spec, -1, -1) == "\"" then
        return string.sub(val_spec, 2, -2)
    end
    if string.find(val_spec, "{") == nil then
        local X_val
        if type(old_val) == "number" then
            X_val = old_val
        end
        local Y_val
        if type(new_val) == "number" then
            Y_val = new_val
        end
        return helpers.evaluate_expression(val_spec, { X = X_val, Y = Y_val, x = X_val, y = Y_val })
    end

    local parsed_tbl = {}

    -- Alternates between start inds and stop inds
    local block_start_stop_inds = {}
    -- Will be added to get 2 (past the {)
    table.insert(block_start_stop_inds, 1)
    local curr_nesting = 0
    local last_comma = 1
    local began_block = false
    for i = 1, #val_spec do
        if string.sub(val_spec, i, i) == "{" then
            if curr_nesting == 1 then
                table.insert(block_start_stop_inds, last_comma + 1)
            end
            curr_nesting = curr_nesting + 1
        elseif string.sub(val_spec, i, i) == "}" then
            curr_nesting = curr_nesting - 1
            if curr_nesting == 1 then
                -- +1 to get to this one's comma
                table.insert(block_start_stop_inds, i + 1)
            end
            -- No multiple tables next to each other
            if curr_nesting == 0 then
                if began_block then
                    return false
                end
                began_block = true
            end
        elseif string.sub(val_spec, i, i) == "," then
            last_comma = i
        end
        if curr_nesting < 0 then
            return false
        end
    end
    if curr_nesting ~= 0 then
        return false
    end
    -- Will be subtracted to become -2 (before the })
    table.insert(block_start_stop_inds, -1)
    for i = 1, #block_start_stop_inds / 2 do
        for prop_val in string.gmatch(string.sub(val_spec, block_start_stop_inds[2 * i - 1] + 1, block_start_stop_inds[2 * i] - 1), "([^,]+)") do
            -- Account for empty from potential trailing comm
            if #prop_val > 0 then
                local equals_pos = string.find(prop_val, "=")
                if equals_pos == nil then
                    return false
                end
                local key = string.sub(prop_val, 1, equals_pos - 1)
                local val_subspec = string.sub(prop_val, equals_pos + 1, -1)
                -- Special true/false/nil handling
                if val_subspec == "true" or val_subspec == "false" or val_subspec == "nil" then
                    if val_subspec == "true" then
                        parsed_tbl[tonumber(key) or key] = true
                    elseif val_subspec == "false" then
                        parsed_tbl[tonumber(key) or key] = false
                    elseif val_subspec == "nil" then
                        parsed_tbl[tonumber(key) or key] = nil
                    end
                else
                    local val_spec_val = parse_value(val_subspec, old_val, new_val)
                    if val_spec_val == nil or val_spec_val == false then
                        return false
                    end
                    parsed_tbl[tonumber(key) or key] = val_spec_val
                end
            end
        end
        -- Parse block
        if i < #block_start_stop_inds / 2 then
            -- -1 now to not include the comma at the end (if any)
            local nested_block_expr = string.sub(val_spec, block_start_stop_inds[2 * i], block_start_stop_inds[2 * i + 1] - 1)
            local equals_pos = string.find(nested_block_expr, "=")
            if equals_pos == nil then
                return false
            end
            local key = string.sub(nested_block_expr, 1, equals_pos - 1)
            local nested_table = string.sub(nested_block_expr, equals_pos + 1, -1)
            local nested_block_val = parse_value(nested_table, old_val, new_val)
            if nested_block_val == nil or nested_block_val == false then
                return false
            end
            parsed_tbl[tonumber(key) or key] = nested_block_val
        end
    end

    return parsed_tbl
end

-- Overrides
for override in string.gmatch(settings.startup["propertyrandomizer-overrides"].value, "([^;]+)") do
    local split_ind = string.find(override, ":")
    local instr
    local params
    if split_ind == nil then
        -- Allow backward compat
        if string.sub(override, 1, 1) == "!" then
            instr = "OFF"
            params = string.sub(override, 2, -1)
        else
            instr = "ON"
            params = override
        end
    end

    instr = instr or string.sub(override, 1, split_ind - 1)
    params = params or string.sub(override, split_ind + 1, -1)
    if instr == "OFF" then
        if spec[params] ~= nil then
            for _, order_group in pairs(randomizations_to_perform) do
                if order_group[params] ~= nil then
                    order_group[params] = false
                end
            end
        else
            table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Unrecognized/invalid randomization on an override so it was skipped: " .. params)
        end
    elseif instr == "ON" then
        if spec[params] ~= nil then
            for _, order_group in pairs(randomizations_to_perform) do
                if order_group[params] ~= nil then
                    order_group[params] = true
                end
            end
        else
            table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Unrecognized/invalid randomization on an override so it was skipped: " .. params)
        end
    elseif instr == "RESET" then
        -- Everything for this done later
    elseif instr == "SET" then
        -- Everything for this done later
    else
        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Unrecognized instruction " .. instr .. " in following override, so it was skipped: " .. override)
    end
end

do_overrides_postfixes = function()
    -- We've already done some of the checks, so no need to repeat
    for override in string.gmatch(settings.startup["propertyrandomizer-overrides"].value, "([^;]+)") do
        local split_ind = string.find(override, ":")
        -- Need to check this in case of old-style overrides
        if split_ind ~= nil then
            local instr = string.sub(override, 1, split_ind - 1)
            local params = string.sub(override, split_ind + 1, -1)
            if instr == "RESET" then
                local old_prop_info = parse_property(params, old_data_raw)
                local new_prop_info = parse_property(params, data.raw)
                if old_prop_info ~= false and new_prop_info ~= false then
                    if new_prop_info.prop == "ALL" then
                        local keys_to_remove = {}
                        for k, _ in pairs(new_prop_info.tbl) do
                            table.insert(keys_to_remove, k)
                        end
                        for _, k in pairs(keys_to_remove) do
                            new_prop_info.tbl[k] = nil
                        end
                        for k, v in pairs(old_prop_info.tbl) do
                            new_prop_info.tbl[k] = v
                        end
                    elseif new_prop_info.prop == "NUMERICAL" then
                        local keys_to_remove = {}
                        for k, v in pairs(new_prop_info.tbl) do
                            if type(v) == "number" then
                                table.insert(keys_to_remove, k)
                            end
                        end
                        for _, k in pairs(keys_to_remove) do
                            new_prop_info.tbl[k] = nil
                        end
                        for k, v in pairs(old_prop_info.tbl) do
                            if type(v) == "number" then
                                new_prop_info.tbl[k] = v
                            end
                        end
                    else
                        new_prop_info.tbl[new_prop_info.prop] = old_prop_info.tbl[old_prop_info.prop]
                    end
                end
            elseif instr == "SET" then
                local bracket_pos = string.find(params, "%]")
                if bracket_pos == nil then
                    table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Override params that (should) include prototype not formatted with [ or ] like ...[top-level-class=prot-name]... (no spaces), and so was skipped: " .. params)
                else
                    local prop_val_spec = string.sub(params, bracket_pos + 1, -1)
                    local equals_pos = string.find(prop_val_spec, "=")
                    if equals_pos == nil then
                        table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Override assignment params not formatted with = like ...prop-spec=new-val; (no spaces), and so was skipped: " .. params)
                    else
                        -- Need to re-include the prototype part
                        local prop_spec = string.sub(params, 1, bracket_pos) .. string.sub(prop_val_spec, 1, equals_pos - 1)
                        local val_spec = string.sub(prop_val_spec, equals_pos + 1, -1)
                        local old_prop_info = parse_property(prop_spec, old_data_raw)
                        local new_prop_info = parse_property(prop_spec, data.raw)
                        if old_prop_info ~= false and new_prop_info ~= false then
                            -- Special true/false/nil handling
                            if val_spec == "true" or val_spec == "false" or val_spec == "nil" then
                                if val_spec == "true" then
                                    new_prop_info.tbl[new_prop_info.prop] = true
                                elseif val_spec == "false" then
                                    new_prop_info.tbl[new_prop_info.prop] = false
                                elseif val_spec == "nil" then
                                    new_prop_info.tbl[new_prop_info.prop] = nil
                                end
                            else
                                local expr_val = parse_value(val_spec, old_prop_info.tbl[old_prop_info.prop], new_prop_info.tbl[new_prop_info.prop])
                                if expr_val == nil or expr_val == false then
                                    table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Expression not valid, so override containing it was skipped: " .. val_spec)
                                else
                                    new_prop_info.tbl[new_prop_info.prop] = expr_val
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------------------------------------
-- Setting remaining values
----------------------------------------------------------------------

local bias_string_to_num = constants.bias_string_to_num
local bias_string_to_idx = constants.bias_string_to_idx
config.bias = bias_string_to_num[config.bias_setting]
config.bias_idx = bias_string_to_idx[config.bias_setting]

local chaos_string_to_num = constants.chaos_string_to_num
local chaos_string_to_idx = constants.chaos_string_to_idx
local chaos_string_to_range_num = constants.chaos_string_to_range_num
config.chaos = chaos_string_to_num[config.chaos_setting]
config.chaos_idx = chaos_string_to_idx[config.chaos_setting]
config.chaos_range = chaos_string_to_range_num[config.chaos_setting]
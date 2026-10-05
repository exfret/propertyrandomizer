-- Plain-Lua checks for decorative biome placement, with no game process.
-- Run from the mod root: lua randomizations/planetary/test-biome-decoratives.lua

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for key, item in pairs(value) do
        result[key] = table.deepcopy(item)
    end
    return result
end

config = {seed = 2871}
-- The real mod RNG uses bit32; plain Lua 5.4 provides these operators instead.
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xffffffff end,
    lshift = function(a, b) return (a << b) & 0xffffffff end,
    rshift = function(a, b) return (a & 0xffffffff) >> b end,
}
local decoratives = require("randomizations/planetary/biome-decoratives")
local rng = require("lib/random/rng")

local checks = 0
local function check(condition, message)
    checks = checks + 1
    assert(condition, message)
end

local function equal(first, second)
    if type(first) ~= type(second) then
        return false
    end
    if type(first) ~= "table" then
        return first == second
    end
    for key, value in pairs(first) do
        if not equal(value, second[key]) then
            return false
        end
    end
    for key, _ in pairs(second) do
        if first[key] == nil then
            return false
        end
    end
    return true
end

local function decorative(name)
    return {
        type = "optimized-decorative",
        name = name,
        pictures = {{filename = name .. ".png"}},
        collision_box = {
            {
                -0.5,
                -0.5,
            },
            {
                0.5,
                0.5,
            },
        },
        autoplace = {
            probability_expression = "foreign_" .. name,
            placement_density = 7,
            tile_restriction = {"foreign-land"},
        },
    }
end

local function planet(name, names)
    local settings = {}
    for _, entry in pairs(names) do
        settings[entry] = {}
    end
    return {
        type = "planet",
        name = name,
        map_gen_settings = {
            autoplace_settings = {
                decorative = {
                    treat_missing_as_default = false,
                    settings = settings,
                },
            },
        },
    }
end

local raw = {}
raw.planet = {}
raw["optimized-decorative"] = {}
raw["noise-expression"] = {}
local decorative_names = {
    "fern",
    "lichen",
    "silt",
    "puddle",
    "disabled-leaf",
}
for _, name in pairs(decorative_names) do
    raw["optimized-decorative"][name] = decorative(name)
end
local host_palette = {
    "silt",
    "puddle",
}
local donor_palette = {
    "fern",
    "lichen",
    "disabled-leaf",
}
raw.planet.home = planet("home", host_palette)
raw.planet.marsh = planet("marsh", donor_palette)
raw.planet.marsh.map_gen_settings.autoplace_settings.decorative.settings["disabled-leaf"].frequency = 0
raw.planet.secret = planet("secret", {"lichen"})
raw.planet.secret.hidden = true
raw.planet["marsh-copy"] = planet("marsh-copy", {"fern"})
raw.planet["marsh-copy"].orig_name = "marsh"
raw.planet.target = planet("target", host_palette)
raw.planet.target.map_gen_settings.property_expression_names = {}
raw.planet.target.map_gen_settings.property_expression_names["decorative:puddle:probability"] = "host-puddle-expression"
raw["optimized-decorative"].silt.autoplace.local_expressions = {local_patch = "host_moisture"}
raw["optimized-decorative"].silt.autoplace.local_functions = {
    f = {
        parameters = {"a"},
        expression = "a + local_patch",
    },
}
raw["optimized-decorative"].silt.autoplace.probability_expression = "f(0.1)"

local original_prototypes = table.deepcopy(raw["optimized-decorative"])
local original_home = table.deepcopy(raw.planet.home)
local snapshot = decoratives.capture(raw)
check(#snapshot.marsh == 2, "Disabled decorative entered the palette")
check(snapshot.secret == nil and snapshot["marsh-copy"] == nil, "Hidden or duplicate planet became a donor")
check(snapshot.marsh[1] ~= raw["optimized-decorative"].fern, "Palette aliases source prototypes")

local regions = {
    {
        source = "marsh",
        index = 2,
        selector = "test_region_selector",
        tiles = {"host-mixed-land"},
    },
}
local before_no_mask = table.deepcopy(raw)
local skipped = decoratives.apply(raw, raw.planet.target, regions, {snapshot = snapshot})
check(next(skipped) == nil, "Missing land mask should skip placement")
check(equal(raw, before_no_mask), "Missing land mask changed prototypes")

local function apply()
    return decoratives.apply(raw, raw.planet.target, regions, {
        snapshot = snapshot,
        land_mask = "test_host_land_mask",
    })
end
local before_apply = table.deepcopy(raw)
local clones, clone_regions = apply()
local count = 0
for name, donor in pairs(clones) do
    count = count + 1
    local prototype = raw["optimized-decorative"][name]
    local autoplace = prototype.autoplace
    check(autoplace.default_enabled == false, "Clone could become enabled off-target")
    check(raw.planet.target.map_gen_settings.autoplace_settings.decorative.settings[name] ~= nil, "Clone is not enabled on its target")
    check(autoplace.tile_restriction[1] == "host-mixed-land", "Clone lacks destination tile restriction")
    check(clone_regions[name] == 2, "Clone region is missing from runtime diagnostics")
    check(string.find(autoplace.probability_expression, "test_region_selector == 2", 1, true) ~= nil, "Clone lost its shared region selector")
    check(string.find(autoplace.probability_expression, "foreign", 1, true) == nil, "Donor noise graph leaked into placement")
    check(equal(prototype.pictures, original_prototypes[donor].pictures), "Decorative appearance changed")
end
check(count == 2, "Unexpected number of clones")
for name, prototype in pairs(original_prototypes) do
    check(equal(prototype, raw["optimized-decorative"][name]), "Original decorative changed: " .. name)
end
check(equal(raw.planet.home, original_home), "Unselected planet changed")

local overrides = raw.planet.target.map_gen_settings.property_expression_names
local silt_mask = raw["noise-expression"][overrides["decorative:silt:probability"]]
local silt_source = raw["noise-expression"][string.gsub(silt_mask.name, "_masked$", "")]
check(equal(silt_source.local_expressions, original_prototypes.silt.autoplace.local_expressions), "Host local expressions were lost")
check(equal(silt_source.local_functions, original_prototypes.silt.autoplace.local_functions), "Host local functions were lost")
check(silt_source.expression == "f(0.1)", "Original host expression changed")
check(silt_source.local_expressions ~= raw["optimized-decorative"].silt.autoplace.local_expressions, "Host local expressions were aliased")
check(string.find(silt_mask.expression, "if(test_host_land_mask, 0, ", 1, true) == 1, "Host decoratives not masked only on changed land")
check(string.find(silt_mask.expression, silt_mask.name, 1, true) == nil, "Host mask is recursive")
local puddle_mask = raw["noise-expression"][overrides["decorative:puddle:probability"]]
local puddle_source = raw["noise-expression"][string.gsub(puddle_mask.name, "_masked$", "")]
check(puddle_source.expression == "var(\"host-puddle-expression\")", "Existing override was lost or a hyphenated name was parsed as subtraction")
check(puddle_source.local_expressions == nil, "Existing override inherited an unrelated local scope")

local first_result = table.deepcopy(raw)
raw = before_apply
rng.prgs = {}
apply()
check(equal(raw, first_result), "Same seed and input did not reproduce the placement")

local boolean_values = {
    false,
    true,
}
for i, value in pairs(boolean_values) do
    local target = planet("boolean-override-" .. i, {"silt"})
    target.map_gen_settings.property_expression_names = {}
    target.map_gen_settings.property_expression_names["decorative:silt:probability"] = value
    decoratives.apply(raw, target, regions, {
        snapshot = snapshot,
        land_mask = "test_host_land_mask",
    })
    local mask_name = target.map_gen_settings.property_expression_names["decorative:silt:probability"]
    local source = raw["noise-expression"][string.gsub(mask_name, "_masked$", "")]
    check(source.expression == value, "Boolean probability override was turned into an expression name")
end

print("biome-decoratives: " .. checks .. " checks passed")

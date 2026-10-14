local rng = require("src/lib/random/rng")
local randnum = require("src/lib/random/randnum")
local exclusions = require("src/config/prototype-exclusions")
local locale_utils = require("src/localisation/locale")

local function benefit(effect, value)
    if effect == "consumption" or effect == "pollution" then return value < 0 end
    return value > 0
end


local function has_benefit(module)
    for effect, value in pairs(module.effect) do
        if benefit(effect, value) then return true end
    end
    return false
end

local function trade(a, b, bundle)
    for _, effect in pairs(bundle) do
        local multiplier = effect .. "_quality_multiplier"
        a.effect[effect], b.effect[effect] = b.effect[effect], a.effect[effect]
        a[multiplier], b[multiplier] = b[multiplier], a[multiplier]
    end
end

randomizations.module_effects = function(id)
    local modules = {}
    local seen = {}
    for _, module in pairs(data.raw.module or {}) do
        if not exclusions.excluded(id, "numerical", module) then
            -- Detach aliases before editing so excluded modules stay unchanged.
            module.effect = table.deepcopy(module.effect)
            table.insert(modules, module)
            for effect, _ in pairs(module.effect) do seen[effect] = true end
        end
    end
    table.sort(modules, function(a, b) return a.name < b.name end)
    local effect_names = {}
    for effect, _ in pairs(seen) do table.insert(effect_names, effect) end
    table.sort(effect_names)

    local key = rng.key({ id = id })
    -- Same-effect trades preserve the pool of values, including every positive productivity entry.
    -- Atomic bundles let two modules exchange their only benefits without becoming empty halfway through.
    if #modules > 1 then
        for _ = 1, 4 do
            rng.shuffle(key, modules)
            for _, a in pairs(modules) do
                for _, effect in pairs(effect_names) do
                    local b = modules[rng.int(key, #modules)]
                    if a ~= b and a.effect[effect] ~= b.effect[effect] then
                        local bundle = {}
                        for _, field in pairs(effect_names) do
                            if field == effect or rng.value(key) < 0.5 then table.insert(bundle, field) end
                        end
                        trade(a, b, bundle)
                        if not has_benefit(a) or not has_benefit(b) then trade(a, b, bundle) end
                    end
                end
            end
        end
    end

    -- Preserve signs and keep nonzero entries above the documented four-decimal cutoff (EffectValue, installed 2.1 docs).
    for _, module in pairs(modules) do
        for _, effect in pairs(effect_names) do
            local value = module.effect[effect]
            if value ~= nil and value ~= 0 then
                local sign = value < 0 and -1 or 1
                local magnitude = randnum.rand({
                    id = id,
                    prototype = module,
                    dummy = math.abs(value),
                    variance = "medium",
                    rounding = "none",
                    dir = benefit(effect, value) and 1 or -1,
                    abs_min = 0.0001,
                    abs_max = 1000,
                    data_type = "effect_value",
                })
                module.effect[effect] = sign * math.min(1000, math.max(0.0001, math.floor(magnitude * 10000) / 10000))
            end
        end
        module.localised_description = {
            "",
            locale_utils.find_localised_description(module),
            { "propertyrandomizer-status.reconfigured-red" },
        }
    end
end

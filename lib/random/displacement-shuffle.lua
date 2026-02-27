local fleish = require("lib/random/fleishman")

local export = {}

---O(n log(n)) Shuffles a list of elements such that each element's new index has a controllable average distance to its old index
---@param rng_key string
---@param array table
---@param avg_displacement number The average distance between old index and new index per element
export.displacement_shuffle_chaos = function (rng_key, array, avg_displacement)
    local ordinals = {}
    for i, element in pairs(array) do
        local displacement = fleish.randomize(rng_key, 0, avg_displacement, 2, config.chaos)
        ordinals[element] = i + displacement
    end
    table.sort(array, function (a, b)
        return ordinals[a] < ordinals[b]
    end)
end

return export
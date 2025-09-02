-- Intended to replicate Factorio's deterministic pairs behavior when run outside factorio

do
    local _raw_pairs = pairs

    -- Stable key comparator:
    -- 1) numbers < strings < booleans < others
    -- 2) numbers: numeric order
    -- 3) strings: lexicographic order
    -- 4) booleans: false < true
    -- 5) other/mixed: fallback to type(name) then tostring(value)
    local type_rank = { number = 1, string = 2, boolean = 3 }
    local function keycmp(a, b)
        local ta, tb = type(a), type(b)
        local ra, rb = type_rank[ta] or 99, type_rank[tb] or 99
        if ra ~= rb then return ra < rb end
        if ta == "number" then return a < b end
        if ta == "string" then return a < b end
        if ta == "boolean" then return (a and 1 or 0) < (b and 1 or 0) end
        -- Fallback: stable but arbitrary
        if ta ~= tb then return ta < tb end
        return tostring(a) < tostring(b)
    end

    local function ordered_pairs_impl(t)
        -- Allow a custom key order via metatable field `__orderedkeys` (optional)
        local mt = getmetatable(t)
        local ok = mt and rawget(mt, "__orderedkeys")

        local keys
        if type(ok) == "function" then
            keys = ok(t)  -- must return an array of keys
        else
            keys = {}
            for k in _raw_pairs(t) do
                keys[#keys+1] = k
            end
            table.sort(keys, keycmp)
        end

        local i = 0
        local function iter(_, _)
            i = i + 1
            local k = keys[i]
            if k ~= nil then
                return k, t[k]
            end
        end
        return iter, t, nil
    end

    -- Override global `pairs` with deterministic version.
    -- For the original, use `_raw_pairs`.
    function _G.pairs(t)
        -- If a table provides its own __pairs (Lua 5.2 style), respect it.
        local mt = getmetatable(t)
        local __pairs = mt and rawget(mt, "__pairs")
        if type(__pairs) == "function" then
            return __pairs(t)
        end
        return ordered_pairs_impl(t)
    end
end
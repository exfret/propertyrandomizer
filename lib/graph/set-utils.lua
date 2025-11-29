local set_utils = {}

set_utils.universal_set_key = "U"

-- O(from_n) Modifies 1st argument to also include elements from 2nd argument
set_utils.merge_union = function (to, from)
    if to[set_utils.universal_set_key] then
        return
    end
    if from[set_utils.universal_set_key] then
        set_utils.merge_difference(to, to)
        to[set_utils.universal_set_key] = true
        return
    end
    for key, _ in pairs(from) do
        to[key] = true
    end
end

-- O(to_n) Modifies 1st argument to only include elements also in 2nd argument
set_utils.merge_intersection = function (to, from)
    if from[set_utils.universal_set_key] then
        return
    end
    if to[set_utils.universal_set_key] then
        to[set_utils.universal_set_key] = nil
        set_utils.merge_union(to, from)
        return
    end
    for key, _ in pairs(to) do
        to[key] = from[key]
    end
end

-- O(to_n) Modifies 1st argument to only include elements in 2nd argument. Slower, but returns true if a change was made.
set_utils.merge_intersection_check = function (to, from)
    if from[set_utils.universal_set_key] then
        return false
    end
    if to[set_utils.universal_set_key] then
        to[set_utils.universal_set_key] = nil
        set_utils.merge_union(to, from)
        return true
    end
    local changed = false
    for key, _ in pairs(to) do
        local from_val = from[key]
        if from_val == nil then
            changed = true
        end
        to[key] = from_val
    end
    return changed
end

-- O(set1_n) Returns true if any element is in both set1 and set2
set_utils.intersects = function (set1, set2)
    for key, _ in pairs(set1) do
        if set2[key] then
            return true
        end
    end
    return false
end

-- O(subtrahend_n) Modifies minuend to not contain elements in subtrahend
set_utils.merge_difference = function (minuend, subtrahend)
    assert(not minuend[set_utils.universal_set_key])
    if subtrahend[set_utils.universal_set_key] then
        for key, _ in pairs(minuend) do
            minuend[key] = nil
        end
    end
    for key, _ in pairs(subtrahend) do
        minuend[key] = nil
    end
end

-- O(1) Symbolizes the set containing all elements
set_utils.create_universal_set = function ()
    return { [set_utils.universal_set_key] = true }
end

set_utils.is_universal_set = function (set)
    return set[set_utils.universal_set_key] ~= nil
end

-- O(1) Returns true if the set contains no elements
set_utils.set_empty = function (set)
    return next(set) == nil
end

-- O(n) Returns number of elements in set
set_utils.count = function (set)
    local count = 0
    for _ in pairs(set) do count = count + 1 end
    return count
end

return set_utils
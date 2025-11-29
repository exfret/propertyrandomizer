local rng = require("lib/random/rng")

-- Queue functions with epic constant time operations
local queue_export = {}

-- O(1)
queue_export.new_queue = function ()
    return {
        list = {},
        front = 1,
        back = 1,
    }
end

-- O(1)
queue_export.push = function (queue, item)
    queue.list[queue.back] = item
    queue.back = queue.back + 1
end

-- O(1)
queue_export.pop = function (queue)
    assert(queue.back > queue.front)
    local item = queue.list[queue.front]
    queue.list[queue.front] = nil
    queue.front = queue.front + 1
    return item
end

-- O(1)
queue_export.is_empty = function (queue)
    return queue.back <= queue.front
end

local swap = function (list, idx1, idx2)
    local t = list[idx1]
    list[idx1] = list[idx2]
    list[idx2] = t
end

-- O(1) Swaps a random item with the front item and pops it.
queue_export.pop_random = function (queue, rng_key)
    local swap_idx = rng.range(rng_key, queue.front, queue.back - 1)
    swap(queue.list, queue.front, swap_idx)
    return queue_export.pop(queue)
end

return queue_export
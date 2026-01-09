local rng = require("lib/random/rng")

-- Queue functions with epic constant time operations
local queue_export = {}

-- O(1)
queue_export.new = function ()
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

-- O(n) - removes all elements where filter(element) returns true
queue_export.remove = function (queue, filter)
    local new_list = {}
    local new_back = 1

    for i = queue.front, queue.back - 1 do
        if queue.list[i] ~= nil then
            local item = queue.list[i]
            if not filter(item) then
                new_list[new_back] = item
                new_back = new_back + 1
            end
        end
    end

    queue.list = new_list
    queue.front = 1
    queue.back = new_back
end

return queue_export
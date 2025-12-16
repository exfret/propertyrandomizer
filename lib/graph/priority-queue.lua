local priority_queue = {}

-- Creates a new priority queue
-- priority_fn: function(element) -> number, used to determine priority.
-- Lower numbers = higher priority (popped first)
function priority_queue.new(priority_fn)
    local pq = {
        heap = {},
        priority_fn = priority_fn,
        size = 0
    }
    return pq
end

-- Internal: bubble element up the heap to maintain heap property
local function bubble_up(heap, priority_fn, idx)
    while idx > 1 do
        local parent_idx = math.floor(idx / 2)
        local parent_priority = priority_fn(heap[parent_idx])
        local current_priority = priority_fn(heap[idx])

        if current_priority < parent_priority then
            heap[idx], heap[parent_idx] = heap[parent_idx], heap[idx]
            idx = parent_idx
        else
            break
        end
    end
end

-- Internal: bubble element down the heap to maintain heap property
local function bubble_down(heap, priority_fn, idx, size)
    while true do
        local left_child = idx * 2
        local right_child = idx * 2 + 1
        local highest_idx = idx

        if left_child <= size and priority_fn(heap[left_child]) < priority_fn(heap[highest_idx]) then
            highest_idx = left_child
        end

        if right_child <= size and priority_fn(heap[right_child]) < priority_fn(heap[highest_idx]) then
            highest_idx = right_child
        end

        if highest_idx ~= idx then
            heap[idx], heap[highest_idx] = heap[highest_idx], heap[idx]
            idx = highest_idx
        else
            break
        end
    end
end

-- Push an element onto the priority queue
function priority_queue.push(pq, element)
    pq.size = pq.size + 1
    pq.heap[pq.size] = element
    bubble_up(pq.heap, pq.priority_fn, pq.size)
end

-- Pop the highest priority element from the queue
-- Returns nil if queue is empty
function priority_queue.pop(pq)
    local root = pq.heap[1]

    if pq.size == 1 then
        pq.heap[1] = nil
        pq.size = 0
    else
        pq.heap[1] = pq.heap[pq.size]
        pq.heap[pq.size] = nil
        pq.size = pq.size - 1
        bubble_down(pq.heap, pq.priority_fn, 1, pq.size)
    end

    return root
end

-- Check if queue is empty
function priority_queue.is_empty(pq)
    return pq.size == 0
end

return priority_queue

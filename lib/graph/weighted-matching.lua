-- Minimum-cost perfect bipartite matching, using shortest augmenting paths with potentials.
-- Rows and columns are indexed 1..n; a missing cost forbids that edge.
-- Returns column -> row, or nil when no perfect matching exists. Caller ordering breaks ties deterministically.
local matching = {}

matching.solve = function(costs, n)
    local row_potential = {}
    local column_potential = { [0] = 0 }
    local matched = {}
    for i = 1, n do
        row_potential[i] = 0
        column_potential[i] = 0
        matched[i] = 0
    end
    for row = 1, n do
        matched[0] = row
        local column = 0
        local distance = {}
        local previous = {}
        local visited = {}
        repeat
            visited[column] = true
            local source = matched[column]
            local delta = math.huge
            local next_column
            for target = 1, n do
                if visited[target] == nil then
                    local cost = costs[source][target]
                    if cost ~= nil then
                        local reduced = cost - row_potential[source] - column_potential[target]
                        if distance[target] == nil or reduced < distance[target] then
                            distance[target] = reduced
                            previous[target] = column
                        end
                    end
                    if distance[target] ~= nil and distance[target] < delta then
                        delta = distance[target]
                        next_column = target
                    end
                end
            end
            if next_column == nil then
                return nil
            end
            for target = 0, n do
                if visited[target] ~= nil then
                    row_potential[matched[target]] = row_potential[matched[target]] + delta
                    column_potential[target] = column_potential[target] - delta
                elseif distance[target] ~= nil then
                    distance[target] = distance[target] - delta
                end
            end
            column = next_column
        until matched[column] == 0
        repeat
            local parent = previous[column]
            matched[column] = matched[parent]
            column = parent
        until column == 0
    end
    matched[0] = nil
    return matched
end

return matching

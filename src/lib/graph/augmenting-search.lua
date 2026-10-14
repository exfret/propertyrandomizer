-- Incremental matching for callers that start with occupied slots. Proposals use
-- the same Kuhn search as monotone matching, then validate the whole rewire once.
local bipartite = require("src/lib/graph/bipartite-matching")
local refinement = require("src/lib/graph/matching-refinement")

local search = {}

search.new = function(params)
    local assigned, occupants = {}, {}
    for _, head in pairs(params.heads) do
        local base = params.initial(head)
        assigned[head] = base
        if base ~= params.detached then
            assert(occupants[base] == nil, "Duplicate initial base")
            occupants[base] = head
        end
    end
    local state = {assigned = assigned}
    state.try = function(root)
        local freed = assigned[root]
        if params.begin ~= nil then params.begin(root, freed) end
        -- Kuhn visits each occupied slot (and hence its head) once per proposal.
        -- Each edge predicate is already evaluated at most once; a second
        -- per-proposal memo table only adds lookups and allocations.
        local path, _, stats = refinement.run({
            max_refinements = 10,
            propose = function()
                return bipartite.find_path({
                    head = root,
                    occupants = occupants,
                    candidates = function(head)
                        local list = params.candidates(head)
                        if head ~= root and params.can_detach(head) then
                            local with_detachment = {}
                            for _, base in pairs(list) do table.insert(with_detachment, base) end
                            table.insert(with_detachment, params.detached)
                            list = with_detachment
                        end
                        return list
                    end,
                    allowed = function(head, base)
                        return base == params.detached or (head == root and base == freed) or params.allowed(head, base)
                    end,
                    can_end = function(base)
                        return base == freed or params.can_end == nil or params.can_end(base, freed)
                    end,
                })
            end,
            validate = function(proposal)
                -- Keeping the current slot is an ordinary shuffled choice.
                if #proposal == 1 and proposal[1].base == freed then return true end
                return params.commit(proposal)
            end,
            refine = function(proposal, failure)
                return params.refine ~= nil and params.refine(proposal, failure) or 0
            end,
        })
        if not stats.accepted then return false, stats end
        -- Clear old occupants first: a path may close on the root's old base.
        for _, move in pairs(path) do
            local old = assigned[move.head]
            if old ~= params.detached then occupants[old] = nil end
        end
        for _, move in pairs(path) do
            assigned[move.head] = move.base
            if move.base ~= params.detached then occupants[move.base] = move.head end
        end
        return true, stats
    end
    return state
end

return search

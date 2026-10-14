-- Which planet discoveries each technology follows in the tree as it stands (src/prototypes/duplicates/dupe.lua re-exports these)
-- Nothing here requires another module, so unified randomization can load it without the rest of the duplicates (src/randomizations/unified/execute.lua), and plain Lua can test it

local branches = {}

-- Branches of the technology tree, for keeping a planet copy to its own things (user, 2026-10-08: "What shouldn't happen is reliance on another planet's things just because it's the same dupe number")
-- A technology's branch is the set of the latest discovery technologies it follows (those that no other discovery it follows comes after), and empty for the starting planet's own technologies, which follow none
-- The needs argument is a prerequisite closure (technology name --> set of every technology it needs), and the result a function technology name --> its branch
branches.branch_finder = function(needs)
    local function is_discovery(name)
        for _, effect in pairs(((data.raw.technology or {})[name] or {}).effects or {}) do
            if effect.type == "unlock-space-location" then
                return true
            end
        end
        return false
    end
    local branches = {}
    return function(tech_name)
        if branches[tech_name] == nil then
            local followed = {}
            for name, _ in pairs(needs(tech_name)) do
                if is_discovery(name) then
                    followed[name] = true
                end
            end
            if is_discovery(tech_name) then
                followed[tech_name] = true
            end
            local latest = {}
            for name, _ in pairs(followed) do
                local is_latest = true
                for other, _ in pairs(followed) do
                    if other ~= name and needs(other)[name] ~= nil then
                        is_latest = false
                    end
                end
                if is_latest then
                    latest[name] = true
                end
            end
            branches[tech_name] = latest
        end
        return branches[tech_name]
    end
end

-- The discoveries each planet copy's technology follows in the tree as it stands (its branch, branches.branch_finder), as technology name --> sorted list of discovery names, for the copies (a dupe_number) that aren't discoveries themselves
-- Unified randomization keeps these as their prerequisites when it clears the rest (src/randomizations/unified/execute.lua), so that it never makes something early need a copied item, and the tech tree rebuild keeps the copy behind its planet copy's discovery (user, 2026-10-12: "the duplicated items belong to the duplicated planets, not to nauvis")
branches.copy_gates = function(technologies)
    local closures = {}
    local function needs(tech_name)
        if closures[tech_name] == nil then
            local found = {}
            -- Stored first, so a prerequisite cycle ends here
            closures[tech_name] = found
            for _, prereq in pairs((technologies[tech_name] or {}).prerequisites or {}) do
                found[prereq] = true
                for further, _ in pairs(needs(prereq)) do
                    found[further] = true
                end
            end
        end
        return closures[tech_name]
    end
    local branch_of = branches.branch_finder(needs)
    local gates = {}
    for tech_name, tech in pairs(technologies) do
        if type(tech.dupe_number) == "number" then
            local names = {}
            local branch = branch_of(tech_name)
            if branch[tech_name] == nil then
                for name, _ in pairs(branch) do
                    table.insert(names, name)
                end
            end
            if #names > 0 then
                table.sort(names)
                gates[tech_name] = names
            end
        end
    end
    return gates
end

-- Whether something on branch inner belongs on branch outer (both from branches.branch_finder): on the starting planet's branch only what's also on it does, and otherwise what's on one or more of outer's own branches
branches.on_branch = function(inner, outer)
    if next(outer) == nil then
        return next(inner) == nil
    end
    if next(inner) == nil then
        return false
    end
    for name, _ in pairs(inner) do
        if outer[name] == nil then
            return false
        end
    end
    return true
end

return branches

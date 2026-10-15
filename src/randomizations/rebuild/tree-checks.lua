-- Checks of a rebuilt tech tree against the user's rules for it (randomizations.rebuild_tech_tree in src/randomizations/rebuild/init.lua, user 2026-10-12)
-- Each rule reads only the finished tree and a few facts about the game, so the rebuild logs them as REBUILDCHECK lines and dev/run-tests.py fails a run that breaks one
-- Nothing here reads data.raw or requires another module, so plain Lua can run it on fixtures and on a dumped game (tests/unit/randomizations/rebuild/test-tree-checks.lua)
-- tree_checks.run takes these facts as one table
--   * technologies and recipes are data.raw.technology and data.raw.recipe as the rebuild left them
--   * rooms_of(recipe name) is the set of rooms (logic room keys) where the recipe could be made before the rebuild, or nil
--   * discoverers is room key --> set of the names of the techs discovering it, for the rooms that need discovering (the starting planet doesn't)
--   * copy_number(room key) is a planet copy's dupe number, and 1 for every other room (src/prototypes/surfaces/surface-sets.lua)
--   * labs is a list of the labs' input sets (pack name --> true)
--   * reasons (optional) is tech name --> prerequisite name --> why the rebuild gave it, for the techs the rebuild placed

local tree_checks = {}

-- How many examples each rule's log line names
tree_checks.MAX_EXAMPLES = 5

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function visible(tech)
    return tech ~= nil and tech.hidden ~= true
end

-- The packs a tech's unit takes, as a set, or nil for a tech researched otherwise
local function packs_of(tech)
    if tech == nil or tech.unit == nil then
        return nil
    end
    local packs = {}
    for _, ingredient in pairs(tech.unit.ingredients or {}) do
        packs[ingredient[1] or ingredient.name] = true
    end
    return packs
end

-- A tech's research as one comparable string: its unit (count, time, packs and amounts) or its trigger
tree_checks.research_key = function(tech)
    if tech.unit ~= nil then
        local ingredients = {}
        for _, ingredient in pairs(tech.unit.ingredients or {}) do
            table.insert(ingredients, tostring(ingredient[1] or ingredient.name) .. "x" .. tostring(ingredient[2] or ingredient.amount))
        end
        table.sort(ingredients)
        return "unit " .. tostring(tech.unit.count or tech.unit.count_formula) .. "/" .. tostring(tech.unit.time) .. " [" .. table.concat(ingredients, ",") .. "]"
    end
    if tech.research_trigger ~= nil then
        local trigger = tech.research_trigger
        local fields = {}
        for _, field in pairs(sorted_keys(trigger)) do
            local value = trigger[field]
            if type(value) == "table" then
                local listed = {}
                for _, entry in pairs(value) do
                    table.insert(listed, tostring(entry))
                end
                table.sort(listed)
                value = "{" .. table.concat(listed, ",") .. "}"
            end
            table.insert(fields, field .. "=" .. tostring(value))
        end
        return "trigger " .. table.concat(fields, ",")
    end
    return "none"
end

-- Whether every room of a set needs discovering (an empty set doesn't)
local function all_gated(rooms, discoverers)
    if rooms == nil or next(rooms) == nil then
        return false
    end
    for room, _ in pairs(rooms) do
        if discoverers[room] == nil then
            return false
        end
    end
    return true
end

-- Runs every rule on the facts (see the top of this file)
-- Returns a list of { name, violations = list of strings, info = whether it only informs }
tree_checks.run = function(facts)
    local technologies = facts.technologies
    local recipes = facts.recipes
    local discoverers = facts.discoverers or {}
    local is_discoverer = {}
    for _, names in pairs(discoverers) do
        for name, _ in pairs(names) do
            is_discoverer[name] = true
        end
    end
    local tech_names = sorted_keys(technologies)

    -- Recipe name --> the visible techs unlocking it, sorted
    local unlockers = {}
    for _, tech_name in pairs(tech_names) do
        local tech = technologies[tech_name]
        if visible(tech) then
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" then
                    unlockers[effect.recipe] = unlockers[effect.recipe] or {}
                    local listed = false
                    for _, other in pairs(unlockers[effect.recipe]) do
                        listed = listed or other == tech_name
                    end
                    if not listed then
                        table.insert(unlockers[effect.recipe], tech_name)
                    end
                end
            end
        end
    end

    -- The discoveries a tech needs through prerequisites, itself included, as a set (memoized; a cycle, which the cycles rule reports, ends where it closes)
    local discoveries_memo = {}
    local function discoveries_needed(tech_name)
        local known = discoveries_memo[tech_name]
        if known ~= nil then
            return known
        end
        local found = {}
        discoveries_memo[tech_name] = found
        if is_discoverer[tech_name] then
            found[tech_name] = true
        end
        for _, prereq in pairs((technologies[tech_name] or {}).prerequisites or {}) do
            for name, _ in pairs(discoveries_needed(prereq)) do
                found[name] = true
            end
        end
        return found
    end
    -- Every tech a tech needs through prerequisites, not itself, as a set (only for the few techs a rule compares, so not memoized)
    local function closure(tech_name)
        local found = {}
        local pending = {}
        for _, prereq in pairs((technologies[tech_name] or {}).prerequisites or {}) do
            table.insert(pending, prereq)
        end
        while #pending > 0 do
            local current = table.remove(pending)
            if found[current] == nil then
                found[current] = true
                for _, prereq in pairs((technologies[current] or {}).prerequisites or {}) do
                    table.insert(pending, prereq)
                end
            end
        end
        return found
    end
    local function needs_any(tech_name, names)
        for name, _ in pairs(discoveries_needed(tech_name)) do
            if names[name] ~= nil then
                return true
            end
        end
        return false
    end

    local results = {}
    local function add(name, violations, info)
        table.insert(results, {
            name = name,
            violations = violations,
            info = info == true,
        })
    end

    -- gates: a tech unlocking a recipe made only on planets needing discovery needs the discovery of one of them (user's issue 1)
    local gates = {}
    for _, tech_name in pairs(tech_names) do
        local tech = technologies[tech_name]
        if visible(tech) then
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" then
                    local rooms = facts.rooms_of(effect.recipe)
                    if all_gated(rooms, discoverers) then
                        local wanted = {}
                        for room, _ in pairs(rooms) do
                            for name, _ in pairs(discoverers[room]) do
                                wanted[name] = true
                            end
                        end
                        if not needs_any(tech_name, wanted) then
                            table.insert(gates, tech_name .. " unlocks " .. effect.recipe .. " (made only on " .. table.concat(sorted_keys(rooms), ", ") .. ") without their discovery")
                        end
                    end
                end
            end
        end
    end
    add("gates", gates)

    -- served: for a locked recipe made only on planets needing discovery, each of them has an unlock of it that makes the planet wait for no discovery its own discovery doesn't need (user's issue 3)
    -- Nor one the recipe's other inputs there can't be had without, where facts.inherent_discoveries says (recipe name, room --> set of discovery names): the recipe needs those anyway (user: recipes "depend on all the unlocks they need")
    -- A recipe a room without discovery makes too (like the starting planet) is placed by what it needs there instead (user: noncritical recipes "depend on all the unlocks they need")
    local served = {}
    for _, recipe_name in pairs(sorted_keys(unlockers)) do
        local recipe = recipes[recipe_name]
        if recipe ~= nil and recipe.enabled == false and all_gated(facts.rooms_of(recipe_name), discoverers) then
            for _, room in pairs(sorted_keys(facts.rooms_of(recipe_name))) do
                if discoverers[room] ~= nil then
                    local allowed = {}
                    for discovery, _ in pairs(discoverers[room]) do
                        for name, _ in pairs(discoveries_needed(discovery)) do
                            allowed[name] = true
                        end
                    end
                    if facts.inherent_discoveries ~= nil then
                        for name, _ in pairs(facts.inherent_discoveries(recipe_name, room)) do
                            allowed[name] = true
                        end
                    end
                    local best
                    for _, tech_name in pairs(unlockers[recipe_name]) do
                        local extra = {}
                        for name, _ in pairs(discoveries_needed(tech_name)) do
                            if allowed[name] == nil then
                                table.insert(extra, name)
                            end
                        end
                        if best == nil or #extra < #best then
                            table.sort(extra)
                            best = extra
                        end
                    end
                    if best ~= nil and #best > 0 then
                        table.insert(served, recipe_name .. " on " .. room .. " waits for " .. table.concat(best, ", "))
                    end
                end
            end
        end
    end
    add("served", served)

    -- superfluous: no unlock of a recipe that another unlock of it makes pointless, by being one of its prerequisites, or by having the same research and only prerequisites it needs anyway (user's issue 2)
    local superfluous = {}
    for _, recipe_name in pairs(sorted_keys(unlockers)) do
        local list = unlockers[recipe_name]
        if #list > 1 then
            local closures = {}
            local keys = {}
            for _, tech_name in pairs(list) do
                closures[tech_name] = closure(tech_name)
                keys[tech_name] = tree_checks.research_key(technologies[tech_name])
            end
            -- Whether other is researchable whenever tech_name is: it's one tech_name needs, or another technology of the recipe's with the same research and only prerequisites tech_name needs anyway
            -- A discovery's research matching a recipe's technology's is happenstance, since the discovery opens a planet; it covers only a technology needing it
            local function covered_by(tech_name, other)
                if closures[tech_name][other] ~= nil then
                    return true
                end
                if keys[tech_name] ~= keys[other] or is_discoverer[tech_name] or is_discoverer[other] then
                    return false
                end
                for _, prereq in pairs(technologies[other].prerequisites or {}) do
                    if closures[tech_name][prereq] == nil then
                        return false
                    end
                end
                return true
            end
            for _, tech_name in pairs(list) do
                for _, other in pairs(list) do
                    -- Of two that cover each other, the first by name is kept
                    if other ~= tech_name and covered_by(tech_name, other) and not (covered_by(other, tech_name) and tech_name < other) then
                        table.insert(superfluous, recipe_name .. ": " .. tech_name .. " (covered by " .. other .. ")")
                        break
                    end
                end
            end
        end
    end
    add("superfluous", superfluous)

    -- start-enabled: no recipe made only on planets needing discovery is enabled from the start (user's second list, issue 4)
    local start_enabled = {}
    for _, recipe_name in pairs(sorted_keys(recipes)) do
        local recipe = recipes[recipe_name]
        if recipe.enabled ~= false and recipe.hidden ~= true and all_gated(facts.rooms_of(recipe_name), discoverers) then
            table.insert(start_enabled, recipe_name)
        end
    end
    add("start-enabled", start_enabled)

    -- justified: every prerequisite the rebuild gave has a reason (its gate, what the recipe or research needs, a planet's route or start), so none comes from elsewhere (user's issue 5)
    if facts.reasons ~= nil then
        local unjustified = {}
        for _, tech_name in pairs(sorted_keys(facts.reasons)) do
            local tech = technologies[tech_name]
            if visible(tech) then
                for _, prereq in pairs(tech.prerequisites or {}) do
                    if facts.reasons[tech_name][prereq] == nil then
                        table.insert(unjustified, tech_name .. " needs " .. prereq)
                    end
                end
            end
        end
        add("justified", unjustified)
    end

    -- science: a tech researched with packs takes the packs of every discovery it needs, where some lab takes them all ("Also consume later science", user 2026-10-12)
    local science = {}
    local no_lab = {}
    local function lab_takes(packs)
        for _, inputs in pairs(facts.labs or {}) do
            local takes = true
            for pack, _ in pairs(packs) do
                takes = takes and inputs[pack] ~= nil
            end
            if takes then
                return true
            end
        end
        return false
    end
    for _, tech_name in pairs(tech_names) do
        local tech = technologies[tech_name]
        local packs = packs_of(tech)
        if visible(tech) and packs ~= nil and tech.unit.count ~= nil and not is_discoverer[tech_name] then
            local missing = {}
            for discovery, _ in pairs(discoveries_needed(tech_name)) do
                for pack, _ in pairs(packs_of(technologies[discovery]) or {}) do
                    if packs[pack] == nil then
                        missing[pack] = true
                    end
                end
            end
            if next(missing) ~= nil then
                local all = {}
                for pack, _ in pairs(packs) do
                    all[pack] = true
                end
                for pack, _ in pairs(missing) do
                    all[pack] = true
                end
                local line = tech_name .. " lacks " .. table.concat(sorted_keys(missing), ", ")
                if lab_takes(all) then
                    table.insert(science, line)
                else
                    table.insert(no_lab, line)
                end
            end
        end
    end
    add("science", science)
    add("science-no-lab", no_lab, true)

    -- copies: a copied item's recipe (dupe number n) is unlocked after the discovery of a planet copy with its number, where there is one (user 2026-10-12: "the duplicated items belong to the duplicated planets, not to nauvis")
    -- A recipe that took in other planets' versions of it (merged_versions, src/prototypes/recipes/recipe-merges.lua) keeps the number of the version it was, but belongs to every planet it's made on (user, 2026-10-15)
    -- The discovery of a planet copy with any of their numbers will do then, and it needs none where one of them isn't a planet copy
    local copies = {}
    local copy_discoveries = {}
    for room, names in pairs(discoverers) do
        local number = facts.copy_number(room)
        if number > 1 then
            copy_discoveries[number] = copy_discoveries[number] or {}
            for name, _ in pairs(names) do
                copy_discoveries[number][name] = true
            end
        end
    end
    -- The numbers of the planet copies a copied item's recipe belongs to, as a set, or nil for a recipe that doesn't belong to planet copies only
    local function copy_numbers(recipe_name)
        local recipe = recipes[recipe_name] or {}
        local number = recipe.dupe_number
        if type(number) ~= "number" or number <= 1 then
            return nil
        end
        local numbers = {}
        if next(recipe.merged_versions or {}) ~= nil then
            for room, _ in pairs(facts.rooms_of(recipe_name) or {}) do
                local room_number = facts.copy_number(room)
                if room_number <= 1 then
                    return nil
                end
                numbers[room_number] = true
            end
        end
        if next(numbers) == nil then
            numbers[number] = true
        end
        return numbers
    end
    for _, recipe_name in pairs(sorted_keys(unlockers)) do
        local numbers = copy_numbers(recipe_name)
        local wanted = {}
        for number, _ in pairs(numbers or {}) do
            for name, _ in pairs(copy_discoveries[number] or {}) do
                wanted[name] = true
            end
        end
        if next(wanted) ~= nil then
            local label = table.concat(sorted_keys(numbers), " or ")
            for _, tech_name in pairs(unlockers[recipe_name]) do
                if not needs_any(tech_name, wanted) then
                    table.insert(copies, tech_name .. " unlocks " .. recipe_name .. " (copy " .. label .. ") before any copy " .. label .. " planet")
                end
            end
        end
    end
    add("copies", copies)

    -- cycles: every prerequisite exists and none leads back to its tech
    local cycles = {}
    local state = {}
    for _, tech_name in pairs(tech_names) do
        for _, prereq in pairs(technologies[tech_name].prerequisites or {}) do
            if technologies[prereq] == nil then
                table.insert(cycles, tech_name .. " needs missing " .. prereq)
            end
        end
    end
    for _, tech_name in pairs(tech_names) do
        if state[tech_name] == nil then
            state[tech_name] = 1
            local names = { tech_name }
            local positions = { 1 }
            while #names > 0 do
                local current = names[#names]
                local position = positions[#positions]
                local prereq = (technologies[current].prerequisites or {})[position]
                if prereq == nil then
                    state[current] = 2
                    names[#names] = nil
                    positions[#positions] = nil
                else
                    positions[#positions] = position + 1
                    if state[prereq] == 1 then
                        table.insert(cycles, current .. " needs " .. prereq .. ", which needs it")
                    elseif state[prereq] == nil and technologies[prereq] ~= nil then
                        state[prereq] = 1
                        table.insert(names, prereq)
                        table.insert(positions, 1)
                    end
                end
            end
        end
    end
    add("cycles", cycles)

    -- fan-out (information): the visible techs most others name as a prerequisite
    local fan = {}
    for _, tech_name in pairs(tech_names) do
        local tech = technologies[tech_name]
        if visible(tech) then
            for _, prereq in pairs(tech.prerequisites or {}) do
                fan[prereq] = (fan[prereq] or 0) + 1
            end
        end
    end
    local fan_names = sorted_keys(fan)
    table.sort(fan_names, function(a, b)
        if fan[a] ~= fan[b] then
            return fan[a] > fan[b]
        end
        return a < b
    end)
    local top_fan = {}
    for i = 1, math.min(tree_checks.MAX_EXAMPLES, #fan_names) do
        table.insert(top_fan, fan_names[i] .. " " .. fan[fan_names[i]])
    end
    add("fan-out", top_fan, true)

    return results
end

-- Writes a line per rule with its count and first examples, and a verdict line, through log_line; returns whether every rule that isn't only information passed
tree_checks.report = function(results, log_line)
    local failed = {}
    for _, result in pairs(results) do
        local examples = {}
        for i = 1, math.min(tree_checks.MAX_EXAMPLES, #result.violations) do
            table.insert(examples, result.violations[i])
        end
        if result.info == true then
            log_line("REBUILDCHECK " .. result.name .. " (information): " .. #result.violations .. (#examples > 0 and (" (" .. table.concat(examples, "; ") .. ")") or ""))
        else
            log_line("REBUILDCHECK " .. result.name .. ": " .. #result.violations .. (#examples > 0 and (" (e.g. " .. table.concat(examples, "; ") .. ")") or ""))
            if #result.violations > 0 then
                table.insert(failed, result.name .. " " .. #result.violations)
            end
        end
    end
    if #failed == 0 then
        log_line("REBUILDCHECK verdict: ok")
        return true
    end
    log_line("REBUILDCHECK verdict: FAILED (" .. table.concat(failed, ", ") .. ")")
    return false
end

return tree_checks

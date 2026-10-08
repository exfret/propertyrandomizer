-- Runs the real entity matcher on small wild-only graphs, with stand-ins for prototype lookup and promotion.
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-entity-autoplace.lua

table.deepcopy = function(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = table.deepcopy(entry)
    end
    return copy
end

local prototypes = {}
package.loaded["helper-tables/categories"] = {}
package.loaded["helper-tables/constants"] = {}
package.loaded["lib/graph-customization"] = {}
package.loaded["lib/logic/acquisition"] = {
    pairing = function() return {} end,
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name) return prototypes[name] end,
}
package.loaded["lib/graph/graph-utils"] = {
    key = function(node) return node.key end,
    prenode = function(graph, pre) return graph.nodes[pre] end,
    get_owner = function(graph, node) return graph.nodes[node.owner] end,
}
package.loaded["lib/locale"] = {}
package.loaded["lib/localised-text"] = {}
package.loaded["lib/random/rng"] = {
    key = function() return "fixture" end,
    shuffle = function(_, entries)
        for index = #entries, 2, -1 do
            local other = math.random(index)
            entries[index], entries[other] = entries[other], entries[index]
        end
    end,
}
package.loaded["lib/wild-entities"] = {}
package.loaded["randomizations/graph/unified/handler-helpers/entity"] = {
    fits_autoplace_of = function(prototype, other)
        return prototype.blocked ~= true and other.blocked ~= true
    end,
}
package.loaded["randomizations/graph/unified/handler-helpers/military"] = {}

local entity = require("randomizations/graph/unified/handlers/entity")

log = function() end

local function run(seed, blocked, reject, distinct_entries)
    math.randomseed(seed)
    prototypes = {}
    data = {raw = {}}
    data.raw.planet = {}
    lookups = {rooms = {}}
    randomization_info = {options = {first_pass = {blacklist = {}}}}
    local graph = {
        nodes = {},
        orand_to_parent = {},
    }
    local params = {
        random_graph = graph,
        sorted_deps = {},
        shuffled_prereqs = {},
        head_to_base = {},
    }
    params.promotion = {
        promised_contexts = function() return {} end,
        try_rewires = function() return reject ~= true end,
    }
    -- Two originals, each with a copy; test both shared entries and distinct entities on each copy.
    for index = 1, 4 do
        local family = index <= 2 and "fixture-original-a" or "fixture-original-b"
        local room = "fixture-room-" .. index
        local name = "fixture-entity-" .. index
        data.raw.planet[room] = {
            name = room,
            orig_name = family,
        }
        lookups.rooms[room] = {name = room}
        prototypes[name] = {
            name = name,
            type = "fixture-kind-" .. (distinct_entries == true and index % 2 or family),
            deconstruction_alternative = distinct_entries == true and name or family,
            blocked = blocked,
        }
        graph.nodes[room] = {
            name = room,
            type = "room-autoplace",
        }
        local parent_key = "parent-" .. index
        local dep_key = "dep-" .. index
        local head_key = "head-" .. index
        local base_key = "base-" .. index
        graph.nodes[parent_key] = {name = name}
        graph.nodes[dep_key] = {
            key = dep_key,
            pre = {[head_key] = true},
        }
        graph.orand_to_parent[dep_key] = parent_key
        graph.nodes[head_key] = {
            key = head_key,
            type = "head",
            acq_kind = "autoplace",
            old_base = base_key,
            owner = dep_key,
        }
        graph.nodes[base_key] = {
            key = base_key,
            type = "base",
            acq_kind = "autoplace",
            entity = name,
            owner = room,
        }
        table.insert(params.sorted_deps, dep_key)
        randomization_info.options.first_pass.blacklist[dep_key] = true
    end
    entity.initialize()
    assert(entity.custom_prereq_search(params))
    local used = {}
    for index = 1, 4 do
        local base_key = params.head_to_base["head-" .. index]
        assert(base_key ~= nil, "a wild slot was lost")
        assert(used[base_key] == nil, "two entities took one slot")
        used[base_key] = true
        if blocked == true or reject == true then
            assert(base_key == "base-" .. index, "a forbidden swap was committed")
        else
            local source = data.raw.planet["fixture-room-" .. index]
            local target = data.raw.planet[graph.nodes[base_key].owner]
            assert(source.orig_name ~= target.orig_name, "matching settled for another copy of the same original")
        end
    end
    return params.head_to_base
end

local outcomes = {}
for seed = 1, 50 do
    local first = run(seed)
    local second = run(seed)
    for head, base in pairs(first) do
        assert(second[head] == base, "the same seed changed its matching")
    end
    outcomes[first["head-1"]] = true
    run(seed, false, false, true)
    run(seed, true)
    run(seed, false, true)
end
local varied = 0
for outcome, _ in pairs(outcomes) do
    varied = varied + 1
end
assert(varied > 1, "different seeds always chose the same cross-planet matching")
print("Entity autoplace matching passed: 50 seeds, cross-original mixing with shared and distinct entries, unique slots, deterministic seeds, collision refusals and promotion refusals")

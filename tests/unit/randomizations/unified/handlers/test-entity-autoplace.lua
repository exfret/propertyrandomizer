-- Runs the real entity prerequisite search on small wild and trigger graphs, with stand-ins for prototype lookup and promotion.
-- Run from the mod root: lua tests/unit/randomizations/unified/handlers/test-entity-autoplace.lua

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
local category_roll
local fit_calls = 0
package.loaded["src/prototypes/categories"] = {}
package.loaded["src/config/constants"] = {}
package.loaded["src/config/graph-customization"] = {}
package.loaded["src/logic/builders/acquisition"] = {
    pairing = function() return {} end,
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name) return prototypes[name] end,
}
package.loaded["src/lib/graph/graph-utils"] = {
    key = function(node) return node.key end,
    prenode = function(graph, pre) return graph.nodes[pre] end,
    get_owner = function(graph, node) return graph.nodes[node.owner] end,
}
package.loaded["src/localisation/locale"] = {}
package.loaded["src/localisation/localised-text"] = {}
package.loaded["src/lib/random/rng"] = {
    key = function() return "fixture" end,
    value = function() return category_roll or math.random() end,
    shuffle = function(_, entries)
        for index = #entries, 2, -1 do
            local other = math.random(index)
            entries[index], entries[other] = entries[other], entries[index]
        end
    end,
}
package.loaded["src/prototypes/entities/wild-entities"] = {}
package.loaded["src/randomizations/unified/handler-helpers/entity"] = {
    tile_layers = function() return {} end,
    fits_autoplace_of = function(prototype, other)
        fit_calls = fit_calls + 1
        return prototype.blocked ~= true and other.blocked ~= true
    end,
}
package.loaded["src/randomizations/unified/handler-helpers/military"] = {}

local entity = require("src/randomizations/unified/handlers/entity")
local context_costs = require("src/cost/context-costs")

log = function() end

local function run(seed, blocked, reject, distinct_entries, roll, mixed, reject_first, forbid_after_commit)
    fit_calls = 0
    category_roll = roll
    math.randomseed(seed)
    prototypes = {}
    data = {raw = {}}
    data.raw.planet = {}
    lookups = {rooms = {}, buildables = {}}
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
    local attempts = 0
    params.promotion = {
        cache_rewires = function() end,
        -- These fixtures assert every head survives, so give each a promised context.
        promised_contexts = function() return {"fixture-context"} end,
        head_candidate_ok = function() return not forbid_after_commit or attempts == 0 end,
        try_rewires = function(changes)
            local seen = {}
            for _, change in pairs(changes) do
                assert(seen[change.node_key] == nil, "augmenting path revisited a head")
                seen[change.node_key] = true
            end
            attempts = attempts + 1
            return reject ~= true and not (reject_first and attempts == 1)
        end,
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
            type = mixed and (index % 2 == 0 and "item-ammo" or "item-capsule") or "room-autoplace",
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
            acq_kind = mixed and (index % 2 == 0 and "ammo" or "capsule") or "autoplace",
            old_base = base_key,
            owner = dep_key,
        }
        graph.nodes[base_key] = {
            key = base_key,
            type = "base",
            acq_kind = mixed and (index % 2 == 0 and "ammo" or "capsule") or "autoplace",
            entity = name,
            old_head = head_key,
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
            -- A normal shuffle may keep the original category, planet, or entity.
            assert(target ~= nil and source ~= nil)
        end
    end
    if mixed and roll == 0 then
        for head_key, base_key in pairs(params.head_to_base) do
            assert(graph.nodes[head_key].acq_kind == graph.nodes[base_key].acq_kind, "same-category search crossed categories")
        end
    end
    assert(fit_calls <= 16, "static geometry was recomputed for a head/base pair")
    return params.head_to_base, attempts
end

local outcomes = {}
for seed = 1, 50 do
    local _, attempts = run(seed, false, false, false, 0.99, false, false, true)
    assert(attempts <= 1, "progression eligibility was cached across a graph change")
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
assert(varied > 1, "different seeds always chose the same assignment")
print("Entity autoplace search passed: 50 seeds, shuffled shared and distinct entries, unique slots, deterministic seeds, collision refusals and promotion refusals")

local crosses, retried = false, false
for seed = 1, 50 do
    run(seed, false, false, false, 0, true)
    local result, attempts = run(seed, false, false, false, 0.99, true, true)
    for head, base in pairs(result) do
        if tonumber(head:match("%d+$")) % 2 ~= tonumber(base:match("%d+$")) % 2 then crosses = true end
    end
    if attempts > 1 then retried = true end
end
assert(crosses, "general searches never crossed acquisition categories")
assert(retried, "later heads were not searched after the rejected trial")
print("Entity prerequisite search passed: category coin, general pool, rejection preserves the matching and searches later heads")

-- Exercise learned mining obligations through the real handler. The friendly
-- head can take the unused item, but must not erase either promised mine return.
package.loaded["src/lib/random/rng"].shuffle = function() end
category_roll = 0.99
defines = {prototypes = {item = {item = true}}}
unified_starting_data_raw = {item = {}}
context_costs.current = {anywhere_costs = {}}
randomization_info = {options = {first_pass = {blacklist = {}}}}
local graph = {nodes = {}, orand_to_parent = {}}
local params = {
    random_graph = graph,
    sorted_deps = {"dep-3", "dep-1", "dep-2"},
    shuffled_prereqs = {"base-1", "base-2", "base-free"},
    head_to_base = {},
}
for i = 1, 3 do
    local dep, head, base = "dep-" .. i, "head-" .. i, "base-" .. i
    local name, item = "building-" .. i, "item-" .. i
    prototypes[name] = {name = name}
    unified_starting_data_raw.item[item] = {name = item}
    graph.nodes[dep] = {key = dep, pre = {[head] = true}}
    graph.nodes[name] = {name = name}
    graph.orand_to_parent[dep] = name
    graph.nodes[head] = {
        key = head,
        type = "head",
        acq_kind = "build",
        old_base = base,
        owner = dep,
        friendly = i == 3 and true or nil,
    }
    graph.nodes[base] = {key = base, type = "base", acq_kind = "build", owner = item, friendly = i == 3 and true or nil}
    graph.nodes[item] = {type = "item", name = item}
    randomization_info.options.first_pass.blacklist[dep] = true
    if i < 3 then
        graph.nodes["mine-base-" .. i] = {type = "base", mine_back = true, mine_back_entity = name}
        graph.nodes["mine-head-" .. i] = {type = "head", mine_back = true, mine_back_entity = name, mine_back_item = item}
    end
end
graph.nodes["base-free"] = {key = "base-free", type = "base", acq_kind = "build", owner = "item-free"}
graph.nodes["item-free"] = {type = "item", name = "item-free"}
local rejected, mining_checks = 0, 0
params.promotion = {
    cache_rewires = function() end,
    required_contexts = function() return {"fixture-context"} end,
    resolve_head = function() end,
    head_candidate_ok = function(head, base)
        assert(type(base) == "string", "a non-building has no mine base")
        if head:find("mine-head", 1, true) then mining_checks = mining_checks + 1 end
        return true
    end,
    try_rewires = function(changes)
        for _, change in pairs(changes) do
            if change.node_key:find("mine-head", 1, true) and change.detach then
                rejected = rejected + 1
                return false, {node_key = change.node_key, context = "fixture-context"}
            end
        end
        return true
    end,
}
entity.initialize()
assert(entity.custom_prereq_search(params))
assert(params.head_to_base["head-3"] == "base-free", "friendly head must use the unneeded item position")
assert(params.head_to_base["mine-head-1"] ~= nil and params.head_to_base["mine-head-2"] ~= nil)
assert(rejected == 2 and mining_checks > 0, "both mining witnesses must refine candidate checks")
print("Entity mining refinement passed: preserves promised returns and retries the same root with learned contexts")

-- Run from the mod root: lua scripts/test-claim-tool.lua
local claim_data = require("lib/claim-tool")
local claim_control = require("scripts/claim-tool")

local neutral, player_force, enemy, ally = {}, {}, {}, {}
local player = {force = player_force}
game = {
    forces = {neutral = neutral},
    get_player = function(index)
        if index == 1 then
            return player
        end
    end,
}

local function entity(force, valid)
    return {
        force = force,
        valid = valid ~= false,
    }
end
local natural = entity(neutral)
local hostile = entity(enemy)
local friendly = entity(ally)
local owned = entity(player_force)
local destroyed = entity(neutral, false)
local event = {
    item = "unrelated-selection-tool",
    player_index = 1,
    entities = {
        natural,
        hostile,
        friendly,
        owned,
        destroyed,
    },
}
claim_control.on_selected(event)
assert(natural.force == neutral)
event.item = "propertyrandomizer-claim"
event.player_index = 2
claim_control.on_selected(event)
assert(natural.force == neutral)
event.player_index = 1
claim_control.on_selected(event)
assert(natural.force == player_force)
assert(hostile.force == enemy and friendly.force == ally and owned.force == player_force)
assert(destroyed.force == neutral)
claim_control.on_selected(event)
assert(natural.force == player_force)
print("ok - claims only valid neutral entities for the selecting player's force")

local raw = {
    fixture = {
        player_owned = {
            autoplace = {
                force = "player",
                probability_expression = "fixture-noise",
            },
        },
        enemy_owned = {autoplace = {force = "enemy"}},
        other_owned = {autoplace = {force = "fixture-force"}},
        default_owned = {autoplace = {}},
        built = {},
    },
    unrelated = {player_owned = {autoplace = {force = "player"}}},
}
claim_data.prepare(raw, {fixture = true})
claim_data.prepare(raw, {fixture = true})
assert(raw.fixture.player_owned.autoplace.force == "neutral")
assert(raw.fixture.player_owned.autoplace.probability_expression == "fixture-noise")
assert(raw.fixture.enemy_owned.autoplace.force == "enemy")
assert(raw.fixture.other_owned.autoplace.force == "fixture-force")
assert(raw.fixture.default_owned.autoplace.force == nil and raw.fixture.built.autoplace == nil)
assert(raw.unrelated.player_owned.autoplace.force == "player")
claim_data.prepare({}, {})
print("ok - player-owned map generation becomes neutral, with other forces and placement unchanged")

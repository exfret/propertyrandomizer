-- Run from the mod root: lua lib/test-prototype-exclusions.lua
local customization = require("lib/customization")
local exclusions = require("lib/prototype-exclusions")
local graph = require("lib/graph-customization")
local model = require("scripts/customizer-model")
local creators = {}
package.loaded["lib/trigger"] = {
    get_creator_table = function() return creators end,
    type_to_gather_struct_func = {fixture = function(structs, prototype) table.insert(structs, prototype.nested) end},
}
local indirect = require("randomizations/helper/indirect")

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = copy(child) end
    return result
end
table.deepcopy = copy

local raw = {
    fixture = {
        protected = {
            type = "fixture",
            name = "protected",
            value = 10,
            nested = {value = 4},
        },
        ordinary = {
            type = "fixture",
            name = "ordinary",
            value = 20,
        },
    },
}
local classes = {custom = {fixture = true}}
for _, scope in pairs({
    "all",
    "numerical/all",
    "randomization/belt_speed",
}) do
    local source = "EXCLUDE:" .. scope .. ":prototype/custom/protected"
    local state = customization.parse(source)
    assert(#state.warnings == 0, source)
    assert(customization.serialize(state) == source)
    exclusions.initialize(state, raw, classes)
    assert(exclusions.excluded("belt_speed", "numerical", raw.fixture.protected))
    assert(not exclusions.excluded("belt_speed", "numerical", raw.fixture.ordinary))
    assert(exclusions.excluded("inserter_speed", "numerical", raw.fixture.protected) == (scope ~= "randomization/belt_speed"))
    assert(exclusions.excluded("all_icons", "misc", raw.fixture.protected) == (scope == "all"))
    graph.initialize(state, raw, classes, 1)
    assert(graph.excluded("entity", raw.fixture.protected) == (scope == "all"))
    local old = raw.fixture.protected
    local value = old.value
    local nested = old.nested.value
    exclusions.run("belt_speed", "numerical", function()
        assert(exclusions.active_excluded(old))
        old.value = -1
        old.nested.value = -1
        old.extra = "unwanted"
        raw.fixture.protected = {
            type = "fixture",
            name = "protected",
            value = -1,
        }
        raw.fixture.ordinary.value = 30
    end)
    assert(raw.fixture.protected == old and old.value == value and old.nested.value == nested and old.extra == nil)
    assert(raw.fixture.ordinary.value == 30)
    assert(not exclusions.active_excluded(old))
end
local state = customization.parse("EXCLUDE:graph/all:type/fixture;EXCLUDE:graph/entity:prototype/custom/protected;EXCLUDE:randomization/icons:prototype/custom/protected;EXCLUDE:randomization/items:prototype/custom/ordinary")
assert(#state.warnings == 0)
exclusions.initialize(state, raw, classes)
assert(exclusions.excluded("items", "graph", raw.fixture.protected))
assert(not exclusions.excluded("belt_speed", "numerical", raw.fixture.protected))
assert(exclusions.excluded("all_icons", "misc", raw.fixture.protected), "spec IDs resolve to the actual cosmetic pass")
graph.initialize(state, raw, classes, 1)
assert(graph.excluded("items", raw.fixture.ordinary), "legacy item rules are applied before matching")
local legacy_only = customization.parse("EXCLUDE:randomization/items:prototype/custom/ordinary")
graph.initialize(legacy_only, raw, classes, 1)
assert(graph.excluded("items", raw.fixture.ordinary))
assert(not graph.excluded("item", raw.fixture.ordinary), "legacy and unified identity randomizations have separate scopes")
local cleared = customization.parse("EXCLUDE:all:type/fixture;INCLUDE:all:type/fixture")
assert(customization.serialize(cleared) == "")
for _, source in pairs({
    "EXCLUDE:randomization/no-such-id:type/fixture",
    "EXCLUDE:all:bad/fixture",
    "EXCLUDE:numerical:prototype/custom/protected",
}) do
    assert(#customization.parse(source).warnings == 1)
end
local draft = model.new("EXCLUDE:all:type/fixture;EXCLUDE:numerical/all:type/fixture")
assert(model.exclusions(draft, "all")["type/fixture"])
model.exclude(draft, "randomization/belt_speed", "prototype/custom/protected", true)
assert(customization.parse(model.export(draft)).prototype_exclusions["randomization/belt_speed"]["prototype/custom/protected"])
model.reset(draft, "belt_speed")
assert(model.exclusions(draft, "randomization/belt_speed")["prototype/custom/protected"], "parameter reset is independent of exclusions")
model.exclude(draft, "randomization/belt_speed", "prototype/custom/protected", false)
assert(next(model.exclusions(draft, "randomization/belt_speed")) == nil)
model.reset(draft)
assert(next(draft.configuration.prototype_exclusions) == nil)
local missing = customization.parse("EXCLUDE:all:type/absent")
assert(#exclusions.unmatched(missing, graph.catalog(raw, classes)) == 1)
local baseline = copy(raw)
baseline.fixture.protected.group = "baseline-group"
raw.fixture.protected.group = "changed-by-graph"
raw.fixture.protected.value = 65
local by_group = customization.parse("EXCLUDE:numerical/all:group/baseline-group")
exclusions.initialize(by_group, raw, classes, baseline)
assert(exclusions.excluded("belt_speed", "numerical", raw.fixture.protected), "scope membership uses the pre-graph metadata")
exclusions.run("belt_speed", "numerical", function() raw.fixture.protected.value = -1 end)
assert(raw.fixture.protected.value == 65 and raw.fixture.protected.group == "changed-by-graph", "numerical exclusions preserve earlier permitted graph changes")
classes.custom.alternate = true
raw.alternate = {}
local converted = copy(raw.fixture.protected)
converted.type = "alternate"
raw.alternate.protected = converted
raw.fixture.protected = nil
exclusions.initialize(by_group, raw, classes, baseline)
assert(exclusions.excluded("belt_speed", "numerical", converted), "original membership follows a permitted concrete type conversion")
exclusions.run("belt_speed", "numerical", function()
    raw.alternate.protected = nil
    raw.fixture.protected = {value = -1}
end)
assert(raw.alternate.protected == converted and raw.fixture.protected == nil and converted.value == 65, "restore the current form, retaining earlier graph changes")

-- A child referenced by an excluded parent must not change on that parent's behalf.
local parent_kind = "ammo"
raw[parent_kind] = {}
local protected_parent = {
    type = parent_kind,
    name = "protected-parent",
}
local ordinary_parent = {
    type = parent_kind,
    name = "ordinary-parent",
}
raw[parent_kind][protected_parent.name] = protected_parent
raw[parent_kind][ordinary_parent.name] = ordinary_parent
classes.custom[parent_kind] = true
raw.fixture.shared = {
    type = "fixture",
    name = "shared",
    nested = {value = 10},
}
creators.shared = {
    protected_parent,
    ordinary_parent,
}
creators.ordinary = {ordinary_parent}
data = {raw = raw}
local parent_rule = customization.parse("EXCLUDE:randomization/belt_speed:prototype/custom/protected-parent")
exclusions.initialize(parent_rule, raw, classes)
local visits = {}
local function visit(child) visits[child.name] = true end
exclusions.run("belt_speed", "numerical", function() indirect.iterate_child_prototypes("fixture", visit) end)
assert(visits.ordinary and not visits.shared, "an excluded parent protects a shared indirect child")
visits = {}
exclusions.run("inserter_speed", "numerical", function() indirect.iterate_child_prototypes("fixture", visit) end)
assert(visits.shared, "indirect protection is restricted to the selected randomization")
visits = {}
local child_rule = customization.parse("EXCLUDE:numerical/all:prototype/custom/shared")
exclusions.initialize(child_rule, raw, classes)
exclusions.run("belt_speed", "numerical", function() indirect.iterate_child_prototypes("fixture", visit) end)
assert(not visits.shared and visits.ordinary, "a directly excluded child is skipped as well")
print("ok - exclusion scopes, legacy IDs, direct/indirect pass protection, import/export and independent drafts")

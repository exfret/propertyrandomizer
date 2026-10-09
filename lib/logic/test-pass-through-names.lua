-- Plain-Lua check of the node types declared pass-through (not loaded by the mod)
-- Run from the mod root: lua lib/logic/test-pass-through-names.lua
--
-- A type declared pass-through (add_node with pass_through = true, lib/logic/builder.lua) can be left out of any graph logic.build makes (lib/logic/pass-through.lua), so code finding nodes by name would miss them
-- This fails on any file naming a declared type outside the builders, which name them to build them
-- The old logic and unused code build graphs of their own, and test fixtures may name anything

-- Where pass-through types are built, before logic.build leaves them out
local BUILDERS = {
    ["lib/logic/concrete.lua"] = true,
    ["lib/logic/abstract.lua"] = true,
}

local function read(path)
    local file = assert(io.open(path, "r"))
    local text = file:read("a")
    file:close()
    return text
end

local function is_test(path)
    return string.find(string.match(path, "[^/]*$"), "test", 1, true) ~= nil
end

-- Every Lua file of the mod, relative to its root, sorted, notes aside
-- In a git checkout only the files git tracks, since ignored folders keep old copies of the source (like benchmark-logs' tested-source); a tree without git, like the precommit runner's snapshot, has only those anyway
local function lua_files()
    local found = {}
    local pipe = assert(io.popen("git ls-files -- '*.lua' 2>/dev/null"))
    for line in pipe:lines() do
        table.insert(found, line)
    end
    pipe:close()
    if #found == 0 then
        pipe = assert(io.popen("find . -name \"*.lua\" -not -path \"./.git/*\""))
        for line in pipe:lines() do
            table.insert(found, (string.gsub(line, "^%./", "")))
        end
        pipe:close()
    end
    local files = {}
    for _, path in pairs(found) do
        if string.find(path, "^notes/") == nil then
            table.insert(files, path)
        end
    end
    table.sort(files)
    return files
end

local files = lua_files()

-- Type name --> the file declaring it
local declared = {}
local num_declared = 0
for _, path in pairs(files) do
    if string.find(path, "^lib/logic/") ~= nil and not is_test(path) then
        for type_name in string.gmatch(read(path), "add_node%(%s*\"([^\"]+)\"[^\n]-pass_through%s*=%s*true") do
            if declared[type_name] == nil then
                num_declared = num_declared + 1
            end
            declared[type_name] = path
        end
    end
end
assert(num_declared > 0, "no pass-through types found: the declarations' form changed, and this check should follow it")

local found = {}
for _, path in pairs(files) do
    if BUILDERS[path] == nil and not is_test(path) and string.find(path, "^lib/old%-logic/") == nil and string.find(path, "^lib/unused/") == nil then
        local line_number = 0
        for line in string.gmatch(read(path) .. "\n", "([^\n]*)\n") do
            line_number = line_number + 1
            for type_name, _ in pairs(declared) do
                if string.find(line, "\"" .. type_name .. "\"", 1, true) ~= nil then
                    table.insert(found, path .. ":" .. line_number .. " names " .. type_name)
                end
            end
        end
    end
end
table.sort(found)
assert(#found == 0, "node types declared pass-through are named outside the builders, where logic.build may have left them out:\n" .. table.concat(found, "\n"))
print("ok - no code outside the builders names the " .. num_declared .. " pass-through types")

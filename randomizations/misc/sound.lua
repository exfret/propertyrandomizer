local rng = require("lib/random/rng")

-- Item sounds specifically? Or other groups?

local sounds = {}

-- NEW
randomizations.all_sounds = function(id)
    local sound_file_extensions = {
        [".ogg"] = true,
        [".wav"] = true,
        [".voc"] = true
    }

    local function is_sound_file(file)
        return file and string.len(file) >= 4 and sound_file_extensions[string.sub(file, -4)]
    end

    local function is_sound_property(property)
        if type(property) ~= "table" then
            return false
        end
    
        if is_sound_file(property.filename) then
            return true
        end
        if property[1] ~= nil and type(property[1]) == "table" and is_sound_file(property[1].filename) then
            return true
        end
        if property.variations ~= nil and is_sound_file(property.variations.filename) then
            return true
        end
        if property.variations ~= nil and property.variations[1] ~= nil and is_sound_file(property.variations[1].filename) then
            return true
        end
    
        return false
    end

    local function gather_sounds(tbl)
        local sound_tbl_prop_keys = {}
        local sounds = {}

        -- Blacklist programmable speakers and ambient sounds, as well as different types of surfaces for their ambient sounds
        local is_blacklisted_sound_type = {
            ["programmable-speaker"] = true,
            ["ambient-sound"] = true,
            ["surface"] = true,
            ["planet"] = true,
            ["space-platform-hub"] = true
        }

        if type(tbl) ~= "table" then
            return {sound_tbl_prop_keys = sound_tbl_prop_keys, sounds = sounds}
        elseif is_blacklisted_sound_type[tbl.type] then
            return {sound_tbl_prop_keys = sound_tbl_prop_keys, sounds = sounds}
        end

        for key, val in pairs(tbl) do
            if is_sound_property(val) then
                table.insert(sound_tbl_prop_keys, {tbl = tbl, property = key})
                table.insert(sounds, val)
            else
                local sound_info = gather_sounds(val)
                for _, tbl_prop_key in pairs(sound_info.sound_tbl_prop_keys) do
                    table.insert(sound_tbl_prop_keys, tbl_prop_key)
                end
                for _, sound in pairs(sound_info.sounds) do
                    table.insert(sounds, sound)
                end
            end
        end

        return {sound_tbl_prop_keys = sound_tbl_prop_keys, sounds = sounds}
    end

    -- Gather up all the sounds
    local sound_info = gather_sounds(data.raw)

    log(serpent.block(sound_info))
  
    -- Now mix them all together
    rng.shuffle(rng.key({id = id}), sound_info.sounds)

    for ind, tbl_prop_key in pairs(sound_info.sound_tbl_prop_keys) do
        tbl_prop_key.tbl[tbl_prop_key.property] = sound_info.sounds[ind]
    end
end
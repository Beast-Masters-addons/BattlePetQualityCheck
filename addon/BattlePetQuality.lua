---@type BattlePetQualityCheck
local _, addon = ...
---@class BattlePetQuality
local lib = addon.BattlePetQuality

function lib.itemQualityString(quality)
    local key = ('ITEM_QUALITY%d_DESC'):format(quality)
    return _G[key]
end

function lib.petQualityColor(quality)
    assert(type(quality) == 'number')
    assert(quality >= 0 and quality <= 8)
    return _G.ITEM_QUALITY_COLORS[quality]
end

--/dump _G['BattlePetQuality'].quality_string(1)
function lib.petQualityString(quality)
    assert(quality >= 0, 'Quality must be at least 0 (poor)')
    return _G["BATTLE_PET_BREED_QUALITY" .. quality + 1]
end

function lib.wrapTextInQualityColor(quality, string)
    return addon.BattlePetQuality.petQualityColor(quality)['color']:WrapTextInColorCode(string)
end

function lib.petQualityColorString(quality)
    return lib.wrapTextInQualityColor(quality, lib.petQualityString(quality))
end
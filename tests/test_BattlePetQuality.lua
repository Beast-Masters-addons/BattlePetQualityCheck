loadfile('build_utils/wow_api/PetJournal.lua')()
loadfile('build_utils/wow_api/mixin.lua')()
loadfile('build_utils/wow_api/Color.lua')()
loadfile('build_utils/wow_api/quality.lua')()

---@type BattlePetQualityCheck
local addon = { BattlePetQuality = {} }

loadfile('../addon/BattlePetQuality.lua')('test', addon)

---@type BattlePetQuality
local lib = addon.BattlePetQuality

local lu = require('luaunit')

function testPetQualityStringPoor()
    local string = lib.petQualityString(0)
    lu.assertEquals(string, "Poor")
end

function testPetQualityColorStringPoor()
    local string = lib.petQualityColorString(0)
    lu.assertEquals(string, "|cff9d9d9dPoor|r")
end

function testPetQualityColorStringUncommon()
    local string = lib.petQualityColorString(2)
    lu.assertEquals(string, "|cff1eff00Uncommon|r")
end

--/run print(ITEM_QUALITY_COLORS[1]['color']:WrapTextInColorCode("Poor"))
--/dump ITEM_QUALITY_COLORS[0]['color']:WrapTextInColorCode("Poor")
--/dump ITEM_QUALITY_COLORS[2]['color']:WrapTextInColorCode("Uncommon")

os.exit(lu.LuaUnit.run())

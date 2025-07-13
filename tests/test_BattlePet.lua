loadfile('data.lua')()
loadfile('build_utils/wow_api/PetJournal.lua')()
loadfile('build_utils/wow_api/frame.lua')()
loadfile('build_utils/wow_api/functions.lua')()
loadfile('build_utils/utils/load_toc.lua')('../BattlePetQualityCheck.toc')

local lu = require('luaunit')
local addon = _G['AddonTable']

---@type BattlePet
local lib = addon.BattlePet

addon.LibPetJournal:LoadPets()

function testGetHighestOwnedPetQuality()
    local quality = lib:getHighestOwnedPetQuality(374)
    lu.assertEquals(quality, 3)
end

function testGetHighestOwnedPetQualityPoor()
    local quality = lib:getHighestOwnedPetQuality(459)
    lu.assertEquals(quality, 0)
end

function testGetPetsBySpecies()
    local pets = addon.BattlePet:getPetsBySpecies(374)
    lu.assertEquals(pets[1], "BattlePet-0-00000046A353")
end

os.exit(lu.LuaUnit.run())
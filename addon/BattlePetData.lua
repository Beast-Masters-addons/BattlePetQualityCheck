---@type BattlePetQualityCheck
local _, addon = ...
---@class BattlePetData
local lib = addon.BattlePetData

---@type number @Pet species ID
lib.speciesID = nil
---@type number @Pet level
lib.level = nil
---@type number @Pet quality/rarity
lib.quality = nil
---@type string @Pet species name
lib.name = nil
---@type string @Pet custom name
lib.customName = nil
---@type string Pet description
lib.description = nil

---Get pet data
---@param petGUID string Pet GUID
---@return BattlePetData
function lib:petData(petGUID)
    assert(petGUID, 'Empty argument to petData')
    local o = {}
    o.guid = petGUID
    o.speciesID, o.customName, o.level, o.xp, o.maxXp, o.displayID, o.isFavorite, o.name, o.icon, o.petType,
    o.creatureID, o.sourceText, o.description, o.isWild, o.canBattle, o.tradable,
    o.unique, o.obtainable = _G.C_PetJournal.GetPetInfoByPetID(petGUID)
    if not o.speciesID then
        addon.utils:error('No data for pet with GUID ' .. petGUID)
        return
    end

    o.health, o.maxHealth, o.power, o.speed, o.quality = _G.C_PetJournal.GetPetStats(petGUID)

    self.info = o

    setmetatable(o, self)
    self.__index = self
    return o
end

function lib:link()
    local name
    if self.customName then
        name = self.customName
    else
        name = self.name
    end

    return string.format("%s|Hbattlepet:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r",
            addon.BattlePetQuality.petQualityColor(self.quality).hex,
            self.speciesID,
            self.level,
            self.quality - 1,
            self.health,
            self.power,
            self.speed,
            self.guid,
            name
    )
end
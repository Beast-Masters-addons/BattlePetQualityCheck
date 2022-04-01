---@type BattlePetQualityCheck
local _, addon = ...
---@class BattlePet
local lib = addon.BattlePet
lib.debug = false

function lib.getPetBySpeciesName(name)
    for _, owned_pet_guid in _G.LibPetJournal:IteratePetIDs() do
        -- Loop through the owned pets
        local _, _, _, _, _, _, _, species_name = _G.C_PetJournal.GetPetInfoByPetID(owned_pet_guid)
        if species_name == name then
            return _G.C_PetJournal.GetPetInfoByPetID(owned_pet_guid)
        end
    end
end

lib.petSpecies = {}

---Add a pet to species cache
---@param speciesId number Species ID
---@param petId string Pet GUID
function lib:addSpecies(speciesId, petId)
    if type(self.petSpecies[speciesId]) ~= 'table' then
        self.petSpecies[speciesId] = { petId }
    else
        table.insert(self.petSpecies[speciesId], petId)
    end
end

function lib:scanSpecies()
    self.petSpecies = {}
    for _, petId in addon.LibPetJournal:IteratePetIDs() do
        local speciesId = _G.C_PetJournal.GetPetInfoByPetID(petId)
        self:addSpecies(speciesId, petId)
    end
    _G.PetSpeciesCache = self.petSpecies
end

---Get all owned pets of a given species
---@param speciesId number Species ID
---@return table List with pet GUIDs
function lib:getPetsBySpecies(speciesId)
    if not self.petSpecies or next(self.petSpecies) == nil then
        self:scanSpecies()
    end
    if not self.petSpecies[speciesId] then
        return
    end

    assert(self.petSpecies[speciesId], 'Unknown pet species id')
    return self.petSpecies[speciesId]
end

--/dump _G['BattlePetQualityCheck'].BattlePet:getHighestOwnedPetQuality(415)
function lib:getHighestOwnedPetQuality(speciesId)
    assert(speciesId, 'speciesId is empty')
    local max_quality = -1
    local pets = self:getPetsBySpecies(speciesId)
    if not pets then
        if self.debug then
            addon.utils:printf('No pets with species %d found', speciesId)
        end
        return
    end

    for _, petID in ipairs(pets) do
        local pet = addon.BattlePetData:petData(petID)
        if pet ~= nil and pet.quality > max_quality then
            max_quality = pet.quality
        end
    end
    return max_quality
end

function lib:getPetsBelowLimit(speciesId, qualityLimit, quantityLimit)
    assert(speciesId, 'speciesId is empty')

    local pet_objects = {}
    local max_quality_count = 0
    local pets = self:getPetsBySpecies(speciesId)
    if not pets then
        if self.debug then
            addon.utils:printf('No pets with species %d found', speciesId)
        end
        return
    end
    if #pets < quantityLimit then
        if self.debug then
            addon.utils:printf('%d pets found, below limit of %d', #pets, quantityLimit)
        end
        --Owned pets is less than limit
        return
    end
    --@debug@
    --print('getPetsBelowLimit species', speciesId)
    --@end-debug@

    for _, petID in ipairs(pets) do
        local pet = addon.BattlePetData:petData(petID)
        if pet.isWild then
            if pet.quality == qualityLimit then
                max_quality_count = max_quality_count + 1
            end
            table.insert(pet_objects, pet)
        else
            if self.debug then
                addon.utils:printf('Pet %s of species %d is not wild', pet.name, pet.speciesID)
            end
        end
    end

    if #pet_objects == 0 then
        if self.debug then
            addon.utils:printf('No wild pets with species %d', speciesId)
        end
        return
    end

    if max_quality_count == #pets then
        --All owned pets are max quality
        if self.debug then
            addon.utils:printf('All %d owned pets are max quality %d', #pets, qualityLimit)
        end
        return
    end
    --DevTools_Dump(pet_objects)
    return pet_objects
end

--/dump _G['BattlePetQualityCheck'].BattlePet.petSpecies
--/dump _G['BattlePetQualityCheck'].BattlePet:showPetsNotRare(1, 4, 3)
function lib:showPetsNotRare(speciesID, qualityLimit, quantityLimit)
    local pets = self:getPetsBelowLimit(speciesID, qualityLimit, quantityLimit)
    if not pets then
        return
    end

    local header = addon.utils:colorize(('You have %d pets of type %s, where at least one has quality below'):
    format(#pets, pets[1].name), 0xff, 0xff, 0)
    addon.utils:printf('%s %s:', header, addon.BattlePetQuality.petQualityColorString(qualityLimit))

    for _, pet in ipairs(pets) do
        addon.utils:printf('%s (%s %d)', pet:link(), _G.LEVEL, pet.level)
    end
end
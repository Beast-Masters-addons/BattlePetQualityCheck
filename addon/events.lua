---@type BattlePetQualityCheck
local _, addon = ...
---@class BattlePetQualityEvents
local events = addon.events
events.addon = addon

local frame = _G.CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
    if events[event] == nil then
        error(('No event handler for %s'):format(event))
    end
    events[event](self, ...)
end)

function events:ADDON_LOADED(addonName)
    if addonName == addon.name then
        --@debug@
        addon.utils:printf("%s loaded with debug output", addon.name)
        --@end-debug@
        self:RegisterEvent("PET_BATTLE_OPENING_DONE")
        self:RegisterEvent('NEW_PET_ADDED')
        addon.BattlePet:scanSpecies()
    end
end

function events.NEW_PET_ADDED(_, capturedPetGUID)
    local CapturedSpeciesID = _G.C_PetJournal.GetPetInfoByPetID(capturedPetGUID)
    --Pet Journal is not updated with captured pet, so we need to add it manually
    table.insert(addon.LibPetJournal._petids, capturedPetGUID)
    --Add captured pet to internal cache
    addon.BattlePet:addSpecies(CapturedSpeciesID, capturedPetGUID)

    addon.BattlePet:showPetsNotRare(CapturedSpeciesID, 4, 3)
end

function events.PET_BATTLE_OPENING_DONE()
    if _G.C_PetBattles.IsWildBattle() then
        addon.utils:cprint('Battle pet quality:', 0x28, 0xbd, 0x00)
        --Loop through the opponents pets
        for i = 1, _G.C_PetBattles.GetNumPets(2) do
            local rarity = _G.C_PetBattles.GetBreedQuality(2, i)
            local SpeciesId = _G.C_PetBattles.GetPetSpeciesID(2, i)
            --addon.utils:printf('Species %d at position %d', SpeciesId, i)

            local upgrade_text
            local owned_rarity = addon.BattlePet:getHighestOwnedPetQuality(SpeciesId)
            if not owned_rarity then
                upgrade_text = addon.utils:colorize('Not owned', 0xcc, 0xff, 0x00)
            elseif owned_rarity < rarity then
                upgrade_text = addon.utils:colorize('Upgrade from', 0xcc, 0xff, 0x00) .. ' ' ..
                        addon.BattlePetQuality.petQualityColorString(owned_rarity)
            else
                upgrade_text = 'Already owns ' .. addon.BattlePetQuality.petQualityColorString(owned_rarity)
            end
            local name = _G.C_PetBattles.GetName(2, i)
            addon.utils:printf('Wild pet %d: %s (%s)', i,
                    addon.BattlePetQuality.wrapTextInQualityColor(rarity, name), upgrade_text)
        end
    end
end
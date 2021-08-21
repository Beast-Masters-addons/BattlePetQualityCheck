---@type BattlePetQualityCheck
local _, addon = ...

-- https://wowwiki.fandom.com/wiki/Creating_a_slash_command
_G.SLASH_PETQ1 = "/petq"
_G.SlashCmdList['PETQ'] = function(msg)
    if msg == '' then
        for species in addon.LibPetJournal:IterateSpeciesIDs() do
            addon.BattlePet:showPetsNotRare(species, 4, 3)
        end
    else
        addon.BattlePet:showPetsNotRare(tonumber(msg), 4, 3)
    end
end
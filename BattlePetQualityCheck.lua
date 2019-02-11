local LibPetJournal = LibStub("LibPetJournal-2.0")
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PET_BATTLE_OPENING_DONE")
EventFrame:RegisterEvent('NEW_PET_ADDED')

local function GetHighestOwnedPetQuality(SpeciesId)
	local highest_quality = -1
	for _, pet_id in LibPetJournal:IteratePetIDs() do -- Loop through the owned pets
		local OwnedSpeciesId, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = C_PetJournal.GetPetInfoByPetID(pet_id)

		if OwnedSpeciesId == SpeciesId then -- Pet exists in journal
			local _, _, _, _, rarity = C_PetJournal.GetPetStats(pet_id)
			if rarity > highest_quality then
				highest_quality = rarity
			end
		end
	end
	if highest_quality == -1 then
		return false
	end
	return highest_quality
end

function quality_color(quality)
	return _G.ITEM_QUALITY_COLORS[quality-1].hex
end
function quality_string(quality)
	return _G["BATTLE_PET_BREED_QUALITY"..quality]
end
function quality_color_string(quality)
	return string.format('%s%s|r', quality_color(quality), quality_string(quality))
end
function colorize(text, color)
	if string.sub(color, 1,4) == '|cFF' then --TODO: Fix this
		color = string.sub(color, 5)
	end
	return string.format('|cFF%s%s|r', color, text)
	end

EventFrame:SetScript("OnEvent", function(self, event,...)
	if event == "PET_BATTLE_OPENING_DONE" then
		if C_PetBattles.IsWildBattle(2,i) then
			-- DEFAULT_CHAT_FRAME:AddMessage("|cFF5cb4f8 Battle Pet Quality checker|r")
			DEFAULT_CHAT_FRAME:AddMessage(colorize('Battle pet quality:', '28bd00'))
			for i=1,C_PetBattles.GetNumPets(2) do --Loop through the opponents pets
				local rarity = C_PetBattles.GetBreedQuality(2,i)
				local SpeciesId = C_PetBattles.GetPetSpeciesID(2,i)

				local upgrade_text = ''
				local owned_rarity = GetHighestOwnedPetQuality(SpeciesId)
				--DEFAULT_CHAT_FRAME:AddMessage('Species: ' .. SpeciesId .. ' Quality: ' .. Quality)
				--print('Wild quality: ' .. Quality .. ' Tame quality: ' .. HasPet)
				if not owned_rarity then
					-- Missing pet: [name]
					upgrade_text = "|cFFccff00 (Not owned)|r"
					upgrade_text = colorize('Not owned', 'ccff00')
				elseif owned_rarity < rarity then
					upgrade_text = string.format('%s %s', colorize('Upgrade from', 'ccff00'), quality_color_string(owned_rarity))
				else
					upgrade_text = string.format('Already owns %s', quality_color_string(owned_rarity))
				end
				local name = C_PetBattles.GetName(2,i)
				DEFAULT_CHAT_FRAME:AddMessage(string.format('Wild pet %d: %s%s|r (%s)', i, quality_color(rarity), name, upgrade_text))

			end
		end
	elseif event == 'NEW_PET_ADDED' then
		local CapturedPetGUID = ... --Event payload
		local CapturedSpeciesID, _, level, xp, max, dis, fav, species_name, icon = C_PetJournal.GetPetInfoByPetID(CapturedPetGUID)
		local owned_count = 1 --Captured pet is not counted
		for _, owned_pet_guid in LibPetJournal:IteratePetIDs() do -- Loop through the owned pets
			local OwnedSpeciesId, customName, owned_level  = C_PetJournal.GetPetInfoByPetID(owned_pet_guid)
			if OwnedSpeciesId == CapturedSpeciesID then -- Pet exists in journal
				local _, _, _, _, owned_rarity = C_PetJournal.GetPetStats(owned_pet_guid)
				--TODO: Add link
				-- DEFAULT_CHAT_FRAME:AddMessage(string.format('Owned: %s%s|r level %d', quality_color(owned_rarity), species_name, owned_level))
				-- DEFAULT_CHAT_FRAME:AddMessage(string.format('|Hunit:%s|h:%s|h', owned_pet_guid, species_name))
				owned_count = owned_count + 1
			end
		end
		if owned_count == 3 then
			--DEFAULT_CHAT_FRAME:AddMessage(string.format('You have %d pets of type %s', owned_count, species_name))
			DEFAULT_CHAT_FRAME:AddMessage(string.format('You have 3 pets of type %s, where at least 1 has quality below %s. Consider releasing one.', species_name, quality_color_string(4)))
		end
	end
end)



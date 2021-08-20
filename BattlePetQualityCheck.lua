local LibPetJournal = LibStub("LibPetJournal-2.0")
local utils = _G['BMUtils']
utils = LibStub('BM-utils-1')
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PET_BATTLE_OPENING_DONE")
EventFrame:RegisterEvent('NEW_PET_ADDED')

local function GetHighestOwnedPetQuality(SpeciesId)
	if not SpeciesId then --https://www.lua.org/pil/8.5.html
		error("GetHighestOwnedPetQuality was called with empty argument", 2)
	end
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
	return _G.ITEM_QUALITY_COLORS[quality-1]["color"]:WrapTextInColorCode(quality_string(quality))
end

function colorize(text, color)
	if string.sub(color, 1,4) == '|cFF' then --TODO: Fix this
		color = string.sub(color, 5)
	end
	return string.format('|cFF%s%s|r', color, text)
end

local function pet_link(guid)
	if type(guid) ~= "string" then --https://www.lua.org/pil/8.5.html
		error("string expected", 2)
	end

	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description  = C_PetJournal.GetPetInfoByPetID(guid)
	local health, maxHealth, power, speed, quality = C_PetJournal.GetPetStats(guid)

	if customName then
		name = customName
	end

	return string.format("%s|Hbattlepet:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r",
			quality_color(quality),
			speciesID,
			level,
			quality - 1,
			health,
			power,
			speed,
			guid,
			name
			)
end

function GetPetBySpeciesName(name)
	for _, owned_pet_guid in LibPetJournal:IteratePetIDs() do -- Loop through the owned pets
		local OwnedSpeciesId, customName, _, _, _, _, _, species_name  = C_PetJournal.GetPetInfoByPetID(owned_pet_guid)
		if species_name==name then
			return C_PetJournal.GetPetInfoByPetID(owned_pet_guid)
		end
	end
end

function pet_count_check(species_id, limit, quality_limit)
	local owned_count = 0
	local links = {}
	local quality_counts = {}
	-- local OwnedSpeciesId, speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable
	local species_name
	if not limit then
		limit = 3
	end
	if not quality_limit then
		quality_limit = 4
	end
	for _, owned_pet_guid in LibPetJournal:IteratePetIDs() do -- Loop through the owned pets
		local OwnedSpeciesId, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(owned_pet_guid)
		if isWild and OwnedSpeciesId == species_id then -- Pet has requested species
			local _, _, _, _, quality = C_PetJournal.GetPetStats(owned_pet_guid)
			links[owned_pet_guid] = pet_link(owned_pet_guid)
			species_name = name
			if not quality_counts[quality] then
				quality_counts[quality] = 1
			else
				quality_counts[quality] = quality_counts[quality] + 1
			end
			owned_count = owned_count + 1
			if owned_count >= 3 then
				break
			end
			-- owned_text[owned_pet_guid] = string.format('%s%s|r level %d\r\n', quality_color(owned_rarity), species_name, owned_level)
		end
	end

	if owned_count < limit then
		return
	end
	if quality_counts[quality_limit] and quality_counts[quality_limit] == 3 then --All pets have maximum quality
		return
	end

	utils:printf('You have %d pets of type %s, where at least one has quality below %s:',
			owned_count, species_name, quality_color_string(quality_limit))
	for _, link in pairs(links) do
		DEFAULT_CHAT_FRAME:AddMessage(link)
	end
end

-- https://wowwiki.fandom.com/wiki/Creating_a_slash_command
SLASH_PETQ1 = "/petq"
SlashCmdList['PETQ'] = function(msg)
	for species in LibPetJournal:IterateSpeciesIDs() do
		pet_count_check(species)
	end
	pet_count_check(species)
end


EventFrame:SetScript("OnEvent", function(self, event,...)
	if event == "PET_BATTLE_OPENING_DONE" then
		if C_PetBattles.IsWildBattle(2,i) then
			DEFAULT_CHAT_FRAME:AddMessage(colorize('Battle pet quality:', '28bd00'))
			for i=1,C_PetBattles.GetNumPets(2) do --Loop through the opponents pets
				local rarity = C_PetBattles.GetBreedQuality(2,i)
				local SpeciesId = C_PetBattles.GetPetSpeciesID(2,i)

				local upgrade_text = ''
				local owned_rarity = GetHighestOwnedPetQuality(SpeciesId)
				if not owned_rarity then
					-- Missing pet: [name]
					--upgrade_text = "|cFFccff00 (Not owned)|r"
					upgrade_text = utils:colorize('Not owned', 0xcc,0xff,0x00)
				elseif owned_rarity < rarity then
					upgrade_text = string.format('%s %s', utils:colorize('Upgrade from', 'ffccff00'), quality_color_string(owned_rarity))
				else
					upgrade_text = string.format('Already owns %s', quality_color_string(owned_rarity))
				end
				local name = C_PetBattles.GetName(2,i)
				utils:printf('Wild pet %d: %s%s|r (%s)', i, quality_color(rarity), name, upgrade_text)

			end
		end
	elseif event == 'NEW_PET_ADDED' then
		local CapturedPetGUID = ... --Event payload
		local CapturedSpeciesID = C_PetJournal.GetPetInfoByPetID(CapturedPetGUID)
		--Pet Journal is not updated with captured pet, so we need to add it manually
		tinsert(LibPetJournal._petids, CapturedPetGUID)
		pet_count_check(CapturedSpeciesID)
	end
end)
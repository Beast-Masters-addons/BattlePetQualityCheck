---@class BattlePetQualityCheck
local addonName, addon = ...
addon.name = addonName
addon.version = '@version@'

local minor
---@type BMUtils
addon.utils, minor = _G.LibStub('BM-utils-1')
assert(minor >= 6, ('BMUtils 1.6 or higher is required, found 1.%d'):format(minor))

---@type BattlePet
addon.BattlePet = {}

---@type BattlePetData
addon.BattlePetData = {}

---@type BattlePetQuality
addon.BattlePetQuality = {}

---@type BattlePetQualityEvents
addon.events = {}

addon.LibPetJournal = _G.LibStub("LibPetJournal-2.0")

_G['BattlePetQualityCheck'] = addon
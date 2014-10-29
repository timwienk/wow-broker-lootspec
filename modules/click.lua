local name, addon = ...
local click = addon:NewModule('Click')

-- Localise global variables
local _G = _G
local LoadAddOn, ShowUIPanel, HideUIPanel = _G.LoadAddOn, _G.ShowUIPanel, _G.HideUIPanel
local EJ_GetCurrentInstance, EJ_GetDifficulty = _G.EJ_GetCurrentInstance, _G.EJ_GetDifficulty
local UnitClass, GetInstanceInfo = _G.UnitClass, _G.GetInstanceInfo

local EncounterJournal, EncounterJournal_SetFilter
local EncounterJournal_ListInstances, EncounterJournal_DisplayInstance, EncounterJournal_SelectDifficulty

local function LoadEncounterJournal()
	if not _G.EncounterJournal then
		LoadAddOn('Blizzard_EncounterJournal')
	end

	EncounterJournal = _G.EncounterJournal
	EncounterJournal_SetFilter = _G.EncounterJournal_SetFilter
	EncounterJournal_ListInstances = _G.EncounterJournal_ListInstances
	EncounterJournal_DisplayInstance = _G.EncounterJournal_DisplayInstance
	EncounterJournal_SelectDifficulty = _G.EncounterJournal_SelectDifficulty
end

function click:OnEnable()
	addon:Subscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Subscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function click:OnDisable()
	addon:Unsubscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Unubscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function click:OnClick(frame, button)
	if button == 'RightButton' then
		if not EncounterJournal then
			LoadEncounterJournal()
		end

		if EncounterJournal:IsShown() then
			HideUIPanel(EncounterJournal)
		else
			self.PrepareEncounterJournal()
			ShowUIPanel(EncounterJournal)
		end
	end
end

function click:OnLootSpecUpdated()
	if EncounterJournal and EncounterJournal:IsShown() then
		self.PrepareEncounterJournal()
	end
end

function click.PrepareEncounterJournal()
	local _, _, class = UnitClass('player')
	local _, spec = addon.GetLootSpecialization()
	local instance = EJ_GetCurrentInstance()

	if instance > 0 then
		local _, _, difficulty = GetInstanceInfo()

		if instance ~= EncounterJournal.instanceID then
			EncounterJournal_ListInstances()
			EncounterJournal_DisplayInstance(instance)
		end

		if difficulty and difficulty ~= EJ_GetDifficulty() then
			EncounterJournal_SelectDifficulty(nil, difficulty)
		end
	end

	if spec then
		EncounterJournal_SetFilter(nil, class, spec)
	else
		EncounterJournal_SetFilter(nil, class, 0)
	end

	EncounterJournal.encounter.info.lootTab:Click()
end

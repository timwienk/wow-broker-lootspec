local name, addon = ...
local click = addon:NewModule('Click')

-- Localise global variables
local LoadAddOn, ShowUIPanel, HideUIPanel = LoadAddOn, ShowUIPanel, HideUIPanel
local EJ_GetCurrentInstance, EJ_GetDifficulty = EJ_GetCurrentInstance, EJ_GetDifficulty
local UnitClass, GetInstanceInfo = UnitClass, GetInstanceInfo

function click:OnEnable()
	addon:Subscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Subscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function click:OnDisable()
	addon:Unsubscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Unubscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function click:OnClick(frame, button)
	if button == 'LeftButton' then
		if not EncounterJournal then
			LoadAddOn('Blizzard_EncounterJournal')
		end

		local journal = EncounterJournal

		if journal:IsShown() then
			HideUIPanel(journal)
		else
			self.PrepareEncounterJournal()
			ShowUIPanel(journal)
		end
	end
end

function click:OnLootSpecUpdated()
	local journal = EncounterJournal

	if journal and journal:IsShown() then
		self.PrepareEncounterJournal()
	end
end

function click.PrepareEncounterJournal()
	local _, _, class = UnitClass('player')
	local _, spec = addon.GetLootSpecialization()
	local instance = EJ_GetCurrentInstance()
	local journal = EncounterJournal

	if instance > 0 then
		local _, _, difficulty = GetInstanceInfo()

		if difficulty > 7 then
			difficulty = 1
		elseif difficulty > 2 then
			difficulty = difficulty - 2
		end

		if instance ~= journal.instanceID then
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

	journal.encounter.info.lootTab:Click()
end

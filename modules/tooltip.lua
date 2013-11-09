local name, addon = ...
local tooltip = addon:NewModule('Tooltip')

-- Localise global variables
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
local GetNumSpecializations, LOOT_SPECIALIZATION_DEFAULT = GetNumSpecializations, LOOT_SPECIALIZATION_DEFAULT
local format = string.format

local LibQTip = LibStub('LibQTip-1.0')

function tooltip:OnEnable()
	addon:Subscribe('MOUSE_ENTER', self, 'Show')
	addon:Subscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Subscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function tooltip:OnDisable()
	self:Hide()
	addon:Unsubscribe('MOUSE_ENTER', self, 'Show')
	addon:Unsubscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Unsubscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function tooltip:OnClick(frame, button)
	if button == 'LeftButton' then
		self:Show(frame)
	end
end

function tooltip:OnLootSpecUpdated()
	self:Hide()
end

function tooltip:Show(anchor)
	self:Hide()

	if self.enabledState then
		self.tip = LibQTip:Acquire(name .. 'Tooltip', 3, 'LEFT', 'LEFT')
		self.tip:Clear()

		self:Populate()

		self.tip.OnRelease = function() self.tip = nil end
		self.tip:SetAutoHideDelay(0.1, anchor)
		self.tip:SmartAnchorTo(anchor)
		self.tip:Show()
	end
end

function tooltip:Hide()
	if self.tip then
		LibQTip:Release(self.tip)
	end
end

function tooltip:Populate()
	local lootspec = addon.GetLootSpecialization()
	local id, name, _, icon = GetSpecializationInfo(GetSpecialization())

	self:AddLine(0, icon, format(LOOT_SPECIALIZATION_DEFAULT, name), lootspec == 0)

	for i = 1, GetNumSpecializations() do
		id, name, _, icon = GetSpecializationInfo(i)
		self:AddLine(id, icon, name, lootspec == id)
	end
end

function tooltip:AddLine(id, icon, name, active)
	local line = self.tip:AddLine()
	local radio = '|T:0|t'

	if active then
		radio = '|TInterface\\Buttons\\UI-RadioButton:8:8:0:0:64:16:19:28:3:12|t'
	end

	self.tip:SetCell(line, 1, radio)
	self.tip:SetCell(line, 2, '|T' .. icon .. ':14|t')
	self.tip:SetCell(line, 3, name)
	self.tip:SetLineScript(line, 'OnMouseUp', self:GetLineScript(id))
	return line
end

function tooltip:GetLineScript(id)
	return function()
		addon.SetLootSpecialization(id)
		self:Hide()
	end
end

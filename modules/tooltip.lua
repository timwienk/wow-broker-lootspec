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
		self.tip = LibQTip:Acquire(name .. 'Tooltip', 2, 'LEFT', 'LEFT')
		self.tip:Clear()

		self:Populate()

		self.tip:SetAutoHideDelay(0.1, anchor)
		self.tip:SmartAnchorTo(anchor)
		self.tip:Show()
	end
end

function tooltip:Hide()
	if self.tip then
		LibQTip:Release(self.tip)
		self.tip = nil
	end
end

function tooltip:Populate()
	local lootspec = addon.GetLootSpecialization()
	local id, name = GetSpecializationInfo(GetSpecialization())

	self:AddLine(0, format(LOOT_SPECIALIZATION_DEFAULT, name), lootspec == 0)

	for i = 1, GetNumSpecializations() do
		id, name = GetSpecializationInfo(i)
		self:AddLine(id, name, lootspec == id)
	end
end

function tooltip:AddLine(id, name, active)
	local line = self.tip:AddLine()

	self.tip:SetCell(line, 1, active, self:GetIconProvider())
	self.tip:SetCell(line, 2, name)
	self.tip:SetLineScript(line, 'OnMouseUp', self:GetLineScript(id))

	return line
end

function tooltip:GetLineScript(id)
	return function()
		addon.SetLootSpecialization(id)
		self:Hide()
	end
end

function tooltip:GetIconProvider()
	if self.iconProvider then
		return self.iconProvider
	end

	local provider, prototype = LibQTip:CreateCellProvider()

	function prototype:InitializeCell()
		self.texture = self:CreateTexture()
		self.texture:SetAllPoints(self)
	end

	function prototype:SetupCell(tooltip, value)
		local texture = self.texture

		texture:SetWidth(8)
		texture:SetHeight(8)

		if value then
			texture:SetTexture('Interface\\Buttons\\UI-RadioButton')
			texture:SetTexCoord(0.31, 0.44, 0.1, 0.9)
		else
			texture:SetTexture(0, 0, 0, 0)
		end

		return texture:GetWidth(), texture:GetHeight()
	end

	self.iconProvider = provider

	return provider
end

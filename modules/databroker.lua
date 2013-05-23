local name, addon = ...
local broker = addon:NewModule('DataBroker')

function broker:OnInitialize()
	self.type = 'data source'
	self:SetValue('Unknown', 'Interface\\Icons\\INV_Misc_Coin_06')

	LibStub('LibDataBroker-1.1'):NewDataObject(name, self)
end

function broker:OnEnable()
	addon:Subscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
	addon:TriggerLootSpecUpdated()
end

function broker:OnDisable()
	addon:Unsubscribe('LOOT_SPEC_UPDATED', self, 'OnLootSpecUpdated')
end

function broker:OnLootSpecUpdated()
	local lootspec, id, name, description, icon = addon.GetLootSpecialization()

	if not name then
		name = 'Unknown'
	end

	if lootspec == 0 then
		name = name .. '*'
	end

	self:SetValue(name, icon)
end

function broker:SetValue(value, icon)
	self.text = addon.L['Loot'] .. ': ' .. value
	self.value = value
	self.icon = icon
end

function broker.OnEnter(frame)
	if broker.enabledState then
		addon:Publish('MOUSE_ENTER', frame)
	end
end

function broker.OnLeave(frame)
	if broker.enabledState then
		addon:Publish('MOUSE_LEAVE', frame)
	end
end

function broker.OnClick(frame, ...)
	if broker.enabledState then
		addon:Publish('MOUSE_CLICK', frame, ...)
	end
end

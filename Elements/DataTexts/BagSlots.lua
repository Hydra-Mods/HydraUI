local HydraUI, Language, Assets, Settings = select(2, ...):get()

local GetNumSlots
local GetNumFreeSlots
local ContainerToInventoryID
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local Label = Language["Bags"]

if C_Container then
	GetNumSlots = C_Container.GetContainerNumSlots
	GetNumFreeSlots = C_Container.GetContainerNumFreeSlots
	ContainerToInventoryID = C_Container.ContainerIDToInventoryID
else
	GetNumSlots = GetContainerNumSlots
	GetNumFreeSlots = GetContainerNumFreeSlots
	ContainerToInventoryID = ContainerIDToInventoryID
end

local OnEnter = function(self)
	self:SetTooltip()

	GameTooltip:AddLine(Language["Inventory"])
	GameTooltip:AddLine(" ")

	for i = 0, NUM_BAG_SLOTS do
		local NumSlots = GetNumSlots(i)

		if NumSlots then
			local FreeSlots = GetNumFreeSlots(i)
			local Name = "|cFFFFFFFF[" .. BACKPACK_TOOLTIP .. "]|r"

			if (i > 0) then
				Name = GetInventoryItemLink("player", ContainerToInventoryID(i))

				if Name then
					local Texture = select(10, GetItemInfo(Name))

					GameTooltip:AddDoubleLine(format("|T%s:14:14:0:0:64:64:4:60:4:60|t  %s", Texture, Name), format("%s/%s", NumSlots-FreeSlots, NumSlots), nil, nil, nil, 1, 1, 1)
				end
			else
				GameTooltip:AddDoubleLine(format("|T%s:14:14:0:0:64:64:4:60:4:60|t  %s", 130716, Name), format("%s/%s", NumSlots-FreeSlots, NumSlots), nil, nil, nil, 1, 1, 1)
			end
		end
	end

	local Total, Profit = HydraUI:GetTrashValue()

	if (Total > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(Language["|cFF9D9D9D[Poor quality]|r item value:"], GetCoinTextureString(Profit), 1, 1, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local TotalSlots = 0
	local FreeSlots = 0

	for i = 0, NUM_BAG_SLOTS do
		local NumSlots = GetNumSlots(i)

		if NumSlots then
			FreeSlots = FreeSlots + GetNumFreeSlots(i)
			TotalSlots = TotalSlots + NumSlots
		end
	end

	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s/%s|r", Settings["data-text-label-color"], Label, HydraUI.ValueColor, TotalSlots-FreeSlots, TotalSlots)
end

local OnEnable = function(self)
	self:RegisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", ToggleAllBags)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)

	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)

	self.Text:SetText("")
end

HydraUI:AddDataText("Bag Slots", OnEnable, OnDisable, Update)
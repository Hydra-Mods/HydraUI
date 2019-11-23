local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local Label = Language["Bags"]

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	GameTooltip:AddLine(Language["Inventory"])
	GameTooltip:AddLine(" ")
	
	for i = 0, NUM_BAG_SLOTS do
		local NumSlots = GetContainerNumSlots(i)
		
		if NumSlots then
			local FreeSlots = GetContainerNumFreeSlots(i)
			local Name = "|cffFFFFFF[" .. BACKPACK_TOOLTIP .. "]|r"
			
			if (i > 0) then
				Name = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
			end
			
			if Name then
				GameTooltip:AddDoubleLine(Name, format("%s/%s", NumSlots-FreeSlots, NumSlots), nil, nil, nil, 1, 1, 1)
			end
		end
	end
	
	local Total, Profit = vUI:GetTrashValue()
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(Language["Trash item vendor value:"], GetCoinTextureString(Profit), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local TotalSlots = 0
	local FreeSlots = 0
	
	for i = 0, NUM_BAG_SLOTS do
		local NumSlots = GetContainerNumSlots(i)
		
		if NumSlots then
			FreeSlots = FreeSlots + GetContainerNumFreeSlots(i)
			TotalSlots = TotalSlots + NumSlots
		end
	end
	
	self.Text:SetFormattedText("%s: %s/%s", Label, TotalSlots-FreeSlots, TotalSlots)
end

local OnEnable = function(self)
	self:RegisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("BAG_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

DT:SetType("Bag Slots", OnEnable, OnDisable, Update)
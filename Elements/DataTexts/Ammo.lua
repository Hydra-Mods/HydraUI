local HydraUI, Language, Assets, Settings = select(2, ...):get()

local select = select
local GetItemInfo = GetItemInfo
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCount = GetInventoryItemCount

local Label = AMMOSLOT
local ThrownSubType = LE_ITEM_WEAPON_THROWN

local OnEnter = function(self)
	self:SetTooltip()
	
	if GetInventoryItemID("player", 0) then
		GameTooltip:SetInventoryItem("player", 0)
	elseif GetInventoryItemID("player", 18) then
		GameTooltip:SetInventoryItem("player", 18)
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self)
	local Count = 0
	
	if (GetInventoryItemID("player", 0) > 0) then -- Ammo slot
		Count = GetInventoryItemCount("player", 0)
	else
		Count = GetInventoryItemCount("player", 18)
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Count)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Ammo", OnEnable, OnDisable, Update)
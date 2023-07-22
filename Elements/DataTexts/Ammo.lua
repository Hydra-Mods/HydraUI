local HydraUI, Language, Assets, Settings = select(2, ...):get()

local select = select
local GetItemInfo = GetItemInfo
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCount = GetInventoryItemCount

local Label = AMMOSLOT
local ThrownSubType = LE_ITEM_WEAPON_THROWN
local PreviousCount = 0

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
	if InCombatLockdown() then
		return print(ERR_NOT_IN_COMBAT)
	end

	ToggleCharacter("PaperDollFrame")
end

local Update = function(self)
	local Count = 0

	if (GetInventoryItemID("player", 0) > 0) then -- Ammo slot
		Count = GetInventoryItemCount("player", 0)
	elseif (GetInventoryItemCount("player", 18) and GetInventoryItemCount("player", 18) > 1) then -- Ranged slot
		Count = GetInventoryItemCount("player", 18)
	end

	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, HydraUI.ValueColor, Count)

	if (PreviousCount > 0 and Count < 50) then -- Make sure we had ammo
		self.Anim:Play()
	elseif (PreviousCount < 50 and Count > 50) then -- We didn't have enough ammo, but now we do.
		self.Anim:Stop()
		self.Anim:SetChange(0.5)
		self.Highlight:SetAlpha(0)
	end

	PreviousCount = Count
end

local OnFinished = function(self)
	self:SetChange(self:GetChange() == 0 and 0.5 or 0)
	self:Play()
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)

	if (not self.Anim) then
		self.Anim = LibMotion:CreateAnimation(self.Highlight, "Fade")
		self.Anim:SetEasing("inout")
		self.Anim:SetDuration(1.2)
		self.Anim:SetChange(0.5)
		self.Anim:SetScript("OnFinished", OnFinished)
	end

	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)

	self.Highlight:SetAlpha(0)

	self.Text:SetText("")
end

HydraUI:AddDataText("Ammo", OnEnable, OnDisable, Update)
local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Slots = {1, 3, 5, 9, 10, 6, 7, 8, 16, 17, 18}
local GetRepairAllCost = GetRepairAllCost
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemDurability = GetInventoryItemDurability
local floor = math.floor
local format = format
local Label = Language["Durability"]

local ScanTooltip = CreateFrame("GameTooltip", nil, UIParent, "GameTooltipTemplate")

local OnEnter = function(self)
	self:SetTooltip()
	
	GameTooltip:AddLine(Label)
	GameTooltip:AddLine(" ")
	
	local TotalCost = 0
	local Current, Max, HasItem, HasCooldown, RepairCost
	
	for i = 1, #Slots do
		Current, Max = GetInventoryItemDurability(Slots[i])
		
		if Current then
			GameTooltip:AddDoubleLine(format("|T%s:14:14:0:0:64:64:4:60:4:60|t  %s", GetInventoryItemTexture("player", Slots[i]), GetInventoryItemLink("player", Slots[i])), format("%s%%", floor(Current / Max * 100)), 1, 1, 1, 1, 1, 1)
			
			HasItem, HasCooldown, RepairCost = ScanTooltip:SetInventoryItem("player", Slots[i], true)
			
			if (HasItem and RepairCost) then
				TotalCost = TotalCost + RepairCost
			end
		end
	end
	
	if (TotalCost > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(format("%s %s", REPAIR_COST, GetCoinTextureString(TotalCost)), 1, 1, 1)
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
	local Total, Count = 0, 0
	local Current, Max
	
	for i = 1, #Slots do
		Current, Max = GetInventoryItemDurability(Slots[i])
		
		if Current then
			Total = Total + (Current / Max)
			Count = Count + 1
		end
	end
	
	local Percent = floor(Total / Count * 100)
	
	if (Count > 0) then
		self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Percent)
	else
		self.Text:SetFormattedText("|cFF%s%s:|r |cFF%sN/A|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"])
	end
	
	if (25 > Percent and not self.Anim:IsPlaying()) then
		self.Anim:Play()
	elseif (Percent > 25 and self.Anim:IsPlaying()) then
		self.Anim:Stop()
		self.Anim:SetChange(0.5)
		self.Highlight:SetAlpha(0)
	end
end

local OnFinished = function(self)
	self:SetChange(self:GetChange() == 0 and 0.5 or 0)
	self:Play()
end

local OnEnable = function(self)
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("MERCHANT_SHOW")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	if (not self.Anim) then
		self.Anim = CreateAnimationGroup(self.Highlight):CreateAnimation("Fade")
		self.Anim:SetEasing("inout")
		self.Anim:SetDuration(1.2)
		self.Anim:SetChange(0.5)
		self.Anim:SetScript("OnFinished", OnFinished)
	end
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_SHOW")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Durability", OnEnable, OnDisable, Update)
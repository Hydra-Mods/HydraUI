local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local UnitHasMana = UnitHasMana
local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local NOT_APPLICABLE = NOT_APPLICABLE
local Label = BUTTON_LAG_MAIL

local OnEnter = function(self)
	if (not UnitHasMana("player")) then
		return
	end

	self:SetTooltip()
	
	local One, Two, Three = GetLatestThreeSenders()
	local Result = 0
	
	if One then
		Result = Result + 1
		GameTooltip:AddDoubleLine(BUTTON_LAG_MAIL, One)
	end
	
	if Two then
		Result = Result + 1
		GameTooltip:AddDoubleLine(BUTTON_LAG_MAIL, Two)
	end
	
	if Three then
		Result = Result + 1
		GameTooltip:AddDoubleLine(BUTTON_LAG_MAIL, Three)
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event)
	local One, Two, Three = GetLatestThreeSenders()
	local Result = 0
	
	if One then
		Result = Result + 1
	end
	
	if Two then
		Result = Result + 1
	end
	
	if Three then
		Result = Result + 1
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Result)
end

local OnEnable = function(self)
	self:RegisterEvent("UPDATE_PENDING_MAIL")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UPDATE_PENDING_MAIL")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText(Label, OnEnable, OnDisable, Update)
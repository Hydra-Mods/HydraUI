local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local UnitHasMana = UnitHasMana
local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local NOT_APPLICABLE = NOT_APPLICABLE
local Label = MANA_REGEN

local OnEnter = function(self)
	if (not UnitHasMana("player")) then
		return
	end

	self:SetTooltip()
	
	local Base, Combat = GetManaRegen()
	
	GameTooltip:AddLine(format("%s %s", Label, HydraUI:Comma(floor(Combat * 5))), 1, 1, 1)
	GameTooltip:AddLine(format(MANA_REGEN_TOOLTIP, HydraUI:Comma(floor(Base * 5))))
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Result
	
	if UnitHasMana("player") then
		local Base, Combat = GetManaRegen()
		
		if InCombatLockdown() then
			Result = floor(Combat * 5)
		else
			Result = floor(Base * 5)
		end
	else
		Result = NOT_APPLICABLE
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Result)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("UNIT_MAXPOWER")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("UNIT_MAXPOWER")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Mana Regen", OnEnable, OnDisable, Update)
local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local Label = Language["Regen"]

local OnEnter = function(self)
	self:SetTooltip()
	
	local Base, Casting = GetManaRegen()
	
	GameTooltip:AddLine(format(MANA_COMBAT_REGEN_TOOLTIP, floor(Casting * 5)), nil, nil, nil, true)
	
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
	
	local Base, Casting = GetManaRegen()
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.0f|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], (InCombatLockdown() and Casting or Base) * 5)
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

vUI:AddDataText("Regen", OnEnable, OnDisable, Update)
local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetManaRegen = GetManaRegen
local InCombatLockdown = InCombatLockdown
local Label = Language["Regen"]

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Base, Casting = GetManaRegen()
	local Regen
	
	if InCombatLockdown() then
		Regen = Casting * 5
	else
		Regen = Base * 5
	end
	
	self.Text:SetFormattedText("|cff%s%s:|r |cff%s%.0f|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Regen)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

vUI:AddDataText("Regen", OnEnable, OnDisable, Update)
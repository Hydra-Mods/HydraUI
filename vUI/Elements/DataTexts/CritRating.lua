local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetRangedCritChance = GetRangedCritChance
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance
local Label = Language["Crit"]

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
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
	
	local Crit
	local Spell = GetSpellCritChance()
	local Melee = GetCritChance()
	
	if (vUI.UserClass == "HUNTER") then
		Crit = GetRangedCritChance()
	elseif (Spell > Melee) then
		Crit = Spell
	else
		Crit = Melee
	end
	
	self.Text:SetFormattedText("|cff%s%s:|r |cff%s%.2f%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Crit)
end

local OnEnable = function(self)
	self:RegisterUnitEvent("UNIT_STATS", "player")
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:SetScript("OnEvent", Update)
	--self:SetScript("OnEnter", OnEnter)
	--self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:SetScript("OnEvent", nil)
	--self:SetScript("OnEnter", nil)
	--self:SetScript("OnLeave", nil)
	self:SetScript("OnLeave", OnMouseUp)
	
	self.Text:SetText("")
end

DT:SetType("Crit", OnEnable, OnDisable, Update)
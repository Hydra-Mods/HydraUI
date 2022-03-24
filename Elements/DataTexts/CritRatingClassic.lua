local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetRangedCritChance = GetRangedCritChance
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance
local max = max
local Label = CRIT_ABBR

local GetSpellCrit = function()
	local Max = GetSpellCritChance(2)
	
	for i = 3, 7 do
		Max = max(Max, GetSpellCritChance(i))
	end
	
	return Max
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local Crit
	local Spell = GetSpellCrit()
	local Melee = GetCritChance()
	
	if (HydraUI.UserClass == "HUNTER") then
		GameTooltip:AddLine(format("%s %.2f%%", RANGED_CRIT_CHANCE, GetRangedCritChance()))
		GameTooltip:AddLine(format(CR_CRIT_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED)), 1, 1, 1)
	elseif (Spell > Melee) then
		GameTooltip:AddLine(format("%s %.2f%%", SPELL_CRIT_CHANCE, Spell))
		GameTooltip:AddLine(format(CR_CRIT_TOOLTIP, GetCombatRating(CR_CRIT_SPELL), GetCombatRatingBonus(CR_CRIT_SPELL)), 1, 1, 1)
	else
		GameTooltip:AddLine(format("%s %.2f%%", MELEE_CRIT_CHANCE, Melee))
		GameTooltip:AddLine(format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE)), 1, 1, 1)
	end
	
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
	local Spell = GetSpellCrit()
	local Melee = GetCritChance()
	
	if (HydraUI.UserClass == "HUNTER") then
		Crit = GetRangedCritChance()
	elseif (Spell > Melee) then
		Crit = Spell
	else
		Crit = Melee
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.2f%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Crit)
end

local OnEnable = function(self)
	self:RegisterUnitEvent("UNIT_STATS", "player")
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:SetScript("OnEvent", Update)
	--self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
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
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Crit", OnEnable, OnDisable, Update)
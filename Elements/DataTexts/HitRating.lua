local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetCombatRatingBonus = GetCombatRatingBonus
local Label = HIT

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local Melee = GetCombatRatingBonus(CR_HIT_MELEE)
	local Spell = GetCombatRatingBonus(CR_HIT_SPELL)
	
	if (HydraUI.UserClass == "HUNTER") then
		GameTooltip:AddLine(format("%s %s", COMBAT_RATING_NAME6, GetCombatRating(CR_HIT_RANGED)))
		GameTooltip:AddLine(format(CR_HIT_MELEE_TOOLTIP, UnitLevel("player"), GetCombatRatingBonus(CR_HIT_RANGED), GetArmorPenetration()), 1, 1, 1)
	elseif (Spell > Melee) then
		GameTooltip:AddLine(format("%s %s", COMBAT_RATING_NAME6, GetCombatRating(CR_HIT_SPELL)))
		GameTooltip:AddLine(format(CR_HIT_SPELL_TOOLTIP, UnitLevel("player"), GetCombatRatingBonus(CR_HIT_SPELL), GetSpellPenetration(), GetSpellPenetration()), 1, 1, 1)
	else
		GameTooltip:AddLine(format("%s %s", COMBAT_RATING_NAME6, GetCombatRating(CR_HIT_MELEE)))
		GameTooltip:AddLine(format(CR_HIT_MELEE_TOOLTIP, UnitLevel("player"), GetCombatRatingBonus(CR_HIT_MELEE), GetArmorPenetration()), 1, 1, 1)
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating = 0
	local Melee = GetCombatRatingBonus(CR_HIT_MELEE)
	local Spell = GetCombatRatingBonus(CR_HIT_SPELL)
	
	if (HydraUI.UserClass == "HUNTER") then
		Rating = GetCombatRatingBonus(CR_HIT_RANGED)
	elseif (Spell > Melee) then
		Rating = Spell
	else
		Rating = Melee
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.2f%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Rating)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText(Label, OnEnable, OnDisable, Update)
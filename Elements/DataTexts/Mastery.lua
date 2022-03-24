local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetMasteryEffect = GetMasteryEffect
local GetCombatRatingBonus = GetCombatRatingBonus
local CR_MASTERY = CR_MASTERY
local Label = STAT_MASTERY

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local Mastery, Bonus = GetMasteryEffect()
	local MasteryBonus = GetCombatRatingBonus(CR_MASTERY) * Bonus
	local Spec = GetSpecialization()
	
	if Spec then
		local MasterySpell, MasterySpell2 = GetSpecializationMasterySpells(Spec)
		
		if (MasterySpell) then
			GameTooltip:AddSpellByID(MasterySpell)
		end
		
		if MasterySpell2 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddSpellByID(MasterySpell2)
		end
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, HydraUI:Comma(GetCombatRating(CR_MASTERY)), MasteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
	else
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, HydraUI:Comma(GetCombatRating(CR_MASTERY)), MasteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
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
	
	local Mastery, Bonus = GetMasteryEffect()
	local MasteryBonus = GetCombatRatingBonus(CR_MASTERY) * Bonus
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.2f%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], MasteryBonus)
end

local OnEnable = function(self)
	self:RegisterUnitEvent("UNIT_STATS", "player")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Mastery", OnEnable, OnDisable, Update)
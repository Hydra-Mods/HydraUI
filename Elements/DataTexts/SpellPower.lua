local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetTalentTabInfo = GetTalentTabInfo

local HealingLabel = STAT_SPELLHEALING
local SpellLabel = STAT_SPELLDAMAGE

local GetHighestSpellPower = function()
	local Power = 0
	
	for i = 2, 7 do
		Power = max(Power, GetSpellBonusDamage(i))
	end
	
	return Power
end

local GetSpecInfo = function()
	local MainSpecID
	local HighestPoints = 0
	local Name, PointsSpent, _
	
	for i = 1, 3 do
		Name, _, PointsSpent = GetTalentTabInfo(i)
		
		if Name then
			if (PointsSpent > HighestPoints) then
				MainSpecID = i
				HighestPoints = PointsSpent
			end
		end
	end
	
	return MainSpecID
end

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating
	local Label
	
	local Spell = GetHighestSpellPower()
	local Healing = GetSpellBonusHealing()
	
	if (Spell > 0 or Healing > 0) then
		if (Spell > Healing) or (HydraUI.UserClass == "SHAMAN" and GetSpecInfo() ~= 3) then
			Rating = Spell
			Label = SpellLabel
		else
			Rating = Healing
			Label = HealingLabel
		end
	else
		Label = SpellLabel
		Rating = 0
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Rating)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:UnregisterEvent("UNIT_AURA")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Spell Power", OnEnable, OnDisable, Update)
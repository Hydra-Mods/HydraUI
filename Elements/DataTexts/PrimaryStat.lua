local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local UnitStat = UnitStat

local ValidStat = {
	[1] = SPELL_STAT1_NAME,
	[2] = SPELL_STAT2_NAME,
	[4] = SPELL_STAT4_NAME,
}

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Stat, StatEffective, PositiveBuffs, NegativeBuffs
	local Highest = 0
	local HighestStat = 0
	
	for i = 1, 4 do
		if ValidStat[i] then
			Stat, StatEffective, PositiveBuffs, NegativeBuffs = UnitStat("player", i)
			
			Effective = StatEffective + PositiveBuffs + NegativeBuffs
			
			if (Effective > HighestStat) then
				Highest = i
				HighestStat = Stat
			end
		end
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], ValidStat[Highest], Settings["data-text-value-color"], HighestStat)
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

HydraUI:AddDataText("Primary Stat", OnEnable, OnDisable, Update)
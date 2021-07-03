local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local UnitArmor = UnitArmor
local Label = ARMOR

local OnEnter = function(self)
	self:SetTooltip()
	
	local Base, EffectiveArmor = UnitArmor("player")
	local Level = UnitLevel("player")
    local ArmorReduction = EffectiveArmor / ((85 * Level) + 400)
	ArmorReduction = 100 * (ArmorReduction / (ArmorReduction + 1))
	
	GameTooltip:AddLine(format("%s %s", Label, HydraUI:Comma(EffectiveArmor)), 1, 1, 1)
	GameTooltip:AddLine(format(STAT_ARMOR_TOOLTIP, ArmorReduction), nil, nil, nil, true)
	
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
	
	local Base, EffectiveArmor = UnitArmor("player")
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], HydraUI:Comma(EffectiveArmor))
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
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

HydraUI:AddDataText("Armor", OnEnable, OnDisable, Update)
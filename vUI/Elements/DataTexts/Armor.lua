local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local Label = Language["Armor"]

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Base, EffectiveArmor, Armor, PosBuff, NegBuff = UnitArmor("player")
	local Level = UnitLevel("player")
	local Reduction = EffectiveArmor / ((85 * Level) + 400)
	
	Reduction = 100 * (Reduction / (Reduction + 1))
	
	self.Text:SetFormattedText("%s: %.1f%%", Label, Reduction)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

DT:SetType("Armor", OnEnable, OnDisable, Update)
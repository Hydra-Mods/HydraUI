local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing

local HealingLabel = Language["Spell Healing"]
local SpellLabel = Language["Spell Damage"]

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating
	local Label
	
	local Spell = GetSpellBonusDamage(7)
	local Healing = GetSpellBonusHealing()
	
	if (Spell > 0 or Healing > 0) then
		if (Healing > Spell) then
			Rating = Healing
			Label = HealingLabel
		else
			Rating = Spell
			Label = SpellLabel
		end
	else
		Label = SpellLabel
		Rating = 0
	end
	
	self.Text:SetFormattedText("|cff%s%s:|r |cff%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Rating)
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

DT:SetType("Spell Power", OnEnable, OnDisable, Update)
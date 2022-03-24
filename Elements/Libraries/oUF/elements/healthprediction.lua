local _, ns = ...
local oUF = ns.oUF

local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local Update = function(self, event, unit)
	if (self.unit ~= unit) then
		return
	end
	
	local IncomingHeals = UnitGetIncomingHeals(unit) or 0
	local Health = UnitHealth(unit)
	local MaxHealth = UnitHealthMax(unit)
	
	if self.HealBar then
		self.HealBar:SetMinMaxValues(0, MaxHealth)
		
		if (IncomingHeals == 0) then
			self.HealBar:SetValue(0)
		elseif (Health + IncomingHeals >= MaxHealth) then
			self.HealBar:SetValue(MaxHealth - Health)
		else
			self.HealBar:SetValue(IncomingHeals)
		end
	end
	
	if self.AbsorbsBar then
		local TotalAbsorbs = UnitGetTotalAbsorbs(unit) or 0
		
		self.AbsorbsBar:SetMinMaxValues(0, MaxHealth)
		
		if (TotalAbsorbs == 0) then
			self.AbsorbsBar:SetValue(0)
		elseif (Health + TotalAbsorbs >= MaxHealth) then
			self.AbsorbsBar:SetValue(MaxHealth - Health)
		else
			self.AbsorbsBar:SetValue(TotalAbsorbs)
		end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	if self.HealBar then
		self:RegisterEvent("UNIT_HEAL_PREDICTION", Update)
		self:RegisterEvent("UNIT_MAXHEALTH", Update)
		self:RegisterEvent("UNIT_HEALTH", Update)
		self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Update)
		self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Update)
		
		self.HealBar.__owner = self
		self.HealBar.ForceUpdate = ForceUpdate
		
		self.HealBar:Show()
		
		if self.AbsorbsBar then
			self.AbsorbsBar.__owner = self
			self.AbsorbsBar.ForceUpdate = ForceUpdate
			
			self.AbsorbsBar:SetMinMaxValues(0, 1)
			self.AbsorbsBar:SetValue(0)
			self.AbsorbsBar:Show()
		end
		
		return true
	end
end

local Disable = function(self)
	if self.HealBar then
		self.HealBar:Hide()
		
		if self.AbsorbsBar then
			self.AbsorbsBar:Hide()
		end
		
		self:UnregisterEvent("UNIT_HEAL_PREDICTION", Update)
		self:UnregisterEvent("UNIT_MAXHEALTH", Update)
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", Update)
		self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Update)
	end
end

oUF:AddElement("HealPrediction", Update, Enable, Disable)
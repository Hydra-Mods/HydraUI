local _, ns = ...
local oUF = ns.oUF

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local OnUpdate = function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	
	self:SetValue(self.elapsed)
	
	if (self.elapsed >= self.max) then
		self.LastPower = UnitPower("player")
		self:Hide()
		
		self:ForceUpdate() -- Update to begin ticking
	end
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Type = UnitPowerType("player")
	local Power = UnitPower("player")
	
	if (Type ~= 0) then
		return
	elseif (Power == UnitPowerMax("player")) then -- Max mana or a level up
		self.LastPower = UnitPower("player")
		self:Hide()
		
		return
	end
	
	if (self.LastPower > Power) then -- Cast
		self.elapsed = 0
		self.max = 5.5 -- 5-ish second rule
		self:SetMinMaxValues(0, self.max)
		self:Show()
		self:SetScript("OnUpdate", OnUpdate)
	elseif (Power > self.LastPower) then -- Tick
		self.elapsed = 0
		self.max = 2
		self:SetMinMaxValues(0, self.max)
		self:Show()
		self:SetScript("OnUpdate", OnUpdate)
	end
	
	self.LastPower = Power
end

local Path = function(self, ...)
	return (self.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local element = self.ManaTimer
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		element.LastPower = UnitPower("player")
		element:Hide()
		element:RegisterEvent("UNIT_POWER_FREQUENT")
		element:SetScript("OnEvent", Update)
	end
end

local Disable = function(self)
	local element = self.ManaTimer
	
	if element then
		element:Hide()
		element:UnregisterEvent("UNIT_POWER_FREQUENT")
		element:SetScript("OnEvent", nil)
	end
end

oUF:AddElement("ManaRegen", Path, Enable, Disable)
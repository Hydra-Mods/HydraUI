if (select(2, UnitClass("player")) ~= ("ROGUE" or "DRUID")) then
	return
end

local _, ns = ...
local oUF = ns.oUF

local UnitPower = UnitPower
local GetTime = GetTime

local LastTick = GetTime()
local LastPower = 0

local OnUpdate = function(self)
	local Power = UnitPower("player")
	local Time = GetTime()
	local Value = Time - LastTick
	
	if (Power > LastPower) or (Value >= 2) then
		LastTick = Time
	end
	
	self:SetValue(Value)
	
	LastPower = Power
end

local ForceUpdate = function(element)
	return OnUpdate(element)
end

local Path = function(self)
	return OnUpdate(self.EnergyTick)
end

local Enable = function(self)
	local element = self.EnergyTick
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		element:SetMinMaxValues(0, 2)
		element:SetScript("OnUpdate", OnUpdate)
		element:Show()
	end
end

local Disable = function(self)
	local element = self.EnergyTick
	
	if element then
		element:Hide()
		element:SetScript("OnUpdate", nil)
	end
end

oUF:AddElement("EnergyTick", Path, Enable, Disable)
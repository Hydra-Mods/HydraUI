if (select(2, UnitClass("player") ~= "WARLOCK")) then
	return
end

local _, ns = ...
local oUF = ns.oUF

local floor = floor
local UnitPower = UnitPower
local UnitPowerDisplayMod = UnitPowerDisplayMod

local Current
local Shards
local Fragments
local Power
local Modifier

local GetWarlockPower = function()
	Power = UnitPower("player", 7, true)
	Modifier = UnitPowerDisplayMod(7)
	
	return (Modifier ~= 0) and (Power / Modifier) or 0
end

local Update = function(self, event, unit)
	if (self.unit ~= unit) then
		return
	end
	
	Current = GetWarlockPower()
	Shards = floor(Current)
	Fragments = (Current - Shards)
	
	for i = 1, 5 do
		if (i <= Shards) then
			if (self.SoulShards[i]:GetValue() ~= 1) then
				self.SoulShards[i]:SetAlpha(1)
			end
			
			self.SoulShards[i]:SetValue(1)
		elseif (i == (Shards + 1)) then
			self.SoulShards[i]:SetValue(Fragments)
			self.SoulShards[i]:SetAlpha(0.7)
		else
			self.SoulShards[i]:SetValue(0)
			self.SoulShards[i]:SetAlpha(0.7)
		end
	end
end

local Path = function(self, ...)
	return Update(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local element = self.SoulShards
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
		
		element:Show()
		
		return true
	end
end

local Disable = function(self)
	local element = self.SoulShards
	
	if element then
		element:Hide()
		
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
	end
end

oUF:AddElement("Soul Shards", Path, Enable, Disable)
local _, ns = ...
local oUF = ns.oUF

local UnitIsUnit = UnitIsUnit

local Update = function(self)
	if UnitIsUnit("target", self.unit) then
		self.TargetIndicator:Show()
	elseif self.TargetIndicator:IsShown() then
		self.TargetIndicator:Hide()
	end
end

local ForceUpdate = function(element)
	return Update(element)
end

local Enable = function(self)
	local element = self.TargetIndicator
	
	if element then
		element.unit = self.unit
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
		
		return true
	end
end

local Disable = function(self)
	local element = self.TargetIndicator
	
	if element then
		element:Hide()
		
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)
	end
end

oUF:AddElement("TargetIndicator", Update, Enable, Disable)
local _, ns = ...
local oUF = ns.oUF

local UnitClassification = UnitClassification

local SkullClasses = {
	["worldboss"] = "FFEB3B",
	["elite"] = "FFEB3B",
	["rareelite"] = "C0C0C0",
	["rare"] = "C0C0C0",
}

local Update = function(self, event)
	local Class = UnitClassification(self.unit)
	
	if (Class and SkullClasses[Class]) then
		self.EliteIndicator:SetVertexColorHex(SkullClasses[Class])
		self.EliteIndicator:Show()
	else
		self.EliteIndicator:Hide()
	end
end

local Path = function(self, ...)
	return (self.EliteIndicator.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	if (not element.__owner.unit) then
		return
	end
	
	return Path(element.__owner, "ForceUpdate")
end

local Enable = function(self)
	if self.EliteIndicator then
		self.EliteIndicator.__owner = self
		self.EliteIndicator.ForceUpdate = ForceUpdate
		
		return true
	end
end

local Disable = function(self)
	if self.EliteIndicator then
		self.EliteIndicator:Hide()
	end
end

oUF:AddElement("EliteIndicator", Path, Enable, Disable)
local _, ns = ...
local oUF = ns.oUF
local HydraUI = ns:get()

local GetShapeshiftFormID = GetShapeshiftFormID
local GetComboPoints = GetComboPoints
local CAT_FORM = CAT_FORM
local FormID

local Update = function(self, event, unit, power)
	if ((unit ~= self.unit) or (unit == "player" and power ~= "COMBO_POINTS")) then
		return
	end
	
	local element = self.ComboPoints
	
	if element.PreUpdate then
		element:PreUpdate()
	end
	
	local Points = GetComboPoints("player", "target")
	
	for i = 1, 5 do
		if (i > Points) then
			if (element[i]:GetAlpha() > 0.3) then
				element[i]:SetAlpha(0.3)
			end
		else
			if (element[i]:GetAlpha() < 1) then
				element[i]:SetAlpha(1)
			end
		end
	end
	
	if element.PostUpdate then
		return element:PostUpdate(Points)
	end
end

local Path = function(self, ...)
	return (self.ComboPoints.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate")
end

local UpdateForm = function(self)
	FormID = GetShapeshiftFormID()
	
	if (FormID == CAT_FORM) then
		self.ComboPoints:Show()
	else
		self.ComboPoints:Hide()
	end
	
	if self.ComboPoints.UpdateShapeshiftForm then
		self.ComboPoints:UpdateShapeshiftForm(FormID)
	end
end

local Enable = function(self)
	local element = self.ComboPoints
	
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path, true)
		self:RegisterEvent("UNIT_POWER_UPDATE", Path, true)

		if (HydraUI.UserClass == "DRUID") then
			self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateForm, true)
			self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateForm, true)
		end
		
		for i = 1, 5 do
			if (element[i]:IsObjectType("Texture") and not element[i]:GetTexture()) then
				element[i]:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
			end
			
			element[i]:SetAlpha(0.3)
		end
		
		return true
	end
end

local Disable = function(self)
	local element = self.ComboPoints
	
	if element then
		element:Hide()
		
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		self:UnregisterEvent("UNIT_POWER_UPDATE", Path)
		
		if self:IsEventRegistered("UPDATE_SHAPESHIFT_FORM") then
			self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateForm)
			self:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateForm)
		end
	end
end

oUF:AddElement("ComboPoints", Path, Enable, Disable)
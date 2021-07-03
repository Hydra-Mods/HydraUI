local _, ns = ...
local oUF = ns.oUF

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness

local Update = function(self, event)
	local element = self.PetHappiness
	
	if element.PreUpdate then
		element:PreUpdate()
	end
	
	local Happiness = GetPetHappiness()
	local HasUI, IsHunter = HasPetUI()
	
	if (Happiness and IsHunter) then
		if (Happiness == 1) then
			element:SetTexCoord(0.375, 0.5625, 0, 0.359375)
		elseif (Happiness == 2) then
			element:SetTexCoord(0.1875, 0.375, 0, 0.359375)
		else
			element:SetTexCoord(0, 0.1875, 0, 0.359375)
		end
		
		element:Show()
	else
		element:Hide()
	end
	
	if element.PostUpdate then
		return element:PostUpdate(Happiness)
	end
end

local Path = function(self, ...)
	return (self.PetHappiness.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate")
end

local Enable = function(self, unit)
	if (unit ~= "pet") then
		return
	end
	
	local element = self.PetHappiness
	
	if (not element) then
		return
	end
	
	element.__owner = self
	element.ForceUpdate = ForceUpdate
	
	self:RegisterEvent("UNIT_HAPPINESS", Path, true)
	
	if (element:IsObjectType("Texture") and not element:GetTexture()) then
		element:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
	end
	
	return true
end

local Disable = function(self)
	local element = self.PetHappiness
	
	if element then
		element:Hide()
		
		self:UnregisterEvent("UNIT_HAPPINESS", Path)
	end
end

oUF:AddElement("Happiness", Path, Enable, Disable)
if 1 == 1 then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF Fade: unable to locate oUF")

local UnitAffectingCombat = UnitAffectingCombat
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local GetMouseFocus = GetMouseFocus

local Update = function(self, event)
    if (UnitAffectingCombat(self.unit)) or (UnitExists("playertarget")) or (UnitExists(self.unit .. "target")) or (UnitHealth(self.unit) < UnitHealthMax(self.unit)) or (GetMouseFocus() == self) then
		if (self:GetAlpha() < 1) then
			self.Fade:SetChange(1)
			self.Fade:SetEasing("in")
			self.Fade:Play()
		end
	else
		if (self:GetAlpha() > 0) then
			self.Fade:SetChange(0)
			self.Fade:SetEasing("out")
			
			self.Group:Play()
		end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", Update, true)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", Update, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
	self:RegisterEvent("UNIT_HEALTH_FREQUENT", Update)
	self:RegisterEvent("UNIT_MAXHEALTH", Update)
	
	self:HookScript("OnEnter", Update)
	self:HookScript("OnLeave", Update)
	
	self.Group = CreateAnimationGroup(self)
	
	self.Sleep = self.Group:CreateAnimation("Sleep")
	self.Sleep:SetDuration(1)
	
	self.Fade = self.Group:CreateAnimation("Fade")
	self.Fade:SetDuration(0.15)
	self.Fade:SetOrder(2)
	
	return true
end

local Disable = function(self)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
	self:UnregisterEvent("UNIT_MAXHEALTH")
end

oUF:AddElement("Fade", Update, Enable, Disable)
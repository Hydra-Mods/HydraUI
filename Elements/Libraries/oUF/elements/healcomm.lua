local _, ns = ...
local oUF = ns.oUF

local HealComm = LibStub("LibHealComm-4.0")

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGUID = UnitGUID
local select = select

local Update = function(self, event, unit)
	if (self.unit ~= unit) then
		return
	end
	
	local GUID = UnitGUID(unit)
	local IncomingHeals = (HealComm:GetHealAmount(GUID, HealComm.ALL_HEALS) or 0) * (HealComm:GetHealModifier(GUID) or 1)
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
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	if self.HealBar then
		local GUID
		
		local UpdateUnit = function(...)
			for i = 1, select("#", ...) do
				GUID = select(i, ...)
				
				if (UnitGUID(self.unit) == GUID) then
					Update(self, nil, self.unit)
					
					break
				end
			end
		end
		
		local HealUpdated = function(callback, casterguid, spellid, datatype, expiration, ...)
			UpdateUnit(...)
		end
		
		local ModifierChanged = function(callback, casterguid, mod)
			UpdateUnit(casterguid)
		end
		
		local GUIDDisappeared = function(callback, casterguid)
			UpdateUnit(casterguid)
		end
		
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
		self:RegisterEvent("UNIT_HEALTH_FREQUENT", Update)
		self:RegisterEvent("UNIT_MAXHEALTH", Update)
		
		HealComm.RegisterCallback(self, "HealComm_HealStarted", HealUpdated)
		HealComm.RegisterCallback(self, "HealComm_HealUpdated", HealUpdated)
		HealComm.RegisterCallback(self, "HealComm_HealDelayed", HealUpdated)
		HealComm.RegisterCallback(self, "HealComm_HealStopped", HealUpdated)
		HealComm.RegisterCallback(self, "HealComm_ModifierChanged", ModifierChanged)
		HealComm.RegisterCallback(self, "HealComm_GUIDDisappeared", GUIDDisappeared)
		
		self.HealBar.__owner = self
		self.HealBar.ForceUpdate = ForceUpdate
		
		self.HealBar:Show()
		
		return true
	end
end

local Disable = function(self)
	if self.HealBar then
		self.HealBar:Hide()
		
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update, true)
		self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Update)
		self:UnregisterEvent("UNIT_MAXHEALTH", Update)
		
		HealComm.UnregisterCallback(self, "HealComm_HealStarted")
		HealComm.UnregisterCallback(self, "HealComm_HealUpdated")
		HealComm.UnregisterCallback(self, "HealComm_HealDelayed")
		HealComm.UnregisterCallback(self, "HealComm_HealStopped")
		HealComm.UnregisterCallback(self, "HealComm_ModifierChanged")
		HealComm.UnregisterCallback(self, "HealComm_GUIDDisappeared")
	end
end

oUF:AddElement("HealComm", Update, Enable, Disable)
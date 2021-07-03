if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then
	return
end

local parent, ns = ...
local oUF = ns.oUF

local Start, Duration, IsReady

local GetTime = GetTime
local GetRuneCooldown = GetRuneCooldown
local UnitHasVehicleUI = UnitHasVehicleUI

local OnUpdate = function(self, elapsed)
	local Duration = self.Duration + elapsed
	
	if (Duration >= self.Max) then
		self:SetScript("OnUpdate", nil)
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
		self.ReadyAnim:Play()
	else
		self.Duration = Duration
		
		self:SetValue(Duration)
	end
end

local UpdateRune = function(self, event, id)
	local Rune = self.Runes[id]
	
	if (not Rune) then
		return
	end
	
	if UnitHasVehicleUI("player") then
		Rune:Hide()
		
		return
	else
		Rune:Show()
	end
	
	Start, Duration, IsReady = GetRuneCooldown(id)
	
	if ((not IsReady) and Start) then
		Rune.Duration = GetTime() - Start
		Rune.Max = Duration
		Rune:SetMinMaxValues(0, Duration)
		Rune:SetScript("OnUpdate", OnUpdate)
	end
end

local Update = function(self, event)
	for i = 1, 6 do
		UpdateRune(self, event, i)
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate")
end

local Enable = function(self, unit)
	local Runes = self.Runes
	
	if (Runes and unit == "player") then
		Runes.__owner = self
		Runes.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("RUNE_POWER_UPDATE", UpdateRune, true)
		
		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()

		return true
	end
end

local Disable = function(self)
	RuneFrame.Show = nil
	RuneFrame:Show()
	
	self:UnregisterEvent("RUNE_POWER_UPDATE", UpdateRune)
end

oUF:AddElement("Runes", Update, Enable, Disable)
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF Dispel: unable to locate oUF")

local select = select
local Class = select(2, UnitClass("player"))
local UnitAura = UnitAura
local DebuffTypeColor = DebuffTypeColor

local Priorities = {
	["Magic"] = 5,
	["Curse"] = 4,
	["Disease"] = 3,
	["Poison"] = 2,
	["Custom"] = 1,
}

local Classes = {
	["DRUID"] = {["Magic"] = true, ["Poison"] = true, ["Disease"] = false, ["Curse"] = true},
	["MONK"] = {["Magic"] = false, ["Poison"] = true, ["Disease"] = true},
	["PALADIN"] = {["Magic"] = false, ["Poison"] = true, ["Disease"] = true},
	["PRIEST"] = {["Magic"] = true, ["Disease"] = true},
	["SHAMAN"] = {["Magic"] = false, ["Poison"] = true, ["Disease"] = true},
}

local Filter = {
	--[GetSpellInfo(186263)] = true, -- Shadow Mend
	[GetSpellInfo(124275)] = true, -- Light Stagger
	[GetSpellInfo(124274)] = true, -- Moderate Stagger
	[GetSpellInfo(124273)] = true, -- Heavy Stagger
}

-- Spells which should be watched to gauge damage or effects on players, but cannot be dispelled. (DoT's and Stuns mostly)
local Debuffs = {
	-- Affix
	["Sanguine Ichor"] = true,
	
	-- Test, remove me
	--["Weakened Soul"] = true,
}

local Valid = Classes[Class]

local UpdateSpec = function()
	local Spec = GetSpecialization()
	local Role = select(5, GetSpecializationInfo(Spec))
	
	if (Role == "HEALER") then
		Classes[Class].Magic = true
	else
		Classes[Class].Magic = false
	end
end

local Update = function(self, event, unit)
	if ((unit ~= self.unit) or not Valid) then
		return
	end
	
	local Dispel = self.Dispel
	local Found = false
	
	for i = 1, 40 do
		local Name, Icon, Count, DispelType = UnitAura(unit, i, "HARMFUL")
		
		if (not Name) then
			break
		end
		
		if ((not DispelType) and Debuffs[Name]) then
			DispelType = "Custom"
		end
		
		if (not Filter[Name]) then
			if (DispelType and Valid[DispelType] and DebuffTypeColor[DispelType]) then
				local CurrPrio = Priorities[DispelType]
				
				if (CurrPrio > Dispel.Prio) then
					Dispel.Index = i
					Dispel.Prio = CurrPrio
				end
				
				Found = true
			end
		end
	end
	
	if (Found and Dispel.Index) then
		local Name, Icon, Count, DispelType, Duration, Expires, Caster, IsStealable, NameplateShowPersonal, SpellID = UnitAura(unit, Dispel.Index, "HARMFUL")
		
		if (not Expires) then
			if Dispel:IsShown() then
				Dispel:Hide()
				Dispel.Prio = 0
				Dispel.Index = nil
				Dispel.SpellID = nil
			end
			
			return
		end
		
		Dispel.SpellID = SpellID
		Dispel.icon:SetTexture(Icon)
		Dispel.cd:SetCooldown(Expires - Duration, Duration)
		
		if (Count and Count > 1) then
			Dispel.count:SetText(Count)
		else
			Dispel.count:SetText("")
		end
		
		local Color = DebuffTypeColor[DispelType]
		
		if Color then
			Dispel:SetBackdropBorderColor(Color.r, Color.g, Color.b)
		else
			Dispel:SetBackdropBorderColor(0.9, 0.1, 0.1) -- User defined debuffs
		end
		
		if (not Dispel:IsShown()) then
			Dispel:Show()
		end
	elseif Dispel:IsShown() then
		Dispel:Hide()
		Dispel.Prio = 0
		Dispel.Index = nil
		Dispel.SpellID = nil
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local OnEnter = function(self)
	if self.SpellID then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 20)
		GameTooltip:SetSpellByID(self.SpellID)
		GameTooltip:Show()
	end
end

local OnLeave = function(self)
	GameTooltip:Hide()
end

local Enable = function(self)
	local Dispel = self.Dispel
	
	if Dispel then
		if Valid then
			self:RegisterEvent("UNIT_AURA", Update)
			Dispel.ForceUpdate = ForceUpdate
			Dispel.__owner = self
			Dispel.Prio = 0
			
			Dispel:EnableMouse(true)
			Dispel:SetScript("OnEnter", OnEnter)
			Dispel:SetScript("OnLeave", OnLeave)
			
			if (not Dispel.Updater) then
				Dispel.Updater = CreateFrame("Frame")
				Dispel.Updater:RegisterEvent("PLAYER_TALENT_UPDATE")
				Dispel.Updater:RegisterEvent("CHARACTER_POINTS_CHANGED")
				Dispel.Updater:SetScript("OnEvent", UpdateSpec)
			end
		end
		
		Dispel:Hide()
		
		return true
	end
end

local Disable = function(self)
	if self.Dispel then
		self:UnregisterEvent("UNIT_AURA", Update)
		self.Dispel:Hide()
		self.Dispel.Updater:SetScript("OnEvent", nil)
		self.Dispel.Updater:UnregisterAllEvents()
		self.Dispel:EnableMouse(false)
		self.Dispel:SetScript("OnEnter", nil)
		self.Dispel:SetScript("OnLeave", nil)
	end
end

oUF:AddElement("Dispel", Update, Enable, Disable)
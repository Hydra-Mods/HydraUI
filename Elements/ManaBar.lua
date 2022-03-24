local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Load = {DRUID = 1, PRIEST = 1, SHAMAN = 1}

if (not Load[HydraUI.UserClass]) then
	return
end

local Visibility = {
	SHAMAN = {[262] = 1, [263] = 1}, -- Elemental, Enhance
	PRIEST = {[258] = 1}, -- Shadow
}

Defaults["unitframes-show-mana-bar"] = true

local floor = floor
local format = format
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local ManaBar = HydraUI:NewModule("Mana Bar")
local ManaID = Enum.PowerType.Mana

function ManaBar:UNIT_POWER_UPDATE()
	local Mana = UnitPower("player", ManaID)
	local MaxMana = UnitPowerMax("player", ManaID)
	
	self.Bar:SetValue(Mana)
	self.Bar:SetMinMaxValues(0, MaxMana)
	
	self.Progress:SetText(format("%s / %s", HydraUI:ShortValue(Mana), HydraUI:ShortValue(MaxMana)))
	self.Percentage:SetText(floor((Mana / MaxMana * 100 + 0.05) * 10) / 10 .. "%")
end

function ManaBar:UNIT_POWER_FREQUENT()
	local Mana = UnitPower("player", ManaID)
	local MaxMana = UnitPowerMax("player", ManaID)
	
	self.Bar:SetValue(Mana)
	
	self.Progress:SetText(format("%s / %s", HydraUI:ShortValue(Mana), HydraUI:ShortValue(MaxMana)))
	self.Percentage:SetText(floor((Mana / MaxMana * 100 + 0.05) * 10) / 10 .. "%")
end

function ManaBar:UPDATE_SHAPESHIFT_FORM()
	if (UnitPowerType("player") == ManaID) then
		self:Hide()
	else
		self:Show()
	end
end

function ManaBar:ACTIVE_TALENT_GROUP_CHANGED()
	local SpecID = GetSpecializationInfo(GetSpecialization())
	
	if (SpecID and Visibility[HydraUI.UserClass][SpecID]) then
		self:Show()
	else
		self:Hide()
	end
end

function ManaBar:CreateBar()
	self:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-power-height"] + 2)
	self:SetPoint("CENTER", HydraUI.UIParent, 0, -180)
	
	self.Fade = CreateAnimationGroup(self)
	
	self.FadeIn = self.Fade:CreateAnimation("Fade")
	self.FadeIn:SetEasing("in")
	self.FadeIn:SetDuration(0.15)
	self.FadeIn:SetChange(1)
	
	self.FadeOut = self.Fade:CreateAnimation("Fade")
	self.FadeOut:SetEasing("out")
	self.FadeOut:SetDuration(0.15)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.BarBG = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.BarBG:SetPoint("TOPLEFT", self, 0, 0)
	self.BarBG:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(HydraUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(0, 0, 0)
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Bar:SetPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameLevel(6)
	
	self.Bar:SetMinMaxValues(0, UnitPowerMax("player", ManaID))
	self.Bar:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-mana"]))
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColor(HydraUI:HexToRGB(Settings["color-mana"]))
	self.Bar.BG:SetAlpha(0.2)
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetPoint("LEFT", self.Bar, 3, 0)
	HydraUI:SetFontInfo(self.Percentage, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("LEFT")
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetPoint("RIGHT", self.Bar, -3, 0)
	HydraUI:SetFontInfo(self.Progress, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("RIGHT")
	
	HydraUI:CreateMover(self)
end

function ManaBar:Enable()
	self:RegisterEvent("UNIT_POWER_UPDATE")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
	
	self:UNIT_POWER_UPDATE()
	
	if (HydraUI.UserClass == "DRUID") then
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	end
end

function ManaBar:Disable()
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:Hide()
end

function ManaBar:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

function ManaBar:Load()
	if Settings["unitframes-show-mana-bar"] then
		self:CreateBar()
		self:Enable()
		
		if (HydraUI.UserClass == "DRUID") then
			self:UPDATE_SHAPESHIFT_FORM()
		else
			self:ACTIVE_TALENT_GROUP_CHANGED()
		end
	end
end

local UpdateEnableManaBar = function(value)
	if value then
		if (not ManaBar.Bar) then
			ManaBar:CreateBar()
		end
		
		ManaBar:Enable()
	else
		ManaBar:Disable()
	end
end

GUI:AddWidgets(Language["General"], Language["Unit Frames"], function(left, right)
	right:CreateHeader(Language["Mana Bar"])
	right:CreateSwitch("unitframes-show-mana-bar", Settings["unitframes-show-mana-bar"], Language["Enable Mana Bar"], Language["Enable a mana bar for Druids/Priests/Shaman"], UpdateEnableManaBar)
end)
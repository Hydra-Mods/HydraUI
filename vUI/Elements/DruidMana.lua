local vUI, GUI, Language, Media, Settings = select(2, ...):get()

if (vUI.UserClass ~= "DRUID") then
	return
end

local floor = floor
local format = format
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local DruidMana = vUI:NewModule("Druid Mana")
local ManaID = Enum.PowerType.Mana

function DruidMana:UNIT_POWER_UPDATE()
	local Mana = UnitPower("player", ManaID)
	local MaxMana = UnitPowerMax("player", ManaID)
	
	self.Bar:SetValue(Mana)
	self.Bar:SetMinMaxValues(0, MaxMana)
	
	self.Progress:SetText(format("%s / %s", vUI:ShortValue(Mana), vUI:ShortValue(MaxMana)))
	self.Percentage:SetText(floor((Mana / MaxMana * 100 + 0.05) * 10) / 10 .. "%")
end

function DruidMana:UNIT_POWER_FREQUENT()
	local Mana = UnitPower("player", ManaID)
	local MaxMana = UnitPowerMax("player", ManaID)
	
	self.Bar:SetValue(Mana)
	
	self.Progress:SetText(format("%s / %s", vUI:ShortValue(Mana), vUI:ShortValue(MaxMana)))
	self.Percentage:SetText(floor((Mana / MaxMana * 100 + 0.05) * 10) / 10 .. "%")
end

function DruidMana:PLAYER_ENTERING_WORLD()
	self:SetScaledSize(Settings["unitframes-player-width"], Settings["unitframes-player-power-height"] + 2)
	self:SetScaledPoint("CENTER", UIParent, 0, -100)
	
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
	
	self.BarBG = CreateFrame("Frame", nil, self)
	self.BarBG:SetScaledPoint("TOPLEFT", self, 0, 0)
	self.BarBG:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(0, 0, 0)
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Bar:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameLevel(6)
	
	self.Bar:SetMinMaxValues(0, UnitPowerMax("player", ManaID))
	self.Bar:SetStatusBarColorHex(Settings["color-mana"])
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColorHex(Settings["color-mana"])
	self.Bar.BG:SetAlpha(0.2)
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetScaledPoint("LEFT", self.Bar, 3, 0)
	self.Percentage:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("LEFT")
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetScaledPoint("RIGHT", self.Bar, -3, 0)
	self.Progress:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("RIGHT")
	
	vUI:GetModule("Move"):Add(self)
	
	self:UNIT_POWER_UPDATE()
	--self:UPDATE_SHAPESHIFT_FORM()
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function DruidMana:UPDATE_SHAPESHIFT_FORM()
	if (GetShapeshiftForm() == 0) then
		self:Hide()
	else
		self:Show()
	end
end

function DruidMana:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

DruidMana:RegisterEvent("UNIT_POWER_UPDATE")
DruidMana:RegisterEvent("UNIT_POWER_FREQUENT")
DruidMana:RegisterEvent("PLAYER_ENTERING_WORLD")
--DruidMana:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
DruidMana:SetScript("OnEvent", DruidMana.OnEvent)
local HydraUI, Language, Assets, Settings = select(2, ...):get()

if (HydraUI.UserClass ~= "DRUID") then
	return
end

local floor = floor
local format = format
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local DruidMana = HydraUI:NewModule("Druid Mana")
local ManaID = Enum.PowerType.Mana

function DruidMana:UNIT_POWER_UPDATE()
	local Mana = UnitPower("player", ManaID)
	local MaxMana = UnitPowerMax("player", ManaID)
	
	self.Bar:SetValue(Mana)
	self.Bar:SetMinMaxValues(0, MaxMana)
	
	self.Progress:SetText(format("%s / %s", HydraUI:ShortValue(Mana), HydraUI:ShortValue(MaxMana)))
	self.Percentage:SetText(floor((Mana / MaxMana * 100 + 0.05) * 10) / 10 .. "%")
end

function DruidMana:UNIT_POWER_FREQUENT()
	local Mana = UnitPower("player", ManaID)
	local MaxMana = UnitPowerMax("player", ManaID)
	
	self.Bar:SetValue(Mana)
	
	self.Progress:SetText(format("%s / %s", HydraUI:ShortValue(Mana), HydraUI:ShortValue(MaxMana)))
	self.Percentage:SetText(floor((Mana / MaxMana * 100 + 0.05) * 10) / 10 .. "%")
end

function DruidMana:UPDATE_SHAPESHIFT_FORM()
	if (UnitPowerType("player") == ManaID) then
		self:Hide()
	else
		self:Show()
	end
end

function DruidMana:CreateBar()
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

function DruidMana:Enable()
	self:RegisterEvent("UNIT_POWER_UPDATE")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", self.OnEvent)
	
	self:UNIT_POWER_UPDATE()
	self:UPDATE_SHAPESHIFT_FORM()
end

function DruidMana:Disable()
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:Hide()
end

function DruidMana:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

function DruidMana:Load()
	if Settings["unitframes-show-druid-mana"] then
		self:CreateBar()
		self:Enable()
	end
end

local UpdateEnableDruidMana = function(value)
	if value then
		if (not DruidMana.Bar) then
			DruidMana:CreateBar()
		end
	
		DruidMana:Enable()
	else
		DruidMana:Disable()
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Unit Frames"], function(left, right)
	right:CreateHeader(Language["Druid Mana"])
	right:CreateSwitch("unitframes-show-druid-mana", Settings["unitframes-show-druid-mana"], Language["Enable Druid Mana"], Language["Enable a bar displaying your mana while in other forms"], UpdateEnableDruidMana)
end)
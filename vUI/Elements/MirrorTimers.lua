local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local MirrorTimers = vUI:NewModule("Mirror Timers")

local GetMirrorTimerProgress = GetMirrorTimerProgress
local GetMirrorTimerInfo = GetMirrorTimerInfo

MirrorTimers.Colors = {
	["EXHAUSTION"] = "FFE500",
	["BREATH"] = "007FFF",
	["DEATH"] = "FFB200",
	["FEIGNDEATH"] = "FFB200",
}

function MirrorTimers:OnUpdate()
	if self.Paused then
		return
	end
	
	self.Value = GetMirrorTimerProgress(self.Timer) / 1000
	
	if (self.Value > 0) then
		self.Text:SetText(format("%s (%s)", self.Label, vUI:FormatTime(self.Value)))
	else
		self.Text:SetText(format("%s", self.Label))
	end
	
	self:SetValue(self.Value)
end

function MirrorTimers:MIRROR_TIMER_PAUSE(ispaused)
	if ispaused then
		self.Bar.Paused = true
	else
		self.Bar.Paused = false
	end
end

function MirrorTimers:MIRROR_TIMER_STOP()
	self.Bar:Hide()
end

MirrorTimers.MirrorTimer_Show = function(timer, value, maxvalue, scale, paused, label)
	MirrorTimers.Bar.Max = maxvalue
	MirrorTimers.Bar.Value = value
	MirrorTimers.Bar.Timer = timer
	MirrorTimers.Bar.Label = label
	
	MirrorTimers.Bar:SetMinMaxValues(0, maxvalue / 1000)
	MirrorTimers.Bar:SetValue(value)
	MirrorTimers.Bar:SetStatusBarColor(vUI:HexToRGB(MirrorTimers.Colors[timer]))
	MirrorTimers.BarBG:SetVertexColor(vUI:HexToRGB(MirrorTimers.Colors[timer]))
	MirrorTimers.Bar.Text:SetText(format("%s (%s)", label, vUI:FormatTime(value / 1000)))
	MirrorTimers.Bar:Show()
end

function MirrorTimers:Load()
	self.Bar = CreateFrame("StatusBar", "vUI Timers Bar", UIParent)
	vUI:SetPoint(self.Bar, "TOP", UIParent, 0, -120)
	vUI:SetSize(self.Bar, 210, 20)
	self.Bar:SetFrameLevel(5)
	self.Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetScript("OnUpdate", self.OnUpdate)
	self.Bar:Hide()
	
	self.BarBG = self.Bar:CreateTexture(nil, "BORDER")
	vUI:SetPoint(self.BarBG, "TOPLEFT", self.Bar, 0, 0)
	vUI:SetPoint(self.BarBG, "BOTTOMRIGHT", self.Bar, 0, 0)
	self.BarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.BarBG:SetAlpha(0.2)
	
	self.Bar.Text = self.Bar:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.Bar.Text, "CENTER", self.Bar, 0, 0)
	vUI:SetFontInfo(self.Bar.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Bar.Text:SetJustifyH("CENTER")
	
	self.BarOutline = self.Bar:CreateTexture(nil, "BORDER")
	vUI:SetPoint(self.BarOutline, "TOPLEFT", self.Bar, -1, 1)
	vUI:SetPoint(self.BarOutline, "BOTTOMRIGHT", self.Bar, 1, -1)
	self.BarOutline:SetTexture(Assets:GetTexture("Blank"))
	self.BarOutline:SetVertexColor(0, 0, 0)
	
	self.OuterBG = CreateFrame("Frame", nil, self.Bar)
	vUI:SetPoint(self.OuterBG, "TOPLEFT", self.Bar, -4, 4)
	vUI:SetPoint(self.OuterBG, "BOTTOMRIGHT", self.Bar, 4, -4)
	self.OuterBG:SetBackdrop(vUI.BackdropAndBorder)
	self.OuterBG:SetBackdropBorderColor(0, 0, 0)
	self.OuterBG:SetFrameLevel(1)
	self.OuterBG:SetFrameStrata("BACKGROUND")
	self.OuterBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	
	self:Hook("MirrorTimer_Show")
	
	self:RegisterEvent("MIRROR_TIMER_PAUSE")
	self:RegisterEvent("MIRROR_TIMER_STOP")
	
	self.Hider = CreateFrame("Frame", nil, UIParent)
	self.Hider:Hide()
	
	vUI:CreateMover(self.Bar, 6)
	
	for i = 1, MIRRORTIMER_NUMTIMERS do
		_G["MirrorTimer" .. i]:SetParent(self.Hider)
	end
end

MirrorTimers:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)
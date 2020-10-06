local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Experience = vUI:NewModule("Experience")

local format = format
local floor = floor
local XP, MaxXP, Rested
local IsResting = IsResting
local RestingText
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitLevel = UnitLevel
local GetXPExhaustion = GetXPExhaustion
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local ExperienceBar = CreateFrame("StatusBar", "vUIExperienceBar", vUI.UIParent)

ExperienceBar.Elapsed = 0

local Gained = 0
local Seconds = 0

local UpdateXP = function(self, first)
	if (UnitLevel("player") == MAX_PLAYER_LEVEL) then
		self:UnregisterAllEvents()
		self:SetScript("OnEnter", nil)
		self:SetScript("OnLeave", nil)
		self:SetScript("OnEvent", nil)
		self:Hide()
		
		return
	end
	
	Rested = GetXPExhaustion()
    XP = UnitXP("player")
    MaxXP = UnitXPMax("player")
    RestingText = IsResting() and ("|cFF" .. Settings["experience-rested-color"] .. "zZz|r") or ""
	
	self.Bar:SetMinMaxValues(0, MaxXP)
	self.Bar.Rested:SetMinMaxValues(0, MaxXP)
	
	if Rested then
		self.Bar.Rested:SetValue(XP + Rested)
		
		if Settings["experience-display-rested-value"] then
			self.Progress:SetText(format("%s / %s (+%s) %s", vUI:Comma(XP), vUI:Comma(MaxXP), vUI:Comma(Rested), RestingText))
		else
			self.Progress:SetText(format("%s / %s %s", vUI:Comma(XP), vUI:Comma(MaxXP), RestingText))
		end
	else
		self.Bar.Rested:SetValue(0)
		self.Progress:SetText(format("%s / %s %s", vUI:Comma(XP), vUI:Comma(MaxXP), RestingText))
	end
	
	self.Percentage:SetText(floor((XP / MaxXP * 100 + 0.05) * 10) / 10 .. "%")
	
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r %s", Settings["ui-header-font-color"], Language["Level"], UnitLevel("player")))
	self.HeaderBG:SetWidth(self.HeaderBG.Text:GetWidth() + 14)
	
	if (XP > 0) then
		if (self.Bar.Spark:GetAlpha() == 0) then
			self.Bar.Spark:SetAlpha(1)
		end
	elseif (self.Bar.Spark:GetAlpha() > 0) then
		self.Bar.Spark:SetAlpha(0)
	end
	
	if (Rested and (Rested > 0)) then
		if (self.Bar.Rested.Spark:GetAlpha() == 0) then
			self.Bar.Rested.Spark:SetAlpha(1)
		end
	elseif (self.Bar.Rested.Spark:GetAlpha() > 0) then
		self.Bar.Rested.Spark:SetAlpha(0)
	end
	
	if Settings["experience-animate"] then
		if (not first) then
			self.Change:SetChange(XP)
			self.Change:Play()
			
			if ((XP > self.LastXP) and not self.Flash:IsPlaying()) then
				self.Flash:Play()
			end
		else
			self.Bar:SetValue(XP)
		end
	else
		self.Bar:SetValue(XP)
	end
	
	Gained = (XP - self.LastXP) + Gained
	
	if (Seconds == 0 and Gained > 0) then -- Start the XP timer
		ExperienceBar:SetScript("OnUpdate", ExperienceBar.OnUpdate)
	end
	
	if self.TooltipShown then
		GameTooltip:ClearLines()
		self:OnEnter()
	end
	
	self.LastXP = XP
end

local UpdateDisplayLevel = function(value)
	if value then
		vUIExperienceBar.HeaderBG:Show()
		
		vUIExperienceBar.BarBG:ClearAllPoints()
		vUIExperienceBar.BarBG:SetPoint("TOPLEFT", vUIExperienceBar.HeaderBG, "TOPRIGHT", 2, 0)
		vUIExperienceBar.BarBG:SetPoint("BOTTOMRIGHT", vUIExperienceBar, 0, 0)
	else
		vUIExperienceBar.HeaderBG:Hide()
		
		vUIExperienceBar.BarBG:ClearAllPoints()
		vUIExperienceBar.BarBG:SetPoint("TOPLEFT", vUIExperienceBar, 0, 0)
		vUIExperienceBar.BarBG:SetPoint("BOTTOMRIGHT", vUIExperienceBar, 0, 0)
	end
end

local UpdateDisplayProgress = function(value)
	if (value and Settings["experience-progress-visibility"] ~= "MOUSEOVER") then
		vUIExperienceBar.Progress:Show()
	else
		vUIExperienceBar.Progress:Hide()
	end
end

local UpdateDisplayPercent = function(value)
	if (value and Settings["experience-percent-visibility"] ~= "MOUSEOVER") then
		vUIExperienceBar.Percentage:Show()
	else
		vUIExperienceBar.Percentage:Hide()
	end
end

local UpdateBarWidth = function(value)
	vUIExperienceBar:SetWidth(value)
end

local UpdateBarHeight = function(value)
	vUIExperienceBar:SetHeight(value)
	vUIExperienceBar.HeaderBG:SetHeight(value)
	vUIExperienceBar.Bar.Spark:SetHeight(value)
end

function ExperienceBar:OnEnter()
	if Settings["experience-mouseover"] then
		self:SetAlpha(1)
	end
	
	if (Settings["experience-display-progress"] and Settings["experience-progress-visibility"] == "MOUSEOVER") then
		if (not self.Progress:IsShown()) then
			self.Progress:Show()
		end
	end
	
	if (Settings["experience-display-percent"] and Settings["experience-percent-visibility"] == "MOUSEOVER") then
		if (not self.Percentage:IsShown()) then
			self.Percentage:Show()
		end
	end
	
	if (not Settings["experience-show-tooltip"]) then
		return
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8)
	
	Rested = GetXPExhaustion()
	XP = UnitXP("player")
	Max = UnitXPMax("player")
	
	local Percent = floor((XP / Max * 100 + 0.05) * 10) / 10
	local Remaining = Max - XP
	local RemainingPercent = floor((Remaining / Max * 100 + 0.05) * 10) / 10
	
	GameTooltip:AddLine(LEVEL .. " " .. UnitLevel("player"))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Current Experience"])
	GameTooltip:AddDoubleLine(format("%s / %s", vUI:Comma(XP), vUI:Comma(Max)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining Experience"])
	GameTooltip:AddDoubleLine(format("%s", vUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	if Rested then
		local RestedPercent = floor((Rested / Max * 100 + 0.05) * 10) / 10
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Rested Experience"])
		GameTooltip:AddDoubleLine(vUI:Comma(Rested), format("%s%%", RestedPercent), 1, 1, 1, 1, 1, 1)
	end
	
	-- Advanced information
	if (Gained > 0) then
		local PerHour = (((Gained / Seconds) * 60) * 60)
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Session Stats"])
		GameTooltip:AddDoubleLine(Language["Experience gained"], vUI:Comma(Gained), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(Language["Per hour"], vUI:Comma(PerHour), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(Language["Duration"], vUI:FormatTime(Seconds), 1, 1, 1, 1, 1, 1)
	end
	
	self.TooltipShown = true
	
	GameTooltip:Show()
end

function ExperienceBar:OnLeave()
	if Settings["experience-mouseover"] then
		self:SetAlpha(Settings["experience-mouseover-opacity"] / 100)
	end
	
	if Settings["experience-show-tooltip"] then
		GameTooltip:Hide()
		
		self.TooltipShown = false
	end
	
	if (Settings["experience-display-progress"] and Settings["experience-progress-visibility"] == "MOUSEOVER") then
		if self.Progress:IsShown() then
			self.Progress:Hide()
		end
	end
	
	if (Settings["experience-display-percent"] and Settings["experience-percent-visibility"] == "MOUSEOVER") then
		if self.Percentage:IsShown() then
			self.Percentage:Hide()
		end
	end
end

local UpdateProgressVisibility = function(value)
	if (value == "MOUSEOVER") then
		ExperienceBar.Progress:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-progress"]) then
		ExperienceBar.Progress:Show()
	end
end

local UpdatePercentVisibility = function(value)
	if (value == "MOUSEOVER") then
		ExperienceBar.Percentage:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-percent"]) then
		ExperienceBar.Percentage:Show()
	end
end

ExperienceBar["PLAYER_LEVEL_UP"] = UpdateXP
ExperienceBar["PLAYER_XP_UPDATE"] = UpdateXP
ExperienceBar["PLAYER_UPDATE_RESTING"] = UpdateXP
ExperienceBar["UPDATE_EXHAUSTION"] = UpdateXP

ExperienceBar["PLAYER_ENTERING_WORLD"] = function(self)
	if (not Settings["experience-enable"]) then
		self:UnregisterAllEvents()
		
		return
	end
	
	self:SetSize(Settings["experience-width"], Settings["experience-height"])
	self:SetPoint("TOP", vUI.UIParent, 0, -13)
	self:SetFrameStrata("HIGH")
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	
	if Settings["experience-mouseover"] then
		self:SetAlpha(Settings["experience-mouseover-opacity"] / 100)
	end
	
	self.LastXP = UnitXP("player")
	
	self.HeaderBG = CreateFrame("Frame", nil, self)
	self.HeaderBG:SetHeight(Settings["experience-height"])
	self.HeaderBG:SetPoint("LEFT", self, 0, 0)
	self.HeaderBG:SetBackdrop(vUI.BackdropAndBorder)
	self.HeaderBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.HeaderBG:SetBackdropBorderColor(0, 0, 0)
	
	self.HeaderBG.Texture = self.HeaderBG:CreateTexture(nil, "ARTWORK")
	self.HeaderBG.Texture:SetPoint("TOPLEFT", self.HeaderBG, 1, -1)
	self.HeaderBG.Texture:SetPoint("BOTTOMRIGHT", self.HeaderBG, -1, 1)
	self.HeaderBG.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.HeaderBG.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.HeaderBG.Text = self.HeaderBG:CreateFontString(nil, "OVERLAY")
	self.HeaderBG.Text:SetPoint("CENTER", self.HeaderBG, 0, 0)
	vUI:SetFontInfo(self.HeaderBG.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.HeaderBG.Text:SetJustifyH("CENTER")
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r", Settings["ui-widget-color"], Language["Level"]))
	
	self.BarBG = CreateFrame("Frame", nil, self)
	self.BarBG:SetPoint("TOPLEFT", self.HeaderBG, "TOPRIGHT", 2, 0)
	self.BarBG:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Texture = self.BarBG:CreateTexture(nil, "ARTWORK")
	self.Texture:SetPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Texture:SetPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BGAll = CreateFrame("Frame", nil, self)
	self.BGAll:SetPoint("TOPLEFT", self.HeaderBG, -3, 3)
	self.BGAll:SetPoint("BOTTOMRIGHT", self.BarBG, 3, -3)
	self.BGAll:SetBackdrop(vUI.BackdropAndBorder)
	self.BGAll:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.BGAll:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetStatusBarColor(vUI:HexToRGB(Settings["experience-bar-color"]))
	self.Bar:SetPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Bar:SetPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameLevel(6)
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Bar.BG:SetAlpha(0.2)
	
	self.Bar.Spark = self.Bar:CreateTexture(nil, "OVERLAY")
	self.Bar.Spark:SetDrawLayer("OVERLAY", 7)
	self.Bar.Spark:SetSize(1, Settings["experience-height"])
	self.Bar.Spark:SetPoint("LEFT", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	self.Bar.Spark:SetTexture(Assets:GetTexture("Blank"))
	self.Bar.Spark:SetVertexColor(0, 0, 0)
	
	self.Shine = self.Bar:CreateTexture(nil, "ARTWORK")
	self.Shine:SetAllPoints(self.Bar:GetStatusBarTexture())
	self.Shine:SetTexture(Assets:GetTexture("pHishTex12"))
	self.Shine:SetVertexColor(1, 1, 1)
	self.Shine:SetAlpha(0)
	self.Shine:SetDrawLayer("ARTWORK", 7)
	
	self.Change = CreateAnimationGroup(self.Bar):CreateAnimation("Progress")
	self.Change:SetEasing("in")
	self.Change:SetDuration(0.3)
	
	self.Flash = CreateAnimationGroup(self.Shine)
	
	self.Flash.In = self.Flash:CreateAnimation("Fade")
	self.Flash.In:SetEasing("in")
	self.Flash.In:SetDuration(0.3)
	self.Flash.In:SetChange(0.3)
	
	self.Flash.Out = self.Flash:CreateAnimation("Fade")
	self.Flash.Out:SetOrder(2)
	self.Flash.Out:SetEasing("out")
	self.Flash.Out:SetDuration(0.5)
	self.Flash.Out:SetChange(0)
	
	self.Bar.Rested = CreateFrame("StatusBar", nil, self.Bar)
	self.Bar.Rested:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.Rested:SetStatusBarColor(vUI:HexToRGB(Settings["experience-rested-color"]))
	self.Bar.Rested:SetFrameLevel(5)
	self.Bar.Rested:SetAllPoints(self.Bar)
	
	self.Bar.Rested.Spark = self.Bar.Rested:CreateTexture(nil, "OVERLAY")
	self.Bar.Rested.Spark:SetSize(1, Settings["experience-height"])
	self.Bar.Rested.Spark:SetPoint("LEFT", self.Bar.Rested:GetStatusBarTexture(), "RIGHT", 0, 0)
	self.Bar.Rested.Spark:SetTexture(Assets:GetTexture("Blank"))
	self.Bar.Rested.Spark:SetVertexColor(0, 0, 0)
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetPoint("LEFT", self.Bar, 5, 0)
	vUI:SetFontInfo(self.Progress, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	-- Add fade to self.Progress
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetPoint("RIGHT", self.Bar, -5, 0)
	vUI:SetFontInfo(self.Percentage, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
	
	-- Add fade to self.Percentage
	
	UpdateDisplayLevel(Settings["experience-display-level"])
	UpdateDisplayProgress(Settings["experience-display-progress"])
	UpdateDisplayPercent(Settings["experience-display-percent"])
	UpdateProgressVisibility(Settings["experience-progress-visibility"])
	UpdatePercentVisibility(Settings["experience-percent-visibility"])
	UpdateXP(self, true)
	
	vUI:CreateMover(self, 6)
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function ExperienceBar:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 1) then
		Seconds = Seconds + 1
		self.Elapsed = 0
	end
end

ExperienceBar:RegisterEvent("PLAYER_LEVEL_UP")
ExperienceBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ExperienceBar:RegisterEvent("PLAYER_XP_UPDATE")
ExperienceBar:RegisterEvent("PLAYER_UPDATE_RESTING")
ExperienceBar:RegisterEvent("UPDATE_EXHAUSTION")
ExperienceBar:SetScript("OnEvent", function(self, event)
	if self[event] then
		self[event](self)
	end
end)

local UpdateBarColor = function(value)
	ExperienceBar.Bar:SetStatusBarColor(vUI:HexToRGB(value))
	ExperienceBar.Bar.BG:SetVertexColor(vUI:HexToRGB(value))
end

local UpdateRestedColor = function(value)
	ExperienceBar.Bar.Rested:SetStatusBarColor(vUI:HexToRGB(value))
end

local UpdateShowRestedValue = function()
	UpdateXP(ExperienceBar)
end

local UpdateMouseover = function(value)
	if value then
		ExperienceBar:SetAlpha(Settings["experience-mouseover-opacity"] / 100)
	else
		ExperienceBar:SetAlpha(1)
	end
end

local UpdateMouseoverOpacity = function(value)
	if Settings["experience-mouseover"] then
		ExperienceBar:SetAlpha(value / 100)
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Experience"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("experience-enable", Settings["experience-enable"], Language["Enable Experience Module"], Language["Enable the vUI experience module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSwitch("experience-display-level", Settings["experience-display-level"], Language["Display Level"], Language["Display your current level in the experience bar"], UpdateDisplayLevel)
	Left:CreateSwitch("experience-display-progress", Settings["experience-display-progress"], Language["Display Progress Value"], Language["Display your current progressinformation in the experience bar"], UpdateDisplayProgress)
	Left:CreateSwitch("experience-display-percent", Settings["experience-display-percent"], Language["Display Percent Value"], Language["Display your current percentinformation in the experience bar"], UpdateDisplayPercent)
	Left:CreateSwitch("experience-display-rested-value", Settings["experience-display-rested-value"], Language["Display Rested Value"], Language["Display your current restedvalue on the experience bar"], UpdateShowRestedValue)
	Left:CreateSwitch("experience-show-tooltip", Settings["experience-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the experience bar"])
	Left:CreateSwitch("experience-animate", Settings["experience-animate"], Language["Animate Experience Changes"], Language["Smoothly animate changes to the experience bar"])
	
	Right:CreateHeader(Language["Size"])
	Right:CreateSlider("experience-width", Settings["experience-width"], 240, 400, 10, Language["Bar Width"], Language["Set the width of the experience bar"], UpdateBarWidth)
	Right:CreateSlider("experience-height", Settings["experience-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the experience bar"], UpdateBarHeight)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateColorSelection("experience-bar-color", Settings["experience-bar-color"], Language["Experience Color"], Language["Set the color of the experience bar"], UpdateBarColor)
	Right:CreateColorSelection("experience-rested-color", Settings["experience-rested-color"], Language["Rested Color"], Language["Set the color of the rested bar"], UpdateRestedColor)
	
	Right:CreateHeader(Language["Visibility"])
	Right:CreateDropdown("experience-progress-visibility", Settings["experience-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"], UpdateProgressVisibility)
	Right:CreateDropdown("experience-percent-visibility", Settings["experience-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"], UpdatePercentVisibility)
	
	Left:CreateHeader("Mouseover")
	Left:CreateSwitch("experience-mouseover", Settings["experience-mouseover"], Language["Display On Mouseover"], Language["Only display the experience bar while mousing over it"], UpdateMouseover)
	Left:CreateSlider("experience-mouseover-opacity", Settings["experience-mouseover-opacity"], 0, 100, 5, Language["Mouseover Opacity"], Language["Set the opacity of the experience bar while not mousing over it"], UpdateMouseoverOpacity, nil, "%")
end)
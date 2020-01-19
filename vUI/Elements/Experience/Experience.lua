local vUI, GUI, Language, Media, Settings = select(2, ...):get()

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

local ExperienceBar = CreateFrame("StatusBar", "vUIExperienceBar", UIParent)

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
	self.HeaderBG:SetScaledWidth(self.HeaderBG.Text:GetWidth() + 14)
	
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
		vUIExperienceBar.BarBG:SetScaledPoint("TOPLEFT", vUIExperienceBar.HeaderBG, "TOPRIGHT", 2, 0)
		vUIExperienceBar.BarBG:SetScaledPoint("BOTTOMRIGHT", vUIExperienceBar, 0, 0)
	else
		vUIExperienceBar.HeaderBG:Hide()
		
		vUIExperienceBar.BarBG:ClearAllPoints()
		vUIExperienceBar.BarBG:SetScaledPoint("TOPLEFT", vUIExperienceBar, 0, 0)
		vUIExperienceBar.BarBG:SetScaledPoint("BOTTOMRIGHT", vUIExperienceBar, 0, 0)
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
	if (Settings["experience-position"] ~= "CHATFRAME") then
		vUIExperienceBar:SetScaledWidth(value)
	end
end

local UpdateBarHeight = function(value)
	if (Settings["experience-position"] ~= "CHATFRAME") then
		vUIExperienceBar:SetScaledHeight(value)
		vUIExperienceBar.HeaderBG:SetScaledHeight(value)
		vUIExperienceBar.Bar.Spark:SetScaledHeight(value)
	end
end

local UpdateBarPosition = function(value)
	local WidthWidget = GUI:GetWidgetByWindow(Language["Experience"], "experience-width")
	local HeightWidget = GUI:GetWidgetByWindow(Language["Experience"], "experience-height")
	
	ExperienceBar:ClearAllPoints()
	
	if (value == "TOP") then
		ExperienceBar.BGAll:Show()
		ExperienceBar:SetScaledSize(Settings["experience-width"], Settings["experience-height"])
		ExperienceBar:SetScaledPoint("TOP", UIParent, 0, -13)
		ExperienceBar.HeaderBG:SetScaledHeight(Settings["experience-height"])
		ExperienceBar.Bar.Spark:SetScaledHeight(Settings["experience-height"])
		
		vUIChatFrameBottom:Show()
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			
			if (Settings["reputation-enable"] and GetWatchedFactionInfo() and Settings["reputation-position"] ~= "CLASSIC") then
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
			else
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", vUI:GetModule("Reputation"), "TOP", 0, 5)
			end
		end
		
		WidthWidget:Enable()
		HeightWidget:Enable()
	elseif (value == "CHATFRAME") then
		vUIChatFrameBottom:Hide()
		
		local Height = vUIChatFrameBottom:GetHeight()
		
		ExperienceBar.BGAll:Hide()
		ExperienceBar:SetScaledSize(vUIChatFrameBottom:GetWidth(), Height)
		ExperienceBar:SetScaledPoint("CENTER", vUIChatFrameBottom, 0, 0)
		
		ExperienceBar.HeaderBG:SetScaledHeight(Height)
		ExperienceBar.Bar.Spark:SetScaledHeight(Height)
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			
			if (Settings["reputation-enable"] and GetWatchedFactionInfo() and Settings["reputation-position"] ~= "CLASSIC") then
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
			else
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", vUI:GetModule("Reputation"), "TOP", 0, 5)
			end
		end
		
		WidthWidget:Disable()
		HeightWidget:Disable()
	elseif (value == "CLASSIC") then
		vUIChatFrameBottom:Show()
		
		ExperienceBar.BGAll:Show()
		ExperienceBar:SetScaledHeight(Settings["experience-height"])
		ExperienceBar:SetScaledPoint("BOTTOM", UIParent, 0, 13)
		ExperienceBar.HeaderBG:SetScaledHeight(Settings["experience-height"])
		ExperienceBar.Bar.Spark:SetScaledHeight(Settings["experience-height"])
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", ExperienceBar, "TOP", 0, 5)
			
			ExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - 6)
		end
		
		WidthWidget:Disable()
		HeightWidget:Enable()
	end
end

function ExperienceBar:OnEnter()
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
	
	if Settings["experience-show-tooltip"] then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8)
		
		Rested = GetXPExhaustion()
		XP = UnitXP("player")
		Max = UnitXPMax("player")
		
		local Percent = floor((XP / Max * 100 + 0.05) * 10) / 10
		local Remaining = Max - XP
		local RemainingPercent = floor((Remaining / Max * 100 + 0.05) * 10) / 10
		
		GameTooltip:AddLine(LEVEL .. " " .. UnitLevel("player"))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Current experience"])
		GameTooltip:AddDoubleLine(format("%s / %s", vUI:Comma(XP), vUI:Comma(Max)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Remaining experience"])
		GameTooltip:AddDoubleLine(format("%s", vUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
		
		if Rested then
			local RestedPercent = floor((Rested / Max * 100 + 0.05) * 10) / 10
			
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(Language["Rested experience"])
			GameTooltip:AddDoubleLine(vUI:Comma(Rested), format("%s%%", RestedPercent), 1, 1, 1, 1, 1, 1)
		end
		
		self.TooltipShown = true
		
		GameTooltip:Show()
	end
end

function ExperienceBar:OnLeave()
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
	
	self:SetScaledSize(Settings["experience-width"], Settings["experience-height"])
	self:SetScaledPoint("TOP", UIParent, 0, -13)
	self:SetFrameStrata("HIGH")
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	
	self.LastXP = 0
	
	self.HeaderBG = CreateFrame("Frame", nil, self)
	self.HeaderBG:SetScaledHeight(Settings["experience-height"])
	self.HeaderBG:SetScaledPoint("LEFT", self, 0, 0)
	self.HeaderBG:SetBackdrop(vUI.BackdropAndBorder)
	self.HeaderBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.HeaderBG:SetBackdropBorderColor(0, 0, 0)
	
	self.HeaderBG.Texture = self.HeaderBG:CreateTexture(nil, "ARTWORK")
	self.HeaderBG.Texture:SetScaledPoint("TOPLEFT", self.HeaderBG, 1, -1)
	self.HeaderBG.Texture:SetScaledPoint("BOTTOMRIGHT", self.HeaderBG, -1, 1)
	self.HeaderBG.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.HeaderBG.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.HeaderBG.Text = self.HeaderBG:CreateFontString(nil, "OVERLAY")
	self.HeaderBG.Text:SetScaledPoint("CENTER", self.HeaderBG, 0, 0)
	self.HeaderBG.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.HeaderBG.Text:SetJustifyH("CENTER")
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r", Settings["ui-widget-color"], Language["Level"]))
	
	self.BarBG = CreateFrame("Frame", nil, self)
	self.BarBG:SetScaledPoint("TOPLEFT", self.HeaderBG, "TOPRIGHT", 2, 0)
	self.BarBG:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Texture = self.BarBG:CreateTexture(nil, "ARTWORK")
	self.Texture:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Texture:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BGAll = CreateFrame("Frame", nil, self)
	self.BGAll:SetScaledPoint("TOPLEFT", self.HeaderBG, -3, 3)
	self.BGAll:SetScaledPoint("BOTTOMRIGHT", self.BarBG, 3, -3)
	self.BGAll:SetBackdrop(vUI.BackdropAndBorder)
	self.BGAll:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.BGAll:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetStatusBarColorHex(Settings["experience-bar-color"])
	self.Bar:SetScaledPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Bar:SetScaledPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameLevel(6)
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColorHex(Settings["ui-window-main-color"])
	self.Bar.BG:SetAlpha(0.2)
	
	self.Bar.Spark = self.Bar:CreateTexture(nil, "OVERLAY")
	self.Bar.Spark:SetDrawLayer("OVERLAY", 7)
	self.Bar.Spark:SetScaledSize(1, Settings["experience-height"])
	self.Bar.Spark:SetScaledPoint("LEFT", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	self.Bar.Spark:SetTexture(Media:GetTexture("Blank"))
	self.Bar.Spark:SetVertexColor(0, 0, 0)
	
	self.Shine = self.Bar:CreateTexture(nil, "ARTWORK")
	self.Shine:SetAllPoints(self.Bar:GetStatusBarTexture())
	self.Shine:SetTexture(Media:GetTexture("pHishTex12"))
	self.Shine:SetVertexColor(1, 1, 1)
	self.Shine:SetAlpha(0)
	self.Shine:SetDrawLayer("ARTWORK", 7)
	
	self.Change = CreateAnimationGroup(self.Bar):CreateAnimation("Progress")
	self.Change:SetOrder(1)
	self.Change:SetEasing("in")
	self.Change:SetDuration(0.3)
	
	self.Flash = CreateAnimationGroup(self.Shine)
	
	self.Flash.In = self.Flash:CreateAnimation("Fade")
	self.Flash.In:SetOrder(1)
	self.Flash.In:SetEasing("in")
	self.Flash.In:SetDuration(0.3)
	self.Flash.In:SetChange(0.3)
	
	self.Flash.Out = self.Flash:CreateAnimation("Fade")
	self.Flash.Out:SetOrder(2)
	self.Flash.Out:SetEasing("out")
	self.Flash.Out:SetDuration(0.5)
	self.Flash.Out:SetChange(0)
	
	self.Bar.Rested = CreateFrame("StatusBar", nil, self.Bar)
	self.Bar.Rested:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.Rested:SetStatusBarColorHex(Settings["experience-rested-color"])
	self.Bar.Rested:SetFrameLevel(5)
	self.Bar.Rested:SetAllPoints(self.Bar)
	
	self.Bar.Rested.Spark = self.Bar.Rested:CreateTexture(nil, "OVERLAY")
	self.Bar.Rested.Spark:SetScaledSize(1, Settings["experience-height"])
	self.Bar.Rested.Spark:SetScaledPoint("LEFT", self.Bar.Rested:GetStatusBarTexture(), "RIGHT", 0, 0)
	self.Bar.Rested.Spark:SetTexture(Media:GetTexture("Blank"))
	self.Bar.Rested.Spark:SetVertexColor(0, 0, 0)
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetScaledPoint("LEFT", self.Bar, 5, 0)
	self.Progress:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	-- Add fade to self.Progress
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetScaledPoint("RIGHT", self.Bar, -5, 0)
	self.Percentage:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
	
	-- Add fade to self.Percentage
	
	UpdateDisplayLevel(Settings["experience-display-level"])
	UpdateDisplayProgress(Settings["experience-display-progress"])
	UpdateDisplayPercent(Settings["experience-display-percent"])
	UpdateBarPosition(Settings["experience-position"])
	UpdateProgressVisibility(Settings["experience-progress-visibility"])
	UpdatePercentVisibility(Settings["experience-percent-visibility"])
	UpdateXP(self, true)
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
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
	ExperienceBar.Bar:SetStatusBarColorHex(value)
	ExperienceBar.Bar.BG:SetVertexColorHex(value)
end

local UpdateRestedColor = function(value)
	ExperienceBar.Bar.Rested:SetStatusBarColorHex(value)
end

local UpdateShowRestedValue = function()
	UpdateXP(ExperienceBar)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Experience"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("experience-enable", Settings["experience-enable"], Language["Enable Experience Module"], "Enable the vUI experience module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSwitch("experience-display-level", Settings["experience-display-level"], Language["Display Level"], "Display your current level in the experience bar", UpdateDisplayLevel)
	Left:CreateSwitch("experience-display-progress", Settings["experience-display-progress"], Language["Display Progress Value"], "Display your current progress|ninformation in the experience bar", UpdateDisplayProgress)
	Left:CreateSwitch("experience-display-percent", Settings["experience-display-percent"], Language["Display Percent Value"], "Display your current percent|ninformation in the experience bar", UpdateDisplayPercent)
	Left:CreateSwitch("experience-display-rested-value", Settings["experience-display-rested-value"], Language["Display Rested Value"], "Display your current rested|nvalue on the experience bar", UpdateShowRestedValue)
	Left:CreateSwitch("experience-show-tooltip", Settings["experience-show-tooltip"], Language["Enable Tooltip"], "Display a tooltip when mousing over the experience bar")
	Left:CreateSwitch("experience-animate", Settings["experience-animate"], Language["Animate Experience Changes"], "Smoothly animate changes to the experience bar")
	
	Right:CreateHeader(Language["Size"])
	Right:CreateSlider("experience-width", Settings["experience-width"], 240, 400, 10, Language["Bar Width"], "Set the width of the experience bar", UpdateBarWidth)
	Right:CreateSlider("experience-height", Settings["experience-height"], 6, 30, 1, Language["Bar Height"], "Set the height of the experience bar", UpdateBarHeight)
	
	Right:CreateHeader(Language["Positioning"])
	Right:CreateDropdown("experience-position", Settings["experience-position"], {[Language["Top"]] = "TOP", [Language["Chat Frame"]] = "CHATFRAME", [Language["Classic"]] = "CLASSIC"}, Language["Set Position"], "Set the position of the experience bar", UpdateBarPosition)
	
	Right:CreateHeader(Language["Visibility"])
	Right:CreateDropdown("experience-progress-visibility", Settings["experience-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], "Set when to display the progress information", UpdateProgressVisibility)
	Right:CreateDropdown("experience-percent-visibility", Settings["experience-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], "Set when to display the percent information", UpdatePercentVisibility)
	
	Left:CreateHeader(Language["Colors"])
	Left:CreateColorSelection("experience-bar-color", Settings["experience-bar-color"], "Experience Color", "Set the color of the experience bar", UpdateBarColor)
	Left:CreateColorSelection("experience-rested-color", Settings["experience-rested-color"], "Rested Color", "Set the color of the rested bar", UpdateRestedColor)
end)
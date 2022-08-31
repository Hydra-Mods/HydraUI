local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Experience = HydraUI:NewModule("Experience")

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
local GetQuestInfo = C_QuestLog.GetInfo
local ReadyForTurnIn = C_QuestLog.ReadyForTurnIn
local GetNumQuests
local LEVEL = LEVEL
local Gained = 0
local Seconds = 0

if HydraUI.IsMainline then
	GetNumQuests = C_QuestLog.GetNumQuestLogEntries
else
	GetNumQuests = GetNumQuestLogEntries
end

Defaults["experience-enable"] = true
Defaults["experience-width"] = 316
Defaults["experience-height"] = 24
Defaults["experience-mouseover"] = false
Defaults["experience-mouseover-opacity"] = 0
Defaults["experience-display-level"] = false
Defaults["experience-display-progress"] = true
Defaults["experience-display-percent"] = true
Defaults["experience-display-rested-value"] = true
Defaults["experience-show-tooltip"] = true
Defaults["experience-animate"] = true
Defaults["experience-progress-visibility"] = "ALWAYS"
Defaults["experience-percent-visibility"] = "ALWAYS"
Defaults["experience-bar-color"] = "4C9900" -- 1AE045
Defaults["experience-rested-color"] = "00B4FF"

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

local UpdateDisplayProgress = function(value)
	if (value and Settings["experience-progress-visibility"] ~= "MOUSEOVER") then
		Experience.Progress:Show()
	else
		Experience.Progress:Hide()
	end
end

local UpdateDisplayPercent = function(value)
	if (value and Settings["experience-percent-visibility"] ~= "MOUSEOVER") then
		Experience.Percentage:Show()
	else
		Experience.Percentage:Hide()
	end
end

local UpdateBarWidth = function(value)
	Experience:SetWidth(value)
end

local UpdateBarHeight = function(value)
	Experience:SetHeight(value)
	Experience.Bar.Spark:SetHeight(value)
end

local UpdateProgressVisibility = function(value)
	if (value == "MOUSEOVER") then
		Experience.Progress:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-progress"]) then
		Experience.Progress:Show()
	end
end

local UpdatePercentVisibility = function(value)
	if (value == "MOUSEOVER") then
		Experience.Percentage:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-percent"]) then
		Experience.Percentage:Show()
	end
end

function Experience:OnMouseUp()
	ToggleCharacter("PaperDollFrame")
end

function Experience:CreateBar()
	local Border = Settings["ui-border-thickness"]
	local Offset = 1 > Border and 1 or (Border + 2)
	
	self:SetSize(Settings["experience-width"], Settings["experience-height"])
	self:SetPoint("TOP", HydraUI.UIParent, 0, -13)
	self:SetFrameStrata("MEDIUM")
	self.Elapsed = 0
	
	if Settings["experience-mouseover"] then
		self:SetAlpha(Settings["experience-mouseover-opacity"] / 100)
	end
	
	self.LastXP = UnitXP("player")
	
	self.BarBG = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.BarBG:SetPoint("TOPLEFT", self, 0, 0)
	self.BarBG:SetPoint("BOTTOMRIGHT", self, 0, 0)
	HydraUI:AddBackdrop(self.BarBG)
	self.BarBG.Outside:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetStatusBarColor(HydraUI:HexToRGB(Settings["experience-bar-color"]))
	self.Bar:SetPoint("TOPLEFT", self.BarBG, Offset, -Offset)
	self.Bar:SetPoint("BOTTOMRIGHT", self.BarBG, -Offset, Offset)
	self.Bar:SetFrameLevel(6)
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Bar.BG:SetAlpha(0.2)
	
	self.Bar.Spark = self.Bar:CreateTexture(nil, "OVERLAY")
	self.Bar.Spark:SetDrawLayer("OVERLAY", 7)
	self.Bar.Spark:SetWidth(1)
	self.Bar.Spark:SetPoint("TOPLEFT", self.Bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	self.Bar.Spark:SetPoint("BOTTOMLEFT", self.Bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
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
	self.Bar.Rested:SetStatusBarColor(HydraUI:HexToRGB(Settings["experience-rested-color"]))
	self.Bar.Rested:SetFrameLevel(5)
	self.Bar.Rested:SetAllPoints(self.Bar)
	
	self.Bar.Rested.Spark = self.Bar.Rested:CreateTexture(nil, "OVERLAY")
	self.Bar.Rested.Spark:SetWidth(1)
	self.Bar.Rested.Spark:SetPoint("TOPLEFT", self.Bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	self.Bar.Rested.Spark:SetPoint("BOTTOMLEFT", self.Bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	self.Bar.Rested.Spark:SetTexture(Assets:GetTexture("Blank"))
	self.Bar.Rested.Spark:SetVertexColor(0, 0, 0)
	
	self.Bar.Quest = CreateFrame("StatusBar", nil, self.Bar)
	self.Bar.Quest:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.Quest:SetStatusBarColor(0.8, 0.8, 0.1)
	self.Bar.Quest:SetFrameLevel(6)
	self.Bar.Quest:SetAllPoints(self.Bar)
	
	self.Bar.Quest.Spark = self.Bar.Quest:CreateTexture(nil, "OVERLAY")
	self.Bar.Quest.Spark:SetWidth(1)
	self.Bar.Quest.Spark:SetPoint("TOPLEFT", self.Bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	self.Bar.Quest.Spark:SetPoint("BOTTOMLEFT", self.Bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	self.Bar.Quest.Spark:SetTexture(Assets:GetTexture("Blank"))
	self.Bar.Quest.Spark:SetVertexColor(0, 0, 0)
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetPoint("LEFT", self.Bar, 5, 0)
	HydraUI:SetFontInfo(self.Progress, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetPoint("RIGHT", self.Bar, -5, 0)
	HydraUI:SetFontInfo(self.Percentage, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
	
	HydraUI:CreateMover(self, 6)
end

if HydraUI.IsWrath then -- Temp for prepatch
	MAX_PLAYER_LEVEL = 70
end

function Experience:OnEvent()
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
	
	local QuestLogXP = 0
	local Zone = GetRealZoneText()
	local ZoneName
	local Level = Settings["experience-display-level"] and (format("%s %d - ", LEVEL, UnitLevel("player"))) or ""
	
	if HydraUI.IsMainline then
		for i = 1, GetNumQuests() do
			local Info = GetQuestInfo(i)
			
			if (Info.isHeader and not Info.isHidden) then
				ZoneName = Info.title
			else
				if (ZoneName and Zone == ZoneName and ReadyForTurnIn(Info.questID)) then
					QuestLogXP = QuestLogXP + GetQuestLogRewardXP(Info.questID)
				end
			end
		end
	else
		for i = 1, GetNumQuestLogEntries() do
			local TitleText, _, _, IsHeader, _, IsComplete, _, QuestID = GetQuestLogTitle(i)
			
			if IsHeader then
				ZoneName = TitleText
				--if (ZoneName and Zone == ZoneName) and IsComplete then
				--end
			else
				if (ZoneName and Zone == ZoneName and IsComplete) then
					QuestLogXP = QuestLogXP + GetQuestLogRewardXP(QuestID)
				end
			end
		end
	end
	
	if (QuestLogXP > 0) then
		if HydraUI.IsTBC then -- Temp, remove me after "Joyous Journeys"
			QuestLogXP = QuestLogXP * 1.50
		end
		
		self.Bar.Quest:SetValue(min(XP + QuestLogXP, MaxXP))
		self.Bar.Quest:Show()
	else
		self.Bar.Quest:Hide()
	end
	
	self.Bar:SetMinMaxValues(0, MaxXP)
	self.Bar.Rested:SetMinMaxValues(0, MaxXP)
	self.Bar.Quest:SetMinMaxValues(0, MaxXP)
	
	if Rested then
		self.Bar.Rested:SetValue(XP + Rested)
		
		if Settings["experience-display-rested-value"] then
			self.Progress:SetFormattedText("%s%s / %s (+%s) %s", Level, HydraUI:Comma(XP), HydraUI:Comma(MaxXP), HydraUI:Comma(Rested), RestingText)
		else
			self.Progress:SetFormattedText("%s%s / %s %s", Level, HydraUI:Comma(XP), HydraUI:Comma(MaxXP), RestingText)
		end
	else
		self.Bar.Rested:SetValue(0)
		self.Progress:SetFormattedText("%s%s / %s %s", Level, HydraUI:Comma(XP), HydraUI:Comma(MaxXP), RestingText)
	end
	
	self.Percentage:SetText(floor((XP / MaxXP * 100 + 0.05) * 10) / 10 .. "%")
	
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
		Experience:SetScript("OnUpdate", Experience.OnUpdate)
	end
	
	if self.TooltipShown then
		GameTooltip:ClearLines()
		self:OnEnter()
	end
	
	self.LastXP = XP
end

function Experience:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 1) then
		Seconds = Seconds + 1
		self.Elapsed = 0
	end
end

function Experience:OnEnter()
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
	GameTooltip:AddDoubleLine(format("%s / %s", HydraUI:Comma(XP), HydraUI:Comma(Max)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining Experience"])
	GameTooltip:AddDoubleLine(format("%s", HydraUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	if Rested then
		local RestedPercent = floor((Rested / Max * 100 + 0.05) * 10) / 10
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Rested Experience"])
		GameTooltip:AddDoubleLine(HydraUI:Comma(Rested), format("%s%%", RestedPercent), 1, 1, 1, 1, 1, 1)
	end
	
	-- Advanced information
	if (Gained > 0) then
		local PerHour = (((Gained / Seconds) * 60) * 60)
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Session Stats"])
		GameTooltip:AddDoubleLine(Language["Experience gained"], HydraUI:Comma(Gained), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(Language["Per hour"], HydraUI:Comma(PerHour), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(Language["Duration"], HydraUI:FormatTime(Seconds), 1, 1, 1, 1, 1, 1)
	end
	
	self.TooltipShown = true
	
	GameTooltip:Show()
end

function Experience:OnLeave()
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

function Experience:Load()
	if (not Settings["experience-enable"]) then
		return
	end
	
	self:CreateBar()
	self:OnEvent()
	
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("UPDATE_EXHAUSTION")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:SetScript("OnEvent", self.OnEvent)
	self:SetScript("OnMouseUp", self.OnMouseUp)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	
	UpdateDisplayProgress(Settings["experience-display-progress"])
	UpdateDisplayPercent(Settings["experience-display-percent"])
	UpdateProgressVisibility(Settings["experience-progress-visibility"])
	UpdatePercentVisibility(Settings["experience-percent-visibility"])
end

local UpdateBarColor = function(value)
	Experience.Bar:SetStatusBarColor(HydraUI:HexToRGB(value))
	Experience.Bar.BG:SetVertexColor(HydraUI:HexToRGB(value))
end

local UpdateRestedColor = function(value)
	Experience.Bar.Rested:SetStatusBarColor(HydraUI:HexToRGB(value))
end

local UpdateExperience = function()
	Experience:OnEvent()
end

local UpdateMouseover = function(value)
	if value then
		Experience:SetAlpha(Settings["experience-mouseover-opacity"] / 100)
	else
		Experience:SetAlpha(1)
	end
end

local UpdateMouseoverOpacity = function(value)
	if Settings["experience-mouseover"] then
		Experience:SetAlpha(value / 100)
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Experience"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("experience-enable", Settings["experience-enable"], Language["Enable Experience Module"], Language["Enable the HydraUI experience module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("experience-display-level", Settings["experience-display-level"], Language["Display Level"], Language["Display your current level in the experience bar"], UpdateExperience)
	left:CreateSwitch("experience-display-progress", Settings["experience-display-progress"], Language["Display Progress Value"], Language["Display your current progress information in the experience bar"], UpdateDisplayProgress)
	left:CreateSwitch("experience-display-percent", Settings["experience-display-percent"], Language["Display Percent Value"], Language["Display your current percent information in the experience bar"], UpdateDisplayPercent)
	left:CreateSwitch("experience-display-rested-value", Settings["experience-display-rested-value"], Language["Display Rested Value"], Language["Display your current rested value on the experience bar"], UpdateExperience)
	left:CreateSwitch("experience-show-tooltip", Settings["experience-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the experience bar"])
	left:CreateSwitch("experience-animate", Settings["experience-animate"], Language["Animate Experience Changes"], Language["Smoothly animate changes to the experience bar"])
	
	right:CreateHeader(Language["Size"])
	right:CreateSlider("experience-width", Settings["experience-width"], 180, 400, 2, Language["Bar Width"], Language["Set the width of the experience bar"], UpdateBarWidth)
	right:CreateSlider("experience-height", Settings["experience-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the experience bar"], UpdateBarHeight)
	
	right:CreateHeader(Language["Colors"])
	right:CreateColorSelection("experience-bar-color", Settings["experience-bar-color"], Language["Experience Color"], Language["Set the color of the experience bar"], UpdateBarColor)
	right:CreateColorSelection("experience-rested-color", Settings["experience-rested-color"], Language["Rested Color"], Language["Set the color of the rested bar"], UpdateRestedColor)
	
	right:CreateHeader(Language["Visibility"])
	right:CreateDropdown("experience-progress-visibility", Settings["experience-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"], UpdateProgressVisibility)
	right:CreateDropdown("experience-percent-visibility", Settings["experience-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"], UpdatePercentVisibility)
	
	left:CreateHeader("Mouseover")
	left:CreateSwitch("experience-mouseover", Settings["experience-mouseover"], Language["Display On Mouseover"], Language["Only display the experience bar while mousing over it"], UpdateMouseover)
	left:CreateSlider("experience-mouseover-opacity", Settings["experience-mouseover-opacity"], 0, 100, 5, Language["Mouseover Opacity"], Language["Set the opacity of the experience bar while not mousing over it"], UpdateMouseoverOpacity, nil, "%")
end)
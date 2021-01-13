local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Reputation = vUI:NewModule("Reputation")

-- Default settings values
Defaults["reputation-enable"] = true
Defaults["reputation-width"] = 310
Defaults["reputation-height"] = 18
Defaults["reputation-mouseover"] = false
Defaults["reputation-mouseover-opacity"] = 0
Defaults["reputation-display-progress"] = true
Defaults["reputation-display-percent"] = true
Defaults["reputation-show-tooltip"] = true
Defaults["reputation-animate"] = true
Defaults["reputation-progress-visibility"] = "ALWAYS"
Defaults["reputation-percent-visibility"] = "ALWAYS"

local format = format
local floor = floor
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetFriendshipReputation = GetFriendshipReputation
local GetFriendshipReputationRanks = GetFriendshipReputationRanks
local IsFactionParagon = C_Reputation.IsFactionParagon
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

local UpdateProgressVisibility = function(value)
	if (value == "MOUSEOVER") then
		Reputation.Progress:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-progress"]) then
		Reputation.Progress:Show()
	end
end

local UpdatePercentVisibility = function(value)
	if (value == "MOUSEOVER") then
		Reputation.Percentage:Hide()
	elseif (value == "ALWAYS" and Settings["experience-display-percent"]) then
		Reputation.Percentage:Show()
	end
end

function Reputation:CreateBar()
	self:SetSize(Settings["reputation-width"], Settings["reputation-height"])
	self:SetFrameStrata("HIGH")
	
	if (Settings["experience-enable"] and UnitLevel("player") ~= MAX_PLAYER_LEVEL) then
		self:SetPoint("TOP", vUIExperienceBar, "BOTTOM", 0, -8)
	else
		self:SetPoint("TOP", vUI.UIParent, 0, -13)
	end
	
	if Settings["reputation-mouseover"] then
		self:SetAlpha(Settings["reputation-mouseover-opacity"] / 100)
	end
	
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
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Texture = self.BarBG:CreateTexture(nil, "ARTWORK")
	self.Texture:SetPoint("TOPLEFT", self.BarBG, 1, -1)
	self.Texture:SetPoint("BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BGAll = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.BGAll:SetPoint("TOPLEFT", self.BarBG, -3, 3)
	self.BGAll:SetPoint("BOTTOMRIGHT", self.BarBG, 3, -3)
	self.BGAll:SetBackdrop(vUI.BackdropAndBorder)
	self.BGAll:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.BGAll:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
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
	self.Bar.Spark:SetSize(1, Settings["reputation-height"])
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
	self.Change:SetEasing("inout")
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
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetPoint("LEFT", self.Bar, 5, 0)
	vUI:SetFontInfo(self.Progress, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	if (not Settings["reputation-display-progress"]) then
		self.Progress:Hide()
	end
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetPoint("RIGHT", self.Bar, -5, 0)
	vUI:SetFontInfo(self.Percentage, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
	
	UpdateProgressVisibility(Settings["reputation-progress-visibility"])
	UpdatePercentVisibility(Settings["reputation-percent-visibility"])
	
	if (not Settings["reputation-display-percent"]) then
		self.Percentage:Hide()
	end
	
	vUI:CreateMover(self, 6)
end

function Reputation:OnEvent()
	local Name, StandingID, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if Name then
		local FriendID = GetFriendshipReputation(FactionID)
		
		if FriendID then
			local FriendID, FriendRep, FriendMaxRep, FriendName, Description, Texture, TextLevel, Threshold = GetFriendshipReputation(FactionID)
			
			Min = Threshold
			Max = FriendMaxRep
			Value = FriendRep
		elseif IsFactionParagon(FactionID) then
			local CurrentValue, Threshold, _, RewardPending = GetFactionParagonInfo(FactionID)
			
			Min = 0
			Max = Threshold
			Value = CurrentValue % Threshold
			
			if RewardPending then
				Value = Value + Threshold
			end
		end
		
		Max = Max - Min
		Value = Value - Min
		
		self.Bar:SetMinMaxValues(0, Max)
		self.Bar:SetStatusBarColor(vUI:HexToRGB(Settings["color-reaction-" .. StandingID]))
		
		self.Progress:SetText(format("%s: %s / %s", Name, vUI:Comma(Value), vUI:Comma(Max)))
		self.Percentage:SetText(floor((Value / Max * 100 + 0.05) * 10) / 10 .. "%")
		
		if Settings["reputation-animate"] then
			self.Change:SetChange(Value)
			self.Change:Play()
			
			if (not self.Flash:IsPlaying()) then
				self.Flash:Play()
			end
		else
			self.Bar:SetValue(Value)
		end
		
		if (not self:IsShown()) then
			self:Show()
			self.FadeIn:Play()
		end
	elseif self:IsShown() then
		self.FadeOut:Play()
	end
end

function Reputation:OnMouseUp()
	ToggleCharacter("ReputationFrame")
end

function Reputation:OnEnter()
	if Settings["reputation-mouseover"] then
		self:SetAlpha(1)
	end
	
	if (Settings["reputation-display-progress"] and Settings["reputation-progress-visibility"] == "MOUSEOVER") then
		if (not self.Progress:IsShown()) then
			self.Progress:Show()
		end
	end
	
	if (Settings["reputation-display-percent"] and Settings["reputation-percent-visibility"] == "MOUSEOVER") then
		if (not self.Percentage:IsShown()) then
			self.Percentage:Show()
		end
	end
	
	if (not Settings["reputation-show-tooltip"]) then
		return
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8)
	
	local Name, StandingID, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if (not Name) then
		return
	end
	
	local FriendID = GetFriendshipReputation(FactionID)
	local Level
	
	if FriendID then
		local FriendID, FriendRep, FriendMaxRep, FriendName, Description, Texture, TextLevel, Threshold = GetFriendshipReputation(FactionID)
		
		Min = Threshold
		Max = FriendMaxRep
		Value = FriendRep
		Level = TextLevel
	elseif IsFactionParagon(FactionID) then
		local CurrentValue, Threshold, _, RewardPending = GetFactionParagonInfo(FactionID)
		
		Min = 0
		Max = Threshold
		Value = CurrentValue % Threshold
		Level = _G["FACTION_STANDING_LABEL" .. StandingID]
		
		if RewardPending then
			Value = Value + Threshold
		end
	else
		Level = _G["FACTION_STANDING_LABEL" .. StandingID]
	end
	
	GameTooltip:AddLine(Name)
	GameTooltip:AddLine(" ")
	
	Max = Max - Min
	Value = Value - Min
	
	local Remaining = Max - Value
	local RemainingPercent = floor((Remaining / Max * 100 + 0.05) * 10) / 10
	
	GameTooltip:AddLine(Language["Current reputation"])
	GameTooltip:AddDoubleLine(format("%s / %s", vUI:Comma(Value), vUI:Comma(Max)), format("%s%%", floor((Value / Max * 100 + 0.05) * 10) / 10), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining reputation"])
	GameTooltip:AddDoubleLine(format("%s", vUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Faction standing"])
	GameTooltip:AddLine(Level, 1, 1, 1)
	
	self.TooltipShown = true
	
	GameTooltip:Show()
end

function Reputation:OnLeave()
	if Settings["reputation-mouseover"] then
		self:SetAlpha(Settings["reputation-mouseover-opacity"] / 100)
	end

	if Settings["reputation-show-tooltip"] then
		GameTooltip:Hide()
		
		self.TooltipShown = false
	end
	
	if (Settings["reputation-display-progress"] and Settings["reputation-progress-visibility"] == "MOUSEOVER") then
		if self.Progress:IsShown() then
			self.Progress:Hide()
		end
	end
	
	if (Settings["reputation-display-percent"] and Settings["reputation-percent-visibility"] == "MOUSEOVER") then
		if self.Percentage:IsShown() then
			self.Percentage:Hide()
		end
	end
end

function Reputation:Load()
	if (not Settings["reputation-enable"]) then
		return
	end
	
	self:CreateBar()
	self:OnEvent()
	
	self:RegisterEvent("UPDATE_FACTION")
	self:SetScript("OnEvent", self.OnEvent)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	self:SetScript("OnMouseUp", self.OnMouseUp)
end

local UpdateDisplayProgress = function(value)
	if value then
		Reputation.Progress:Show()
	else
		Reputation.Progress:Hide()
	end
end

local UpdateDisplayPercent = function(value)
	if value then
		Reputation.Percentage:Show()
	else
		Reputation.Percentage:Hide()
	end
end

local UpdateBarWidth = function(value)
	Reputation:SetWidth(value)
end

local UpdateBarHeight = function(value)
	Reputation:SetHeight(value)
	Reputation.Bar.Spark:SetHeight(value)
end

local UpdateMouseover = function(value)
	if value then
		Reputation:SetAlpha(Settings["reputation-mouseover-opacity"] / 100)
	else
		Reputation:SetAlpha(1)
	end
end

local UpdateMouseoverOpacity = function(value)
	if Settings["reputation-mouseover"] then
		Reputation:SetAlpha(value / 100)
	end
end

GUI:AddWidgets(Language["General"], Language["Reputation"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("reputation-enable", true, Language["Enable Reputation Module"], Language["Enable the vUI reputation module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("reputation-display-progress", Settings["reputation-display-progress"], Language["Display Progress Value"], Language["Display your current progressinformation in the reputation bar"], UpdateDisplayProgress)
	left:CreateSwitch("reputation-display-percent", Settings["reputation-display-percent"], Language["Display Percent Value"], Language["Display your current percentinformation in the reputation bar"], UpdateDisplayPercent)
	left:CreateSwitch("reputation-show-tooltip", Settings["reputation-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the reputation bar"])
	left:CreateSwitch("reputation-animate", Settings["reputation-animate"], Language["Animate Reputation Changes"], Language["Smoothly animate changes to the reputation bar"])
	
	right:CreateHeader(Language["Size"])
	right:CreateSlider("reputation-width", Settings["reputation-width"], 240, 400, 10, Language["Bar Width"], Language["Set the width of the reputation bar"], UpdateBarWidth)
	right:CreateSlider("reputation-height", Settings["reputation-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the reputation bar"], UpdateBarHeight)
	
	right:CreateHeader(Language["Visibility"])
	right:CreateDropdown("reputation-progress-visibility", Settings["reputation-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"], UpdateProgressVisibility)
	right:CreateDropdown("reputation-percent-visibility", Settings["reputation-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"], UpdatePercentVisibility)
	
	left:CreateHeader("Mouseover")
	left:CreateSwitch("reputation-mouseover", Settings["reputation-mouseover"], Language["Display On Mouseover"], Language["Only display the reputation bar while mousing over it"], UpdateMouseover)
	left:CreateSlider("reputation-mouseover-opacity", Settings["reputation-mouseover-opacity"], 0, 100, 5, Language["Mouseover Opacity"], Language["Set the opacity of the reputation bar while not mousing over it"], UpdateMouseoverOpacity, nil, "%")
end)
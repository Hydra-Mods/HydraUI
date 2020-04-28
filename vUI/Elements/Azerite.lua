local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Azerite = vUI:NewModule("Azerite")

local FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local GetPowerLevel = C_AzeriteItem.GetPowerLevel

function Azerite:CreateBar()
	self:SetSize(Settings["azerite-width"], Settings["azerite-height"])
	self:SetFrameStrata("HIGH")
	
	if Settings["experience-enable"] then
		self:SetPoint("TOP", vUIExperienceBar, "BOTTOM", 0, -6)
	else
		self:SetPoint("TOP", vUI.UIParent, 0, -13)
	end
	
	self.HeaderBG = CreateFrame("Frame", nil, self)
	self.HeaderBG:SetHeight(Settings["azerite-height"])
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
	self.Bar:SetStatusBarColor(vUI:HexToRGB("EECC99"))
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
	self.Bar.Spark:SetSize(1, Settings["azerite-height"])
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
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetPoint("LEFT", self.Bar, 5, 0)
	vUI:SetFontInfo(self.Progress, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	-- Add fade to self.Progress
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetPoint("RIGHT", self.Bar, -5, 0)
	vUI:SetFontInfo(self.Percentage, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
	
	if (not Settings["azerite-display-percent"]) then
		self.Percentage:Hide()
	end
	
	vUI:CreateMover(self, 6)
end

function Azerite:OnEvent()
	local AzeriteLocation = FindActiveAzeriteItem()
	
	if (not AzeriteLocation) then
		self:UnregisterAllEvents()
		self:Hide()
		
		return
	end
	
	local XP, TotalXP = GetAzeriteItemXPInfo(AzeriteLocation)
	local Level = GetPowerLevel(AzeriteLocation)
	
	self.Bar:SetMinMaxValues(0, TotalXP)
	
	self.Progress:SetText(format("%s / %s", vUI:Comma(XP), vUI:Comma(TotalXP)))
	self.Percentage:SetText(floor((XP / TotalXP * 100 + 0.05) * 10) / 10 .. "%")
	
	self.Change:SetChange(XP)
	self.Change:Play()
	
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r %s", Settings["ui-header-font-color"], Language["Level"], Level))
	self.HeaderBG:SetWidth(self.HeaderBG.Text:GetWidth() + 14)
end

function Azerite:OnEnter()
	if (Settings["azerite-display-progress"] and Settings["azerite-progress-visibility"] == "MOUSEOVER") then
		if (not self.Progress:IsShown()) then
			self.Progress:Show()
		end
	end
	
	if (Settings["azerite-display-percent"] and Settings["azerite-percent-visibility"] == "MOUSEOVER") then
		if (not self.Percentage:IsShown()) then
			self.Percentage:Show()
		end
	end
	
	if (not Settings["azerite-show-tooltip"]) then
		return
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8)
	
	local Name, StandingID, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if (not Name) then
		return
	end
	
	GameTooltip:AddLine(Name)
	GameTooltip:AddLine(" ")
	
	Max = Max - Min
	Value = Value - Min
	
	local Remaining = Max - Value
	local RemainingPercent = floor((Remaining / Max * 100 + 0.05) * 10) / 10
	
	GameTooltip:AddLine(Language["Current Azerite"])
	GameTooltip:AddDoubleLine(format("%s / %s", vUI:Comma(Value), vUI:Comma(Max)), format("%s%%", floor((Value / Max * 100 + 0.05) * 10) / 10), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining Azerite"])
	GameTooltip:AddDoubleLine(format("%s", vUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Faction standing"])
	GameTooltip:AddLine(_G["FACTION_STANDING_LABEL" .. StandingID], 1, 1, 1)
	
	self.TooltipShown = true
	
	GameTooltip:Show()
end

function Azerite:OnLeave()
	if Settings["azerite-show-tooltip"] then
		GameTooltip:Hide()
		
		self.TooltipShown = false
	end
	
	if (Settings["azerite-display-progress"] and Settings["azerite-progress-visibility"] == "MOUSEOVER") then
		if self.Progress:IsShown() then
			self.Progress:Hide()
		end
	end
	
	if (Settings["azerite-display-percent"] and Settings["azerite-percent-visibility"] == "MOUSEOVER") then
		if self.Percentage:IsShown() then
			self.Percentage:Hide()
		end
	end
end

function Azerite:Load()
	if (not Settings["azerite-enable"]) then
		return
	end
	
	self:CreateBar()
	self:OnEvent()
	
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	--self:SetScript("OnMouseUp", self.OnMouseUp)
end

local UpdateDisplayProgress = function(value)
	if value then
		Azerite.Progress:Show()
	else
		Azerite.Progress:Hide()
	end
end

local UpdateDisplayPercent = function(value)
	if value then
		Azerite.Percentage:Show()
	else
		Azerite.Percentage:Hide()
	end
end

local UpdateBarWidth = function(value)
	Azerite:SetWidth(value)
end

local UpdateBarHeight = function(value)
	Azerite:SetHeight(value)
	Azerite.Bar.Spark:SetHeight(value)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Azerite"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("azerite-enable", true, Language["Enable Azerite Module"], Language["Enable the vUI azerite module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSwitch("azerite-display-progress", Settings["azerite-display-progress"], Language["Display Progress Value"], Language["Display your current progress information in the azerite bar"], UpdateDisplayProgress)
	Left:CreateSwitch("azerite-display-percent", Settings["azerite-display-percent"], Language["Display Percent Value"], Language["Display your current percent information in the azerite bar"], UpdateDisplayPercent)
	Left:CreateSwitch("azerite-show-tooltip", Settings["azerite-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the azerite bar"])
	Left:CreateSwitch("azerite-animate", Settings["azerite-animate"], Language["Animate Azerite Changes"], Language["Smoothly animate changes to the azerite bar"])
	
	Right:CreateHeader(Language["Size"])
	Right:CreateSlider("azerite-width", Settings["azerite-width"], 240, 400, 10, Language["Bar Width"], Language["Set the width of the azerite bar"], UpdateBarWidth)
	Right:CreateSlider("azerite-height", Settings["azerite-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the azerite bar"], UpdateBarHeight)
	
	Right:CreateHeader(Language["Visibility"])
	Right:CreateDropdown("azerite-progress-visibility", Settings["azerite-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"], UpdateProgressVisibility)
	Right:CreateDropdown("azerite-percent-visibility", Settings["azerite-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"], UpdatePercentVisibility)
end)
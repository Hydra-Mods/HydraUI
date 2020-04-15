local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Azerite = vUI:NewModule("Azerite")

local FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local GetPowerLevel = C_AzeriteItem.GetPowerLevel

function Azerite:CreateBar()
	vUI:SetSize(self, Settings["azerite-width"], Settings["azerite-height"])
	vUI:SetPoint(self, "TOP", UIParent, 0, -13)
	self:SetFrameStrata("HIGH")
	
	self.HeaderBG = CreateFrame("Frame", nil, self)
	vUI:SetHeight(self.HeaderBG, Settings["azerite-height"])
	vUI:SetPoint(self.HeaderBG, "LEFT", self, 0, 0)
	self.HeaderBG:SetBackdrop(vUI.BackdropAndBorder)
	self.HeaderBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.HeaderBG:SetBackdropBorderColor(0, 0, 0)
	
	self.HeaderBG.Texture = self.HeaderBG:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.HeaderBG.Texture, "TOPLEFT", self.HeaderBG, 1, -1)
	vUI:SetPoint(self.HeaderBG.Texture, "BOTTOMRIGHT", self.HeaderBG, -1, 1)
	self.HeaderBG.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.HeaderBG.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.HeaderBG.Text = self.HeaderBG:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.HeaderBG.Text, "CENTER", self.HeaderBG, 0, 0)
	vUI:SetFontInfo(self.HeaderBG.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.HeaderBG.Text:SetJustifyH("CENTER")
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r", Settings["ui-widget-color"], Language["Level"]))
	
	self.BarBG = CreateFrame("Frame", nil, self)
	vUI:SetPoint(self.BarBG, "TOPLEFT", self.HeaderBG, "TOPRIGHT", 2, 0)
	vUI:SetPoint(self.BarBG, "BOTTOMRIGHT", self, 0, 0)
	self.BarBG:SetBackdrop(vUI.BackdropAndBorder)
	self.BarBG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BarBG:SetBackdropBorderColor(0, 0, 0)
	
	self.Texture = self.BarBG:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.Texture, "TOPLEFT", self.BarBG, 1, -1)
	vUI:SetPoint(self.Texture, "BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BGAll = CreateFrame("Frame", nil, self)
	vUI:SetPoint(self.BGAll, "TOPLEFT", self.HeaderBG, -3, 3)
	vUI:SetPoint(self.BGAll, "BOTTOMRIGHT", self.BarBG, 3, -3)
	self.BGAll:SetBackdrop(vUI.BackdropAndBorder)
	self.BGAll:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.BGAll:SetBackdropBorderColor(0, 0, 0)
	
	self.Bar = CreateFrame("StatusBar", nil, self.BarBG)
	self.Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetStatusBarColor(vUI:HexToRGB("EECC99"))
	vUI:SetPoint(self.Bar, "TOPLEFT", self.BarBG, 1, -1)
	vUI:SetPoint(self.Bar, "BOTTOMRIGHT", self.BarBG, -1, 1)
	self.Bar:SetFrameLevel(6)
	
	self.Bar.BG = self.Bar:CreateTexture(nil, "BORDER")
	self.Bar.BG:SetAllPoints(self.Bar)
	self.Bar.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar.BG:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Bar.BG:SetAlpha(0.2)
	
	self.Bar.Spark = self.Bar:CreateTexture(nil, "OVERLAY")
	self.Bar.Spark:SetDrawLayer("OVERLAY", 7)
	vUI:SetSize(self.Bar.Spark, 1, Settings["azerite-height"])
	vUI:SetPoint(self.Bar.Spark, "LEFT", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
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
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.Progress, "LEFT", self.Bar, 5, 0)
	vUI:SetFontInfo(self.Progress, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	-- Add fade to self.Progress
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.Percentage, "RIGHT", self.Bar, -5, 0)
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
	vUI:SetWidth(self.HeaderBG, self.HeaderBG.Text:GetWidth() + 14)
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
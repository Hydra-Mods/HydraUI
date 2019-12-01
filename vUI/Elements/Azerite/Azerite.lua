local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Azerite = vUI:NewModule("Azerite")
local Reputation = vUI:GetModule("Reputation")

local FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local GetPowerLevel = C_AzeriteItem.GetPowerLevel

function Azerite:UpdateBarPosition(value)
	self:ClearAllPoints()
	
	if (value == "TOP") then
		self.BGAll:Show()
		self:SetScaledSize(Settings["azerite-width"], Settings["azerite-height"])
		self.Bar.Spark:SetScaledHeight(Settings["reputation-height"])
		
		if (Settings["reputation-enable"] and Settings["reputation-position"] == "TOP") then
			self:SetScaledPoint("TOP", Reputation, "BOTTOM", 0, -8)
		else
			self:SetScaledPoint("TOP", UIParent, 0, -13)
		end
		
		vUIChatFrameBottom:Show()
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			
			if (Settings["reputation-enable"] and Settings["reputation-position"] ~= "CLASSIC") then
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
			else
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", Reputation, "TOP", 0, 5)
			end
		end
	elseif (value == "CHATFRAME") then
		vUIChatFrameBottom:Hide()
		
		local Height = vUIChatFrameBottom:GetHeight()
		
		self.BGAll:Hide()
		self:SetScaledSize(vUIChatFrameBottom:GetWidth(), Height)
		self:SetScaledPoint("CENTER", vUIChatFrameBottom, 0, 0)
		
		self.Bar.Spark:SetScaledHeight(Height)
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			
			if (Settings["reputation-enable"] and Settings["reputation-position"] ~= "CLASSIC") then
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
			else
				vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", Reputation, "TOP", 0, 5)
			end
		end
	elseif (value == "CLASSIC") then
		vUIChatFrameBottom:Show()
		
		self.BGAll:Show()
		self:SetScaledHeight(Settings["azerite-height"])
		self:SetScaledPoint("BOTTOM", UIParent, 0, 13)
		self.Bar.Spark:SetScaledHeight(Settings["azerite-height"])
		
		if vUIBottomActionBarsPanel then
			vUIBottomActionBarsPanel:ClearAllPoints()
			vUIBottomActionBarsPanel:SetScaledPoint("BOTTOM", self, "TOP", 0, 5)
			
			self:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - 6)
		end
	end
end

function Azerite:CreateBar()
	self:SetScaledSize(Settings["azerite-width"], Settings["azerite-height"])
	self:SetScaledPoint("TOP", UIParent, 0, -13)
	self:SetFrameStrata("HIGH")
	--self:SetScript("OnEnter", self.OnEnter)
	--self:SetScript("OnLeave", self.OnLeave)
	
	self.HeaderBG = CreateFrame("Frame", nil, self)
	self.HeaderBG:SetScaledHeight(Settings["azerite-height"])
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
	self.Bar:SetStatusBarColorHex("EECC99")
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
	self.Bar.Spark:SetScaledSize(1, Settings["azerite-height"])
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
	
	self.Progress = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Progress:SetScaledPoint("LEFT", self.Bar, 5, 0)
	self.Progress:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Progress:SetJustifyH("LEFT")
	
	-- Add fade to self.Progress
	
	self.Percentage = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Percentage:SetScaledPoint("RIGHT", self.Bar, -5, 0)
	self.Percentage:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Percentage:SetJustifyH("RIGHT")
	
	if (not Settings["azerite-display-percent"]) then
		self.Percentage:Hide()
	end
	
	self:UpdateBarPosition(Settings["azerite-position"])
end

function Azerite:OnEvent()
	local AzeriteLocation = FindActiveAzeriteItem()
	local XP, TotalXP = GetAzeriteItemXPInfo(AzeriteLocation)
	local Level = GetPowerLevel(AzeriteLocation)
	
	self.Bar:SetMinMaxValues(0, TotalXP)
	
	self.Progress:SetText(format("%s / %s", vUI:Comma(XP), vUI:Comma(TotalXP)))
	self.Percentage:SetText(floor((XP / TotalXP * 100 + 0.05) * 10) / 10 .. "%")
	
	self.Change:SetChange(XP)
	self.Change:Play()
	
	self.HeaderBG.Text:SetText(format("|cFF%s%s:|r %s", Settings["ui-header-font-color"], Language["Level"], Level))
	self.HeaderBG:SetScaledWidth(self.HeaderBG.Text:GetWidth() + 14)
	
	--[[local Name, StandingID, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if Name then
		Max = Max - Min
		Value = Value - Min
		
		self.Bar:SetMinMaxValues(0, Max)
		self.Bar:SetStatusBarColorHex(Settings["color-reaction-" .. StandingID])
		
		self.Progress:SetText(format("%s: %s / %s", Name, vUI:Comma(Value), vUI:Comma(Max)))
		self.Percentage:SetText(floor((Value / Max * 100 + 0.05) * 10) / 10 .. "%")
		
		self.Change:SetChange(Value)
		self.Change:Play()
		
		if (not self:IsShown()) then
			self:Show()
			self.FadeIn:Play()
		end
	elseif self:IsShown() then
		self.FadeOut:Play()
	end]]
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
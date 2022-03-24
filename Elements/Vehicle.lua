local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Vehicle = HydraUI:NewModule("Vehicle")

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

function Vehicle:OnEnter()
	local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-font-color"])
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, -6)
	GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, R, G, B)
	GameTooltip:Show()
end

function Vehicle:OnLeave()
	GameTooltip:Hide()
end

function Vehicle:OnEvent()
    if CanExitVehicle() then
        if UnitOnTaxi("player") then
            self.Text:SetText(Language["Land Early"])
			
			self:SetScript("OnEnter", self.OnEnter)
			self:SetScript("OnLeave", self.OnLeave)
        else
            self.Text:SetText(LEAVE_VEHICLE)
			
			self:SetScript("OnEnter", nil)
			self:SetScript("OnLeave", nil)
        end
		
        self:Show()
		self.FadeIn:Play()
    else
		self.FadeOut:Play()
    end
end

function Vehicle:OnMouseUp()
    if UnitOnTaxi("player") then
        TaxiRequestEarlyLanding()
		
		HydraUI:print(Language["Requested early landing."])
    else
        VehicleExit()
    end
	
	self.FadeOut:Play()
end

function Vehicle:Load()
	self:SetSize(Settings["minimap-size"] + 8, 22)
	self:SetFrameStrata("HIGH")
	self:SetFrameLevel(10)
	self:SetBackdrop(HydraUI.BackdropAndBorder)
	self:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("VEHICLE_UPDATE")
	self:SetScript("OnMouseUp", self.OnMouseUp)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	self:SetScript("OnEvent", self.OnEvent)
	
	self.Texture = self:CreateTexture(nil, "ARTWORK")
	self.Texture:SetPoint("TOPLEFT", self, 1, -1)
	self.Texture:SetPoint("BOTTOMRIGHT", self, -1, 1)
	self.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Text = self:CreateFontString(nil, "OVERLAY", 7)
	self.Text:SetPoint("CENTER", self, 0, -1)
	HydraUI:SetFontInfo(self.Text, Settings["ui-header-font"], Settings["ui-font-size"])
	self.Text:SetSize(self:GetWidth() - 12, 20)
	
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
	
	if (not CanExitVehicle()) then
		self:SetAlpha(0)
		self:Hide()
	end
	
	if Settings["minimap-enable"] then
		self:SetPoint("TOP", _G["HydraUI Minimap"], "BOTTOM", 0, -2)
	else
		self:SetPoint("TOP", HydraUI.UIParent, 0, -120)
	end
	
	HydraUI:CreateMover(self)
end
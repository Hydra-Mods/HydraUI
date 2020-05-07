local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Vehicle = vUI:NewModule("Vehicle")

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

function Vehicle:OnEnter()
	local R, G, B = vUI:HexToRGB(Settings["ui-widget-font-color"])
	
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
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

function Vehicle:Exit()
    if UnitOnTaxi("player") then
        TaxiRequestEarlyLanding()
		
		vUI:print(Language["Requested early landing."])
    else
        VehicleExit()
    end
	
	self.FadeOut:Play()
end

function Vehicle:Load()
	self:SetSize(Settings["minimap-size"] + 8, 22)
	self:SetPoint("TOP", _G["vUI Minimap"], "BOTTOM", 0, -2)
	self:SetFrameStrata("HIGH")
	self:SetFrameLevel(10)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetScript("OnMouseUp", self.Exit)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("VEHICLE_UPDATE")
	self:SetScript("OnEvent", self.OnEvent)
	
	self.Texture = self:CreateTexture(nil, "ARTWORK")
	self.Texture:SetPoint("TOPLEFT", self, 1, -1)
	self.Texture:SetPoint("BOTTOMRIGHT", self, -1, 1)
	self.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Text = self:CreateFontString(nil, "OVERLAY", 7)
	self.Text:SetPoint("CENTER", self, 0, -1)
	vUI:SetFontInfo(self.Text, Settings["ui-header-font"], Settings["ui-font-size"])
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
	
	vUI:CreateMover(self)
end
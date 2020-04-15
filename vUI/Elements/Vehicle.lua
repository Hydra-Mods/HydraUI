local vUI, GUI, Language, Media, Settings = select(2, ...):get()

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

function Vehicle:OnEvent(event)
    if CanExitVehicle() then
        if UnitOnTaxi("player") then
            self.Text:SetText(TAXI_CANCEL_DESCRIPTION)
			
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
	self.Button = CreateFrame("Button", "vUI Vehicle", UIParent)
	vUI:SetSize(self.Button, Settings["minimap-size"] + 8, 22)
	vUI:SetPoint(self.Button, "TOP", _G["vUI Minimap"], "BOTTOM", 0, -2)
	self.Button:SetFrameStrata("HIGH")
	self.Button:SetFrameLevel(10)
	self.Button:SetBackdrop(vUI.BackdropAndBorder)
	self.Button:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Button:SetBackdropBorderColor(0, 0, 0)
	self.Button:SetScript("OnMouseUp", self.Exit)
	self.Button:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.Button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self.Button:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	self.Button:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self.Button:RegisterEvent("UNIT_EXITED_VEHICLE")
	self.Button:RegisterEvent("VEHICLE_UPDATE")
	self.Button:SetScript("OnEvent", self.OnEvent)
	
	self.Button.Texture = self.Button:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.Button.Texture, "TOPLEFT", self.Button, 1, -1)
	vUI:SetPoint(self.Button.Texture, "BOTTOMRIGHT", self.Button, -1, 1)
	self.Button.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Button.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Button.Text = self.Button:CreateFontString(nil, "OVERLAY", 7)
	vUI:SetPoint(self.Button.Text, "CENTER", self.Button, 0, -1)
	vUI:SetFontInfo(self.Button.Text, Settings["ui-header-font"], Settings["ui-font-size"])
	vUI:SetSize(self.Button.Text, self.Button:GetWidth() - 12, 20)
	
	self.Button.Fade = CreateAnimationGroup(self.Button)
	
	self.Button.FadeIn = self.Button.Fade:CreateAnimation("Fade")
	self.Button.FadeIn:SetEasing("in")
	self.Button.FadeIn:SetDuration(0.15)
	self.Button.FadeIn:SetChange(1)
	
	self.Button.FadeOut = self.Button.Fade:CreateAnimation("Fade")
	self.Button.FadeOut:SetEasing("out")
	self.Button.FadeOut:SetDuration(0.15)
	self.Button.FadeOut:SetChange(0)
	self.Button.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	if (not CanExitVehicle()) then
		self.Button:SetAlpha(0)
		self.Button:Hide()
	end
end
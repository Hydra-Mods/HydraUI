local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Toast = HydraUI:NewModule("Toast")

local AddToast = function(self)
	if self.Styled then
		return
	end
	
	HydraUI:SetFontInfo(self.TopLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	HydraUI:SetFontInfo(self.MiddleLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	HydraUI:SetFontInfo(self.BottomLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	HydraUI:SetFontInfo(self.DoubleLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	
	self.TooltipFrame:Hide()
	
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", HydraUI:GetModule("Chat"), "TOPLEFT", 0, 3)
	
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])

	self:SetBackdrop(HydraUI.BackdropAndBorder)
	self:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	self:SetBackdropBorderColor(0, 0, 0)
end

function Toast:Load()
	hooksecurefunc(BNToastFrame, "AddToast", AddToast)
end
local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Toast = vUI:NewModule("Toast")

local AddToast = function(self)
	if self.Styled then
		return
	end
	
	vUI:SetFontInfo(self.TopLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	vUI:SetFontInfo(self.MiddleLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	vUI:SetFontInfo(self.BottomLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	vUI:SetFontInfo(self.DoubleLine, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	
	self.TooltipFrame:Hide()
	
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", vUI:GetModule("Chat"), "TOPLEFT", 0, 3)
	
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])

	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	self:SetBackdropBorderColor(0, 0, 0)
end

function Toast:Load()
	hooksecurefunc(BNToastFrame, "AddToast", AddToast)
end
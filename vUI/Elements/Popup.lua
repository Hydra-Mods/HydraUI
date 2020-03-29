local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Popup = CreateFrame("Frame", "vUIPopupFrame", UIParent)

local POPUP_WIDTH = 320
local POPUP_HEIGHT = 100
local BUTTON_WIDTH = ((POPUP_WIDTH - 6) / 2) - 1

-- IsSevere flag, where you need to hold accept for 1 sec to apply the click. place a statusbar in the button. For things like deleting profiles/saved data

local Button1OnMouseUp = function(self)
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	if self.Callback then
		self.Callback(self.Arg1, self.Arg2)
	end
	
	self:GetParent():Hide()
end

local Button2OnMouseUp = function(self)
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	if self.Callback then
		self.Callback(self.Arg1, self.Arg2)
	end
	
	self:GetParent():Hide()
end

local ButtonOnMouseDown = function(self)
	local R, G, B = vUI:HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local ButtonOnEnter = function(self)
	self.Highlight:SetAlpha(0.1)
end

local ButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

Popup.CreatePopupFrame = function(self)
	self:SetScaledSize(POPUP_WIDTH, POPUP_HEIGHT)
	self:SetScaledPoint("TOP", UIParent, 0, -180)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetClampedToScreen(true)
	--self:SetAlpha(0)
	--self:Hide()
	
	-- Header
	self.Header = CreateFrame("Frame", nil, self)
	self.Header:SetScaledSize(POPUP_WIDTH - 6, 20)
	self.Header:SetScaledPoint("TOP", self, 0, -3)
	self.Header:SetBackdrop(vUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.Header.Texture = self.Header:CreateTexture(nil, "ARTWORK")
	self.Header.Texture:SetScaledPoint("TOPLEFT", self.Header, 1, -1)
	self.Header.Texture:SetScaledPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.Header.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Header.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetScaledPoint("LEFT", self.Header, 5, -1)
	self.Header.Text:SetFont(Media:GetFont(Settings["ui-header-font"]), 14)
	self.Header.Text:SetJustifyH("LEFT")
	self.Header.Text:SetShadowColor(0, 0, 0)
	self.Header.Text:SetShadowOffset(1, -1)
	self.Header.Text:SetTextColor(vUI:HexToRGB(Settings["ui-header-font-color"]))
	
	-- Body
	self.Body = CreateFrame("Frame", nil, self)
	self.Body:SetScaledSize(POPUP_WIDTH - 6, POPUP_HEIGHT - 50)
	self.Body:SetScaledPoint("TOP", self.Header, "BOTTOM", 0, -2)
	self.Body:SetBackdrop(vUI.BackdropAndBorder)
	self.Body:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Body:SetBackdropBorderColor(0, 0, 0)
	
	self.Body.Text = self.Body:CreateFontString(nil, "OVERLAY")
	--self.Body.Text:SetScaledPoint("TOP", self.Body, 0, -3)
	--self.Body.Text:SetScaledWidth(POPUP_WIDTH - 12)
	
	self.Body.Text:SetScaledPoint("TOPLEFT", self.Body, 3, -3)
	self.Body.Text:SetScaledPoint("BOTTOMRIGHT", self.Body, -3, 3)
	self.Body.Text:SetFont(Media:GetFont(Settings["ui-button-font"]), Settings["ui-font-size"])
	--self.Body.Text:SetJustifyH("LEFT")
	self.Body.Text:SetShadowColor(0, 0, 0)
	self.Body.Text:SetShadowOffset(1, -1)
	self.Body.Text:SetText(value)
	
	-- Button1
	self.Button1 = CreateFrame("Frame", nil, self)
	self.Button1:SetScaledSize(BUTTON_WIDTH, 20)
	self.Button1:SetScaledPoint("BOTTOMLEFT", self, 3, 3)
	self.Button1:SetBackdrop(vUI.BackdropAndBorder)
	self.Button1:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	self.Button1:SetBackdropBorderColor(0, 0, 0)
	self.Button1:SetScript("OnMouseUp", Button1OnMouseUp)
	self.Button1:SetScript("OnMouseDown", ButtonOnMouseDown)
	self.Button1:SetScript("OnEnter", ButtonOnEnter)
	self.Button1:SetScript("OnLeave", ButtonOnLeave)
	
	self.Button1.Texture = self.Button1:CreateTexture(nil, "BORDER")
	self.Button1.Texture:SetScaledPoint("TOPLEFT", self.Button1, 1, -1)
	self.Button1.Texture:SetScaledPoint("BOTTOMRIGHT", self.Button1, -1, 1)
	self.Button1.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	self.Button1.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	self.Button1.Highlight = self.Button1:CreateTexture(nil, "ARTWORK")
	self.Button1.Highlight:SetScaledPoint("TOPLEFT", self.Button1, 1, -1)
	self.Button1.Highlight:SetScaledPoint("BOTTOMRIGHT", self.Button1, -1, 1)
	self.Button1.Highlight:SetTexture(Media:GetTexture("Blank"))
	self.Button1.Highlight:SetVertexColor(1, 1, 1, 0.4)
	self.Button1.Highlight:SetAlpha(0)
	
	self.Button1.Text = self.Button1:CreateFontString(nil, "OVERLAY")
	self.Button1.Text:SetScaledPoint("CENTER", self.Button1, "CENTER", 0, 0)
	self.Button1.Text:SetScaledSize(BUTTON_WIDTH - 6, 20)
	self.Button1.Text:SetFont(Media:GetFont(Settings["ui-button-font"]), Settings["ui-font-size"])
	self.Button1.Text:SetJustifyH("CENTER")
	self.Button1.Text:SetShadowColor(0, 0, 0)
	self.Button1.Text:SetShadowOffset(1, -1)
	self.Button1.Text:SetText(value)
	
	-- Button2
	self.Button2 = CreateFrame("Frame", nil, self)
	self.Button2:SetScaledSize(BUTTON_WIDTH, 20)
	self.Button2:SetScaledPoint("BOTTOMRIGHT", self, -3, 3)
	self.Button2:SetBackdrop(vUI.BackdropAndBorder)
	self.Button2:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	self.Button2:SetBackdropBorderColor(0, 0, 0)
	self.Button2:SetScript("OnMouseUp", Button2OnMouseUp)
	self.Button2:SetScript("OnMouseDown", ButtonOnMouseDown)
	self.Button2:SetScript("OnEnter", ButtonOnEnter)
	self.Button2:SetScript("OnLeave", ButtonOnLeave)
	
	self.Button2.Texture = self.Button2:CreateTexture(nil, "BORDER")
	self.Button2.Texture:SetScaledPoint("TOPLEFT", self.Button2, 1, -1)
	self.Button2.Texture:SetScaledPoint("BOTTOMRIGHT", self.Button2, -1, 1)
	self.Button2.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	self.Button2.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	self.Button2.Highlight = self.Button2:CreateTexture(nil, "ARTWORK")
	self.Button2.Highlight:SetScaledPoint("TOPLEFT", self.Button2, 1, -1)
	self.Button2.Highlight:SetScaledPoint("BOTTOMRIGHT", self.Button2, -1, 1)
	self.Button2.Highlight:SetTexture(Media:GetTexture("Blank"))
	self.Button2.Highlight:SetVertexColor(1, 1, 1, 0.4)
	self.Button2.Highlight:SetAlpha(0)
	
	self.Button2.Text = self.Button2:CreateFontString(nil, "OVERLAY")
	self.Button2.Text:SetScaledPoint("CENTER", self.Button2, "CENTER", 0, 0)
	self.Button2.Text:SetScaledSize(BUTTON_WIDTH - 6, 20)
	self.Button2.Text:SetFont(Media:GetFont(Settings["ui-button-font"]), Settings["ui-font-size"])
	self.Button2.Text:SetJustifyH("CENTER")
	self.Button2.Text:SetShadowColor(0, 0, 0)
	self.Button2.Text:SetShadowOffset(1, -1)
	self.Button2.Text:SetText(value)
	
	self.Created = true
end

Popup.Display = function(self, header, body, accept, acceptfunc, cancel, cancelfunc, arg1, arg2)
	if (not self.Created) then
		self:CreatePopupFrame()
	end
	
	self.Header.Text:SetText(header)
	
	self.Body.Text:SetText(body)
	
	self.Button1.Text:SetText(accept)
	self.Button1.Callback = acceptfunc and acceptfunc or nil
	
	self.Button2.Text:SetText(cancel)
	self.Button2.Callback = cancelfunc and cancelfunc or nil
	
	self.Button1.Arg1 = arg1
	self.Button1.Arg2 = arg2
	
	self.Button2.Arg1 = arg1
	self.Button2.Arg2 = arg2
	
	self:Show()
end

function vUI:ClearPopup()
	Popup:Hide()
end

function vUI:DisplayPopup(...)
	Popup:Display(...)
end
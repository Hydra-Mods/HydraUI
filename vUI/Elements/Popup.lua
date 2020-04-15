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
	vUI:SetSize(self, POPUP_WIDTH, POPUP_HEIGHT)
	vUI:SetPoint(self, "TOP", UIParent, 0, -180)
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
	vUI:SetSize(self.Header, POPUP_WIDTH - 6, 20)
	vUI:SetPoint(self.Header, "TOP", self, 0, -3)
	self.Header:SetBackdrop(vUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.Header.Texture = self.Header:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.Header.Texture, "TOPLEFT", self.Header, 1, -1)
	vUI:SetPoint(self.Header.Texture, "BOTTOMRIGHT", self.Header, -1, 1)
	self.Header.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Header.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.Header.Text, "LEFT", self.Header, 5, -1)
	vUI:SetFontInfo(self.Header.Text, Media:GetFont(Settings["ui-header-font"]), 14)
	self.Header.Text:SetJustifyH("LEFT")
	self.Header.Text:SetShadowColor(0, 0, 0)
	self.Header.Text:SetShadowOffset(1, -1)
	self.Header.Text:SetTextColor(vUI:HexToRGB(Settings["ui-header-font-color"]))
	
	-- Body
	self.Body = CreateFrame("Frame", nil, self)
	vUI:SetSize(self.Body, POPUP_WIDTH - 6, POPUP_HEIGHT - 50)
	vUI:SetPoint(self.Body, "TOP", self.Header, "BOTTOM", 0, -2)
	self.Body:SetBackdrop(vUI.BackdropAndBorder)
	self.Body:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Body:SetBackdropBorderColor(0, 0, 0)
	
	self.Body.Text = self.Body:CreateFontString(nil, "OVERLAY")
	--vUI:SetPoint(self.Body.Text, "TOP", self.Body, 0, -3)
	--vUI:SetWidth(self.Body.Text, POPUP_WIDTH - 12)
	
	vUI:SetPoint(self.Body.Text, "TOPLEFT", self.Body, 3, -3)
	vUI:SetPoint(self.Body.Text, "BOTTOMRIGHT", self.Body, -3, 3)
	vUI:SetFontInfo(self.Body.Text, Media:GetFont(Settings["ui-button-font"]), Settings["ui-font-size"])
	--self.Body.Text:SetJustifyH("LEFT")
	self.Body.Text:SetShadowColor(0, 0, 0)
	self.Body.Text:SetShadowOffset(1, -1)
	self.Body.Text:SetText(value)
	
	-- Button1
	self.Button1 = CreateFrame("Frame", nil, self)
	vUI:SetSize(self.Button1, BUTTON_WIDTH, 20)
	vUI:SetPoint(self.Button1, "BOTTOMLEFT", self, 3, 3)
	self.Button1:SetBackdrop(vUI.BackdropAndBorder)
	self.Button1:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	self.Button1:SetBackdropBorderColor(0, 0, 0)
	self.Button1:SetScript("OnMouseUp", Button1OnMouseUp)
	self.Button1:SetScript("OnMouseDown", ButtonOnMouseDown)
	self.Button1:SetScript("OnEnter", ButtonOnEnter)
	self.Button1:SetScript("OnLeave", ButtonOnLeave)
	
	self.Button1.Texture = self.Button1:CreateTexture(nil, "BORDER")
	vUI:SetPoint(self.Button1.Texture, "TOPLEFT", self.Button1, 1, -1)
	vUI:SetPoint(self.Button1.Texture, "BOTTOMRIGHT", self.Button1, -1, 1)
	self.Button1.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	self.Button1.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	self.Button1.Highlight = self.Button1:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.Button1.Highlight, "TOPLEFT", self.Button1, 1, -1)
	vUI:SetPoint(self.Button1.Highlight, "BOTTOMRIGHT", self.Button1, -1, 1)
	self.Button1.Highlight:SetTexture(Media:GetTexture("Blank"))
	self.Button1.Highlight:SetVertexColor(1, 1, 1, 0.4)
	self.Button1.Highlight:SetAlpha(0)
	
	self.Button1.Text = self.Button1:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.Button1.Text, "CENTER", self.Button1, "CENTER", 0, 0)
	vUI:SetSize(self.Button1.Text, BUTTON_WIDTH - 6, 20)
	self.Button1.Text:SetFont(Media:GetFont(Settings["ui-button-font"]), Settings["ui-font-size"])
	self.Button1.Text:SetJustifyH("CENTER")
	self.Button1.Text:SetShadowColor(0, 0, 0)
	self.Button1.Text:SetShadowOffset(1, -1)
	self.Button1.Text:SetText(value)
	
	-- Button2
	self.Button2 = CreateFrame("Frame", nil, self)
	vUI:SetSize(self.Button2, BUTTON_WIDTH, 20)
	vUI:SetPoint(self.Button2, "BOTTOMRIGHT", self, -3, 3)
	self.Button2:SetBackdrop(vUI.BackdropAndBorder)
	self.Button2:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	self.Button2:SetBackdropBorderColor(0, 0, 0)
	self.Button2:SetScript("OnMouseUp", Button2OnMouseUp)
	self.Button2:SetScript("OnMouseDown", ButtonOnMouseDown)
	self.Button2:SetScript("OnEnter", ButtonOnEnter)
	self.Button2:SetScript("OnLeave", ButtonOnLeave)
	
	self.Button2.Texture = self.Button2:CreateTexture(nil, "BORDER")
	vUI:SetPoint(self.Button2.Texture, "TOPLEFT", self.Button2, 1, -1)
	vUI:SetPoint(self.Button2.Texture, "BOTTOMRIGHT", self.Button2, -1, 1)
	self.Button2.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	self.Button2.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	self.Button2.Highlight = self.Button2:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.Button2.Highlight, "TOPLEFT", self.Button2, 1, -1)
	vUI:SetPoint(self.Button2.Highlight, "BOTTOMRIGHT", self.Button2, -1, 1)
	self.Button2.Highlight:SetTexture(Media:GetTexture("Blank"))
	self.Button2.Highlight:SetVertexColor(1, 1, 1, 0.4)
	self.Button2.Highlight:SetAlpha(0)
	
	self.Button2.Text = self.Button2:CreateFontString(nil, "OVERLAY")
	vUI:SetPoint(self.Button2.Text, "CENTER", self.Button2, "CENTER", 0, 0)
	vUI:SetSize(self.Button2.Text, BUTTON_WIDTH - 6, 20)
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
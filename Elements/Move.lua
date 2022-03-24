local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local unpack = unpack
local find = string.find
local gsub = string.gsub
local match = string.match
local Round = Round

HydraUI.MovingFrames = {}
HydraUI.FrameDefaults = {}
HydraUI.MovingActive = false

function HydraUI:PositionToString(frame)
	local A1, Parent, A2, X, Y = frame:GetPoint()
	
	return format("%s:%s:%s:%s:%s", A1, Parent and Parent:GetName() or "HydraUIParent", A2, Round(X or 0), Round(Y or 0))
end

function HydraUI:StringToPosition(str)
	if (type(str) == "table") then -- Remove this after a month or two. (June 2nd 2020)
		return unpack(str) -- Migrated data will provide a table here. This leftover will be flushed after one login
	end
	
	local A1, Parent, A2, X, Y = match(str, "(.*):(.*):(.*):(.*):(.*)")
	
	return A1, _G[Parent], A2, tonumber(X), tonumber(Y)
end

local OnDragStart = function(self)
	if self.PreMove then
		self:PreMove()
	end
	
	self:StartMoving()
end

local OnDragStop = function(self)
	self:StopMovingOrSizing()
	
	if self.PostMove then
		self:PostMove()
	end
	
	local Profile = HydraUI:GetActiveProfile()
	
	if (not Profile.Move) then
		Profile.Move = {}
	end
	
	Profile.Move[self.Name] = HydraUI:PositionToString(self)
end

local OnAccept = function()
	HydraUI:ToggleMovers()
	GUI:Toggle()
end

local OnCancel = function()
	HydraUI:ToggleMovers()
end

function HydraUI:ToggleMovers()
	if InCombatLockdown() then
		HydraUI:print(ERR_NOT_IN_COMBAT)
		
		return
	end
	
	if self.MovingActive then
		for i = 1, #self.MovingFrames do
			self.MovingFrames[i]:EnableMouse(false)
			self.MovingFrames[i]:StopMovingOrSizing()
			self.MovingFrames[i]:SetScript("OnDragStart", nil)
			self.MovingFrames[i]:SetScript("OnDragStop", nil)
			self.MovingFrames[i]:Hide()
		end
		
		local F = HydraUI:GetModule("m")
		
		if F:IsShown() then
			F:Hide()
		end
		
		self.MovingActive = false
	else
		for i = 1, #self.MovingFrames do
			self.MovingFrames[i]:EnableMouse(true)
			self.MovingFrames[i]:RegisterForDrag("LeftButton")
			self.MovingFrames[i]:SetScript("OnDragStart", OnDragStart)
			self.MovingFrames[i]:SetScript("OnDragStop", OnDragStop)
			self.MovingFrames[i]:Show()
		end
		
		if (GUI.Loaded and GUI:IsShown()) then
			HydraUI:DisplayPopup(Language["Attention"], Language["Would you like to reopen the settings window?"], ACCEPT, OnAccept, CANCEL, OnCancel) -- PopupOnCancel
			GUI:Toggle()
		end
		
		self.MovingActive = true
	end
end

function HydraUI:ResetMovers()
	local Profile = HydraUI:GetActiveProfile()
	
	if Profile.Move then
		Profile.Move = nil
		
		for i = 1, #HydraUI.MovingFrames do
			if HydraUI.FrameDefaults[HydraUI.MovingFrames[i].Name] then
				local A1, Parent, A2, X, Y = unpack(HydraUI.FrameDefaults[HydraUI.MovingFrames[i].Name])
				
				HydraUI.MovingFrames[i]:ClearAllPoints()
				HydraUI.MovingFrames[i]:SetPoint(A1, _G[Parent], A2, X, Y)
			end
		end
	end
end

function HydraUI:ResetMover(name)
	for i = 1, #HydraUI.MovingFrames do
		if (HydraUI.MovingFrames[i].Name == name) then
			local A1, Parent, A2, X, Y = unpack(HydraUI.FrameDefaults[HydraUI.MovingFrames[i].Name])
			
			HydraUI.MovingFrames[i]:ClearAllPoints()
			HydraUI.MovingFrames[i]:SetPoint(A1, _G[Parent], A2, X, Y)
			
			break
		end
	end
end

function HydraUI:ResetAllMovers()
	self:DisplayPopup(Language["Attention"], Language["Are you sure you want to reset the position of all moved frames?"], ACCEPT, self.ResetMovers, CANCEL)
end

function HydraUI:IsMoved(frame)
	local Profile = self:GetActiveProfile()
	
	if (not Profile.Move) then
		return
	end
	
	if (frame and frame.GetName) then
		if Profile.Move[frame:GetName()] then
			return true
		end
	end
end

local OnSizeChanged = function(self)
	self.Mover:SetSize(self:GetSize())
end

local MoverOnMouseUp = function(self, button)
	if (button == "RightButton") then
		if HydraUI.FrameDefaults[self.Name] then
			local A1, Parent, A2, X, Y = unpack(HydraUI.FrameDefaults[self.Name])
			local ParentObject = _G[Parent]
			
			self:ClearAllPoints()
			self:SetPoint(A1, ParentObject, A2, X, Y)
			
			local Profile = HydraUI:GetActiveProfile()
			
			if (not Profile.Move) then
				return
			end
			
			Profile.Move[self.Name] = nil -- We're back to default, so don't save the value
		end
	else
		local F = HydraUI:GetModule("m")
		
		if (not F.Loaded) then
			F:LoadFrame()
		end
		
		F.CurrentFrame = self
		
		local A1, P, A2, X, Y = self:GetPoint()
		
		if not P then
			P = HydraUI.UIParent
		end
		
		F.Lines[1].Text:SetText(self.Name)
		F.Lines[2].EditBox:SetText(P and P:GetName() or "")
		F.Lines[3].EditBox:SetText(A1)
		F.Lines[4].EditBox:SetText(A2)
		F.Lines[5].EditBox:SetText(Round(X))
		F.Lines[6].EditBox:SetText(Round(Y))
		
		if (not F:IsShown()) then
			F:Show()
		end
	end
end

local MoverOnEnter = function(self)
	self:SetBackdropColor(HydraUI:HexToRGB("FF4444"))
	
	local A1, Parent, A2, X, Y = self:GetPoint()
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	GameTooltip:AddLine(self.Name)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(Language["Anchor 1:"], A1, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Parent:"], Parent and Parent:GetName() or "HydraUIParent", 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Anchor 2:"], A2, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["X offset:"], Round(X), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Y offset:"], Round(Y), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
	
	for i = 1, #HydraUI.MovingFrames do
		if (HydraUI.MovingFrames[i].Name ~= self.Name) then
			HydraUI.MovingFrames[i]:SetAlpha(0.5)
		end
	end
end

local MoverOnLeave = function(self)
	self:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	
	GameTooltip:Hide()
	
	for i = 1, #HydraUI.MovingFrames do
		HydraUI.MovingFrames[i]:SetAlpha(1)
	end
end

function HydraUI:CreateMover(frame, padding)
	local A1, Parent, A2, X, Y = frame:GetPoint()
	local Name = frame:GetName()
	
	if (not Name) then
		return
	end
	
	local Label = Name
	
	if find(Label, "HydraUI") then
		Label = gsub(Label, "HydraUI ", "")
	end
	
	if (not Parent) then
		Parent = HydraUIParent
	end
	
	local ParentName = Parent:GetName()
	local ParentObject = _G[ParentName]
	local Padding = padding or 0
	local Width, Height = frame:GetSize()
	
	local Mover = CreateFrame("Frame", nil, HydraUI.UIParent, "SecureHandlerStateTemplate, BackdropTemplate")
	Mover:SetSize(Width + Padding, Height + Padding)
	Mover:SetBackdrop(HydraUI.BackdropAndBorder)
	Mover:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Mover:SetBackdropBorderColor(0, 0, 0)
	Mover:SetFrameLevel(20)
	Mover:SetFrameStrata("HIGH")
	Mover:SetMovable(true)
	Mover:SetClampedToScreen(true)
	Mover:SetScript("OnMouseUp", MoverOnMouseUp)
	Mover:SetScript("OnEnter", MoverOnEnter)
	Mover:SetScript("OnLeave", MoverOnLeave)
	Mover.Frame = frame
	Mover.Name = Name
	Mover:Hide()
	
	Mover.BG = CreateFrame("Frame", nil, Mover, "BackdropTemplate")
	Mover.BG:SetPoint("TOPLEFT", Mover, 3, -3)
	Mover.BG:SetPoint("BOTTOMRIGHT", Mover, -3, 3)
	Mover.BG:SetBackdrop(HydraUI.BackdropAndBorder)
	Mover.BG:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Mover.BG:SetBackdropBorderColor(0, 0, 0)
	
	Mover.Label = Mover.BG:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Mover.Label, Settings["ui-widget-font"], 12)
	Mover.Label:SetPoint("CENTER", Mover, 0, 0)
	Mover.Label:SetText(Label)
	
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", Mover, 0, 0)
	frame.Mover = Mover
	frame:HookScript("OnSizeChanged", OnSizeChanged)
	
	self.FrameDefaults[Name] = {A1, ParentName, A2, X, Y}
	
	local Profile = self:GetActiveProfile()
	
	if (Profile and Profile.Move and Profile.Move[Name]) then
		local A1, Parent, A2, X, Y = self:StringToPosition(Profile.Move[Name])
		
		Mover:SetPoint(A1, Parent, A2, X, Y)
	else
		Mover:SetPoint(A1, Parent, A2, X, Y)
	end
	
	table.insert(self.MovingFrames, Mover)
	
	return Mover
end

-- Create mover frame
--if 1 == 1 then return end

local m = HydraUI:NewModule("m")

local InputOnEnterPressed = function(self)
	local Text = self:GetText() or ""
	
	self:SetAutoFocus(false)
	self:ClearFocus()
	
	if self.Hook then
		self:Hook(self:GetParent())
	end
end

local InputOnEscapePressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local InputOnMouseDown = function(self)
	self:HighlightText()
	self:SetAutoFocus(true)
end

function m:CreateLine(parent, label)
	parent.Text = parent:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(parent.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	parent.Text:SetSize(parent:GetWidth(), parent:GetHeight())
	parent.Text:SetPoint("LEFT", parent, 3, 0)
	parent.Text:SetJustifyH("LEFT")
	parent.Text:SetText(label)
end

function m:CreateInput(parent, label, hook)
	parent.EditBox = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
	parent.EditBox:SetSize(100, 20)
	parent.EditBox:SetPoint("RIGHT", parent, -2, 0)
	HydraUI:SetFontInfo(parent.EditBox, Settings["ui-widget-font"], Settings["ui-font-size"])
	parent.EditBox:SetJustifyH("LEFT")
	parent.EditBox:SetAutoFocus(false)
	parent.EditBox:EnableKeyboard(true)
	parent.EditBox:EnableMouse(true)
	parent.EditBox:SetMaxLetters(255)
	parent.EditBox:SetTextInsets(5, 0, 0, 0)
	parent.EditBox:SetText("") -- change me
	parent.EditBox:SetBackdrop(HydraUI.BackdropAndBorder)
	parent.EditBox:SetBackdropBorderColor(0, 0, 0)
	parent.EditBox:SetScript("OnEnterPressed", InputOnEnterPressed)
	parent.EditBox:SetScript("OnEscapePressed", InputOnEscapePressed)
	parent.EditBox:SetScript("OnMouseDown", InputOnMouseDown)
	parent.EditBox:SetScript("OnEditFocusLost", InputOnEscapePressed)
	
	parent.EditBox.BG = parent.EditBox:CreateTexture(nil, "BORDER")
	parent.EditBox.BG:SetTexture(Assets:GetTexture("Blank"))
	parent.EditBox.BG:SetVertexColor(0, 0, 0)
	parent.EditBox.BG:SetPoint("TOPLEFT", parent.EditBox, 0, 0)
	parent.EditBox.BG:SetPoint("BOTTOMRIGHT", parent.EditBox, 0, 0)
	
	parent.EditBox.Tex = parent.EditBox:CreateTexture(nil, "ARTWORK")
	parent.EditBox.Tex:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	parent.EditBox.Tex:SetPoint("TOPLEFT", parent.EditBox, 1, -1)
	parent.EditBox.Tex:SetPoint("BOTTOMRIGHT", parent.EditBox, -1, 1)
	parent.EditBox.Tex:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if hook then
		parent.EditBox.Hook = hook
	end
	
	parent.Text = parent:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(parent.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	parent.Text:SetSize(parent:GetWidth(), parent:GetHeight())
	parent.Text:SetPoint("LEFT", parent, 3, 0)
	parent.Text:SetJustifyH("LEFT")
	parent.Text:SetText(label)
end

m.Valid = {
	"LEFT",
	"RIGHT",
	"TOP",
	"BOTTOM",
	"CENTER",
}

function m:ValidatePoint(point)
	local Valid
	
	for i = 1, #self.Valid do
		if point:find(self.Valid[i]) then
			Valid = true
			
			break
		end
	end
	
	return Valid
end

function m:UpdateFrameInfo()
	local A1, P, A2, X, Y = self.CurrentFrame:GetPoint()
	
	P = P or HydraUI.UIParent
	
	self.Lines[1].Text:SetText(self.CurrentFrame.Name)
	self.Lines[2].EditBox:SetText(P:GetName())
	self.Lines[3].EditBox:SetText(A1)
	self.Lines[4].EditBox:SetText(A2)
	self.Lines[5].EditBox:SetText(Round(X))
	self.Lines[6].EditBox:SetText(Round(Y))
	
	local Profile = HydraUI:GetActiveProfile()
	
	if (not Profile.Move) then
		Profile.Move = {}
	end
	
	Profile.Move[self.CurrentFrame.Name] = HydraUI:PositionToString(self.CurrentFrame)
end

function m:UpdateParent()
	local Name = self:GetText()
	
	if (not _G[Name]) then
		return
	end
	
	local Frame = HydraUI:GetModule("m").CurrentFrame
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, Name, A2, X, Y)
	
	m:UpdateFrameInfo()
end

function m:UpdateFromPoint()
	local Point = self:GetText()
	
	if (not m:ValidatePoint(Point)) then
		Point = "CENTER"
		self:SetText(Point)
	end
	
	local Frame = HydraUI:GetModule("m").CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(Point, P, A2, X, Y)
	
	m:UpdateFrameInfo()
end

function m:UpdateToPoint()
	local Point = self:GetText()
	
	if (not m:ValidatePoint(Point)) then
		Point = "CENTER"
		self:SetText(Point)
	end
	
	local Frame = HydraUI:GetModule("m").CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, Point, X, Y)
	
	m:UpdateFrameInfo()
end

function m:UpdateXOffset()
	local Offset = tonumber(self:GetText())
	
	if (type(Offset) ~= "number") then
		return
	end
	
	local Frame = HydraUI:GetModule("m").CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, Offset, Y)
	
	m:UpdateFrameInfo()
end

function m:UpdateYOffset()
	local Offset = tonumber(self:GetText())
	
	if (type(Offset) ~= "number") then
		return
	end
	
	local Frame = HydraUI:GetModule("m").CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, X, Offset)
	
	m:UpdateFrameInfo()
end

-- change to m:Nudge(x, y) instead

function m:OnNudgeMouseDown()
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("CENTER", self, 1, -1)
end

function m:NudgeDown()
	local Frame = self:GetParent().CurrentFrame
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	X = Round(X)
	Y = Round(Y)
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, X, Y - 1)
	
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("CENTER", self, 0, 0)
	
	m:UpdateFrameInfo()
end

function m:NudgeUp()
	local Frame = self:GetParent().CurrentFrame
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	X = PixelUtil.GetNearestPixelSize(X, Frame:GetEffectiveScale())
	Y = PixelUtil.GetNearestPixelSize(Y + 1, Frame:GetEffectiveScale())
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, X, Y)
	
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("CENTER", self, 0, 0)
	
	m:UpdateFrameInfo()
end

function m:NudgeLeft()
	local Frame = self:GetParent().CurrentFrame
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	X = Round(X)
	Y = Round(Y)
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, X - 1, Y)
	
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("CENTER", self, 0, 0)
	
	m:UpdateFrameInfo()
end

function m:NudgeRight()
	local Frame = self:GetParent().CurrentFrame
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	X = Round(X)
	Y = Round(Y)
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, X + 1, Y)
	
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("CENTER", self, 0, 0)
	
	m:UpdateFrameInfo()
end

function m:LoadFrame()
	self:SetSize(220, 186)
	self:SetPoint("CENTER", UIParent, 0, -20)
	self:SetFrameStrata("DIALOG")
	self:SetFrameLevel(20)
	self:SetBackdrop(HydraUI.BackdropAndBorder)
	self:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	
	self.Header = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Header:SetHeight(22)
	self.Header:SetPoint("TOPLEFT", self, 3, -3)
	self.Header:SetPoint("TOPRIGHT", self, -((3 + 2) + 22), -3)
	self.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.HeaderTexture = self.Header:CreateTexture(nil, "OVERLAY")
	self.HeaderTexture:SetPoint("TOPLEFT", self.Header, 1, -1)
	self.HeaderTexture:SetPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.HeaderTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetPoint("LEFT", self.Header, 5, -1)
	HydraUI:SetFontInfo(self.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	self.Header.Text:SetJustifyH("LEFT")
	self.Header.Text:SetText("|cFF" .. Settings["ui-header-font-color"] .. Language["Frame Position"] .. "|r")
	
	-- Close button
	self.CloseButton = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.CloseButton:SetSize(22, 22)
	self.CloseButton:SetPoint("TOPRIGHT", self, -3, -3)
	self.CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	self.CloseButton:SetBackdropColor(0, 0, 0, 0)
	self.CloseButton:SetBackdropBorderColor(0, 0, 0)
	self.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B")) end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE")) end)
	self.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		self:GetParent():Hide()
	end)
	
	self.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	self.CloseButton.Texture = self.CloseButton:CreateTexture(nil, "ARTWORK")
	self.CloseButton.Texture:SetPoint("TOPLEFT", self.CloseButton, 1, -1)
	self.CloseButton.Texture:SetPoint("BOTTOMRIGHT", self.CloseButton, -1, 1)
	self.CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.CloseButton.Cross = self.CloseButton:CreateTexture(nil, "OVERLAY")
	self.CloseButton.Cross:SetPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Cross:SetSize(16, 16)
	self.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	self.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	self.Inner = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Inner:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -2)
	self.Inner:SetPoint("BOTTOMRIGHT", self, -3, 3)
	self.Inner:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Inner:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Inner:SetBackdropBorderColor(0, 0, 0)
	
	self.Lines = {}
	
	--for i = 1, 6 do
	for i = 1, 7 do
		local Line = CreateFrame("Frame", nil, self.Inner, "BackdropTemplate")
		Line:SetSize(self.Inner:GetWidth() - 6, 20)
		
		if (i == 1) then
			Line:SetPoint("TOPLEFT", self.Inner, 3, -3)
		else
			Line:SetPoint("TOPLEFT", self.Lines[i-1], "BOTTOMLEFT", 0, -2)
		end
		
		self.Lines[i] = Line
	end
	
	self:CreateLine(self.Lines[1], Language["Select a frame"])
	self:CreateInput(self.Lines[2], Language["Anchor Parent"], self.UpdateParent)
	self:CreateInput(self.Lines[3], Language["Anchor From"], self.UpdateFromPoint)
	self:CreateInput(self.Lines[4], Language["Anchor To"], self.UpdateToPoint)
	self:CreateInput(self.Lines[5], Language["X Offset"], self.UpdateXOffset)
	self:CreateInput(self.Lines[6], Language["Y Offset"], self.UpdateYOffset)
	
	self.Nudge = {}
	
	for i = 4, 1, -1 do
		local Button = CreateFrame("Frame", nil, self, "BackdropTemplate")
		Button:SetSize(20, 20)
		Button:SetBackdrop(HydraUI.BackdropAndBorder)
		Button:SetBackdropColor(0, 0, 0)
		Button:SetBackdropBorderColor(0, 0, 0)
		
		Button.Texture = Button:CreateTexture(nil, "ARTWORK")
		Button.Texture:SetPoint("TOPLEFT", Button, 1, -1)
		Button.Texture:SetPoint("BOTTOMRIGHT", Button, -1, 1)
		Button.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		Button.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
		
		Button.Arrow = Button:CreateTexture(nil, "OVERLAY")
		Button.Arrow:SetSize(16, 16)
		Button.Arrow:SetPoint("CENTER", Button, 0, 0)
		Button.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
		
		if (i == 4) then
			Button:SetPoint("RIGHT", self.Lines[7], -2, 0)
		else
			Button:SetPoint("RIGHT", self.Nudge[i+1], "LEFT", -2, 0)
		end
		
		self.Nudge[i] = Button
	end
	
	self.NudgeText = self.Lines[7]:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(self.NudgeText, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.NudgeText:SetSize(self.Lines[7]:GetWidth() / 2, self.Lines[7]:GetHeight())
	self.NudgeText:SetPoint("LEFT", self.Lines[7], 3, 0)
	self.NudgeText:SetJustifyH("LEFT")
	self.NudgeText:SetText(Language["Nudge"])
	
	self.Nudge[1].Arrow:SetTexture(Assets:GetTexture("Arrow Left")) -- l r u d
	self.Nudge[2].Arrow:SetTexture(Assets:GetTexture("Arrow Right"))
	self.Nudge[3].Arrow:SetTexture(Assets:GetTexture("Arrow Up"))
	self.Nudge[4].Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
	
	self.Nudge[1]:SetScript("OnMouseDown", self.OnNudgeMouseDown)
	self.Nudge[1]:SetScript("OnMouseUp", self.NudgeLeft)
	self.Nudge[2]:SetScript("OnMouseDown", self.OnNudgeMouseDown)
	self.Nudge[2]:SetScript("OnMouseUp", self.NudgeRight)
	self.Nudge[3]:SetScript("OnMouseDown", self.OnNudgeMouseDown)
	self.Nudge[3]:SetScript("OnMouseUp", self.NudgeUp)
	self.Nudge[4]:SetScript("OnMouseDown", self.OnNudgeMouseDown)
	self.Nudge[4]:SetScript("OnMouseUp", self.NudgeDown)
	
	self.Loaded = true
end
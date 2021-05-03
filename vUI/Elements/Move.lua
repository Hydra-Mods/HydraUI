local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local unpack = unpack
local find = string.find
local gsub = string.gsub
local match = string.match
local Round = Round

vUI.MovingFrames = {}
vUI.FrameDefaults = {}
vUI.MovingActive = false

function vUI:PositionToString(frame)
	local A1, Parent, A2, X, Y = frame:GetPoint()
	
	return format("%s:%s:%s:%s:%s", A1, Parent and Parent:GetName() or "vUIParent", A2, Round(X), Round(Y))
end

function vUI:StringToPosition(str)
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
	
	local Profile = vUI:GetActiveProfile()
	
	if (not Profile.Move) then
		Profile.Move = {}
	end
	
	Profile.Move[self.Name] = vUI:PositionToString(self)
end

local OnAccept = function()
	vUI:ToggleMovers()
	GUI:Toggle()
end

local OnCancel = function()
	vUI:ToggleMovers()
end

function vUI:ToggleMovers()
	if InCombatLockdown() then
		vUI:print(ERR_NOT_IN_COMBAT)
		
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
			vUI:DisplayPopup(Language["Attention"], Language["Would you like to reopen the settings window?"], Language["Accept"], OnAccept, Language["Cancel"], OnCancel) -- PopupOnCancel
			GUI:Toggle()
		end
		
		self.MovingActive = true
	end
end

function vUI:ResetMovers()
	local Profile = vUI:GetActiveProfile()
	
	if Profile.Move then
		Profile.Move = nil
		
		for i = 1, #vUI.MovingFrames do
			if vUI.FrameDefaults[vUI.MovingFrames[i].Name] then
				local A1, Parent, A2, X, Y = unpack(vUI.FrameDefaults[vUI.MovingFrames[i].Name])
				
				vUI.MovingFrames[i]:ClearAllPoints()
				vUI.MovingFrames[i]:SetPoint(A1, _G[Parent], A2, X, Y)
			end
		end
	end
end

function vUI:ResetMover(name)
	for i = 1, #vUI.MovingFrames do
		if (vUI.MovingFrames[i].Name == name) then
			local A1, Parent, A2, X, Y = unpack(vUI.FrameDefaults[vUI.MovingFrames[i].Name])
			
			vUI.MovingFrames[i]:ClearAllPoints()
			vUI.MovingFrames[i]:SetPoint(A1, _G[Parent], A2, X, Y)
			
			break
		end
	end
end

function vUI:ResetAllMovers()
	self:DisplayPopup(Language["Attention"], Language["Are you sure you want to reset the position of all moved frames?"], Language["Accept"], self.ResetMovers, Language["Cancel"])
end

function vUI:IsMoved(frame)
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
		if vUI.FrameDefaults[self.Name] then
			local A1, Parent, A2, X, Y = unpack(vUI.FrameDefaults[self.Name])
			local ParentObject = _G[Parent]
			
			self:ClearAllPoints()
			self:SetPoint(A1, ParentObject, A2, X, Y)
			
			local Profile = vUI:GetActiveProfile()
			
			if (not Profile.Move) then
				return
			end
			
			Profile.Move[self.Name] = nil -- We're back to default, so don't save the value
		end
	else
		--[[local F = vUI:GetModule("m")
		
		if (not F.Loaded) then
			F:LoadFrame()
		end
		
		F.CurrentFrame = self
		
		local A1, P, A2, X, Y = self:GetPoint()
		
		F.Lines[1].Text:SetText(self.Name)
		F.Lines[2].EditBox:SetText(P:GetName())
		F.Lines[3].EditBox:SetText(A1)
		F.Lines[4].EditBox:SetText(A2)
		F.Lines[5].EditBox:SetText(Round(X))
		F.Lines[6].EditBox:SetText(Round(Y))
		
		if (not F:IsShown()) then
			F:Show()
		end]]
	end
end

local MoverOnEnter = function(self)
	self:SetBackdropColor(vUI:HexToRGB("FF4444"))
	
	local A1, Parent, A2, X, Y = self:GetPoint()
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	GameTooltip:AddLine(self.Name)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(Language["Anchor 1:"], A1, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Parent:"], Parent and Parent:GetName() or "vUIParent", 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Anchor 2:"], A2, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["X offset:"], Round(X), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Y offset:"], Round(Y), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

local MoverOnLeave = function(self)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	
	GameTooltip:Hide()
end

function vUI:CreateMover(frame, padding)
	local A1, Parent, A2, X, Y = frame:GetPoint()
	local Name = frame:GetName()
	
	if (not Name) then
		return
	end
	
	local Label = Name
	
	if find(Label, "vUI") then
		Label = gsub(Label, "vUI ", "")
	end
	
	if (not Parent) then
		Parent = vUIParent
	end
	
	local ParentName = Parent:GetName()
	local ParentObject = _G[ParentName]
	local Padding = padding or 0
	local Width, Height = frame:GetSize()
	
	local Mover = CreateFrame("Frame", nil, vUI.UIParent, "SecureHandlerStateTemplate, BackdropTemplate")
	Mover:SetSize(Width + Padding, Height + Padding)
	Mover:SetBackdrop(vUI.BackdropAndBorder)
	Mover:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
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
	Mover.BG:SetBackdrop(vUI.BackdropAndBorder)
	Mover.BG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Mover.BG:SetBackdropBorderColor(0, 0, 0)
	
	Mover.Label = Mover.BG:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Mover.Label, Settings["ui-widget-font"], 12)
	Mover.Label:SetPoint("CENTER", Mover, 0, 0)
	Mover.Label:SetText(Label)
	
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", Mover, 0, 0)
	frame.Mover = Mover
	frame:HookScript("OnSizeChanged", OnSizeChanged)
	
	self.FrameDefaults[Name] = {A1, ParentName, A2, X, Y}
	
	local Profile = self:GetActiveProfile()
	
	if (Profile.Move and Profile.Move[Name]) then
		local A1, Parent, A2, X, Y = self:StringToPosition(Profile.Move[Name])
		
		Mover:SetPoint(A1, Parent, A2, X, Y)
	else
		Mover:SetPoint(A1, Parent, A2, X, Y)
	end
	
	table.insert(self.MovingFrames, Mover)
	
	return Mover
end

-- Create mover frame
if 1 == 1 then return end

local m = vUI:NewModule("m")

local InputOnEnterPressed = function(self)
	local Text = self:GetText() or ""
	
	self:SetAutoFocus(false)
	self:ClearFocus()
	
	if self.Hook then
		self:Hook()
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
	vUI:SetFontInfo(parent.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	parent.Text:SetSize(parent:GetWidth(), parent:GetHeight())
	parent.Text:SetPoint("LEFT", parent, 3, 0)
	parent.Text:SetJustifyH("LEFT")
	parent.Text:SetText(label)
end

function m:CreateInput(parent, label, hook)
	parent.EditBox = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
	parent.EditBox:SetSize(100, 20)
	parent.EditBox:SetPoint("RIGHT", parent, -2, 0)
	vUI:SetFontInfo(parent.EditBox, Settings["ui-widget-font"], Settings["ui-font-size"])
	parent.EditBox:SetJustifyH("LEFT")
	parent.EditBox:SetAutoFocus(false)
	parent.EditBox:EnableKeyboard(true)
	parent.EditBox:EnableMouse(true)
	parent.EditBox:SetMaxLetters(255)
	parent.EditBox:SetTextInsets(5, 0, 0, 0)
	parent.EditBox:SetText("") -- change me
	parent.EditBox:SetBackdrop(vUI.BackdropAndBorder)
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
	parent.EditBox.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if hook then
		parent.EditBox.Hook = hook
	end
	
	parent.Text = parent:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(parent.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	parent.Text:SetSize(parent:GetWidth(), parent:GetHeight())
	parent.Text:SetPoint("LEFT", parent, 3, 0)
	parent.Text:SetJustifyH("LEFT")
	parent.Text:SetText(label)
end

m.Valid = {
	"left",
	"right",
	"top",
	"bottom",
}

function m:UpdateFrameInfo()
	local A1, P, A2, X, Y = self.CurrentFrame:GetPoint()
	
	self.Lines[1].Text:SetText(self.CurrentFrame.Name)
	self.Lines[2].EditBox:SetText(P:GetName())
	self.Lines[3].EditBox:SetText(A1)
	self.Lines[4].EditBox:SetText(A2)
	self.Lines[5].EditBox:SetText(Round(X))
	self.Lines[6].EditBox:SetText(Round(Y))
	
	local Profile = vUI:GetActiveProfile()
	
	if (not Profile.Move) then
		Profile.Move = {}
	end
	
	Profile.Move[self.CurrentFrame.Name] = vUI:PositionToString(self.CurrentFrame)
end

function m:UpdateParent()
	local Name = self:GetText()
	local Frame = self:GetParent().CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, Name, A2, X, Y)
end

function m:UpdateFromPoint()
	local Point = self:GetText()
	local Frame = self:GetParent().CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(Point, P, A2, X, Y)
end

function m:UpdateToPoint()
	local Point = self:GetText()
	local Frame = self:GetParent().CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, Point, X, Y)
end

function m:UpdateXOffset()
	local Offset = tonumber(self:GetText())
	local Frame = self:GetParent().CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, Offset, Y)
end

function m:UpdateYOffset()
	local Offset = tonumber(self:GetText())
	local Frame = self:GetParent().CurrentFrame
	
	local A1, P, A2, X, Y = Frame:GetPoint()
	
	Frame:ClearAllPoints()
	Frame:SetPoint(A1, P, A2, X, Offset)
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
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	self.Header = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Header:SetHeight(22)
	self.Header:SetPoint("TOPLEFT", self, 3, -3)
	self.Header:SetPoint("TOPRIGHT", self, -((3 + 2) + 22), -3)
	self.Header:SetBackdrop(vUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.HeaderTexture = self.Header:CreateTexture(nil, "OVERLAY")
	self.HeaderTexture:SetPoint("TOPLEFT", self.Header, 1, -1)
	self.HeaderTexture:SetPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.HeaderTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetPoint("LEFT", self.Header, 5, -1)
	vUI:SetFontInfo(self.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	self.Header.Text:SetJustifyH("LEFT")
	self.Header.Text:SetText("|cFF" .. Settings["ui-header-font-color"] .. Language["Frame Position"] .. "|r")
	
	-- Close button
	self.CloseButton = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.CloseButton:SetSize(22, 22)
	self.CloseButton:SetPoint("TOPRIGHT", self, -3, -3)
	self.CloseButton:SetBackdrop(vUI.BackdropAndBorder)
	self.CloseButton:SetBackdropColor(0, 0, 0, 0)
	self.CloseButton:SetBackdropBorderColor(0, 0, 0)
	self.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(vUI:HexToRGB("C0392B")) end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(vUI:HexToRGB("EEEEEE")) end)
	self.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		self:GetParent():Hide()
	end)
	
	self.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	self.CloseButton.Texture = self.CloseButton:CreateTexture(nil, "ARTWORK")
	self.CloseButton.Texture:SetPoint("TOPLEFT", self.CloseButton, 1, -1)
	self.CloseButton.Texture:SetPoint("BOTTOMRIGHT", self.CloseButton, -1, 1)
	self.CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.CloseButton.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.CloseButton.Cross = self.CloseButton:CreateTexture(nil, "OVERLAY")
	self.CloseButton.Cross:SetPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Cross:SetSize(16, 16)
	self.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	self.CloseButton.Cross:SetVertexColor(vUI:HexToRGB("EEEEEE"))
	
	self.Inner = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Inner:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -2)
	self.Inner:SetPoint("BOTTOMRIGHT", self, -3, 3)
	self.Inner:SetBackdrop(vUI.BackdropAndBorder)
	self.Inner:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.Inner:SetBackdropBorderColor(0, 0, 0)
	
	self.Lines = {}
	
	for i = 1, 6 do
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
	
	for i = 1, 4 do
		local Button = CreateFrame("Frame", nil, self, "BackdropTemplate")
		Button:SetSize(20, 20)
		Button:SetBackdrop(vUI.BackdropAndBorder)
		Button:SetBackdropColor(0, 0, 0)
		Button:SetBackdropBorderColor(0, 0, 0)
		
		Button.Texture = Button:CreateTexture(nil, "ARTWORK")
		Button.Texture:SetPoint("TOPLEFT", Button, 1, -1)
		Button.Texture:SetPoint("BOTTOMRIGHT", Button, -1, 1)
		Button.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		Button.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
		
		Button.Arrow = Button:CreateTexture(nil, "OVERLAY")
		Button.Arrow:SetSize(16, 16)
		Button.Arrow:SetPoint("CENTER", Button, 0, 0)
		Button.Arrow:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
		
		if (i == 1) then
			Button:SetPoint("BOTTOMLEFT", self.Inner, 2, 2)
		--	Button:SetPoint("TOPRIGHT", self.Inner, -2, -2)
		else
			Button:SetPoint("LEFT", self.Nudge[i-1], "RIGHT", 2, 0)
		--	Button:SetPoint("RIGHT", self.Nudge[i-1], "LEFT", -2, 0)
		end
		
		self.Nudge[i] = Button
	end
	
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
local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local unpack = unpack
local find = string.find
local gsub = string.gsub

vUI.MovingFrames = {}
vUI.FrameDefaults = {}
vUI.MovingActive = false

local OnDragStart = function(self)
	self:StartMoving()
end

local OnDragStop = function(self)
	self:StopMovingOrSizing()
	
	local Name = self:GetName()
	local A1, Parent, A2, X, Y = self:GetPoint()
	
	if (not Parent) then
		Parent = UIParent
	end
	
	vUIMove[self.Name] = {A1, Parent:GetName(), A2, X, Y}
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
	
		self.MovingActive = true
	end
end

function vUI:ResetAllMovers()
	if (not vUIMove) then
		vUIMove = {}
	end
	
	for i = 1, #self.MovingFrames do
		if self.FrameDefaults[self.MovingFrames[i].Name] then
			local A1, Parent, A2, X, Y = unpack(self.FrameDefaults[self.MovingFrames[i].Name])
			
			self.MovingFrames[i]:ClearAllPoints()
			vUI:SetPoint(self.MovingFrames[i], A1, _G[Parent], A2, X, Y)
			
			vUIMove[self.MovingFrames[i].Name] = {A1, Parent, A2, X, Y}
		end
	end
end

function vUI:IsMoved(frame)
	if (frame and frame.GetName) then
		if vUIMove[frame:GetName()] then
			return true
		end
	end
end

local OnSizeChanged = function(self)
	vUI:SetSize(self.Mover, self:GetSize())
end

local MoverOnMouseUp = function(self, button)
	if (button == "RightButton") then
		if vUI.FrameDefaults[self.Name] then
			local A1, Parent, A2, X, Y = unpack(vUI.FrameDefaults[self.Name])
			local ParentObject = _G[Parent]
			
			self:ClearAllPoints()
			vUI:SetPoint(self, A1, ParentObject, A2, X, Y)
			
			vUIMove[self.Name] = {A1, Parent, A2, X, Y}
		end
	end
end

local MoverOnEnter = function(self)
	self:SetBackdropColor(vUI:HexToRGB("FF4444"))
	
	local A1, Parent, A2, X, Y = self:GetPoint()
	
	if (Parent and Parent.GetName) then
		Parent = Parent:GetName()
	end
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	GameTooltip:AddLine(self.Name)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(Language["Anchor 1:"], A1, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Parent:"], Parent, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Anchor 2:"], A2, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["X offset:"], floor(X), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Y offset:"], floor(Y), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

local MoverOnLeave = function(self)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	
	GameTooltip:Hide()
end

function vUI:CreateMover(frame, padding)
	if (not vUIMove) then
		vUIMove = {}
	end
	
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
		Parent = UIParent
	end
	
	local ParentName = Parent:GetName()
	local ParentObject = _G[ParentName]
	local Padding = padding or 0
	local Width, Height = frame:GetSize()
	
	local Mover = CreateFrame("Frame", nil, UIParent)
	vUI:SetSize(Mover, Width + Padding, Height + Padding)
	Mover:SetBackdrop(vUI.BackdropAndBorder)
	Mover:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Mover:SetBackdropBorderColor(0, 0, 0)
	Mover:SetFrameLevel(20)
	Mover:SetFrameStrata("HIGH")
	Mover:SetMovable(true)
	Mover:SetUserPlaced(true)
	Mover:SetClampedToScreen(true)
	Mover:SetScript("OnMouseUp", MoverOnMouseUp)
	Mover:SetScript("OnEnter", MoverOnEnter)
	Mover:SetScript("OnLeave", MoverOnLeave)
	Mover.Frame = frame
	Mover.Name = Name
	Mover:Hide()
	
	Mover.BG = CreateFrame("Frame", nil, Mover)
	vUI:SetPoint(Mover.BG, "TOPLEFT", Mover, 3, -3)
	vUI:SetPoint(Mover.BG, "BOTTOMRIGHT", Mover, -3, 3)
	Mover.BG:SetBackdrop(vUI.BackdropAndBorder)
	Mover.BG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Mover.BG:SetBackdropBorderColor(0, 0, 0)
	
	Mover.Label = Mover.BG:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Mover.Label, Settings["ui-widget-font"], 12)
	vUI:SetPoint(Mover.Label, "CENTER", Mover, 0, 0)
	Mover.Label:SetText(Label)
	
	local OldA1, OldParent, OldA2, OldX, OldY = frame:GetPoint()
	
	frame:ClearAllPoints()
	vUI:SetPoint(frame, "CENTER", Mover, 0, 0)
	frame.Mover = Mover
	frame:HookScript("OnSizeChanged", OnSizeChanged)
	
	self.FrameDefaults[Name] = {A1, ParentName, A2, X, Y}
	
	if vUIMove[Name] then
		local A1, Parent, A2, X, Y = unpack(vUIMove[Name])
		local ParentObject = _G[Parent]		
		
		vUI:SetPoint(Mover, A1, ParentObject, A2, X, Y)
	else
		vUI:SetPoint(Mover, OldA1, OldParent, OldA2, OldX, OldY)
		
		vUIMove[Name] = {OldA1, OldParent, OldA2, OldX, OldY}
	end
	
	table.insert(self.MovingFrames, Mover)
	
	return Mover
end
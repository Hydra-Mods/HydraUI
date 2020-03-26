local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Move = vUI:NewModule("Move")

local unpack = unpack
local find = string.find
local gsub = string.gsub

Move.Frames = {}
Move.Defaults = {}
Move.Active = false

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

function Move:Toggle()
	if InCombatLockdown() then
		vUI:print(ERR_NOT_IN_COMBAT)
		
		return
	end
	
	if self.Active then
		for i = 1, #self.Frames do
			self.Frames[i]:EnableMouse(false)
			self.Frames[i]:StopMovingOrSizing()
			self.Frames[i]:SetScript("OnDragStart", nil)
			self.Frames[i]:SetScript("OnDragStop", nil)
			self.Frames[i]:Hide()
		end
		
		self.Active = false
	else
		for i = 1, #self.Frames do
			self.Frames[i]:EnableMouse(true)
			self.Frames[i]:RegisterForDrag("LeftButton")
			self.Frames[i]:SetScript("OnDragStart", OnDragStart)
			self.Frames[i]:SetScript("OnDragStop", OnDragStop)
			self.Frames[i]:Show()
		end
	
		self.Active = true
	end
end

function Move:ResetAll()
	if (not vUIMove) then
		vUIMove = {}
	end
	
	for i = 1, #self.Frames do
		if self.Defaults[self.Frames[i].Name] then
			local A1, Parent, A2, X, Y = unpack(self.Defaults[self.Frames[i].Name])
			
			self.Frames[i]:ClearAllPoints()
			self.Frames[i]:SetScaledPoint(A1, _G[Parent], A2, X, Y)
			
			vUIMove[self.Frames[i].Name] = {A1, Parent, A2, X, Y}
		end
	end
end

--[[function Move:IsMoved(frame)
	local Name = frame:GetName()

	if (not Name) then
		return false
	elseif self.Defaults[Name] then
		return true
	end
end]]

local OnSizeChanged = function(self)
	self.Mover:SetScaledSize(self:GetSize())
end

local MoverOnMouseUp = function(self, button)
	if (button == "RightButton") then
		if Move.Defaults[self.Name] then
			local A1, Parent, A2, X, Y = unpack(Move.Defaults[self.Name])
			local ParentObject = _G[Parent]
			
			self:ClearAllPoints()
			self:SetScaledPoint(A1, ParentObject, A2, X, Y)
			
			vUIMove[self.Name] = {A1, Parent, A2, X, Y}
		end
	end
end

local MoverOnEnter = function(self)
	self:SetBackdropColorHex("FF4444")
end

local MoverOnLeave = function(self)
	self:SetBackdropColorHex(Settings["ui-window-bg-color"])
end

function Move:Add(frame, padding)
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
	Mover:SetScaledSize(Width + Padding, Height + Padding)
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
	Mover.BG:SetScaledPoint("TOPLEFT", Mover, 3, -3)
	Mover.BG:SetScaledPoint("BOTTOMRIGHT", Mover, -3, 3)
	Mover.BG:SetBackdrop(vUI.BackdropAndBorder)
	Mover.BG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Mover.BG:SetBackdropBorderColor(0, 0, 0)
	
	Mover.Label = Mover.BG:CreateFontString(nil, "OVERLAY")
	Mover.Label:SetFontInfo(Settings["ui-widget-font"], 12)
	Mover.Label:SetScaledPoint("CENTER", Mover, 0, 0)
	Mover.Label:SetText(Label)
	
	local OldA1, OldParent, OldA2, OldX, OldY = frame:GetPoint()
	
	frame:ClearAllPoints()
	frame:SetScaledPoint("CENTER", Mover, 0, 0)
	frame.Mover = Mover
	frame:HookScript("OnSizeChanged", OnSizeChanged)
	
	self.Defaults[Name] = {A1, ParentName, A2, X, Y}
	
	if vUIMove[Name] then
		local A1, Parent, A2, X, Y = unpack(vUIMove[Name])
		local ParentObject = _G[Parent]		
		
		Mover:SetScaledPoint(A1, ParentObject, A2, X, Y)
	else
		Mover:SetScaledPoint(OldA1, OldParent, OldA2, OldX, OldY)
		
		vUIMove[Name] = {OldA1, OldParent, OldA2, OldX, OldY}
	end
	
	table.insert(self.Frames, Mover)
	
	return Mover
end

function Move:IsMoved(frame)
	if (frame and frame.GetName) then
		if vUIMove[frame:GetName()] then
			return true
		end
	end
end
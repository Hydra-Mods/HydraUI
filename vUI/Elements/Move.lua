local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local unpack = unpack
local find = string.find
local gsub = string.gsub

vUI.MovingFrames = {}
vUI.FrameDefaults = {}
vUI.MovingActive = false

function vUI:PositionToString(frame)
	local A1, Parent, A2, X, Y = frame:GetPoint()
	
	if (not Parent) then
		Parent = vUI.UIParent
	end
	
	local String = format("%s:%s:%s:%s:%s", A1, Parent:GetName(), A2, X, Y)
	
	return String
end

function vUI:StringToPosition(str)
	if (type(str) == "table") then -- Remove this after a month or two. (June 2nd 2020)
		return unpack(str) -- Migrated data will provide a table here. This leftover will be flushed after one login
	end
	
	local A1, Parent, A2, X, Y = string.match(str, "(.*):(.*):(.*):(.*):(.*)")
	
	Parent = _G[Parent]
	
	return A1, Parent, A2, tonumber(X), tonumber(Y)
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
	
	local Name = self:GetName()
	local A1, Parent, A2, X, Y = self:GetPoint()
	
	if (not Parent) then
		Parent = vUI.UIParent
	end
	
	local Profile = vUI:GetActiveProfile()
	
	if (not Profile.Move) then
		Profile.Move = {}
	end
	
	--Profile.Move[self.Name] = {A1, Parent:GetName(), A2, X, Y}
	Profile.Move[self.Name] = vUI:PositionToString(self)
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
	if vUIProfiles then
		for Key, Profile in pairs(vUIProfiles) do
			if Profile.Move then
				Profile.Move = {}
			end
		end
	end
	
	for i = 1, #self.MovingFrames do
		if self.FrameDefaults[self.MovingFrames[i].Name] then
			local A1, Parent, A2, X, Y = unpack(self.FrameDefaults[self.MovingFrames[i].Name])
			
			self.MovingFrames[i]:ClearAllPoints()
			self.MovingFrames[i]:SetPoint(A1, _G[Parent], A2, X, Y)
			
			--vUIMove[self.MovingFrames[i].Name] = {A1, Parent, A2, X, Y}
		end
	end
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
		Parent = vUI.UIParent
	end
	
	local ParentName = Parent:GetName()
	local ParentObject = _G[ParentName]
	local Padding = padding or 0
	local Width, Height = frame:GetSize()
	
	local Mover = CreateFrame("Frame", nil, vUI.UIParent, "SecureHandlerStateTemplate")
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
	
	Mover.BG = CreateFrame("Frame", nil, Mover)
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
		--local A1, Parent, A2, X, Y = unpack(Profile.Move[Name])
		local ParentObject = _G[Parent]		
		
		Mover:SetPoint(A1, ParentObject, A2, X, Y)
	else
		Mover:SetPoint(A1, Parent, A2, X, Y)
	end
	
	table.insert(self.MovingFrames, Mover)
	
	return Mover
end
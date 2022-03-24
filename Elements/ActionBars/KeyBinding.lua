local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local KeyBinding = HydraUI:NewModule("Key Binding")

local GetMouseFocus = GetMouseFocus
local match = string.match

KeyBinding.ValidBindings = {
	["ACTIONBUTTON"] = true,
	["BONUSACTIONBUTTON"] = true,
	["MULTIACTIONBAR1BUTTON"] = true,
	["MULTIACTIONBAR2BUTTON"] = true,
	["MULTIACTIONBAR3BUTTON"] = true,
	["MULTIACTIONBAR4BUTTON"] = true,
	["SHAPESHIFTBUTTON"] = true,
}

KeyBinding.Translate = {
	["ActionButton"] = "ACTIONBUTTON",
	["MultiBarBottomLeftButton"] = "MULTIACTIONBAR1BUTTON",
	["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
	["MultiBarRightButton"] = "MULTIACTIONBAR3BUTTON",
	["MultiBarLeftButton"] = "MULTIACTIONBAR4BUTTON",
}

KeyBinding.Filter = {
	["BACKSPACE"] = true,
	["LALT"] = true,
	["RALT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["ENTER"] = true,
	["LeftButton"] = true,
	["RightButton"] = true,
}

function KeyBinding:OnKeyUp(key)
	if (not IsKeyPressIgnoredForBinding(key) and not self.Filter[key] and self.TargetBindingName) then
		if (key == "ESCAPE") then
			local Binding = GetBindingKey(self.TargetBindingName)
			
			if Binding then
				SetBinding(Binding)
			end
			
			return
		end
		
		key = format("%s%s%s%s", IsAltKeyDown() and "ALT-" or "", IsControlKeyDown() and "CTRL-" or "", IsShiftKeyDown() and "SHIFT-" or "", key)
		
		local OldAction = GetBindingAction(key, true)
		
		if OldAction then
			local OldName = GetBindingName(OldAction)
			
			HydraUI:print(format(Language['Unbound "%s" from %s'], key, OldName))
		end
		
		SetBinding(key, self.TargetBindingName, 1)
		
		local NewAction = GetBindingAction(key, true)
		local NewName = GetBindingName(NewAction)
		
		HydraUI:print(format(Language['Bound "%s" to %s'], key, NewName))
		
		GUI:GetWidget("kb-save"):Enable()
		GUI:GetWidget("kb-discard"):Enable()
	end
end

function KeyBinding:OnKeyDown(key)
	local MouseFocus = GetMouseFocus()
	
	if (MouseFocus and MouseFocus.GetName) then
		local Name = MouseFocus:GetName()
		
		if (not Name) then
			return
		end
		
		local ButtonName = match(Name, "%D+")
		if self.Translate[ButtonName] then
			if self.ValidBindings[self.Translate[ButtonName]] then
				self.TargetBindingName = self.Translate[ButtonName] .. match(Name, "(%d+)$")
			end
		end
	end
end

function KeyBinding:OnEvent(event, button)
	local MouseFocus = GetMouseFocus()
	
	if (MouseFocus and MouseFocus.GetName) then
		local Name = MouseFocus:GetName()
		
		if (not Name) then
			return
		end
		
		local ButtonName = match(Name, "%D+")
		if self.Translate[ButtonName] then
			if self.ValidBindings[self.Translate[ButtonName]] then
				self.TargetBindingName = self.Translate[ButtonName] .. match(Name, "(%d+)$")
			end
		end
	end
	
	if (not self.Filter[button] and self.TargetBindingName) then
		if (button == "MiddleButton") then
			button = "BUTTON3"
		end
		
		if match(button, "Button%d+") then
			button = string.upper(button)
		end
		
		button = format("%s%s%s%s", IsAltKeyDown() and "ALT-" or "", IsControlKeyDown() and "CTRL-" or "", IsShiftKeyDown() and "SHIFT-" or "", button)
		
		local OldAction = GetBindingAction(button, true)
		
		if OldAction then
			local OldName = GetBindingName(OldAction)
			
			HydraUI:print(format(Language['Unbound "%s" from %s'], button, OldName))
		end
		
		SetBinding(button, self.TargetBindingName, 1)
		
		local NewAction = GetBindingAction(button, true)
		local NewName = GetBindingName(NewAction)
		
		HydraUI:print(format(Language['Bound "%s" to %s'], button, NewName))
		
		GUI:GetWidget("kb-save"):Enable()
		GUI:GetWidget("kb-discard"):Enable()
	end
end

function KeyBinding:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.05) then
		local MouseFocus = GetMouseFocus()
		
		if (MouseFocus and MouseFocus.action) then
			self.Hover:SetPoint("TOPLEFT", MouseFocus, 1, -1)
			self.Hover:SetPoint("BOTTOMRIGHT", MouseFocus, -1, 1)
			self.Hover:Show()
		elseif self.Hover:IsShown() then
			self.Hover:Hide()
		end
		
		self.Elapsed = 0
	end
end

local PopupOnAccept = function()
	KeyBinding:Disable()
end

local PopupOnCancel = function()
	KeyBinding:Disable()
end

local OnAccept = function()
	SaveBindings(GetCurrentBindingSet())
	
	GUI:GetWidget("kb-discard"):Disable()
	GUI:GetWidget("kb-save"):Disable()
	
	KeyBinding:Disable()
end

local OnCancel = function()
	KeyBinding:Disable()
end

function KeyBinding:Enable()
	self:EnableKeyboard(true)
	self:SetScript("OnUpdate", self.OnUpdate)
	self:SetScript("OnKeyDown", self.OnKeyDown)
	self:SetScript("OnKeyUp", self.OnKeyUp)
	self:SetScript("OnEvent", self.OnEvent)
	self.Active = true
	
	--HydraUI:DisplayPopup(Language["Attention"], Language["Key binding mode is currently active. Would you like to exit key binding mode?"], ACCEPT, PopupOnAccept, CANCEL) -- PopupOnCancel
	HydraUI:DisplayPopup(Language["Attention"], Language["Key binding mode is active. Would you like to save your changes?"], ACCEPT, OnAccept, CANCEL, OnCancel) -- PopupOnCancel
end

function KeyBinding:Disable()
	self:EnableKeyboard(false)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnKeyDown", nil)
	self:SetScript("OnKeyUp", nil)
	self:SetScript("OnEvent", nil)
	self.Active = false
	self.TargetBindingName = nil
	
	HydraUI:ClearPopup()
end

function KeyBinding:Toggle()
	if self.Active then
		self:Disable()
	else
		self:Enable()
	end
end

function KeyBinding:Load()
	self.Elapsed = 0
	
	self.Hover = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Hover:SetFrameLevel(50)
	self.Hover:SetFrameStrata("DIALOG")
	self.Hover:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Hover:SetBackdropColor(HydraUI:HexToRGB("FFC44D"))
	self.Hover:SetBackdropBorderColor(HydraUI:HexToRGB("FFC44D"))
	self.Hover:SetAlpha(0.6)
	self.Hover:Hide()
end

local ToggleBindingMode = function()
	KeyBinding:Toggle()
end

local SaveChanges = function()
	HydraUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to save these key binding changes?"], ACCEPT, OnAccept, CANCEL, OnCancel)
end

local DiscardChanges = function()
	HydraUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to discard these key binding changes?"], ACCEPT, ReloadUI, CANCEL)
end

GUI:AddWidgets(Language["General"], Language["Action Bars"], function(left, right)
	right:CreateHeader(Language["Key Binding"])
	right:CreateButton("kb-toggle", Language["Toggle"], Language["Key Bind Mode"], Language["While toggled, you can hover over action buttons and press a key combination to rebind them"], ToggleBindingMode)
	right:CreateButton("kb-save", ACCEPT, Language["Save Changes"], Language["Save key binding changes"], SaveChanges):Disable()
	right:CreateButton("kb-discard", Language["Discard"], Language["Discard Changes"], Language["Discard key binding changes"], DiscardChanges):Disable()
	
	--self:GetWidget("kb-save"):Disable()
	--self:GetWidget("kb-discard"):Disable()
end)
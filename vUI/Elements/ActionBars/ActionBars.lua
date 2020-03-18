local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local BUTTON_SIZE = 32
local STANCE_SIZE = 32
local SPACING = 2

-- COUNTDOWN_FOR_COOLDOWNS_TEXT, 1

local Num = NUM_ACTIONBAR_BUTTONS
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange
local HasAction = HasAction

local ActionBars = CreateFrame("Frame")

local Hider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
Hider:Hide()

local Kill = function(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	object:Hide()
end

local SkinButton = function(button)
	if button.IsSkinned then
		return
	end
	
	button:SetNormalTexture("")
	
	if button.Border then
		button.Border:SetTexture(nil)
	end
	
	if button.icon then
		button.icon:ClearAllPoints()
		button.icon:SetScaledPoint("TOPLEFT", button, 1, -1)
		button.icon:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	if _G[button:GetName() .. "FloatingBG"] then
		Kill(_G[button:GetName() .. "FloatingBG"])
	end
	
	if _G[button:GetName() .. "Cooldown"] then
		local Cooldown = _G[button:GetName() .. "Cooldown"]:GetRegions()
		
		if Cooldown then
			Cooldown:SetFontInfo(Settings["action-bars-font"], 18, Settings["action-bars-font-flags"])
		end
	end
	
	if button.HotKey then
		button.HotKey:ClearAllPoints()
		button.HotKey:SetScaledPoint("TOPLEFT", button, 2, -2)
		button.HotKey:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
		button.HotKey:SetJustifyH("LEFT")
		button.HotKey:SetDrawLayer("OVERLAY")
		button.HotKey:SetTextColor(1, 1, 1)
		button.HotKey.SetTextColor = function() end
		
		local HotKeyText = button.HotKey:GetText()
		
		if HotKeyText then
			button.HotKey:SetText("|cffFFFFFF" .. HotKeyText .. "|r")
		end
		
		button.HotKey.OST = button.HotKey.SetText
		button.HotKey.SetText = function(self, text)
			self:OST("|cFFFFFFFF" .. text .. "|r")
		end
		
		if (not Settings["action-bars-show-hotkeys"]) then
			button.HotKey:SetAlpha(0)
		end
	end
	
	if button.Name then
		button.Name:ClearAllPoints()
		button.Name:SetScaledPoint("BOTTOMLEFT", button, 2, 2)
		button.Name:SetScaledWidth(button:GetWidth() - 4)
		button.Name:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
		button.Name:SetJustifyH("LEFT")
		button.Name:SetDrawLayer("OVERLAY")
		button.Name:SetTextColor(1, 1, 1)
		button.Name.SetTextColor = function() end
		
		if (not Settings["action-bars-show-macro-names"]) then
			button.Name:SetAlpha(0)
		end
	end
	
	--[[if (not button.CountBG) then
		button.CountBG = button:CreateTexture(nil, "BORDER")
		button.CountBG:SetScaledPoint("BOTTOMRIGHT", button, 0, 0)
		button.CountBG:SetScaledSize(24, 16)
		button.CountBG:SetTexture(Media:GetTexture("Blank"))
		button.CountBG:SetVertexColor(0, 0, 0, 0.9)
		button.CountBG:Hide()
	end]]
	
	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetScaledPoint("TOPRIGHT", button, -2, -2)
		button.Count:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetDrawLayer("OVERLAY")
		button.Count:SetTextColor(1, 1, 1)
		button.Count.SetTextColor = function() end
		
		if (not Settings["action-bars-show-count"]) then
			button.Count:SetAlpha(0)
		end
	end
	
	button.Backdrop = CreateFrame("Frame", nil, button)
	button.Backdrop:SetScaledPoint("TOPLEFT", button, 0, 0)
	button.Backdrop:SetScaledPoint("BOTTOMRIGHT", button, 0, 0)
	button.Backdrop:SetBackdrop(vUI.Backdrop)
	button.Backdrop:SetBackdropColor(0, 0, 0)
	button.Backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
	
	button.Backdrop.Texture = button.Backdrop:CreateTexture(nil, "BACKDROP")
	button.Backdrop.Texture:SetScaledPoint("TOPLEFT", button.Backdrop, 1, -1)
	button.Backdrop.Texture:SetScaledPoint("BOTTOMRIGHT", button.Backdrop, -1, 1)
	button.Backdrop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	button.Backdrop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	if (button.SetHighlightTexture and not button.Highlight) then
		local Highlight = button:CreateTexture(nil, "ARTWORK", button)
		Highlight:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Highlight:SetVertexColor(1, 1, 1, 0.2)
		Highlight:SetScaledPoint("TOPLEFT", button, 1, -1)
		Highlight:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Highlight = Highlight
		button:SetHighlightTexture(Highlight)
	end
	
	if (button.SetPushedTexture and not button.Pushed) then
		local Pushed = button:CreateTexture(nil, "ARTWORK", button)
		Pushed:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)
		Pushed:SetScaledPoint("TOPLEFT", button, 1, -1)
		Pushed:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Pushed = Pushed
		button:SetPushedTexture(Pushed)
	end
	
	if (button.SetCheckedTexture and not button.Checked) then
		local Checked = button:CreateTexture(nil, "ARTWORK", button)
		Checked:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Checked:SetVertexColor(0.1, 0.9, 0.1, 0.2)
		Checked.SetAlpha = function() end
		Checked:SetScaledPoint("TOPLEFT", button, 1, -1)
		Checked:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Checked = Checked
		button:SetCheckedTexture(Checked)
	end
	
	if button.Flash then
		button.Flash:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		button.Flash:SetVertexColor(0.7, 0.7, 0.1, 0.3)
		button.Flash:SetScaledPoint("TOPLEFT", button, 1, -1)
		button.Flash:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
	end
	
	local Range = button:CreateTexture(nil, "ARTWORK", button)
	Range:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
	Range:SetVertexColor(0.7, 0, 0)
	Range:SetScaledPoint("TOPLEFT", button, 1, -1)
	Range:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
	Range:SetAlpha(0)
	
	button.Range = Range
	
	if button.cooldown then
		button.cooldown:ClearAllPoints()
		button.cooldown:SetScaledPoint("TOPLEFT", button, 1, -1)
		button.cooldown:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.cooldown:SetDrawEdge(true)
		button.cooldown:SetEdgeTexture(Media:GetTexture("Blank"))
		button.cooldown:SetSwipeColor(0, 0, 0, 1)
	end
	
	button:SetFrameLevel(15)
	button:SetFrameStrata("MEDIUM")
	
	button.IsSkinned = true
end

local ShowGridAndSkin = function()
	local Value = Settings["action-bars-show-grid"] and 1 or 0
	local Button
	
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Button = _G[format("ActionButton%d", i)]
		Button:SetAttribute("showgrid", Value)
		SkinButton(Button)
		
		if Value then
			Button:Show()
		end
		
		if (Value == 0 and not HasAction(Button.action)) then
			Button:Hide()
		end
		
		Button = _G[format("MultiBarRightButton%d", i)]
		Button:SetAttribute("showgrid", Value)
		SkinButton(Button)
		
		if Value then
			Button:Show()
		end
		
		if (Value == 0 and not HasAction(Button.action)) then
			Button:Hide()
		end
		
		Button = _G[format("MultiBarBottomRightButton%d", i)]
		Button:SetAttribute("showgrid", Value)
		SkinButton(Button)
		
		if Value then
			Button:Show()
		end
		
		if (Value == 0 and not HasAction(Button.action)) then
			Button:Hide()
		end
		
		Button = _G[format("MultiBarLeftButton%d", i)]
		Button:SetAttribute("showgrid", Value)
		SkinButton(Button)
		
		if Value then
			Button:Show()
		end
		
		if (Value == 0 and not HasAction(Button.action)) then
			Button:Hide()
		end
		
		Button = _G[format("MultiBarBottomLeftButton%d", i)]
		Button:SetAttribute("showgrid", Value)
		SkinButton(Button)
		
		if Value then
			Button:Show()
		end
		
		if (Value == 0 and not HasAction(Button.action)) then
			Button:Hide()
		end
	end
	
	SetCVar("alwaysShowActionBars", Value)
end

local UpdateBar1 = function()
	local ActionBar1 = vUIActionBar1
	local Button
	
	for i = 1, Num do
		Button = _G["ActionButton"..i]
		ActionBar1:SetFrameRef("ActionButton"..i, Button)
	end
	
	ActionBar1:Execute([[
		Button = table.new()
		
		for i = 1, 12 do
			table.insert(Button, self:GetFrameRef("ActionButton"..i))
		end
	]])
	
	ActionBar1:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		for i, Button in ipairs(Button) do
			Button:SetAttribute("actionpage", tonumber(newstate))
		end
	]])
	
	RegisterStateDriver(ActionBar1, "page", ActionBar1.GetBar())
end

local CreateBar1 = function()
	local ActionBar1 = CreateFrame("Frame", "vUIActionBar1", UIParent, "SecureHandlerStateTemplate")
	ActionBar1:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	ActionBar1:SetScaledPoint("BOTTOMLEFT", vUIBottomActionBarsPanel, (SPACING + 1), (SPACING + 1))
	ActionBar1:SetFrameStrata("MEDIUM")
	
	if (not Settings["action-bars-show-1"]) then
		ActionBar1:Hide()
	end
	
	ActionBar1.Page = {
		["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
		["ROGUE"] = "[bonusbar:1] 7;",
		["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
		["PRIEST"] = "[bonusbar:1] 7;",
		["DEFAULT"] = "[bar:6] 6;[bar:5] 5;[bar:4] 4;[bar:3] 3;[bar:2] 2;[overridebar] 14;[shapeshift] 13;[vehicleui] 12;[possessbar] 12;",
	}
	
	ActionBar1.GetBar = function()
		local Condition = ActionBar1.Page["DEFAULT"]
		local Page = ActionBar1.Page[vUI.UserClass]
		
		if Page then
			Condition = Condition .. " " .. Page
		end
		
		Condition = Condition .. " [form] 1; 1"
		
		return Condition
	end
	
	for i = 1, Num do
		local Button = _G["ActionButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		Button:SetParent(ActionBar1)
		
		if (i == 1) then
			Button:SetScaledPoint("LEFT", 0, 0)
		else
			Button:SetScaledPoint("LEFT", ActionBar1[i-1], "RIGHT", SPACING, 0)
		end
		
		ActionBar1[i] = Button
	end
	
	UpdateBar1()
	
	MainMenuBar:SetParent(Hider)
end

local CreateBar2 = function()
	local ActionBar2 = CreateFrame("Frame", "vUIActionBar2", UIParent, "SecureHandlerStateTemplate")
	ActionBar2:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	ActionBar2:SetFrameStrata("MEDIUM")
	
	if (not Settings["action-bars-show-2"]) then
		ActionBar2:Hide()
	end
	
	MultiBarBottomLeft:SetParent(ActionBar2)
	
	for i = 1, Num do
		local Button = _G["MultiBarBottomLeftButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("LEFT", ActionBar2, 0, 0)
		else
			Button:SetScaledPoint("LEFT", ActionBar2[i-1], "RIGHT", SPACING, 0)
		end
		
		ActionBar2[i] = Button
	end
end

local CreateBar3 = function()
	local ActionBar3 = CreateFrame("Frame", "vUIActionBar3", UIParent, "SecureHandlerStateTemplate")
	ActionBar3:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	ActionBar3:SetScaledPoint("RIGHT", vUISideActionBarsPanel, -(SPACING + 1), 0)
	ActionBar3:SetFrameStrata("MEDIUM")
	
	if (not Settings["action-bars-show-3"]) then
		ActionBar3:Hide()
	end
	
	MultiBarRight:SetParent(ActionBar3)
	
	for i = 1, Num do
		local Button = _G["MultiBarRightButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", ActionBar3, 0, 0)
		else
			Button:SetScaledPoint("TOP", ActionBar3[i-1], "BOTTOM", 0, -SPACING)
		end
		
		ActionBar3[i] = Button
	end
end

local CreateBar4 = function()
	local ActionBar4 = CreateFrame("Frame", "vUIActionBar4", UIParent, "SecureHandlerStateTemplate")
	ActionBar4:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	ActionBar4:SetFrameStrata("MEDIUM")
	
	if (not Settings["action-bars-show-4"]) then
		ActionBar4:Hide()
	end
	
	MultiBarLeft:SetParent(ActionBar4)
	
	for i = 1, Num do
		local Button = _G["MultiBarLeftButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", ActionBar4, 0, 0)
		else
			Button:SetScaledPoint("TOP", ActionBar4[i-1], "BOTTOM", 0, -SPACING)
		end
		
		ActionBar4[i] = Button
	end
end

local CreateBar5 = function()
	local ActionBar5 = CreateFrame("Frame", "vUIActionBar5", UIParent, "SecureHandlerStateTemplate")
	ActionBar5:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	ActionBar5:SetFrameStrata("MEDIUM")
	
	if (not Settings["action-bars-show-5"]) then
		ActionBar5:Hide()
	end
	
	MultiBarBottomRight:SetParent(ActionBar5)
	
	for i = 1, Num do
		local Button = _G["MultiBarBottomRightButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:ClearAllPoints()
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", ActionBar5, 0, 0)
		else
			Button:SetScaledPoint("TOP", ActionBar5[i-1], "BOTTOM", 0, -SPACING)
		end
		
		ActionBar5[i] = Button
	end
end

local SkinPetButton = function(button)
	if button.Styled then
		return
	end
	
	local Name = button:GetName()
	local Icon = _G[Name .. "Icon"]
	local Normal2 = _G[Name .. "NormalTexture2"]
	local HotKey = _G[Name .. "HotKey"]
	local Shine = _G[Name .. "Shine"]
	
	Shine:SetScaledSize(BUTTON_SIZE - 6, BUTTON_SIZE - 6)
	Shine:ClearAllPoints()
	Shine:SetPoint("CENTER", button, 0, 0)
	
	Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Icon:SetDrawLayer("BACKGROUND", 7)
	Icon:SetScaledPoint("TOPLEFT", button, 1, -1)
	Icon:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
	
	button:SetNormalTexture("")
	--button.SetNormalTexture = function() end -- Taint error
	
	if button.HotKey then
		button.HotKey:ClearAllPoints()
		button.HotKey:SetScaledPoint("TOPLEFT", button, 2, -2)
		button.HotKey:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
		button.HotKey:SetJustifyH("LEFT")
		button.HotKey:SetDrawLayer("OVERLAY")
		button.HotKey:SetTextColor(1, 1, 1)
		button.HotKey.SetTextColor = function() end
		
		local HotKeyText = button.HotKey:GetText()
		
		if HotKeyText then
			button.HotKey:SetText("|cffFFFFFF" .. HotKeyText .. "|r")
		end
		
		button.HotKey.OST = button.HotKey.SetText
		button.HotKey.SetText = function(self, text)
			self:OST("|cFFFFFFFF" .. text .. "|r")
		end
		
		if (not Settings["action-bars-show-hotkeys"]) then
			button.HotKey:SetAlpha(0)
		end
	end
	
	if button.Name then
		button.Name:ClearAllPoints()
		button.Name:SetScaledPoint("BOTTOMLEFT", button, 2, 2)
		button.Name:SetScaledWidth(button:GetWidth() - 4)
		button.Name:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
		button.Name:SetJustifyH("LEFT")
		button.Name:SetDrawLayer("OVERLAY")
		button.Name:SetTextColor(1, 1, 1)
		button.Name.SetTextColor = function() end
		
		if (not Settings["action-bars-show-macro-names"]) then
			button.Name:SetAlpha(0)
		end
	end
	
	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetScaledPoint("TOPRIGHT", button, -2, -2)
		button.Count:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetDrawLayer("OVERLAY")
		button.Count:SetTextColor(1, 1, 1)
		button.Count.SetTextColor = function() end
		
		if (not Settings["action-bars-show-count"]) then
			button.Count:SetAlpha(0)
		end
	end
	
	_G[Name.."Flash"]:SetTexture("")
	
	if Normal2 then
		Normal2:ClearAllPoints()
		Normal2:SetPoint("TOPLEFT")
		Normal2:SetPoint("BOTTOMRIGHT")
		Normal2:SetTexture("")
	end
	
	if (button.SetHighlightTexture and not button.Highlight) then
		local Highlight = button:CreateTexture(nil, "ARTWORK", button)
		Highlight:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Highlight:SetVertexColor(1, 1, 1, 0.2)
		Highlight:SetScaledPoint("TOPLEFT", button, 1, -1)
		Highlight:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Highlight = Highlight
		button:SetHighlightTexture(Highlight)
	end
	
	if (button.SetPushedTexture and not button.Pushed) then
		local Pushed = button:CreateTexture(nil, "ARTWORK", button)
		Pushed:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)
		Pushed:SetScaledPoint("TOPLEFT", button, 1, -1)
		Pushed:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Pushed = Pushed
		button:SetPushedTexture(Pushed)
	end
	
	if (button.SetCheckedTexture and not button.Checked) then
		local Checked = button:CreateTexture(nil, "ARTWORK", button)
		Checked:SetTexture(Media:GetTexture(Settings["action-bars-button-highlight"]))
		Checked:SetVertexColor(0.1, 0.9, 0.1, 0.2)
		Checked.SetAlpha = function() end
		Checked:SetScaledPoint("TOPLEFT", button, 1, -1)
		Checked:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.Checked = Checked
		button:SetCheckedTexture(Checked)
	end
	
	button.Backdrop = CreateFrame("Frame", nil, button)
	button.Backdrop:SetScaledPoint("TOPLEFT", button, -1, 1)
	button.Backdrop:SetScaledPoint("BOTTOMRIGHT", button, 1, -1)
	button.Backdrop:SetBackdrop(vUI.Backdrop)
	button.Backdrop:SetBackdropColor(0, 0, 0)
	button.Backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
	
	button.Backdrop.Texture = button.Backdrop:CreateTexture(nil, "BACKDROP")
	button.Backdrop.Texture:SetScaledPoint("TOPLEFT", button.Backdrop, 1, -1)
	button.Backdrop.Texture:SetScaledPoint("BOTTOMRIGHT", button.Backdrop, -1, 1)
	button.Backdrop.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	button.Backdrop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	button.Styled = true
end

local CreatePetBar = function()
	PetActionBarFrame:UnregisterEvent("PET_BAR_SHOWGRID")
	PetActionBarFrame:UnregisterEvent("PET_BAR_HIDEGRID")
	PetActionBarFrame.showgrid = 1
	
	local Max = NUM_PET_ACTION_SLOTS
	
	local PetActionBar = CreateFrame("Frame", "vUIPetActionBar", vUIPetActionBarsPanel, "SecureHandlerStateTemplate")
	PetActionBar:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * Max) + (SPACING * (Max - 1))))
	PetActionBar:SetScaledPoint("CENTER", vUIPetActionBarsPanel, 0, 0)
	PetActionBar:SetFrameStrata("MEDIUM")
	
	for i = 1, Max do
		local Button = _G["PetActionButton"..i]
		Button:SetScaledSize(BUTTON_SIZE, BUTTON_SIZE)
		Button:SetParent(vUIPetActionBarsPanel)
		Button:ClearAllPoints()
		
		SkinPetButton(Button)
		
		if (i == 1) then
			Button:SetScaledPoint("TOP", PetActionBar, 0, 0)
		else
			Button:SetScaledPoint("TOP", PetActionBar[i-1], "BOTTOM", 0, -SPACING)
		end
		
		PetActionBar:SetAttribute("addchild", Button)
		PetActionBar[i] = Button
	end
	
	RegisterStateDriver(vUIPetActionBarsPanel, "visibility", "[pet,nooverridebar,nobonusbar:5] show; hide")
end

local CreateStanceBar = function()
	local NumForms = GetNumShapeshiftForms()
	
	local StancePanel = CreateFrame("Frame", "vUI Stance", UIParent, "SecureHandlerStateTemplate")
	StancePanel:SetScaledPoint("TOPLEFT", UIParent, 10, -10)
	StancePanel:SetScaledWidth((STANCE_SIZE * NumForms) + (SPACING * (NumForms + 2)))
	StancePanel:SetScaledHeight(((STANCE_SIZE * 1) + (SPACING * 3)))
	StancePanel:SetBackdrop(vUI.BackdropAndBorder)
	StancePanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	StancePanel:SetBackdropBorderColor(0, 0, 0)
	StancePanel:SetFrameStrata("LOW")
	
	if (not Settings["action-bars-show-stance-bg"]) then
		StancePanel:SetAlpha(0)
	end
	
	vUI:GetModule("Move"):Add(StancePanel)
	
	local Button
	
	if (StanceBarFrame and StanceBarFrame.StanceButtons) then
		for i = 1, NUM_STANCE_SLOTS do
			Button = StanceBarFrame.StanceButtons[i]
			
			SkinButton(Button)
			Button:SetScaledSize(STANCE_SIZE)
			Button:SetParent(UIParent)
			Button:SetFrameStrata("MEDIUM")
			Button:ClearAllPoints()
			
			if (i > NumForms) then
				Button:Hide()
			end
			
			if (i == 1) then
				Button:SetScaledPoint("LEFT", StancePanel, 3, 0)
			else
				Button:SetScaledPoint("LEFT", StanceBarFrame.StanceButtons[i-1], "RIGHT", 2, 0)
			end
		end
	end
	
	if (NumForms == 0) then
		StancePanel:Hide()
	end
	
	ActionBars.StanceBar = StancePanel
end

local CreateBarPanels = function()
	local BottomPanel = CreateFrame("Frame", "vUIBottomActionBarsPanel", UIParent)
	BottomPanel:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 14)), ((BUTTON_SIZE * 2) + (SPACING * 4)))
	BottomPanel:SetBackdrop(vUI.BackdropAndBorder)
	BottomPanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	BottomPanel:SetBackdropBorderColor(0, 0, 0)
	BottomPanel:SetFrameStrata("LOW")
	
	if (not Settings["action-bars-show-bottom-bg"]) then
		BottomPanel:SetAlpha(0)
	end
	
	local SidePanel = CreateFrame("Frame", "vUISideActionBarsPanel", UIParent)
	SidePanel:SetScaledSize(((BUTTON_SIZE * 3) + (SPACING * 5)), ((BUTTON_SIZE * 12) + (SPACING * 14)))
	SidePanel:SetScaledPoint("RIGHT", UIParent, -10, 0)
	SidePanel:SetBackdrop(vUI.BackdropAndBorder)
	SidePanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	SidePanel:SetBackdropBorderColor(0, 0, 0)
	SidePanel:SetFrameStrata("LOW")
	
	local PetPanel = CreateFrame("Frame", "vUIPetActionBarsPanel", UIParent)
	PetPanel:SetScaledSize(((BUTTON_SIZE * 1) + (SPACING * 3)), ((BUTTON_SIZE * 10) + (SPACING * 12)))
	PetPanel:SetScaledPoint("RIGHT", SidePanel, "LEFT", -SPACING, 0)
	PetPanel:SetBackdrop(vUI.BackdropAndBorder)
	PetPanel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	PetPanel:SetBackdropBorderColor(0, 0, 0)
	PetPanel:SetFrameStrata("LOW")
	
	if (not Settings["action-bars-show-side-bg"]) then
		SidePanel:SetAlpha(0)
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC" and UnitLevel("player") ~= MAX_PLAYER_LEVEL) then
		BottomPanel:SetScaledPoint("BOTTOM", vUIExperienceBar, "TOP", 0, 5)
	elseif (Settings["reputation-enable"] and Settings["reputation-position"] == "CLASSIC") then
		BottomPanel:SetScaledPoint("BOTTOM", vUI:GetModule("Reputation"), "TOP", 0, 5)
	else
		BottomPanel:SetScaledPoint("BOTTOM", UIParent, 0, 10)
	end
end

local SetClassicStyle = function()
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	vUIActionBar4:SetScaledPoint("TOP", vUISideActionBarsPanel, 0, -(SPACING + 1))
	
	vUIActionBar5:ClearAllPoints()
	vUIActionBar5:SetScaledPoint("TOPRIGHT", vUIBottomActionBarsPanel, -(SPACING + 1), -(SPACING + 1))
	vUIActionBar5:SetScaledSize((BUTTON_SIZE * 6) + (SPACING * 5), (BUTTON_SIZE * 2) + SPACING)
	
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("TOPLEFT", vUIBottomActionBarsPanel, (SPACING + 1), -(SPACING + 1))
	
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledPoint("LEFT", vUISideActionBarsPanel, (SPACING + 1), 0)
	
	vUIBottomActionBarsPanel:SetScaledSize((((BUTTON_SIZE * 12) + (SPACING * 14)) + (((BUTTON_SIZE * 12) + (SPACING * 14)) / 2)) - SPACING, ((BUTTON_SIZE * 2) + (SPACING * 4)))
	vUISideActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 2) + (SPACING * 4)), ((BUTTON_SIZE * 12) + (SPACING * 14)))
	
	for i = 1, Num do
		vUIActionBar4[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar4[i]:SetScaledPoint("TOP", vUIActionBar4, 0, 0)
		else
			vUIActionBar4[i]:SetScaledPoint("TOP", vUIActionBar4[i-1], "BOTTOM", 0, -SPACING)
		end
	end
	
	for i = 1, Num do
		vUIActionBar5[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar5[i]:SetScaledPoint("BOTTOMLEFT", vUIActionBar5, 0, 0)
		elseif (i == 7) then
			vUIActionBar5[i]:SetScaledPoint("TOPLEFT", vUIActionBar5, 0, 0)
		else
			vUIActionBar5[i]:SetScaledPoint("LEFT", vUIActionBar5[i-1], "RIGHT", SPACING, 0)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local Set2x3Style = function()
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	vUIActionBar4:SetScaledPoint("TOP", vUISideActionBarsPanel, 0, -(SPACING + 1))
	
	vUIActionBar5:ClearAllPoints()
	vUIActionBar5:SetScaledPoint("LEFT", vUISideActionBarsPanel, (SPACING + 1), 0)
	vUIActionBar5:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("TOP", vUIBottomActionBarsPanel, 0, -(SPACING + 1))
	
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledPoint("TOP", vUISideActionBarsPanel, 0, -(SPACING + 1))
	
	vUIBottomActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 14)), ((BUTTON_SIZE * 2) + (SPACING * 4)))
	vUISideActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 3) + (SPACING * 5)), ((BUTTON_SIZE * 12) + (SPACING * 14)))
	
	for i = 1, Num do
		vUIActionBar4[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar4[i]:SetScaledPoint("TOP", vUIActionBar4, 0, 0)
		else
			vUIActionBar4[i]:SetScaledPoint("TOP", vUIActionBar4[i-1], "BOTTOM", 0, -SPACING)
		end
	end
	
	for i = 1, Num do
		vUIActionBar5[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar5[i]:SetScaledPoint("TOP", vUIActionBar5, 0, 0)
		else
			vUIActionBar5[i]:SetScaledPoint("TOP", vUIActionBar5[i-1], "BOTTOM", 0, -SPACING)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local Set3x2Style = function()
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledSize(BUTTON_SIZE, ((BUTTON_SIZE * 12) + (SPACING * 11)))
	vUIActionBar4:SetScaledPoint("TOPLEFT", vUISideActionBarsPanel, (SPACING + 1), -(SPACING + 1))
	
	vUIActionBar5:ClearAllPoints()
	vUIActionBar5:SetScaledPoint("TOP", vUIBottomActionBarsPanel, 0, -(SPACING + 1))
	vUIActionBar5:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("LEFT", vUIBottomActionBarsPanel, (SPACING + 1), 0)
	
	vUIBottomActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 14)), ((BUTTON_SIZE * 3) + (SPACING * 5)))
	vUISideActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 2) + (SPACING * 4)), ((BUTTON_SIZE * 12) + (SPACING * 14)))
	
	for i = 1, Num do
		vUIActionBar4[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar4[i]:SetScaledPoint("TOP", vUIActionBar4, 0, 0)
		else
			vUIActionBar4[i]:SetScaledPoint("TOP", vUIActionBar4[i-1], "BOTTOM", 0, -SPACING)
		end
	end
	
	for i = 1, Num do
		vUIActionBar5[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar5[i]:SetScaledPoint("LEFT", vUIActionBar5, 0, 0)
		else
			vUIActionBar5[i]:SetScaledPoint("LEFT", vUIActionBar5[i-1], "RIGHT", SPACING, 0)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local Set4x1Style = function()
	vUIActionBar2:ClearAllPoints()
	vUIActionBar2:SetScaledPoint("BOTTOM", vUIActionBar1, "TOP", 0, SPACING)
	
	vUIActionBar4:ClearAllPoints()
	vUIActionBar4:SetScaledPoint("TOP", vUIBottomActionBarsPanel, 0, -(SPACING + 1))
	vUIActionBar4:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	
	vUIActionBar5:ClearAllPoints()
	vUIActionBar5:SetScaledPoint("BOTTOM", vUIActionBar2, "TOP", 0, SPACING)
	vUIActionBar5:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 11)), BUTTON_SIZE)
	
	vUIBottomActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 12) + (SPACING * 14)), ((BUTTON_SIZE * 4) + (SPACING * 6)))
	vUISideActionBarsPanel:SetScaledSize(((BUTTON_SIZE * 1) + (SPACING * 3)), ((BUTTON_SIZE * 12) + (SPACING * 14)))
	
	for i = 1, Num do
		vUIActionBar4[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar4[i]:SetScaledPoint("LEFT", vUIActionBar4, 0, 0)
		else
			vUIActionBar4[i]:SetScaledPoint("LEFT", vUIActionBar4[i-1], "RIGHT", SPACING, 0)
		end
	end
	
	for i = 1, Num do
		vUIActionBar5[i]:ClearAllPoints()
		
		if (i == 1) then
			vUIActionBar5[i]:SetScaledPoint("LEFT", vUIActionBar5, 0, 0)
		else
			vUIActionBar5[i]:SetScaledPoint("LEFT", vUIActionBar5[i-1], "RIGHT", SPACING, 0)
		end
	end
	
	if (Settings["experience-enable"] and Settings["experience-position"] == "CLASSIC") then
		vUIExperienceBar:SetScaledWidth(vUIBottomActionBarsPanel:GetWidth() - (SPACING * 3))
	end
end

local SetActionBarLayout = function(value)
	if (value == "2x3") then
		Set2x3Style()
	elseif (value == "3x2") then
		Set3x2Style()
	elseif (value == "4x1") then
		Set4x1Style()
	elseif (value == "DEFAULT") then
		SetClassicStyle()
	end
end

local SetButtonSize = function(value)
	for i = 1, Num do
		vUIActionBar1[i]:SetScaledSize(value)
		vUIActionBar2[i]:SetScaledSize(value)
		vUIActionBar3[i]:SetScaledSize(value)
		vUIActionBar4[i]:SetScaledSize(value)
		vUIActionBar5[i]:SetScaledSize(value)
	end
	
	vUIActionBar1:SetScaledSize(((value * 12) + (SPACING * 11)), value)
	vUIActionBar2:SetScaledSize(((value * 12) + (SPACING * 11)), value)
	vUIActionBar3:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
	
	if (Settings["action-bars-layout"] == "2x3") then
		vUIActionBar4:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
		vUIActionBar5:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
		
		vUIBottomActionBarsPanel:SetScaledSize(((value * 12) + (SPACING * 14)), ((value * 2) + (SPACING * 4)))
		vUISideActionBarsPanel:SetScaledSize(((value * 3) + (SPACING * 5)), ((value * 12) + (SPACING * 14)))
	elseif (Settings["action-bars-layout"] == "3x2") then
		vUIActionBar4:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
		vUIActionBar5:SetScaledSize(((value * 12) + (SPACING * 11)), value)
		
		vUIBottomActionBarsPanel:SetScaledSize(((value * 12) + (SPACING * 14)), ((value * 3) + (SPACING * 5)))
		vUISideActionBarsPanel:SetScaledSize(((value * 2) + (SPACING * 4)), ((value * 12) + (SPACING * 14)))
	elseif (Settings["action-bars-layout"] == "4x1") then
		vUIActionBar4:SetScaledSize(((value * 12) + (SPACING * 11)), value)
		vUIActionBar5:SetScaledSize(((value * 12) + (SPACING * 11)), value)
		
		vUIBottomActionBarsPanel:SetScaledSize(((value * 12) + (SPACING * 14)), ((value * 4) + (SPACING * 6)))
		vUISideActionBarsPanel:SetScaledSize(((value * 1) + (SPACING * 3)), ((value * 12) + (SPACING * 14)))
	elseif (Settings["action-bars-layout"] == "DEFAULT") then
		vUIActionBar4:SetScaledSize(value, ((value * 12) + (SPACING * 11)))
		vUIActionBar5:SetScaledSize((value * 6) + (SPACING * 5), (value * 2) + SPACING)
		
		vUISideActionBarsPanel:SetScaledSize(((value * 2) + (SPACING * 4)), ((value * 12) + (SPACING * 14)))
		vUIBottomActionBarsPanel:SetScaledSize((((value * 12) + (SPACING * 14))) * 1.5 - SPACING, ((value * 2) + (SPACING * 4)))
	end
	
	BUTTON_SIZE = value
end

local SetStanceSize = function(value)
	if InCombatLockdown() then
		return
	end
	
	for i = 1, NUM_STANCE_SLOTS do
		StanceBarFrame.StanceButtons[i]:SetScaledSize(value, value)
	end
	
	local NumForms = GetNumShapeshiftForms()
	
	ActionBars.StanceBar:SetScaledWidth((value * NumForms) + (SPACING * (NumForms + 2)))
	ActionBars.StanceBar:SetScaledHeight(((value * 1) + (SPACING * 3)))
	
	if (NumForms > 0) then
		if (not ActionBars.StanceBar:IsShown()) then
			ActionBars.StanceBar:Show()
		end
	elseif ActionBars.StanceBar:IsShown() then
		ActionBars.StanceBar:Hide()
	end
end

local SetHighlightTexture = function(value)
	local Texture = Media:GetTexture(value)
	
	for i = 1, Num do
		vUIActionBar1[i].Highlight:SetTexture(Texture)
		vUIActionBar1[i].Pushed:SetTexture(Texture)
		vUIActionBar1[i].Checked:SetTexture(Texture)
		vUIActionBar1[i].Range:SetTexture(Texture)
		vUIActionBar1[i].Flash:SetTexture(Texture)
		
		vUIActionBar2[i].Highlight:SetTexture(Texture)
		vUIActionBar2[i].Pushed:SetTexture(Texture)
		vUIActionBar2[i].Checked:SetTexture(Texture)
		vUIActionBar2[i].Range:SetTexture(Texture)
		vUIActionBar2[i].Flash:SetTexture(Texture)
		
		vUIActionBar3[i].Highlight:SetTexture(Texture)
		vUIActionBar3[i].Pushed:SetTexture(Texture)
		vUIActionBar3[i].Checked:SetTexture(Texture)
		vUIActionBar3[i].Range:SetTexture(Texture)
		vUIActionBar3[i].Flash:SetTexture(Texture)
		
		vUIActionBar4[i].Highlight:SetTexture(Texture)
		vUIActionBar4[i].Pushed:SetTexture(Texture)
		vUIActionBar4[i].Checked:SetTexture(Texture)
		vUIActionBar4[i].Range:SetTexture(Texture)
		vUIActionBar4[i].Flash:SetTexture(Texture)
		
		vUIActionBar5[i].Highlight:SetTexture(Texture)
		vUIActionBar5[i].Pushed:SetTexture(Texture)
		vUIActionBar5[i].Checked:SetTexture(Texture)
		vUIActionBar5[i].Range:SetTexture(Texture)
		vUIActionBar5[i].Flash:SetTexture(Texture)
	end
end

local UpdateButtonStatus = function(self)
	local IsUsable, NoMana = IsUsableAction(self.action)
	
	if IsUsable then
		local InRange = IsActionInRange(self.action)
		
		if (InRange == false) then
			self.icon:SetVertexColorHex("FF4C19")
		else
			self.icon:SetVertexColorHex("FFFFFF")
		end
	elseif NoMana then
		self.icon:SetVertexColorHex("3498D8")
	else
		self.icon:SetVertexColorHex("4C4C4C")
	end
end

local StanceBarUpdateState = function()
	if (GetNumShapeshiftForms() > 0) then
		if (not ActionBars.StanceBar:IsShown()) then
			ActionBars.StanceBar:Show()
		end
	elseif ActionBars.StanceBar:IsShown() then
		ActionBars.StanceBar:Hide()
	end
end

ActionBars:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionBars:SetScript("OnEvent", function(self, event)
	if (not Settings["action-bars-enable"]) then
		vUI.UnitFrames["player"].Castbar:SetScaledPoint("BOTTOM", UIParent, 0, 108)
		vUI.UnitFrames["target"].Castbar:SetScaledPoint("BOTTOM", vUI.UnitFrames["player"].Castbar, "TOP", 0, 4)
		
		vUI:GetModule("Move"):Add(vUI.UnitFrames["player"].Castbar, 2)
		vUI:GetModule("Move"):Add(vUI.UnitFrames["target"].Castbar, 2)
	
		return
	end
	
	BUTTON_SIZE = Settings["action-bars-button-size"]
	SPACING = Settings["action-bars-button-spacing"]
	STANCE_SIZE = Settings["action-bars-stance-size"]
	
	CreateBarPanels()
	CreateBar1()
	CreateBar2()
	CreateBar3()
	CreateBar4()
	CreateBar5()
	CreatePetBar()
	CreateStanceBar()
	
	SetActionBarLayout(Settings["action-bars-layout"])
	
	--[[SHOW_MULTI_ACTIONBAR_1 = 1
	SHOW_MULTI_ACTIONBAR_2 = 1
	SHOW_MULTI_ACTIONBAR_3 = 1
	SHOW_MULTI_ACTIONBAR_4 = 1]]
	
	SetActionBarToggles(1, 1, 1, 1, 1)
	
	MultiActionBar_Update()
	
	MultiBarBottomLeft:SetShown(true)
	MultiBarRight:SetShown(true)
	MultiBarLeft:SetShown(true)
	MultiBarBottomRight:SetShown(true)
	
	ShowGridAndSkin()
	
	-- Remove blizzard options so people don't change them instead of our own
	InterfaceOptionsActionBarsPanelBottomLeft:Hide()
	InterfaceOptionsActionBarsPanelBottomRight:Hide()
	InterfaceOptionsActionBarsPanelRight:Hide()
	InterfaceOptionsActionBarsPanelRightTwo:Hide()
	InterfaceOptionsActionBarsPanelStackRightBars:Hide()
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Hide()
	
	hooksecurefunc("ActionButton_OnUpdate", UpdateButtonStatus)
	hooksecurefunc("ActionButton_Update", UpdateButtonStatus)
	hooksecurefunc("ActionButton_UpdateUsable", UpdateButtonStatus)
	hooksecurefunc("StanceBar_UpdateState", StanceBarUpdateState)
	
	if Settings["unitframes-enable"] then
		vUI.UnitFrames["player"].Castbar:SetScaledPoint("BOTTOM", vUIBottomActionBarsPanel, "TOP", 0, 2)
		vUI.UnitFrames["target"].Castbar:SetScaledPoint("BOTTOM", vUI.UnitFrames["player"].Castbar, "TOP", 0, 4)
		
		vUI:GetModule("Move"):Add(vUI.UnitFrames["player"].Castbar, 2)
		vUI:GetModule("Move"):Add(vUI.UnitFrames["target"].Castbar, 2)
	end
	
	ExtraActionBarFrame:SetParent(UIParent)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetScaledPoint("TOP", UIParent, "CENTER", 0, -200)
	ExtraActionButton1.style:SetAlpha(0)
	
	SkinButton(ExtraActionButton1)
	
	self:UnregisterEvent(event)
end)

local UpdateShowBottomBG = function(value)
	if value then
		vUIBottomActionBarsPanel:SetAlpha(1)
	else
		vUIBottomActionBarsPanel:SetAlpha(0)
	end
end

local UpdateShowSideBG = function(value)
	if value then
		vUISideActionBarsPanel:SetAlpha(1)
	else
		vUISideActionBarsPanel:SetAlpha(0)
	end
end

local UpdateShowStanceBG = function(value)
	if value then
		ActionBars.StanceBar:SetAlpha(1)
	else
		ActionBars.StanceBar:SetAlpha(0)
	end
end

local UpdateShowHotKey = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i].HotKey:SetAlpha(1)
			vUIActionBar2[i].HotKey:SetAlpha(1)
			vUIActionBar3[i].HotKey:SetAlpha(1)
			vUIActionBar4[i].HotKey:SetAlpha(1)
			vUIActionBar5[i].HotKey:SetAlpha(1)
		end
		
		ExtraActionButton1.HotKey:SetAlpha(1)
	else
		for i = 1, Num do
			vUIActionBar1[i].HotKey:SetAlpha(0)
			vUIActionBar2[i].HotKey:SetAlpha(0)
			vUIActionBar3[i].HotKey:SetAlpha(0)
			vUIActionBar4[i].HotKey:SetAlpha(0)
			vUIActionBar5[i].HotKey:SetAlpha(0)
		end
		
		ExtraActionButton1.HotKey:SetAlpha(0)
	end
end

local UpdateShowMacroName = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i].Name:SetAlpha(1)
			vUIActionBar2[i].Name:SetAlpha(1)
			vUIActionBar3[i].Name:SetAlpha(1)
			vUIActionBar4[i].Name:SetAlpha(1)
			vUIActionBar5[i].Name:SetAlpha(1)
		end
	else
		for i = 1, Num do
			vUIActionBar1[i].Name:SetAlpha(0)
			vUIActionBar2[i].Name:SetAlpha(0)
			vUIActionBar3[i].Name:SetAlpha(0)
			vUIActionBar4[i].Name:SetAlpha(0)
			vUIActionBar5[i].Name:SetAlpha(0)
		end
	end
end

local UpdateShowCount = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i].Count:SetAlpha(1)
			vUIActionBar2[i].Count:SetAlpha(1)
			vUIActionBar3[i].Count:SetAlpha(1)
			vUIActionBar4[i].Count:SetAlpha(1)
			vUIActionBar5[i].Count:SetAlpha(1)
		end
	else
		for i = 1, Num do
			vUIActionBar1[i].Count:SetAlpha(0)
			vUIActionBar2[i].Count:SetAlpha(0)
			vUIActionBar3[i].Count:SetAlpha(0)
			vUIActionBar4[i].Count:SetAlpha(0)
			vUIActionBar5[i].Count:SetAlpha(0)
		end
	end
end

local UpdateShowGrid = function(value)
	if value then
		for i = 1, Num do
			vUIActionBar1[i]:SetAttribute("showgrid", 1)
			vUIActionBar1[i]:Show()
			
			vUIActionBar2[i]:SetAttribute("showgrid", 1)
			vUIActionBar2[i]:Show()
			
			vUIActionBar3[i]:SetAttribute("showgrid", 1)
			vUIActionBar3[i]:Show()
			
			vUIActionBar4[i]:SetAttribute("showgrid", 1)
			vUIActionBar4[i]:Show()
			
			vUIActionBar5[i]:SetAttribute("showgrid", 1)
			vUIActionBar5[i]:Show()
		end
	else
		for i = 1, Num do
			vUIActionBar1[i]:SetAttribute("showgrid", 0)
			
			if (not HasAction(vUIActionBar1[i].action)) then
				vUIActionBar1[i]:Hide()
			end
			
			vUIActionBar2[i]:SetAttribute("showgrid", 0)
			
			if (not HasAction(vUIActionBar2[i].action)) then
				vUIActionBar2[i]:Hide()
			end
			
			vUIActionBar3[i]:SetAttribute("showgrid", 0)

			if (not HasAction(vUIActionBar3[i].action)) then
				vUIActionBar3[i]:Hide()
			end

			vUIActionBar4[i]:SetAttribute("showgrid", 0)
			
			if (not HasAction(vUIActionBar4[i].action)) then
				vUIActionBar4[i]:Hide()
			end
			
			vUIActionBar5[i]:SetAttribute("showgrid", 0)
			
			if (not HasAction(vUIActionBar5[i].action)) then
				vUIActionBar5[i]:Hide()
			end
		end
	end
	
	SetCVar("alwaysShowActionBars", value and 1 or 0)
end

local UpdateButtonFont = function(button)
	if button.HotKey then
		button.HotKey:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
	end
	
	if button.Name then
		button.Name:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
	end
	
	if button.Count then
		button.Count:SetFontInfo(Settings["action-bars-font"], Settings["action-bars-font-size"], Settings["action-bars-font-flags"])
	end
end

local UpdateActionBarFont = function()
	for i = 1, Num do
		UpdateButtonFont(vUIActionBar1[i])
		UpdateButtonFont(vUIActionBar2[i])
		UpdateButtonFont(vUIActionBar3[i])
		UpdateButtonFont(vUIActionBar4[i])
		UpdateButtonFont(vUIActionBar5[i])
	end
	
	-- Pet Bar + Stance Bar too
end

local UpdateShowBar1 = function(value)
	if value then
		vUIActionBar1:Show()
	else
		vUIActionBar1:Hide()
	end	
end

local UpdateShowBar2 = function(value)
	if value then
		vUIActionBar2:Show()
	else
		vUIActionBar2:Hide()
	end	
end

local UpdateShowBar3 = function(value)
	if value then
		vUIActionBar3:Show()
	else
		vUIActionBar3:Hide()
	end	
end

local UpdateShowBar4 = function(value)
	if value then
		vUIActionBar4:Show()
	else
		vUIActionBar4:Hide()
	end	
end

local UpdateShowBar5 = function(value)
	if value then
		vUIActionBar5:Show()
	else
		vUIActionBar5:Hide()
	end	
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Action Bars"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("action-bars-enable", Settings["action-bars-enable"], "Enable Action Bars Module", "Enable the vUI Action Bars module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Layouts"])
	Left:CreateDropdown("action-bars-layout", Settings["action-bars-layout"], {["2 x 3"] = "2x3", ["3 x 2"] = "3x2", ["4 x 1"] = "4x1", [Language["Default"]] = "DEFAULT"}, "Bar Layout", "Select a bar layout", SetActionBarLayout)
	
	Left:CreateHeader(Language["Sizing"])
	Left:CreateSlider("action-bars-button-size", Settings["action-bars-button-size"], 24, 40, 1, "Button Size", "Set the size of the action buttons", SetButtonSize)
	--Left:CreateSlider("action-bars-button-spacing", Settings["action-bars-button-spacing"], -1, 8, 1, "Button Spacing", "Set the spacing of the action buttons", ReloadUI):RequiresReload(true)
	Left:CreateSlider("action-bars-stance-size", Settings["action-bars-stance-size"], 24, 40, 1, "Stance Button Size", "Set the size of the stance buttons", SetStanceSize)
	
	Left:CreateHeader(Language["Font"])
	Left:CreateDropdown("action-bars-font", Settings["action-bars-font"], Media:GetFontList(), Language["Font"], "Set the font of the action bar buttons", UpdateActionBarFont, "Font")
	Left:CreateSlider("action-bars-font-size", Settings["action-bars-font-size"], 8, 18, 1, "Font Size", "Set the font size of the action bar buttons", UpdateActionBarFont)
	Left:CreateDropdown("action-bars-font-flags", Settings["action-bars-font-flags"], Media:GetFlagsList(), Language["Font Flags"], "Set the font flags of the action bar buttons", UpdateActionBarFont)
	
	Left:CreateHeader(Language["Backdrops"])
	Left:CreateSwitch("action-bars-show-bottom-bg", Settings["action-bars-show-bottom-bg"], "Show Bottom Backdrop", "Display the backdrop of the bottom action bars", UpdateShowBottomBG)
	Left:CreateSwitch("action-bars-show-side-bg", Settings["action-bars-show-side-bg"], "Show Side Backdrop", "Display the backdrop of the side action bars", UpdateShowSideBG)
	Left:CreateSwitch("action-bars-show-stance-bg", Settings["action-bars-show-stance-bg"], "Show Stance Backdrop", "Display the backdrop of the stance bars", UpdateShowStanceBG)
	
	Right:CreateHeader(Language["Toggles"])
	Right:CreateSwitch("action-bars-show-1", Settings["action-bars-show-1"], "Enable Action Bar 1", "Enable Action Bar 1", UpdateShowBar1)
	Right:CreateSwitch("action-bars-show-2", Settings["action-bars-show-2"], "Enable Action Bar 2", "Enable Action Bar 2", UpdateShowBar2)
	Right:CreateSwitch("action-bars-show-3", Settings["action-bars-show-3"], "Enable Action Bar 3", "Enable Action Bar 3", UpdateShowBar3)
	Right:CreateSwitch("action-bars-show-4", Settings["action-bars-show-4"], "Enable Action Bar 4", "Enable Action Bar 4", UpdateShowBar4)
	Right:CreateSwitch("action-bars-show-5", Settings["action-bars-show-5"], "Enable Action Bar 5", "Enable Action Bar 5", UpdateShowBar5)
	
	Right:CreateHeader(Language["Styling"])
	Right:CreateSwitch("action-bars-show-grid", Settings["action-bars-show-grid"], "Show Empty Buttons", "Display unused buttons", UpdateShowGrid)
	Right:CreateSwitch("action-bars-show-hotkeys", Settings["action-bars-show-hotkeys"], "Show Hotkeys", "Display hotkey text on action buttons", UpdateShowHotKey)
	Right:CreateSwitch("action-bars-show-macro-names", Settings["action-bars-show-macro-names"], "Show Macro Names", "Display macro name text on action buttons", UpdateShowMacroName)
	Right:CreateSwitch("action-bars-show-count", Settings["action-bars-show-count"], "Show Count Text", "Display count text on action buttons", UpdateShowCount)
	Right:CreateDropdown("action-bars-button-highlight", Settings["action-bars-button-highlight"], Media:GetTextureList(), Language["Highlight Texture"], "Set the highlight texture used on action buttons", SetHighlightTexture, "Texture")
end)
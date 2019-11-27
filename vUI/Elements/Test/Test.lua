local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

-- The most important file there is.

-- To do: A bag slot visualizer (Yes, like FFXIV)
-- black square, 2x2 pixels inside, colored by what's in the slot if occupied, 0.3 opacity or something if it's an empty slot.
-- Highlight x cheapest items in bags. x should be optional

local Debug = '"%s" set to %s.'
local floor = floor
local format = format
local match = string.match
local tostring = tostring
local select = select
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local UseContainerItem = UseContainerItem
local GetItemInfo = GetItemInfo
local PickupMerchantItem = PickupMerchantItem
local GetFramerate = GetFramerate

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

--[[ This is currently just a test page to see how GUI controls work, and debug them.
GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow("Test")
	
	Left:CreateHeader(Language["Checkboxes"])
	Left:CreateSwitch("test-checkbox-1", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-checkbox-2", true, "Checkbox Demo", "Enable something", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-checkbox-3", false, "Checkbox Demo", "Show the textuals", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Right:CreateHeader(Language["Selections"])
	Right:CreateDropdown("test-dropdown-1", "Roboto", Media:GetFontList(), "Font Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Font")
	Right:CreateDropdown("test-dropdown-2", "Blank", Media:GetTextureList(), "Texture Menu Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	Right:CreateDropdown("test-dropdown-3", "RenHorizonUp", Media:GetHighlightList(), "Highlight Menu Demo", "", function(v, id)vUI:print(format(Debug, id, tostring(v))) end, "Texture")
	
	Right:CreateHeader(Language["Sliders"])
	Right:CreateSlider("test-slider-1", 3, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Right:CreateSlider("test-slider-2", 7, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " px")
	Right:CreateSlider("test-slider-3", 4, 0, 10, 1, "Slider Demo", "doesn't matter", function(v, id) vUI:print(format(Debug, id, tostring(v))) end, nil, " s")
	
	Right:CreateHeader(Language["Buttons"])
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-1") end)
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI:print("test-button-2") end)
	Right:CreateButton("Test", "Button Demo", "Enable something", function() vUI.Throttle:Create("test1", 10) if vUI.Throttle:IsThrottled("test1") then print('throttled:'..vUI:FormatTime(vUI.Throttle:GetRemaining("test1"))) else vUI.Throttle:Start("test1") print("starting") end end)
	
	Left:CreateHeader(Language["Switches"])
	Left:CreateSwitch("test-switch-1", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-switch-2", true, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateSwitch("test-switch-3", false, "Switch Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Left:CreateHeader(Language["Colors"])
	Left:CreateColorSelection("test-color-1", "B0BEC5", "Color Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateColorSelection("test-color-2", "607D8B", "Color Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	Left:CreateColorSelection("test-color-3", "263238", "Color Demo", "", function(v, id) vUI:print(format(Debug, id, tostring(v))) end)
	
	Left:CreateHeader(Language["StatusBars"])
	
	local Bar = Left:CreateStatusBar(0, 0, 0, "Statusbar Demo", "", function(v)
		Framerate = floor(GetFramerate())
		
		return 0, 350, Framerate, Framerate
	end)
	
	Left:CreateStatusBar(5, 0, 10, "Statusbar Demo", "")
	Left:CreateStatusBar(75, 0, 100, "Statusbar Demo", "", nil, "%")
	
	Bar.Ela = 0
	Bar:SetScript("OnUpdate", function(self, ela)
		self.Ela = self.Ela + ela
		
		if (self.Ela >= 1) then
			local Min, Max, Value, Text = self.Hook()
			
			self:SetMinMaxValues(Min, Max)
			self.MiddleText:SetText(Text)
			
			self.Anim:SetChange(Value)
			self.Anim:Play()
			
			self.Ela = 0
		end
	end)
	
	Bar:GetScript("OnUpdate")(Bar, 1)
	
	Right:CreateHeader(Language["Lines"])
	Right:CreateLine("Test Line 1")
	Right:CreateLine("Test Line 2")
	Right:CreateLine("Test Line 3")
	
	Right:CreateHeader(Language["Double Lines"])
	Right:CreateDoubleLine("Left Line 1", "Right Line 1")
	Right:CreateDoubleLine("Left Line 2", "Right Line 2")
	Right:CreateDoubleLine("Left Line 3", "Right Line 3")
	
	Left:CreateHeader(Language["Inputs"])
	Left:CreateInput("test-input-1", vUI.UserName, "Test Input 1", nil, function(v) print(v) end)
	Left:CreateInput("test-input-2", vUI.UserName, "Test Input 2", nil, function(v) print(v) end)
	Left:CreateInput("test-input-3", vUI.UserName, "Test Input 3", nil, function(v) print(v) end)
	
	Left:CreateMessage("Hello world. This is a variable length message for the GUI to process.")
end)]]

local GetNumLoadedAddOns = function()
	local NumLoaded = 0
	
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			NumLoaded = NumLoaded + 1
		end
	end
	
	return NumLoaded
end

local GetClient = function()
	if IsWindowsClient() then
		return Language["Windows"]
	elseif IsMacClient() then
		return Language["Mac"]
	else -- IsLinuxClient
		return Language["Linux"]
	end
end

local GetQuests = function()
	local NumQuests = select(2, GetNumQuestLogEntries())
	local MaxQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
	
	return format("%s / %s", NumQuests, MaxQuests)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Debug"])
	
	Left:CreateHeader(Language["UI Information"])
	Left:CreateDoubleLine(Language["UI Version"], vUI.UIVersion)
	Left:CreateDoubleLine(Language["Game Version"], vUI.GameVersion)
	Left:CreateDoubleLine(Language["Client"], GetClient())
	Left:CreateDoubleLine(Language["UI Scale"], Settings["ui-scale"])
	Left:CreateDoubleLine(Language["Suggested Scale"], vUI:GetSuggestedScale())
	Left:CreateDoubleLine(Language["Resolution"], vUI.ScreenResolution)
	Left:CreateDoubleLine(Language["Fullscreen"], vUI.IsFullScreen)
	Left:CreateDoubleLine(Language["Profile"], vUI:GetActiveProfileName())
	Left:CreateDoubleLine(Language["UI Style"], Settings["ui-style"])
	Left:CreateDoubleLine(Language["Locale"], vUI.UserLocale)
	--Left:CreateDoubleLine(Language["Language"], Settings["ui-language"])
	Left:CreateDoubleLine(Language["Display Errors"], GetCVar("scriptErrors"))
	
	Right:CreateHeader(Language["User Information"])
	Right:CreateDoubleLine(Language["Name"], vUI.UserName)
	Right:CreateDoubleLine(Language["Level"], UnitLevel("player"))
	Right:CreateDoubleLine(Language["Race"], vUI.UserRace)
	Right:CreateDoubleLine(Language["Class"], vUI.UserClassName)
	Right:CreateDoubleLine(Language["Realm"], vUI.UserRealm)
	Right:CreateDoubleLine(Language["Zone"], GetZoneText())
	Right:CreateDoubleLine(Language["Sub Zone"], GetMinimapZoneText())
	Right:CreateDoubleLine(Language["Quests"], GetQuests())
	
	Right:CreateHeader(Language["AddOns Information"])
	Right:CreateDoubleLine(Language["Total AddOns"], GetNumAddOns())
	Right:CreateDoubleLine(Language["Loaded AddOns"], GetNumLoadedAddOns())
end)

local UpdateDebugInfo = CreateFrame("Frame")
UpdateDebugInfo:RegisterEvent("ZONE_CHANGED")
UpdateDebugInfo:RegisterEvent("ZONE_CHANGED_INDOORS")
UpdateDebugInfo:RegisterEvent("ZONE_CHANGED_NEW_AREA")
UpdateDebugInfo:RegisterEvent("PLAYER_ENTERING_WORLD")
UpdateDebugInfo:RegisterEvent("QUEST_LOG_UPDATE")
UpdateDebugInfo:SetScript("OnEvent", function(self, event)
	if (event == "ADDON_LOADED") then
		GUI:GetWidgetByWindow(Language["Debug"], "loaded").Right:SetText(GetLoadedAddOns())
	elseif (event == "QUEST_LOG_UPDATE") then
		GUI:GetWidgetByWindow(Language["Debug"], "quests").Right:SetText(GetQuests())
	else
		GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
		GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
	end
end)

local Fonts = vUI:NewModule("Fonts")

function Fonts:Load()
	local Font = Media:GetFont(Settings["ui-widget-font"])
	
	UIErrorsFrame:SetFont(Font, 16)
	
	RaidWarningFrameSlot1:SetFont(Font, 16)
	RaidWarningFrameSlot2:SetFont(Font, 16)
	
	AutoFollowStatusText:SetFontInfo(Font, 18)
end

local BagsFrame = vUI:NewModule("Bags Frame")
local Move = vUI:GetModule("Move")

BagsFrame.Objects = {
	CharacterBag3Slot,
	CharacterBag2Slot,
	CharacterBag1Slot,
	CharacterBag0Slot,
	MainMenuBarBackpackButton,
}

local BagsFrameButtonOnEnter = function(self)
	if (Settings["bags-frame-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(1)
	end
end

local BagsFrameOnEnter = function(self)
	self:SetAlpha(1)
end

local BagsFrameButtonOnLeave = function(self)
	if (Settings["bags-frame-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(Settings["bags-frame-opacity"] / 100)
	end
end

local BagsFrameOnLeave = function(self)
	self:SetAlpha(Settings["bags-frame-opacity"] / 100)
end

function BagsFrame:UpdateVisibility()
	if (Settings["bags-frame-visiblity"] == "HIDE") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(0)
		self.Panel:Hide()
	elseif (Settings["bags-frame-visiblity"] == "MOUSEOVER") then
		self.Panel:SetScript("OnEnter", BagsFrameOnEnter)
		self.Panel:SetScript("OnLeave", BagsFrameOnLeave)
		self.Panel:SetAlpha(Settings["bags-frame-opacity"] / 100)
		self.Panel:Show()
	elseif (Settings["bags-frame-visiblity"] == "SHOW") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(1)
		self.Panel:Show()
	end
end

function BagsFrame:Load()
	local Panel = CreateFrame("Frame", "vUI Bags Window", UIParent)
	Panel:SetScaledSize(184, 40)
	Panel:SetScaledPoint("BOTTOMRIGHT", -10, 10)
	Panel:SetBackdrop(vUI.BackdropAndBorder)
	Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Panel:SetBackdropBorderColor(0, 0, 0)
	Panel:SetFrameStrata("LOW")
	Move:Add(Panel)
	
	self.Panel = Panel
	
	local Object
	
	for i = 1, #self.Objects do
		Object = self.Objects[i]
		
		Object:SetParent(Panel)
		Object:ClearAllPoints()
		Object:SetScaledSize(32, 32)
		Object:HookScript("OnEnter", BagsFrameButtonOnEnter)
		Object:HookScript("OnLeave", BagsFrameButtonOnLeave)
		
		local Name = Object:GetName()
		local Normal = _G[Name .. "NormalTexture"]
		local Count = _G[Name .. "Count"]
		local Stock = _G[Name .. "Stock"]
		
		if Normal then
			Normal:SetTexture(nil)
		end
		
		if Count then
			Count:ClearAllPoints()
			Count:SetScaledPoint("BOTTOMRIGHT", 0, 2)
			Count:SetJustifyH("RIGHT")
			Count:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
		end
		
		if Stock then
			Stock:ClearAllPoints()
			Stock:SetScaledPoint("TOPLEFT", 0, -2)
			Stock:SetJustifyH("LEFT")
			Stock:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
		end
		
		if Object.icon then
			Object.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		
		Object.BG = Object:CreateTexture(nil, "BACKGROUND")
		Object.BG:SetScaledPoint("TOPLEFT", Object, -1, 1)
		Object.BG:SetScaledPoint("BOTTOMRIGHT", Object, 1, -1)
		Object.BG:SetColorTexture(0, 0, 0)
		
		--[[local Checked = Object:CreateTexture(nil, "ARTWORK")
		Checked:SetScaledPoint("TOPLEFT", Object, 0, 0)
		Checked:SetScaledPoint("BOTTOMRIGHT", Object, 0, 0)
		Checked:SetColorTexture(0.1, 0.8, 0.1)
		Checked:SetAlpha(0.2)
		
		Object:SetCheckedTexture(Checked)]]
		
		local Highlight = Object:CreateTexture(nil, "ARTWORK")
		Highlight:SetScaledPoint("TOPLEFT", Object, 0, 0)
		Highlight:SetScaledPoint("BOTTOMRIGHT", Object, 0, 0)
		Highlight:SetColorTexture(1, 1, 1)
		Highlight:SetAlpha(0.2)
		
		Object:SetHighlightTexture(Highlight)
		
		local Pushed = Object:CreateTexture(nil, "ARTWORK", 7)
		Pushed:SetScaledPoint("TOPLEFT", Object, 0, 0)
		Pushed:SetScaledPoint("BOTTOMRIGHT", Object, 0, 0)
		Pushed:SetColorTexture(0.2, 0.9, 0.2)
		Pushed:SetAlpha(0.4)
		
		Object:SetPushedTexture(Pushed)
		
		if (i == 1) then
			Object:SetScaledPoint("LEFT", Panel, 4, 0)
		else
			Object:SetScaledPoint("LEFT", self.Objects[i-1], "RIGHT", 4, 0)
		end
	end
	
	self:UpdateVisibility()
end

local MicroButtons = vUI:NewModule("Micro Buttons")

MicroButtons.Buttons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	LFDMicroButton,
	CollectionsMicroButton,
	EJMicroButton,
	StoreMicroButton,
	MainMenuMicroButton,
}

local MicroButtonsButtonOnEnter = function(self)
	if (Settings["micro-buttons-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(1)
	end
end

local MicroButtonsButtonOnLeave = function(self)
	if (Settings["micro-buttons-visiblity"] == "MOUSEOVER") then
		self:GetParent():SetAlpha(0)
	end
end

function MicroButtons:UpdateVisibility()
	if (Settings["micro-buttons-visiblity"] == "HIDE") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(0)
		self.Panel:Hide()
	elseif (Settings["micro-buttons-visiblity"] == "MOUSEOVER") then
		self.Panel:SetScript("OnEnter", BagsFrameOnEnter)
		self.Panel:SetScript("OnLeave", BagsFrameOnLeave)
		self.Panel:SetAlpha(Settings["bags-frame-opacity"] / 100)
		self.Panel:Show()
	elseif (Settings["micro-buttons-visiblity"] == "SHOW") then
		self.Panel:SetScript("OnEnter", nil)
		self.Panel:SetScript("OnLeave", nil)
		self.Panel:SetAlpha(1)
		self.Panel:Show()
	end
end

function MicroButtons:Load()
	local Panel = CreateFrame("Frame", "vUI Micro Buttons", UIParent)
	Panel:SetScaledSize(232, 38)
	Panel:SetScaledPoint("BOTTOMRIGHT", BagsFrame.Panel, "BOTTOMLEFT", -2, 0)
	Panel:SetBackdrop(vUI.BackdropAndBorder)
	Panel:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Panel:SetBackdropBorderColor(0, 0, 0)
	Panel:SetFrameStrata("LOW")
	Move:Add(Panel)
	
	self.Panel = Panel
	
	local Button
	
	for i = 1, #self.Buttons do
		Button = self.Buttons[i]
		
		Button:SetParent(Panel)
		Button:ClearAllPoints()
		Button:HookScript("OnEnter", MicroButtonsButtonOnEnter)
		Button:HookScript("OnLeave", MicroButtonsButtonOnLeave)
		
		if (i == 1) then
			Button:SetScaledPoint("TOPLEFT", Panel, 0, 20)
		else
			Button:SetScaledPoint("LEFT", self.Buttons[i-1], "RIGHT", 0, 0)
		end
	end
	
	if (not Settings["micro-buttons-show"]) then
		Panel:Hide()
	end
	
	self:UpdateVisibility()
end

local AutoVendor = vUI:NewModule("Auto Vendor") -- Auto sell useless items

AutoVendor.Filter = {
	[6196] = true,
}

function vUI:GetTrashValue()
	local Profit = 0
	local TotalCount = 0
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID and not AutoVendor.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local SellPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))
				
				if ((SellPrice and (SellPrice > 0)) and Count) then
					TotalPrice = SellPrice * Count
				end
				
				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end
	
	return TotalCount, Profit
end

function AutoVendor:OnEvent()
	local Profit = 0
	local TotalCount = 0
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID and not self.Filter[ID]) then
				local TotalPrice = 0
				local Quality = select(3, GetItemInfo(Link))
				local SellPrice = select(11, GetItemInfo(Link))
				local Count = select(2, GetContainerItemInfo(Bag, Slot))
				
				if ((SellPrice and (SellPrice > 0)) and Count) then
					TotalPrice = SellPrice * Count
				end
				
				if ((Quality and Quality <= 0) and TotalPrice > 0) then
					UseContainerItem(Bag, Slot)
					PickupMerchantItem()
					Profit = Profit + TotalPrice
					TotalCount = TotalCount + Count
				end
			end
		end
	end
	
	if (Profit > 0 and Settings["auto-vendor-report"]) then
		vUI:print(format(Language["You sold %d %s for a total of %s"], TotalCount, TotalCount > 0 and "items" or "item", GetCoinTextureString(Profit)))
	end
end

function AutoVendor:Load()
	if Settings["auto-vendor-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", AutoVendor.OnEvent)
	end
end

local AutoRepair = vUI:NewModule("Auto Repair") -- Check against the rep with the faction of the merchant, add option to repair if honored +

function AutoRepair:OnEvent()
	local Money = GetMoney()
	
	if CanMerchantRepair() then
		local Cost = GetRepairAllCost()
		local CostString = GetCoinTextureString(Cost)
		
		if (Cost > 0) then
			if (Money > Cost) then
				RepairAllItems()
				
				if Settings["auto-repair-report"] then
					vUI:print(format(Language["Your equipped items have been repaired for %s"], CostString))
				end
			else
				local Required = Cost - Money
				local RequiredString = GetCoinTextureString(Required)
				
				if Settings["auto-repair-report"] then
					vUI:print(format(Language["You require %s to repair all equipped items (costs %s total)"], RequiredString, CostString))
				end
			end
		end
	end
end

function AutoRepair:Load()
	if Settings["auto-repair-enable"] then
		self:RegisterEvent("MERCHANT_SHOW")
		self:SetScript("OnEvent", AutoRepair.OnEvent)
	end
end

local UpdateMicroVisibility = function(value)
	MicroButtons:UpdateVisibility()
end

local UpdateBagVisibility = function()
	BagsFrame:UpdateVisibility()
end

local UpdateAutoVendor = function(value)
	if value then
		AutoVendor:RegisterEvent("MERCHANT_SHOW")
	else
		AutoVendor:UnregisterEvent("MERCHANT_SHOW")
	end
end

local UpdateAutoRepair = function(value)
	if value then
		AutoRepair:RegisterEvent("MERCHANT_SHOW")
	else
		AutoRepair:UnregisterEvent("MERCHANT_SHOW")
	end
end

local UpdateBagLooting = function(value)
	SetInsertItemsLeftToRight(value)
end

local Vehicle = vUI:NewModule("Vehicle")

function Vehicle:OnEnter()
	local R, G, B = vUI:HexToRGB(Settings["ui-widget-font-color"])
	
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
	GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, R, G, B)
	GameTooltip:Show()
end

function Vehicle:OnLeave()
	GameTooltip:Hide()
end

function Vehicle:OnEvent(event)
    if CanExitVehicle() then
        if UnitOnTaxi("player") then
            self.Text:SetText(TAXI_CANCEL_DESCRIPTION)
			
			self:SetScript("OnEnter", self.OnEnter)
			self:SetScript("OnLeave", self.OnLeave)
        else
            self.Text:SetText(LEAVE_VEHICLE)
			
			self:SetScript("OnEnter", nil)
			self:SetScript("OnLeave", nil)
        end
		
        self:Show()
		self.FadeIn:Play()
    else
		self.FadeOut:Play()
    end
end

function Vehicle:Exit()
    if UnitOnTaxi("player") then
        TaxiRequestEarlyLanding()
    else
        VehicleExit()
    end
	
	self.FadeOut:Play()
end

function Vehicle:Load()
	self.Button = CreateFrame("Button", "vUI Vehicle", UIParent)
	self.Button:SetScaledSize(Settings["minimap-size"] + 8, 22)
	self.Button:SetScaledPoint("TOP", _G["vUI Minimap"], "BOTTOM", 0, -2)
	self.Button:SetFrameStrata("HIGH")
	self.Button:SetFrameLevel(10)
	self.Button:SetBackdrop(vUI.BackdropAndBorder)
	self.Button:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Button:SetBackdropBorderColor(0, 0, 0)
	self.Button:SetScript("OnMouseUp", self.Exit)
	self.Button:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.Button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self.Button:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	self.Button:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self.Button:RegisterEvent("UNIT_EXITED_VEHICLE")
	self.Button:RegisterEvent("VEHICLE_UPDATE")
	self.Button:SetScript("OnEvent", self.OnEvent)
	
	self.Button.Texture = self.Button:CreateTexture(nil, "ARTWORK")
	self.Button.Texture:SetScaledPoint("TOPLEFT", self.Button, 1, -1)
	self.Button.Texture:SetScaledPoint("BOTTOMRIGHT", self.Button, -1, 1)
	self.Button.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Button.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	self.Button.Text = self.Button:CreateFontString(nil, "OVERLAY", 7)
	self.Button.Text:SetScaledPoint("CENTER", self.Button, 0, -1)
	self.Button.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"])
	self.Button.Text:SetScaledSize(self.Button:GetWidth() - 12, 20)
	
	self.Button.Fade = CreateAnimationGroup(self.Button)
	
	self.Button.FadeIn = self.Button.Fade:CreateAnimation("Fade")
	self.Button.FadeIn:SetEasing("in")
	self.Button.FadeIn:SetDuration(0.15)
	self.Button.FadeIn:SetChange(1)
	
	self.Button.FadeOut = self.Button.Fade:CreateAnimation("Fade")
	self.Button.FadeOut:SetEasing("out")
	self.Button.FadeOut:SetDuration(0.15)
	self.Button.FadeOut:SetChange(0)
	self.Button.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	if (not CanExitVehicle()) then
		self.Button:SetAlpha(0)
		self.Button:Hide()
	end
end

local BagSearch = vUI:NewModule("Bag Search")

local SearchOnTextChanged = function(self)
	local Text = self:GetText()
	
	if Text then
		SetItemSearch(Text)
	end
end

local SearchOnEnterPressed = function(self)
	self:ClearFocus()
	self:SetText("")
end

local SearchOnEditFocusLost = function(self)
	SetItemSearch("")
end

function BagSearch:Load()
	local Search = CreateFrame("EditBox", nil, ContainerFrame1, "InputBoxTemplate")
	Search:SetScaledPoint("TOPRIGHT", ContainerFrame1, -10, -24)
	Search:SetScaledSize(120, 30)
	Search:SetFrameLevel(ContainerFrame1:GetFrameLevel() + 10)
	Search:SetAutoFocus(false)
	Search:SetScript("OnTextChanged", SearchOnTextChanged)
	Search:SetScript("OnEnterPressed", SearchOnEnterPressed)
	Search:SetScript("OnEscapePressed", SearchOnEnterPressed)
	Search:SetScript("OnEditFocusLost", SearchOnEditFocusLost)
end

--[[ 
	Delete cheapest item
	clear item space when you need to make room for more important items
	To be fully implemented when I write my own bags module

--]]

local Delete = vUI:NewModule("Delete")

Delete.FilterIDs = {}
Delete.FilterClassIDs = {}

function Delete:UpdateFilterConsumable(value)
	self.FilterClassIDs[0] = value
end

function Delete:UpdateFilterContainer(value)
	self.FilterClassIDs[1] = value
end

function Delete:UpdateFilterWeapon(value)
	self.FilterClassIDs[2] = value
end

function Delete:UpdateFilterArmor(value)
	self.FilterClassIDs[4] = value
end

function Delete:UpdateFilterReagent(value)
	self.FilterClassIDs[5] = value
end

function Delete:UpdateFilterTradeskill(value)
	self.FilterClassIDs[7] = value
end

function Delete:UpdateFilterQuest(value)
	self.FilterClassIDs[12] = value
end

function Delete:EvaluateItem(link)
	local ItemType, ItemSubType, _, _, _, _, ClassID, SubClassID = select(6, GetItemInfo(link))
	local ID = match(link, ":(%w+)")
	
	if (self.FilterIDs[ID] or self.FilterClassIDs[ClassID]) then
		return
	end
	
	return true
end

function Delete:GetCheapestItem()
	local CheapestItem
	local CheapestValue
	local CheapestBag
	local CheapestSlot
	local CheapestCount
	
	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
			
			if (Link and ID) then
				local SellPrice = select(11, GetItemInfo(Link))
				
				if (SellPrice and (SellPrice > 0) and self:EvaluateItem(Link)) then
					local Count = select(2, GetContainerItemInfo(Bag, Slot))
					
					if Count then
						SellPrice = SellPrice * Count
					end
					
					if ((not CheapestValue) or (SellPrice < CheapestValue)) then
						CheapestItem = Link
						CheapestValue = SellPrice
						CheapestCount = Count
						CheapestBag = Bag
						CheapestSlot = Slot
					end
				end
			end
		end
	end
	
	return CheapestItem, CheapestValue, CheapestCount, CheapestBag, CheapestSlot
end

function Delete:PrintCheapestItem()
	local Item, Value, Count = self:GetCheapestItem()
	
	if (Item and Value) then
		if (Count > 1) then
			vUI:print(format(Language["The cheapest vendorable item in your inventory is currently %sx%s worth %s"], Item, Count, GetCoinTextureString(Value)))
		else
			vUI:print(format(Language["The cheapest vendorable item in your inventory is currently %s worth %s"], Item, GetCoinTextureString(Value)))
		end
	else
		vUI:print(Language["No valid items were found"])
	end
end

function Delete:DeleteCheapestItem()
	local Item, Value, Count, Bag, Slot = self:GetCheapestItem()
	
	if (Bag and Slot) then
		PickupContainerItem(Bag, Slot)
		DeleteCursorItem()
		
		if (Count > 1) then
			vUI:print(format(Language["Deleted %sx%s worth %s"], Item, Count, GetCoinTextureString(Value)))
		else
			vUI:print(format(Language["Deleted %s worth %s"], Item, GetCoinTextureString(Value)))
		end
	else
		vUI:print(Language["No valid items were found"])
	end
end

local UpdateDeleteFilterConsumable = function(value)
	Delete:UpdateFilterConsumable(value)
end

local UpdateFilterContainer = function(value)
	Delete:UpdateFilterContainer(value)
end

local UpdateFilterWeapon = function(value)
	Delete:UpdateFilterWeapon(value)
end

local UpdateFilterArmor = function(value)
	Delete:UpdateFilterArmor(value)
end

local UpdateFilterReagent = function(value)
	Delete:UpdateFilterReagent(value)
end

local UpdateFilterTradeskill = function(value)
	Delete:UpdateFilterTradeskill(value)
end

local UpdateFilterQuest = function(value)
	Delete:UpdateFilterQuest(value)
end

function Delete:Load()
	self:UpdateFilterConsumable(Settings["delete-filter-consumable"])
	self:UpdateFilterContainer(Settings["delete-filter-container"])
	self:UpdateFilterWeapon(Settings["delete-filter-weapon"])
	self:UpdateFilterArmor(Settings["delete-filter-armor"])
	self:UpdateFilterReagent(Settings["delete-filter-reagent"])
	self:UpdateFilterTradeskill(Settings["delete-filter-tradeskill"])
	self:UpdateFilterQuest(Settings["delete-filter-quest"])
end

local PrintCheapest = function()
	Delete:PrintCheapestItem()
end

local OnAccept = function(self)
	Delete:DeleteCheapestItem()
end

local DeleteCheapest = function()
	local Item, Value, Count = Delete:GetCheapestItem()
	
	if (Item and Count) then
		if (Count > 1) then
			vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure that you want to delete %sx%s?"], Item, Count), "Accept", OnAccept, "Cancel", nil)
		else
			vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure that you want to delete %s?"], Item), "Accept", OnAccept, "Cancel", nil)
		end
	end
end

local UpdateEnableCooldownFlash = function(value)
	local CD = vUI:GetModule("Cooldowns")
	
	if value then
		CD:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		CD:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	else
		CD:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
		CD:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end

local UpdateUIScale = function(value)
	value = tonumber(value)
	
	vUI:SetScale(value)
end

local RevertScaleChange = function()
	
end

local ScaleOnAccept = function()
	vUI:SetSuggestedScale()
end

local SetSuggestedScale = function()
	local Suggested = vUI:GetSuggestedScale()
	
	vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to the suggested setting of %s?"], Suggested), "Accept", ScaleOnAccept, "Cancel")
end

local UpdateGUIEnableFade = function(value)
	if value then
		GUI:RegisterEvent("PLAYER_STARTED_MOVING")
		GUI:RegisterEvent("PLAYER_STOPPED_MOVING")
	else
		GUI:UnregisterEvent("PLAYER_STARTED_MOVING")
		GUI:UnregisterEvent("PLAYER_STOPPED_MOVING")
		GUI:SetAlpha(1)
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["General"])
	
	Right:CreateHeader(Language["Settings Window"])
	Right:CreateSwitch("gui-hide-in-combat", Settings["gui-hide-in-combat"], Language["Hide In Combat"], "Hide the settings window when engaging in combat")
	Right:CreateSwitch("gui-enable-fade", Settings["gui-enable-fade"], Language["Fade While Moving"], "Fade out The settings window while moving", UpdateGUIEnableFade)
	Right:CreateSlider("gui-faded-alpha", Settings["gui-faded-alpha"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the settings window|n while faded"], nil, nil, "%")
	
	Right:CreateHeader(Language["Bags Frame"])
	Right:CreateDropdown("bags-frame-visiblity", Settings["bags-frame-visiblity"], {[Language["Hide"]] = "HIDE", [Language["Mouseover"]] = "MOUSEOVER", [Language["Show"]] = "SHOW"}, Language["Set Visibility"], "Set the visibility of the bag frame", UpdateBagVisibility)
	Right:CreateSlider("bags-frame-opacity", Settings["bags-frame-opacity"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the bags frame when|nvisiblity is set to Mouseover"], UpdateBagVisibility, nil, "%")
	Right:CreateSwitch("bags-loot-from-left", Settings["bags-loot-from-left"], Language["Loot Left To Right"], "When looting, new items will be|nplaced into the leftmost bag", UpdateBagLooting)
	
	Right:CreateHeader(Language["Micro Menu Buttons"])
	Right:CreateDropdown("micro-buttons-visiblity", Settings["micro-buttons-visiblity"], {[Language["Hide"]] = "HIDE", [Language["Mouseover"]] = "MOUSEOVER", [Language["Show"]] = "SHOW"}, Language["Set Visibility"], "Set the visibility of the micro menu buttons", UpdateMicroVisibility)
	Right:CreateSlider("micro-buttons-opacity", Settings["micro-buttons-opacity"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the micro menu buttons|n when visiblity is set to Mouseover"], UpdateMicroVisibility, nil, "%")
	
	Left:CreateHeader(Language["Inventory"])
	Left:CreateButton(Language["Search"], Language["Find Cheapest Item"], "Find the cheapest item|ncurrently in your inventory", PrintCheapest)
	Left:CreateButton(Language["Delete"], Language["Delete Cheapest Item"], "Delete the cheapest item|ncurrently in your inventory", DeleteCheapest)
	Left:CreateSwitch("delete-filter-consumable", Settings["delete-filter-consumable"], Language["Filter Consumables"], "Exclude consumables", UpdateDeleteFilterConsumable)
	Left:CreateSwitch("delete-filter-container", Settings["delete-filter-container"], Language["Filter Containers"], "Exclude container items", UpdateFilterContainer)
	Left:CreateSwitch("delete-filter-weapon", Settings["delete-filter-weapon"], Language["Filter Weapons"], "Exclude weapons items", UpdateFilterWeapon)
	Left:CreateSwitch("delete-filter-armor", Settings["delete-filter-armor"], Language["Filter Armor"], "Exclude armor items", UpdateFilterArmor)
	Left:CreateSwitch("delete-filter-reagent", Settings["delete-filter-reagent"], Language["Filter Reagents"], "Exclude reagent related items", UpdateFilterReagent)
	Left:CreateSwitch("delete-filter-tradeskill", Settings["delete-filter-tradeskill"], Language["Filter Tradeskills"], "Exclude tradeskill related items", UpdateFilterTradeskill)
	Left:CreateSwitch("delete-filter-quest", Settings["delete-filter-quest"], Language["Filter Quest Items"], "Exclude quest related items", UpdateFilterQuest)
	
	Right:CreateHeader(Language["Merchant"])
	Right:CreateSwitch("auto-repair-enable", Settings["auto-repair-enable"], Language["Auto Repair Equipment"], "Automatically repair damaged items|nwhen visiting a repair merchant", UpdateAutoRepair)
	Right:CreateSwitch("auto-repair-report", Settings["auto-repair-report"], Language["Auto Repair Report"], "Report the cost of automatic repairs into the chat")
	Right:CreateSwitch("auto-vendor-enable", Settings["auto-vendor-enable"], Language["Auto Vendor Greys"], "Automatically sell all |cFF9D9D9D[Poor]|r quality items", UpdateAutoVendor)
	Right:CreateSwitch("auto-vendor-report", Settings["auto-vendor-report"], Language["Auto Vendor Report"], "Report the profit of automatic vendoring into the chat")
	
	Right:CreateHeader(Language["Interrupt Announcements"])
	Right:CreateSwitch("announcements-enable", Settings["announcements-enable"], Language["Enable Announcements"], "Announce to the selected channel when you|n successfully perform an interrupt spell", ReloadUI):RequiresReload(true)
	Right:CreateDropdown("announcements-channel", Settings["announcements-channel"], {[Language["Self"]] = "SELF", [Language["Say"]] = "SAY", [Language["Group"]] = "GROUP", [Language["Emote"]] = "EMOTE"}, Language["Set Channel"], "Set the channel to announce to")
	
	Right:CreateHeader(Language["Cooldown Flash"])
	Right:CreateSwitch("cooldowns-enable", Settings["cooldowns-enable"], Language["Enable Cooldown Flash"], "When an ability comes off cooldown|n the icon will flash as an alert", UpdateEnableCooldownFlash)
	
	Right:CreateHeader(Language["Scale"])
	--Right:CreateLine("|cFFE81123Do not use this to resize UI elements|r")
	Right:CreateInput("ui-scale", Settings["ui-scale"], Language["Set UI Scale"], "Set the scale for the UI", UpdateUIScale)
	Right:CreateButton(Language["Apply"], Language["Set Suggested Scale"], Language["Apply the scale recommended based on your resolution"], SetSuggestedScale)
	
	SetInsertItemsLeftToRight(Settings["bags-loot-from-left"])
end)

local MirrorTimerColors = {
	["EXHAUSTION"] = "FFE500",
	["BREATH"] = "007FFF",
	["DEATH"] = "FFB200",
	["FEIGNDEATH"] = "FFB200",
}

local MirrorTimers = vUI:NewModule("Mirror Timers")

local MirrorTimersOnUpdate = function(self)
	if self.Paused then
		return
	end
	
	self.Value = GetMirrorTimerProgress(self.Timer) / 1000
	
	if (self.Value > 0) then
		self.Text:SetText(format("%s (%s)", self.Label, vUI:FormatTime(self.Value)))
	else
		self.Text:SetText(format("%s", self.Label))
	end
	
	self:SetValue(self.Value)
end

function MirrorTimers:MIRROR_TIMER_PAUSE(ispaused)
	if ispaused then
		self.Bar.Paused = true
	else
		self.Bar.Paused = false
	end
end

function MirrorTimers:MIRROR_TIMER_STOP()
	self.Bar:Hide()
end

local GetMirrorTimerProgress = GetMirrorTimerProgress
local GetMirrorTimerInfo = GetMirrorTimerInfo

MirrorTimers.MirrorTimer_Show = function(timer, value, maxvalue, scale, paused, label)
	MirrorTimers.Bar.Max = maxvalue
	MirrorTimers.Bar.Value = value
	MirrorTimers.Bar.Timer = timer
	MirrorTimers.Bar.Label = label
	
	MirrorTimers.Bar:SetMinMaxValues(0, maxvalue / 1000)
	MirrorTimers.Bar:SetValue(value)
	MirrorTimers.Bar:SetStatusBarColorHex(MirrorTimerColors[timer])
	MirrorTimers.BarBG:SetVertexColorHex(MirrorTimerColors[timer])
	MirrorTimers.Bar.Text:SetText(format("%s (%s)", label, vUI:FormatTime(value / 1000)))
	MirrorTimers.Bar:Show()
end

function MirrorTimers:Load()
	self.Bar = CreateFrame("StatusBar", "vUI Timers Bar", UIParent)
	self.Bar:SetScaledPoint("TOP", UIParent, 0, -120)
	self.Bar:SetScaledSize(210, 20)
	self.Bar:SetFrameLevel(5)
	self.Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.Bar:SetScript("OnUpdate", MirrorTimersOnUpdate)
	self.Bar:Hide()
	
	self.BarBG = self.Bar:CreateTexture(nil, "BORDER")
	self.BarBG:SetScaledPoint("TOPLEFT", self.Bar, 0, 0)
	self.BarBG:SetScaledPoint("BOTTOMRIGHT", self.Bar, 0, 0)
	self.BarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	self.BarBG:SetAlpha(0.2)
	
	self.Bar.Text = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Bar.Text:SetScaledPoint("CENTER", self.Bar, 0, 0)
	self.Bar.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	self.Bar.Text:SetJustifyH("CENTER")
	
	self.BarOutline = self.Bar:CreateTexture(nil, "BORDER")
	self.BarOutline:SetScaledPoint("TOPLEFT", self.Bar, -1, 1)
	self.BarOutline:SetScaledPoint("BOTTOMRIGHT", self.Bar, 1, -1)
	self.BarOutline:SetTexture(Media:GetTexture("Blank"))
	self.BarOutline:SetVertexColor(0, 0, 0)
	
	self.OuterBG = CreateFrame("Frame", nil, self.Bar)
	self.OuterBG:SetScaledPoint("TOPLEFT", self.Bar, -4, 4)
	self.OuterBG:SetScaledPoint("BOTTOMRIGHT", self.Bar, 4, -4)
	self.OuterBG:SetBackdrop(vUI.BackdropAndBorder)
	self.OuterBG:SetBackdropBorderColor(0, 0, 0)
	self.OuterBG:SetFrameLevel(1)
	self.OuterBG:SetFrameStrata("BACKGROUND")
	self.OuterBG:SetBackdropColorHex(Settings["ui-window-bg-color"])
	
	self:Hook("MirrorTimer_Show")
	
	self:RegisterEvent("MIRROR_TIMER_PAUSE")
	self:RegisterEvent("MIRROR_TIMER_STOP")
	
	self.Hider = CreateFrame("Frame", nil, UIParent)
	self.Hider:Hide()
	
	vUI:GetModule("Move"):Add(self.Bar, 6)
	
	for i = 1, MIRRORTIMER_NUMTIMERS do
		_G["MirrorTimer" .. i]:SetParent(self.Hider)
	end
end

MirrorTimers:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)

--[[local WorldMap = vUI:NewModule("World Map")

function WorldMap:Load()
	WorldMapMagnifyingGlassButton:Hide()
	WorldMapFrame.BlackoutFrame:Hide()
	WorldMapFrame.BorderFrame:Hide()
	WorldMapFrame:SetScaledSize(800, 600)
end]]
--[[
local AutoDismount = vUI:NewModule("Dismount")

local DismountErrors = {
	[50] = SPELL_FAILED_NOT_MOUNTED,
	[198] = ERR_ATTACK_MOUNTED,
	[213] = ERR_TAXIPLAYERALREADYMOUNTED,
}

function AutoDismount:UI_ERROR_MESSAGE(id)
	if DismountErrors[id] then
		Dismount()
	end
end

function AutoDismount:TAXIMAP_OPENED()
	Dismount()
end

local AutoDismountOnEvent = function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function AutoDismount:Load()
	self:RegisterEvent("UI_ERROR_MESSAGE")
	self:RegisterEvent("TAXIMAP_OPENED")
	self:SetScript("OnEvent", AutoDismountOnEvent)
end]]

--[[for k, v in pairs(_G) do
	if (v and type(v) == "string") then
		if v:find("Can't attack while mounted") then
			print(k, v)
		end
	end
end]]
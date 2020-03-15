local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

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
	local Left, Right = self:CreateWindow(Language["Debug"], nil, "zzzDebug")
	
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

GUI:AddOptions(function(self)
	self:CreateSpacer("ZZZ")
	
	local Left, Right = self:CreateWindow(Language["Credits"], nil, "zzzCredits")
	
	Left:CreateHeader(Language["Scripting Help & Mentoring"])
	Left:CreateDoubleLine("Tukz", "Elv")
	Left:CreateDoubleLine("nightcracker", "Simpy")
	Left:CreateDoubleLine("Smelly", "Azilroka")
	Left:CreateDoubleLine("Foof", "Eclipse")
	
	Left:CreateHeader(Language["oUF"])
	Left:CreateDoubleLine("Haste", "lightspark")
	Left:CreateDoubleLine("p3lim", "Rainrider")
	
	Right:CreateHeader(Language["LibStub"])
	Right:CreateDoubleLine("Kaelten", "CtlAltDelAmmo")
	Right:CreateDoubleLine("jnwhiteh", "nevcairiel")
	Right:CreateDoubleLine("mikeclueby4", "")
	
	Right:CreateHeader(Language["LibSharedMedia"])
	Right:CreateDoubleLine("Elkano", "funkehdude")
end)

local Fonts = vUI:NewModule("Fonts")

_G.STANDARD_TEXT_FONT = Media:GetFont("PT Sans")
_G.UNIT_NAME_FONT = Media:GetFont("PT Sans")
_G.DAMAGE_TEXT_FONT = Media:GetFont("PT Sans")

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
	
	Left:CreateHeader(Language["Merchant"])
	Left:CreateSwitch("auto-repair-enable", Settings["auto-repair-enable"], Language["Auto Repair Equipment"], "Automatically repair damaged items|nwhen visiting a repair merchant", UpdateAutoRepair)
	Left:CreateSwitch("auto-repair-report", Settings["auto-repair-report"], Language["Auto Repair Report"], "Report the cost of automatic repairs into the chat")
	Left:CreateSwitch("auto-vendor-enable", Settings["auto-vendor-enable"], Language["Auto Vendor Greys"], "Automatically sell all |cFF9D9D9D[Poor]|r quality items", UpdateAutoVendor)
	Left:CreateSwitch("auto-vendor-report", Settings["auto-vendor-report"], Language["Auto Vendor Report"], "Report the profit of automatic vendoring into the chat")
	
	-- Janky times ahead
	if IsInGuild() then
		GuildControlSetRank(select(3, GetGuildInfo("player")))
		
		local DailyMax = GetGuildBankWithdrawGoldLimit() or 0
		print(DailyMax)
		local Bar = Left:CreateStatusBar(0, 0, DailyMax, Language["Guild Repair"], Language["The amount of gold you have remaining for your daily guild repairs"])
	end
	
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
--[[
local IconSize = 40
local IconHeight = floor(IconSize * 0.6)
local IconRatio = (1 - (IconHeight / IconSize)) / 2

local Icon = CreateFrame("Frame", nil, UIParent)
Icon:SetScaledPoint("CENTER")
Icon:SetScaledSize(IconSize, IconHeight)
Icon:SetBackdrop(vUI.Backdrop)
Icon:SetBackdropColor(0, 0, 0)

Icon.t = Icon:CreateTexture(nil, "OVERLAY")
Icon.t:SetScaledPoint("TOPLEFT", Icon, 1, -1)
Icon.t:SetScaledPoint("BOTTOMRIGHT", Icon, -1, 1)
Icon.t:SetTexture("Interface\\ICONS\\spell_warlock_soulburn")
Icon.t:SetTexCoord(0.1, 0.9, 0.1 + IconRatio, 0.9 - IconRatio)]]
local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Tooltips = HydraUI:NewModule("Tooltips")

-- Default settings values
Defaults["tooltips-enable"] = true
Defaults["tooltips-on-cursor"] = false
Defaults["tooltips-show-id"] = false
Defaults["tooltips-display-realm"] = true
Defaults["tooltips-display-title"] = true
Defaults["tooltips-display-rank"] = false
Defaults["tooltips-font"] = "Roboto"
Defaults["tooltips-font-size"] = 12
Defaults["tooltips-font-flags"] = ""
Defaults["tooltips-hide-on-unit"] = "NEVER"
Defaults["tooltips-hide-on-item"] = "NEVER"
Defaults["tooltips-hide-on-action"] = "NEVER"
Defaults["tooltips-health-bar-height"] = 15
Defaults["tooltips-show-health-text"] = true
Defaults["tooltips-show-target"] = true
Defaults["tooltips-cursor-anchor"] = "ANCHOR_CURSOR"
Defaults["tooltips-cursor-anchor-x"] = 0
Defaults["tooltips-cursor-anchor-y"] = 8
Defaults["tooltips-show-health"] = true
Defaults["tooltips-show-price"] = true

local select = select
local find = string.find
local match = string.match
local floor = floor
local format = format
local UnitPVPName = UnitPVPName
local UnitReaction = UnitReaction
local UnitExists = UnitExists
local UnitClass = UnitClass
local GetGuildInfo = GetGuildInfo
local UnitCreatureType = UnitCreatureType
local UnitLevel = UnitLevel
local UnitRace = UnitRace
local UnitName = UnitName
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClassification = UnitClassification
local GetPetHappiness = GetPetHappiness
local GetMouseFocus = GetMouseFocus
local GetItemInfo = GetItemInfo
local InCombatLockdown = InCombatLockdown
local UnitPlayerControlled = UnitPlayerControlled
local UnitCanAttack = UnitCanAttack
local UnitIsPVP = UnitIsPVP

local GameTooltipStatusBar = GameTooltipStatusBar
local MyGuild

Tooltips.Handled = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	--AutoCompleteBox,
	FriendsTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	EmbeddedItemTooltip,
}

Tooltips.Classifications = {
	["rare"] = Language["|cFFBDBDBDRare|r"],
	["elite"] = Language["|cFFFDD835Elite|r"],
	["rareelite"] = Language["|cFFBDBDBDRare Elite|r"],
	["worldboss"] = Language["Boss"],
}

Tooltips.HappinessLevels = {
	[1] = Language["Unhappy"],
	[2] = Language["Content"],
	[3] = Language["Happy"]
}

function Tooltips:UpdateFonts(tooltip)
	for i = 1, tooltip:GetNumRegions() do
		local Region = select(i, tooltip:GetRegions())
		
		if (Region:GetObjectType() == "FontString") then
			HydraUI:SetFontInfo(Region, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
		end
	end
	
	for i = 1, tooltip:GetNumChildren() do
		local Child = select(i, tooltip:GetChildren())
		
		if (Child and Child.GetName and Child:GetName() ~= nil and find(Child:GetName(), "MoneyFrame")) then
			local Prefix = _G[Child:GetName() .. "PrefixText"]
			local Suffix = _G[Child:GetName() .. "SuffixText"]
			
			if Prefix then
				HydraUI:SetFontInfo(Prefix, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
			end
			
			if Suffix then
				HydraUI:SetFontInfo(Suffix, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
			end
		end
	end
	
	if tooltip.numMoneyFrames then
		local MoneyFrame
		
		for i = 1, tooltip.numMoneyFrames do
			MoneyFrame = _G[tooltip:GetName() .. "MoneyFrame" .. i]
			
			if MoneyFrame then
				for j = 1, MoneyFrame:GetNumChildren() do
					local Region = select(j, MoneyFrame:GetChildren())
					
					if (Region and Region.GetName and Region:GetName()) then
						local Text = _G[Region:GetName() .. "Text"]
						
						if Text then
							HydraUI:SetFontInfo(Text, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
						end
					end
				end
			end
		end
	end
	
	self:UpdateStatusBarFonts()
end

local SetTooltipStyle = function(self)
	self:SetBackdrop(nil) -- To stop blue tooltips

	if self.Styled then
		self.OuterBG:ClearAllPoints()
		self.OuterBG:SetPoint("BOTTOMRIGHT", self, 3, -3)
	
		if (self.GetUnit and self:GetUnit() and Settings["tooltips-show-health"]) then
			self.OuterBG:SetPoint("TOPLEFT", GameTooltipStatusBar, -4, 4)
		else
			self.OuterBG:SetPoint("TOPLEFT", self, -3, 3)
		end
		
		Tooltips:UpdateFonts(self)
	else
		self:SetFrameLevel(10)
		self.SetFrameLevel = function() end
		
		self.Backdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
		self.Backdrop:SetAllPoints(self)
		self.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
		self.Backdrop:SetBackdropBorderColor(0, 0, 0)
		self.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
		self.Backdrop:SetFrameStrata("TOOLTIP")
		self.Backdrop:SetFrameLevel(2)
		
		self.OuterBG = CreateFrame("Frame", nil, self, "BackdropTemplate")
		--self.OuterBG:SetPoint("TOPLEFT", self, -3, 3)
		self.OuterBG:SetPoint("BOTTOMRIGHT", self, 3, -3)
		self.OuterBG:SetBackdrop(HydraUI.BackdropAndBorder)
		self.OuterBG:SetBackdropBorderColor(0, 0, 0)
		self.OuterBG:SetFrameStrata("TOOLTIP")
		self.OuterBG:SetFrameLevel(1)
		self.OuterBG:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
		
		if (self.GetUnit and self:GetUnit() and Settings["tooltips-show-health"]) then
			self.OuterBG:SetPoint("TOPLEFT", GameTooltipStatusBar, -4, 4)
		else
			self.OuterBG:SetPoint("TOPLEFT", self, -3, 3)
		end
		
		if (self == AutoCompleteBox) then
			for i = 1, AUTOCOMPLETE_MAX_BUTTONS do
				local Text = _G["AutoCompleteButton" .. i .. "Text"]
				
				HydraUI:SetFontInfo(Text, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
			end
			
			HydraUI:SetFontInfo(AutoCompleteInstructions, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
			
			AutoCompleteBox.Backdrop:SetFrameStrata("DIALOG")
			AutoCompleteBox.OuterBG:SetFrameStrata("DIALOG")
		end
		
		Tooltips:UpdateFonts(self)
		
		self.Styled = true
	end
end

local GetUnitColor = function(unit)
	local Color
	
	if UnitIsPlayer(unit) then
		local Class = select(2, UnitClass(unit))
		
		if Class then
			Color = HydraUI.ClassColors[Class]
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			Color = HydraUI.ReactionColors[Reaction]
		end
	end
	
	if Color then
		return HydraUI:RGBToHex(Color[1], Color[2], Color[3])
	else
		return "FFFFFF"
	end
end

local FilterUnit = function(unit)
	local State
	
	if UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			if (not UnitCanAttack("player", unit)) then
				State = 1
			else
				State = 2
			end
		elseif UnitCanAttack("player", unit) then
			State = 1
		elseif UnitIsPVP(unit) then
			State = 1
		else
			State = 1
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			if (Reaction >= 4) then
				State = 1
			else
				State = 2
			end
		else
			State = 1
		end
	end
	
	if (Settings["tooltips-hide-on-unit"] == "FRIENDLY" and State == 1) then
		return true
	elseif (Settings["tooltips-hide-on-unit"] == "HOSTILE" and State == 2) then
		return true
	end
end

local OnTooltipSetUnit = function(self)
	if (Settings["tooltips-hide-on-unit"] == "NO_COMBAT" and InCombatLockdown()) or Settings["tooltips-hide-on-unit"] == "ALWAYS" then
		self:Hide()
		
		return
	end
	
	local Unit, UnitID = self:GetUnit()
	
	if UnitID then
		local Class = UnitClass(UnitID)
		
		if (not Class) then
			return
		end
		
		if FilterUnit(UnitID) then
			self:Hide()
			return
		end
		
		local Name, Realm = UnitName(UnitID)
		local Race = UnitRace(UnitID)
		local Level = UnitLevel(UnitID)
		local Title = UnitPVPName(UnitID)
		local Guild, Rank = GetGuildInfo(UnitID)
		local Color = GetUnitColor(UnitID)
		local CreatureType = UnitCreatureType(UnitID)
		local Classification = Tooltips.Classifications[UnitClassification(UnitID)]
		local Flag = ""
		local Line
		
		if (Class == Name) then
			Class = ""
		end
		
		GameTooltipStatusBar:SetStatusBarColor(HydraUI:HexToRGB(Color))
		GameTooltipStatusBar.BG:SetVertexColor(HydraUI:HexToRGB(Color))
		
		local LevelColor = GetQuestDifficultyColor(Level)
		local Hex = HydraUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)
		
		if (Level == -1) then
			Level = "??"
		end
		
		Level = format("|cFF%s%s|r", Hex, Level)
		
		--[[if CanInspect(UnitID) then
			if self.GUID then
				if UnitGUID(UnitID) == self.GUID then
					print(UnitName())
				end
			else
				Tooltips.Unit = UnitID
				NotifyInspect(UnitID)
			end
		end]]
		
		if UnitIsAFK(UnitID) then
			Flag = "|cFFFDD835" .. CHAT_FLAG_AFK .. "|r "
		elseif UnitIsDND(UnitID) then 
			Flag = "|cFFF44336" .. CHAT_FLAG_DND .. "|r "
		end
		
		if (Realm and Realm ~= "" and Settings["tooltips-display-realm"]) then
			GameTooltipTextLeft1:SetText(format("%s|cFF%s%s - %s|r", Flag, Color, (Settings["tooltips-display-title"] and Title or Name), Realm))
		else
			GameTooltipTextLeft1:SetText(format("%s|cFF%s%s|r", Flag, Color, (Settings["tooltips-display-title"] and Title or Name)))
		end
		
		for i = 2, self:NumLines() do
			Line = _G["GameTooltipTextLeft" .. i]
			
			if (Line and Line.GetText and find(Line:GetText(), "^" .. LEVEL)) then
				if Race then
					Line:SetText(format("%s %s|r %s %s", LEVEL, Level, Race, Class))
				elseif CreatureType then
					if Classification then
						Line:SetText(format("%s %s|r %s %s", LEVEL, Level, Classification, CreatureType))
					else
						Line:SetText(format("%s %s|r %s", LEVEL, Level, CreatureType))
					end
				else
					Line:SetText(format("%s %s|r %s", LEVEL, Level, Class))
				end
			elseif (Line and find(Line:GetText(), PVP)) then
				Line:SetText(format("|cFFEE4D4D%s|r", PVP))
			elseif Line and Guild and find(Line:GetText(), Guild) then
				if (Guild == MyGuild) then
					if Settings["tooltips-display-rank"] then
						Guild = format("|cFF5DADE2<%s>|r (%s)", Guild, Rank)
					else
						Guild = format("|cFF5DADE2<%s>|r", Guild)
					end
				else
					if Settings["tooltips-display-rank"] then
						Guild = format("|cFF66BB6A<%s>|r (%s)", Guild, Rank)
					else
						Guild = format("|cFF66BB6A<%s>|r", Guild)
					end
				end
				
				Line:SetText(Guild)
			end
		end

		if (Settings["tooltips-show-target"] and (UnitID ~= "player" and UnitExists(UnitID .. "target"))) then
			local TargetColor = GetUnitColor(UnitID .. "target")
			
			self:AddLine(Language["Targeting: |cFF"] .. TargetColor .. UnitName(UnitID .. "target") .. "|r", 1, 1, 1)
		end
		
		if (HydraUI.UserClass == "HUNTER" and UnitID == "pet") then
			local Happiness = GetPetHappiness()
			
			if Happiness then
				local Color = HydraUI.HappinessColors[Happiness]
				
				if Color then
					self:AddDoubleLine(Language["Happiness:"], format("|cFF%s%s|r", HydraUI:RGBToHex(Color[1], Color[2], Color[3]), Tooltips.HappinessLevels[Happiness]))
				end
			end
		end
	end
end

local OnTooltipSetItem = function(self)
	if (Settings["tooltips-hide-on-item"] == "NO_COMBAT" and InCombatLockdown()) or Settings["tooltips-hide-on-item"] == "ALWAYS" then
		self:Hide()
		
		return
	end
	
	if (MerchantFrame and MerchantFrame:IsShown()) then
		return
	end
	
	local Link = select(2, self:GetItem())
	
	if (not Link) then
		return
	end
	
	self:SetBackdrop(nil)
	
	if Settings["tooltips-show-price"] then
		local VendorPrice = select(11, GetItemInfo(Link))
		
		if VendorPrice then
			local Count = 1
			local MouseFocus = GetMouseFocus()

			if (MouseFocus and MouseFocus.count) then
				Count = MouseFocus.count
			end

			if (Count and type(Count) == "number") then
				local CopperValue = VendorPrice * Count

				if (CopperValue > 0) then
					local CoinString = GetCoinTextureString(CopperValue)

					if CoinString then
						self:AddLine(CoinString, 1, 1, 1)
					end
				end
			end
		end
	end
	
	if Settings["tooltips-show-id"] then
		local ID = match(Link, ":(%w+)")
		
		self:AddLine(" ")
		self:AddDoubleLine(Language["Item ID:"], ID, 1, 1, 1, 1, 1, 1)
	end
end

local OnItemRefTooltipSetItem = function(self)
	local Link = select(2, self:GetItem())
	
	if (not Link) then
		return
	end
	
	if Settings["tooltips-show-id"] then
		local ID = match(Link, ":(%w+)")
		
		self:AddLine(" ")
		self:AddDoubleLine(Language["Item ID:"], ID, 1, 1, 1, 1, 1, 1)
	end
end

local OnTooltipSetSpell = function(self)
	if (Settings["tooltips-hide-on-action"] == "NO_COMBAT" and InCombatLockdown()) or Settings["tooltips-hide-on-action"] == "ALWAYS" then
		self:Hide()
		
		return
	end
	
	if (not Settings["tooltips-show-id"]) then
		return
	end
	
	local ID = select(2, self:GetSpell())
	
	self:AddLine(" ")
	self:AddDoubleLine(Language["Spell ID:"], ID, 1, 1, 1, 1, 1, 1)
end

Tooltips.GameTooltip_SetDefaultAnchor = function(self, parent)
	if Settings["tooltips-on-cursor"] then
		self:SetOwner(parent, Settings["tooltips-cursor-anchor"], Settings["tooltips-cursor-anchor-x"], Settings["tooltips-cursor-anchor-y"])
		
		return
	end
	
	local Unit, UnitID = self:GetUnit()
	
	if (not UnitID) then
		local MouseFocus = GetMouseFocus()
		
		if (MouseFocus and MouseFocus.GetAttribute and MouseFocus:GetAttribute("unit")) then
			UnitID = MouseFocus:GetAttribute("unit")
		end
	end
	
	if (not UnitID and UnitExists("mouseover")) then
		UnitID = "mouseover"
	end
	
	self:ClearAllPoints()
	
	if Settings["right-window-enable"] then
		self:SetPoint("BOTTOMLEFT", Tooltips, 3, 3)
	else
		self:SetPoint("BOTTOMRIGHT", Tooltips, 3, 3)
	end
end

function Tooltips:AddHooks()
	for i = 1, #self.Handled do
		self.Handled[i]:HookScript("OnShow", SetTooltipStyle)
	end
	
	GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
	GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
	GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
	ItemRefTooltip:HookScript("OnTooltipSetItem", OnItemRefTooltipSetItem)
	
	self:Hook("GameTooltip_SetDefaultAnchor")
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local OnValueChanged = function(self)
	local Unit = select(2, self:GetParent():GetUnit())
	
	if (not Unit) then
		return
	end
	
	local Color = GetUnitColor(Unit)
	
	if Settings["tooltips-show-health-text"] then
		local Current = self:GetValue()
		local Max = select(2, self:GetMinMaxValues())
		
		if (Max == 0) then
			if UnitIsDead(Unit) then
				self.HealthValue:SetText("|cFFD64545" .. Language["Dead"] .. "|r")
			elseif UnitIsGhost(Unit) then
				self.HealthValue:SetText("|cFFEEEEEE" .. Language["Ghost"] .. "|r")
			else
				self.HealthValue:SetText(" ")
				self.HealthPercent:SetText(" ")
			end
		else
			if UnitIsDead(Unit) then
				self.HealthValue:SetText("|cFFD64545" .. Language["Dead"] .. "|r")
			elseif UnitIsGhost(Unit) then
				self.HealthValue:SetText("|cFFEEEEEE" .. Language["Ghost"] .. "|r")
			else
				self.HealthValue:SetText(format("%s / %s", Current, Max))
			end
			
			self.HealthPercent:SetText(format("%s%%", floor((Current / Max * 100 + 0.05) * 10) / 10))
		end
	end
	
	self:SetStatusBarColor(HydraUI:HexToRGB(Color))
	self.BG:SetVertexColor(HydraUI:HexToRGB(Color))
end

local OnShow = function(self)
	if (not Settings["tooltips-show-health"]) then
		GameTooltipStatusBar:Hide()
		
		return
	end
	
	OnValueChanged(self)
end

function Tooltips:UpdateStatusBarFonts()
	HydraUI:SetFontInfo(GameTooltipStatusBar.HealthValue, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	HydraUI:SetFontInfo(GameTooltipStatusBar.HealthPercent, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
end

function Tooltips:StyleStatusBar()
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetHeight(Settings["tooltips-health-bar-height"])
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltipStatusBar:GetParent(), "TOPLEFT", 1, 3)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar:GetParent(), "TOPRIGHT", -1, 3)
	GameTooltipStatusBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	GameTooltipStatusBar.BG = GameTooltipStatusBar:CreateTexture(nil, "ARTWORK")
	GameTooltipStatusBar.BG:SetPoint("TOPLEFT", GameTooltipStatusBar, 0, 0)
	GameTooltipStatusBar.BG:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar, 0, 0)
	GameTooltipStatusBar.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	GameTooltipStatusBar.BG:SetAlpha(0.2)
	
	GameTooltipStatusBar.Backdrop = CreateFrame("Frame", nil, GameTooltipStatusBar, "BackdropTemplate")
	GameTooltipStatusBar.Backdrop:SetPoint("TOPLEFT", GameTooltipStatusBar, -1, 1)
	GameTooltipStatusBar.Backdrop:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar, 1, -1)
	GameTooltipStatusBar.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	GameTooltipStatusBar.Backdrop:SetBackdropColor(0, 0, 0)
	GameTooltipStatusBar.Backdrop:SetBackdropBorderColor(0, 0, 0)
	GameTooltipStatusBar.Backdrop:SetFrameLevel(GameTooltipStatusBar:GetFrameLevel() - 1)
	
	GameTooltipStatusBar.HealthValue = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(GameTooltipStatusBar.HealthValue, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	GameTooltipStatusBar.HealthValue:SetPoint("LEFT", GameTooltipStatusBar, 3, 0)
	GameTooltipStatusBar.HealthValue:SetJustifyH("LEFT")
	
	GameTooltipStatusBar.HealthPercent = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(GameTooltipStatusBar.HealthPercent, Settings["tooltips-font"], Settings["tooltips-font-size"], Settings["tooltips-font-flags"])
	GameTooltipStatusBar.HealthPercent:SetPoint("RIGHT", GameTooltipStatusBar, -3, 0)
	GameTooltipStatusBar.HealthPercent:SetJustifyH("RIGHT")
	
	GameTooltipStatusBar:HookScript("OnValueChanged", OnValueChanged)
	GameTooltipStatusBar:HookScript("OnShow", OnShow)
end

local ItemRefCloseOnEnter = function(self)
	self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B"))
end

local ItemRefCloseOnLeave = function(self)
	self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
end

local ItemRefCloseOnMouseUp = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	ItemRefTooltip:Hide()
end

local ItemRefCloseOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

function Tooltips:SkinItemRef()
	ItemRefCloseButton:Hide()
	
	-- Close button
	local CloseButton = CreateFrame("Frame", nil, ItemRefTooltip, "BackdropTemplate")
	CloseButton:SetSize(20, 20)
	CloseButton:SetPoint("TOPRIGHT", ItemRefTooltip, -3, -3)
	CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	CloseButton:SetBackdropColor(0, 0, 0, 0)
	CloseButton:SetBackdropBorderColor(0, 0, 0)
	CloseButton:SetScript("OnEnter", ItemRefCloseOnEnter)
	CloseButton:SetScript("OnLeave", ItemRefCloseOnLeave)
	CloseButton:SetScript("OnMouseUp", ItemRefCloseOnMouseUp)
	CloseButton:SetScript("OnMouseDown", ItemRefCloseOnMouseDown)
	
	CloseButton.Texture = CloseButton:CreateTexture(nil, "ARTWORK")
	CloseButton.Texture:SetPoint("TOPLEFT", CloseButton, 1, -1)
	CloseButton.Texture:SetPoint("BOTTOMRIGHT", CloseButton, -1, 1)
	CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	CloseButton.Cross = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseButton.Cross:SetPoint("CENTER", CloseButton, 0, 0)
	CloseButton.Cross:SetSize(16, 16)
	CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	ItemRefTooltip.NewCloseButton = CloseButton
end

function Tooltips:OnEvent(event, guid)
	self.GUID = guid
	
	if self.Unit and UnitGUID(self.Unit) == guid then
		--local Level = CalculateAverageItemLevel(self.Unit)
		
		--print(format("[%s] Item Level: %.2f", UnitName(self.Unit), Level))
		
		ClearInspectPlayer()
		
		self.Unit = nil
	end
end

function Tooltips:Load()
	if (not Settings["tooltips-enable"]) then
		return
	end
	
	self:SetSize(200, 26)
	
	if Settings["right-window-enable"] then
		local Window = HydraUI:GetModule("Right Window")
		
		self:SetPoint("BOTTOMLEFT", Window.Top, "TOPLEFT", 0, 3)
	else
		self:SetPoint("BOTTOMRIGHT", HydraUI.UIParent, -13, 101)
	end
	
	self:AddHooks()
	self:StyleStatusBar()
	self:SkinItemRef()
	--self:RegisterEvent("INSPECT_READY")
	--self:SetScript("OnEvent", self.OnEvent)
	
	self.Mover = HydraUI:CreateMover(self)
	
	--self.Mover.PreMove = function() GameTooltip_SetDefaultAnchor(GameTooltip, self) GameTooltip:AddLine("Example tooltip") GameTooltip:Show() end
	--self.Mover.PostMove = function() GameTooltip:Hide() end
	
	if IsInGuild() then
		MyGuild = GetGuildInfo("player")
	end
end

local UpdateHealthBarHeight = function(value)
	GameTooltipStatusBar:SetHeight(value)
end

local UpdateShowHealthText = function(value)
	if (value ~= true) then
		GameTooltipStatusBar.HealthValue:SetText(" ")
		GameTooltipStatusBar.HealthPercent:SetText(" ")
	end
end

GUI:AddWidgets(Language["General"], Language["Tooltips"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("tooltips-enable", Settings["tooltips-enable"], Language["Enable Tooltips Module"], Language["Enable the HydraUI tooltips module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Health Bar"])
	left:CreateSwitch("tooltips-show-health", Settings["tooltips-show-health"], Language["Display Health Bar"], Language["Dislay the tooltip health bar"])
	left:CreateSwitch("tooltips-show-health-text", Settings["tooltips-show-health-text"], Language["Display Health Text"], Language["Dislay health information on the tooltip health bar"], UpdateShowHealthText)
	left:CreateSlider("tooltips-health-bar-height", Settings["tooltips-health-bar-height"], 2, 30, 1, Language["Health Bar Height"], Language["Set the height of the tooltip health bar"], UpdateHealthBarHeight)
	
	left:CreateHeader(Language["Information"])
	left:CreateSwitch("tooltips-show-target", Settings["tooltips-show-target"], Language["Display Target"], Language["Dislay the units current target"])
	left:CreateSwitch("tooltips-show-id", Settings["tooltips-show-id"], Language["Display ID's"], Language["Dislay item and spell ID's in the tooltip"])
	left:CreateSwitch("tooltips-display-realm", Settings["tooltips-display-realm"], Language["Display Realm"], Language["Display character realms"])
	left:CreateSwitch("tooltips-display-title", Settings["tooltips-display-title"], Language["Display Title"], Language["Display character titles"])
	left:CreateSwitch("tooltips-display-rank", Settings["tooltips-display-rank"], Language["Display Guild Rank"], Language["Display character guild ranks"])
	left:CreateSwitch("tooltips-show-price", Settings["tooltips-show-price"], Language["Display Vendor Price"], Language["Dislay the vendor price of an item"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("tooltips-font", Settings["tooltips-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the tooltip text"], nil, "Font")
	right:CreateSlider("tooltips-font-size", Settings["tooltips-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the tooltip text"])
	right:CreateDropdown("tooltips-font-flags", Settings["tooltips-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the tooltip text"])
	
	right:CreateHeader(Language["Cursor Anchor"])
	right:CreateSwitch("tooltips-on-cursor", Settings["tooltips-on-cursor"], Language["Tooltip On Cursor"], Language["Anchor the tooltip to the mouse cursor"])
	right:CreateDropdown("tooltips-cursor-anchor", Settings["tooltips-cursor-anchor"], {[Language["Right"]] = "ANCHOR_CURSOR_RIGHT", [Language["Center"]] = "ANCHOR_CURSOR", [Language["Left"]] = "ANCHOR_CURSOR_LEFT"}, Language["Anchor Point"])
	right:CreateSlider("tooltips-cursor-anchor-x", Settings["tooltips-cursor-anchor-x"], -64, 64, 1, Language["X Offset"], Language["Set the horizontal offset of the tooltip. Only works with Left or Right anchor."])
	right:CreateSlider("tooltips-cursor-anchor-y", Settings["tooltips-cursor-anchor-y"], -64, 64, 1, Language["Y Offset"], Language["Set the vertical offset of the tooltip. Only works with Left or Right anchor."])
	
	right:CreateHeader(Language["Disable Tooltips"])
	right:CreateDropdown("tooltips-hide-on-unit", Settings["tooltips-hide-on-unit"], {[Language["Never"]] = "NEVER", [Language["Always"]] = "ALWAYS", [Language["Friendly"]] = "FRIENDLY", [Language["Hostile"]] = "HOSTILE", [Language["Combat"]] = "NO_COMBAT"}, Language["Disable Units"], Language["Set the tooltip to not display units"])
	right:CreateDropdown("tooltips-hide-on-item", Settings["tooltips-hide-on-item"], {[Language["Never"]] = "NEVER", [Language["Always"]] = "ALWAYS", [Language["Combat"]] = "NO_COMBAT"}, Language["Disable Items"], Language["Set the tooltip to not display items"])
	right:CreateDropdown("tooltips-hide-on-action", Settings["tooltips-hide-on-action"], {[Language["Never"]] = "NEVER", [Language["Always"]] = "ALWAYS", [Language["Combat"]] = "NO_COMBAT"}, Language["Disable Actions"], Language["Set the tooltip to not display actions"])
end)
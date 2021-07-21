local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Fonts = HydraUI:NewModule("Fonts")

local Locale = GetLocale()
local Font

if (Locale == "koKR") then
	Font = "Fonts\\2002.TTF"
elseif (Locale == "zhCN") then
	Font = "Fonts\\ARKai_T.ttf"
elseif (Locale == "zhTW") then
	Font = "Fonts\\bLEI00D.ttf"
elseif (Locale == "ruRU") then
	Font = "Fonts\\FRIZQT___CYR.TTF"
end

Defaults["warning-font"] = "Roboto"
Defaults["warning-font-size"] = 16
Defaults["warning-font-flags"] = ""

Defaults["status-font"] = "Roboto"
Defaults["status-font-size"] = 18
Defaults["status-font-flags"] = ""

Defaults["error-font"] = "Roboto"
Defaults["error-font-size"] = 16
Defaults["error-font-flags"] = ""

Defaults["replace-ui-fonts"] = true
Defaults["replacement-ui-font"] = "Roboto"

function Fonts:UpdateFont(object)
	local _, Size, Outline = object:GetFont()
	
	if (Size < 12) then
		Size = 12
	end
	
	object:SetFont(Font, Size, Outline)
end

function Fonts:Load()
	HydraUI:SetFontInfo(UIErrorsFrame, Settings["error-font"], Settings["error-font-size"], Settings["error-font-flags"])
	
	HydraUI:SetFontInfo(RaidWarningFrameSlot1, Settings["warning-font"], Settings["warning-font-size"], Settings["warning-font-flags"])
	HydraUI:SetFontInfo(RaidWarningFrameSlot2, Settings["warning-font"], Settings["warning-font-size"], Settings["warning-font-flags"])
	
	HydraUI:SetFontInfo(AutoFollowStatusText, Settings["status-font"], Settings["status-font-size"], Settings["status-font-flags"])
	
	if (not Settings["replace-ui-fonts"]) then
		return
	end
	
	Font = Assets:GetFont(Settings["replacement-ui-font"])
	
	self:UpdateFont(AchievementFont_Small)
	self:UpdateFont(ChatBubbleFont)
	self:UpdateFont(ChatFontSmall)
	self:UpdateFont(CoreAbilityFont)
	self:UpdateFont(DestinyFontMed)
	self:UpdateFont(DestinyFontLarge)
	self:UpdateFont(DestinyFontHuge)
	self:UpdateFont(Fancy12Font)
	self:UpdateFont(Fancy14Font)
	self:UpdateFont(Fancy16Font)
	self:UpdateFont(Fancy18Font)
	self:UpdateFont(Fancy20Font)
	self:UpdateFont(Fancy22Font)
	self:UpdateFont(Fancy24Font)
	self:UpdateFont(Fancy27Font)
	self:UpdateFont(Fancy30Font)
	self:UpdateFont(Fancy32Font)
	self:UpdateFont(Fancy48Font)
	self:UpdateFont(FriendsFont_Small)
	self:UpdateFont(FriendsFont_Normal)
	self:UpdateFont(FriendsFont_Large)
	self:UpdateFont(FriendsFont_UserText)
	self:UpdateFont(Game11Font)
	self:UpdateFont(Game11Font_o1)
	self:UpdateFont(Game12Font)
	self:UpdateFont(Game13Font)
	self:UpdateFont(Game13FontShadow)
	self:UpdateFont(Game13Font_o1)
	self:UpdateFont(Game15Font)
	self:UpdateFont(Game15Font_o1)
	self:UpdateFont(Game16Font)
	self:UpdateFont(Game18Font)
	self:UpdateFont(Game20Font)
	self:UpdateFont(Game24Font)
	self:UpdateFont(Game27Font)
	self:UpdateFont(Game32Font)
	self:UpdateFont(Game36Font)
	self:UpdateFont(Game42Font)
	self:UpdateFont(Game46Font)
	self:UpdateFont(Game48Font)
	self:UpdateFont(Game48FontShadow)
	self:UpdateFont(Game60Font)
	self:UpdateFont(Game120Font)
	self:UpdateFont(GameFontNormal)
	self:UpdateFont(GameFontNormalLeft)
	self:UpdateFont(GameFontNormalSmall)
	self:UpdateFont(GameFontNormalSmall2)
	self:UpdateFont(GameFontNormalLarge)
	self:UpdateFont(GameFontHighlight)
	self:UpdateFont(GameFontHighlightSmall)
	self:UpdateFont(GameFontHighlightLarge)
	self:UpdateFont(GameFontHighlightExtraSmall)
	self:UpdateFont(GameFont_Gigantic)
	self:UpdateFont(GameTooltipHeader)
	self:UpdateFont(InvoiceFont_Small)
	self:UpdateFont(InvoiceFont_Med)
	self:UpdateFont(MailFont_Large)
	self:UpdateFont(NumberFont_Small)
	self:UpdateFont(NumberFontNormalLarge)
	self:UpdateFont(NumberFont_Normal_Med)
	self:UpdateFont(NumberFont_GameNormal)
	self:UpdateFont(NumberFont_Shadow_Small)
	self:UpdateFont(NumberFont_Shadow_Med)
	self:UpdateFont(NumberFont_Outline_Med)
	self:UpdateFont(NumberFont_Outline_Large)
	self:UpdateFont(NumberFont_Outline_Huge)
	self:UpdateFont(NumberFont_OutlineThick_Mono_Small)
	self:UpdateFont(QuestFont)
	self:UpdateFont(QuestFont_Large)
	self:UpdateFont(QuestFont_Enormous)
	self:UpdateFont(QuestFont_Super_Huge)
	self:UpdateFont(QuestFont_Shadow_Small)
	self:UpdateFont(QuestFont_Shadow_Huge)
	self:UpdateFont(QuestFont_Super_Huge_Outline)
	self:UpdateFont(QuestTitleFontBlackShadow)
	self:UpdateFont(ReputationDetailFont)
	self:UpdateFont(SpellFont_Small)
	self:UpdateFont(SplashHeaderFont)
	self:UpdateFont(SubZoneTextString)
	self:UpdateFont(SystemFont_InverseShadow_Small)
	self:UpdateFont(SystemFont_Large)
	self:UpdateFont(SystemFont_Med1)
	self:UpdateFont(SystemFont_Med2)
	self:UpdateFont(SystemFont_Med3)
	self:UpdateFont(SystemFont_Huge1)
	self:UpdateFont(SystemFont_Huge1_Outline)
	self:UpdateFont(SystemFont_Outline)
	self:UpdateFont(SystemFont_OutlineThick_Huge2)
	self:UpdateFont(SystemFont_OutlineThick_Huge4)
	self:UpdateFont(SystemFont_OutlineThick_WTF) -- ??
	self:UpdateFont(SystemFont_Outline_Small)
	self:UpdateFont(SystemFont_Shadow_Small)
	self:UpdateFont(SystemFont_Shadow_Med1)
	self:UpdateFont(SystemFont_Shadow_Med2)
	self:UpdateFont(SystemFont_Shadow_Med3)
	self:UpdateFont(SystemFont_Shadow_Huge1)
	self:UpdateFont(SystemFont_Small)
	self:UpdateFont(SystemFont_Tiny)
	self:UpdateFont(TextStatusBarText)
	self:UpdateFont(Tooltip_Med)
	self:UpdateFont(Tooltip_Small)
	self:UpdateFont(PVPArenaTextString)
	self:UpdateFont(PVPInfoTextString)
	self:UpdateFont(ZoneTextString)
end

local UpdateRaidFont = function()
	HydraUI:SetFontInfo(RaidWarningFrameSlot1, Settings["warning-font"], Settings["warning-font-size"], Settings["warning-font-flags"])
	HydraUI:SetFontInfo(RaidWarningFrameSlot2, Settings["warning-font"], Settings["warning-font-size"], Settings["warning-font-flags"])
end

local UpdateStatusFont = function()
	HydraUI:SetFontInfo(AutoFollowStatusText, Settings["status-font"], Settings["status-font-size"], Settings["status-font-flags"])
end

local UpdateErrorFont = function()
	HydraUI:SetFontInfo(UIErrorsFrame, Settings["error-font"], Settings["error-font-size"], Settings["error-font-flags"])
end

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	left:CreateHeader(Language["Raid Warnings"])
	left:CreateDropdown("warning-font", Settings["warning-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of raid warnings"], UpdateRaidFont, "Font")
	left:CreateSlider("warning-font-size", Settings["warning-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of raid warnings"], UpdateRaidFont)
	left:CreateDropdown("warning-font-flags", Settings["warning-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of raid warnings"], UpdateRaidFont)
	
	left:CreateHeader(Language["Status Font"])
	left:CreateDropdown("status-font", Settings["status-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the status text"], UpdateStatusFont, "Font")
	left:CreateSlider("status-font-size", Settings["status-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the status text"], UpdateStatusFont)
	left:CreateDropdown("status-font-flags", Settings["status-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the status text"], UpdateStatusFont)
	
	left:CreateHeader(Language["UI Error Frame"])
	left:CreateDropdown("error-font", Settings["error-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the UI error frame"], UpdateErrorFont, "Font")
	left:CreateSlider("error-font-size", Settings["error-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the UI error frame"], UpdateErrorFont)
	left:CreateDropdown("error-font-flags", Settings["error-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the UI error frame"], UpdateErrorFont)
	
	left:CreateHeader(Language["Replace UI Fonts"])
	left:CreateSwitch("replace-ui-fonts", Settings["replace-ui-fonts"], Language["Enable Font Replacement"], Language["Replace default fonts around the UI"], ReloadUI):RequiresReload(true)
	left:CreateDropdown("replacement-ui-font", Settings["replacement-ui-font"], Assets:GetFontList(), Language["Font"], Language["Set the font"], ReloadUI, "Font"):RequiresReload(true)
end)
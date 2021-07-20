local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Fonts = HydraUI:NewModule("Fonts")

local Locale = GetLocale()
local Font = "Interface\\Addons\\HydraUI\\Assets\\Fonts\\Roboto.ttf"

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

function Fonts:UpdateFont(object)
	local _, Size, Outline = object:GetFont()
	
	if (Size < 12) then
		Size = 12
	end
	
	object:SetFont(Font, Size, Outline)
end

Fonts:UpdateFont(AchievementFont_Small)
Fonts:UpdateFont(ChatBubbleFont)
Fonts:UpdateFont(ChatFontSmall)
Fonts:UpdateFont(CoreAbilityFont)
Fonts:UpdateFont(DestinyFontMed)
Fonts:UpdateFont(DestinyFontLarge)
Fonts:UpdateFont(DestinyFontHuge)
Fonts:UpdateFont(Fancy12Font)
Fonts:UpdateFont(Fancy14Font)
Fonts:UpdateFont(Fancy16Font)
Fonts:UpdateFont(Fancy18Font)
Fonts:UpdateFont(Fancy20Font)
Fonts:UpdateFont(Fancy22Font)
Fonts:UpdateFont(Fancy24Font)
Fonts:UpdateFont(Fancy27Font)
Fonts:UpdateFont(Fancy30Font)
Fonts:UpdateFont(Fancy32Font)
Fonts:UpdateFont(Fancy48Font)
Fonts:UpdateFont(FriendsFont_Small)
Fonts:UpdateFont(FriendsFont_Normal)
Fonts:UpdateFont(FriendsFont_Large)
Fonts:UpdateFont(FriendsFont_UserText)
Fonts:UpdateFont(Game11Font)
Fonts:UpdateFont(Game11Font_o1)
Fonts:UpdateFont(Game12Font)
Fonts:UpdateFont(Game13Font)
Fonts:UpdateFont(Game13FontShadow)
Fonts:UpdateFont(Game13Font_o1)
Fonts:UpdateFont(Game15Font)
Fonts:UpdateFont(Game15Font_o1)
Fonts:UpdateFont(Game16Font)
Fonts:UpdateFont(Game18Font)
Fonts:UpdateFont(Game20Font)
Fonts:UpdateFont(Game24Font)
Fonts:UpdateFont(Game27Font)
Fonts:UpdateFont(Game32Font)
Fonts:UpdateFont(Game36Font)
Fonts:UpdateFont(Game42Font)
Fonts:UpdateFont(Game46Font)
Fonts:UpdateFont(Game48Font)
Fonts:UpdateFont(Game48FontShadow)
Fonts:UpdateFont(Game60Font)
Fonts:UpdateFont(Game120Font)
Fonts:UpdateFont(GameFontNormal)
Fonts:UpdateFont(GameFontNormalLeft)
Fonts:UpdateFont(GameFontNormalSmall)
Fonts:UpdateFont(GameFontNormalSmall2)
Fonts:UpdateFont(GameFontNormalLarge)
Fonts:UpdateFont(GameFontHighlight)
Fonts:UpdateFont(GameFontHighlightSmall)
Fonts:UpdateFont(GameFontHighlightLarge)
Fonts:UpdateFont(GameFontHighlightExtraSmall)
Fonts:UpdateFont(GameFont_Gigantic)
Fonts:UpdateFont(GameTooltipHeader)
Fonts:UpdateFont(InvoiceFont_Small)
Fonts:UpdateFont(InvoiceFont_Med)
Fonts:UpdateFont(MailFont_Large)
Fonts:UpdateFont(NumberFont_Small)
Fonts:UpdateFont(NumberFontNormalLarge)
Fonts:UpdateFont(NumberFont_Normal_Med)
Fonts:UpdateFont(NumberFont_GameNormal)
Fonts:UpdateFont(NumberFont_Shadow_Small)
Fonts:UpdateFont(NumberFont_Shadow_Med)
Fonts:UpdateFont(NumberFont_Outline_Med)
Fonts:UpdateFont(NumberFont_Outline_Large)
Fonts:UpdateFont(NumberFont_Outline_Huge)
Fonts:UpdateFont(NumberFont_OutlineThick_Mono_Small)
Fonts:UpdateFont(QuestFont)
Fonts:UpdateFont(QuestFont_Large)
Fonts:UpdateFont(QuestFont_Enormous)
Fonts:UpdateFont(QuestFont_Super_Huge)
Fonts:UpdateFont(QuestFont_Shadow_Small)
Fonts:UpdateFont(QuestFont_Shadow_Huge)
Fonts:UpdateFont(QuestFont_Super_Huge_Outline)
Fonts:UpdateFont(QuestTitleFontBlackShadow)
Fonts:UpdateFont(ReputationDetailFont)
Fonts:UpdateFont(SpellFont_Small)
Fonts:UpdateFont(SplashHeaderFont)
Fonts:UpdateFont(SubZoneTextString)
Fonts:UpdateFont(SystemFont_InverseShadow_Small)
Fonts:UpdateFont(SystemFont_Large)
Fonts:UpdateFont(SystemFont_Med1)
Fonts:UpdateFont(SystemFont_Med2)
Fonts:UpdateFont(SystemFont_Med3)
Fonts:UpdateFont(SystemFont_Huge1)
Fonts:UpdateFont(SystemFont_Huge1_Outline)
Fonts:UpdateFont(SystemFont_Outline)
Fonts:UpdateFont(SystemFont_OutlineThick_Huge2)
Fonts:UpdateFont(SystemFont_OutlineThick_Huge4)
Fonts:UpdateFont(SystemFont_OutlineThick_WTF) -- ??
Fonts:UpdateFont(SystemFont_Outline_Small)
Fonts:UpdateFont(SystemFont_Shadow_Small)
Fonts:UpdateFont(SystemFont_Shadow_Med1)
Fonts:UpdateFont(SystemFont_Shadow_Med2)
Fonts:UpdateFont(SystemFont_Shadow_Med3)
Fonts:UpdateFont(SystemFont_Shadow_Huge1)
Fonts:UpdateFont(SystemFont_Small)
Fonts:UpdateFont(SystemFont_Tiny)
Fonts:UpdateFont(TextStatusBarText)
Fonts:UpdateFont(Tooltip_Med)
Fonts:UpdateFont(Tooltip_Small)
Fonts:UpdateFont(PVPArenaTextString)
Fonts:UpdateFont(PVPInfoTextString)
Fonts:UpdateFont(ZoneTextString)

function Fonts:Load()
	HydraUI:SetFontInfo(UIErrorsFrame, Settings["error-font"], Settings["error-font-size"], Settings["error-font-flags"])
	
	HydraUI:SetFontInfo(RaidWarningFrameSlot1, Settings["warning-font"], Settings["warning-font-size"], Settings["warning-font-flags"])
	HydraUI:SetFontInfo(RaidWarningFrameSlot2, Settings["warning-font"], Settings["warning-font-size"], Settings["warning-font-flags"])
	
	HydraUI:SetFontInfo(AutoFollowStatusText, Settings["status-font"], Settings["status-font-size"], Settings["status-font-flags"])
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
end)
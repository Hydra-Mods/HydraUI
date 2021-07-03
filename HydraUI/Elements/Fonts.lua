local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Fonts = HydraUI:NewModule("Fonts")

Defaults["warning-font"] = "Roboto"
Defaults["warning-font-size"] = 16
Defaults["warning-font-flags"] = ""

Defaults["status-font"] = "Roboto"
Defaults["status-font-size"] = 18
Defaults["status-font-flags"] = ""

Defaults["error-font"] = "Roboto"
Defaults["error-font-size"] = 16
Defaults["error-font-flags"] = ""

--[[_G.STANDARD_TEXT_FONT = Assets:GetFont(Settings["standard-font"])
_G.DAMAGE_TEXT_FONT = Assets:GetFont(Settings["combat-font"])
_G.UNIT_NAME_FONT = Assets:GetFont(Settings["unit-name-font"])]]

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
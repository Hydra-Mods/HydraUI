local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Fonts = vUI:NewModule("Fonts")

--[[_G.STANDARD_TEXT_FONT = Assets:GetFont(Settings["standard-font"])
_G.DAMAGE_TEXT_FONT = Assets:GetFont(Settings["combat-font"])
_G.UNIT_NAME_FONT = Assets:GetFont(Settings["unit-name-font"])]]
	
function Fonts:Load()
	local Font = Assets:GetFont(Settings["ui-widget-font"])

	UIErrorsFrame:SetFont(Font, 16)
	
	RaidWarningFrameSlot1:SetFont(Font, 16)
	RaidWarningFrameSlot2:SetFont(Font, 16)
	
	vUI:SetFontInfo(AutoFollowStatusText, Font, 18)
end
local vUI, GUI, Language, Assets, Settings = select(2, ...):get()
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)

if LDB then
	local vUImenu = LDB:NewDataObject("vUI", {
		type = "launcher",
		icon = "Interface\\AddOns\\vUI\\Assets\\Textures\\Avatar.tga",
		tocname = "vUI",
		OnClick = function(clickedframe, button)
			-- I left the else here so that optional functionality could be added for right click if desired. 
			-- Currently both bring up menu
			if button == "LEFTButton" then GUI:ShowConfig() else GUI:Toggle() end
		end,
		
		OnTooltipShow = function(tt)
			tt:AddLine("vUI Menu")
			tt:Show()
		end,
	})
	if LDBIcon then
		LDBIcon:Register("vUI", vUImenu, vUImenu.MinimapIcon)
	end
end

local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Commands = {}

Commands["move"] = function()
	HydraUI:ToggleMovers()
end

Commands["movereset"] = function()
	HydraUI:ResetAllMovers()
end

Commands["settings"] = function()
	HydraUI:GetModule("GUI"):Toggle()
end

Commands["keybind"] = function()
	HydraUI:GetModule("Key Binding"):Toggle()
end

Commands["reset"] = function()
	HydraUI:Reset()
end

Commands["texel"] = function()
	IsGMClient = function()
		return true
	end

	if (not IsAddOnLoaded("Blizzard_DebugTools")) then
		LoadAddOn("Blizzard_DebugTools")
	end

	TexelSnappingVisualizer:Show()

	--[[
	local PIXEL_SNAPPING_OPTIONS = {
		{ text = "Default", cvarValue = "-1" },
		{ text = "Override On", cvarValue = "1" },
		{ text = "Override Off", cvarValue = "0" },
	}

	SetCVar("overrideTexelSnappingBias", "1")

	SetCVar("overridePixelGridSnapping", "-1")

	--]]
end

Commands["help"] = function()
	print(format(Language["|cFF%sHydraUI|r Commands"], Settings["ui-widget-color"]))
	print(" ")
	print(format("|Hcommand:/hui|h|cFF%s/hui|r|h - Toggle the settings window", Settings["ui-widget-color"]))
	print(format("|Hcommand:/hui move|h|cFF%s/hui move|r|h - Drag UI elements around the screen", Settings["ui-widget-color"]))
	print(format("|Hcommand:/hui movereset|h|cFF%s/hui movereset|r|h - Reposition all movers to their default locations", Settings["ui-widget-color"]))
	print(format("|Hcommand:/hui keybind|h|cFF%s/hui keybind|r|h - Toggle mouseover keybinding", Settings["ui-widget-color"]))
	print(format("|Hcommand:/hui reset|h|cFF%s/hui reset|r|h - Reset all stored UI information and settings", Settings["ui-widget-color"]))
end

local RunCommand = function(arg)
	if Commands[arg] then
		Commands[arg]()
	else
		Commands.settings()
	end
end

SLASH_HYDRAUI1 = "/hui"
SLASH_HYDRAUI2 = "/hydraui"
SLASH_HYDRAUI3 = "/vui" -- Remove later, I just know people will still type this for now... including myself
SlashCmdList["HYDRAUI"] = RunCommand

SLASH_RELOAD1 = "/rl"
SlashCmdList["RELOAD"] = C_UI.Reload

SLASH_GLOBALSTRINGFIND1 = "/gfind"
SlashCmdList["GLOBALSTRINGFIND"] = function(query)
	for Key, Value in next, _G do
		if (Value and type(Value) == "string") then
			if Value:lower():find(query:lower()) then
				print(format("|cFFFFFF00%s|r |cFFFFFFFF= %s|r", Key, Value))
			end
		end
	end
end
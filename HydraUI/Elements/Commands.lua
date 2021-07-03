local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Commands = {}

Commands["move"] = function()
	HydraUI:ToggleMovers()
end

Commands["movereset"] = function()
	HydraUI:ResetAllMovers()
end

Commands["settings"] = function()
	GUI:Toggle()
end

Commands["keybind"] = function()
	HydraUI:GetModule("Key Binding"):Toggle()
end

Commands["reset"] = function()
	HydraUI:Reset()
end

Commands["help"] = function()
	print(format(Language["|cFF%sHydraUI|r Commands"], Settings["ui-widget-color"]))
	print(" ")
	print(format("|Hcommand:/HydraUI|h|cFF%s/HydraUI|r|h - Toggle the settings window", Settings["ui-widget-color"]))
	print(format("|Hcommand:/HydraUI move|h|cFF%s/HydraUI move|r|h - Drag UI elements around the screen", Settings["ui-widget-color"]))
	print(format("|Hcommand:/HydraUI movereset|h|cFF%s/HydraUI movereset|r|h - Reposition all movers to their default locations", Settings["ui-widget-color"]))
	print(format("|Hcommand:/HydraUI keybind|h|cFF%s/HydraUI keybind|r|h - Toggle mouseover keybinding", Settings["ui-widget-color"]))
	print(format("|Hcommand:/HydraUI reset|h|cFF%s/HydraUI reset|r|h - Reset all stored UI information and settings", Settings["ui-widget-color"]))
end

local RunCommand = function(arg)
	if Commands[arg] then
		Commands[arg]()
	else
		Commands["settings"]()
	end
end

SLASH_HYDRAUI1 = "/hydraui"
SLASH_HYDRAUI2 = "/hui"
SLASH_HYDRAUI3 = "/vui"
SlashCmdList["HYDRAUI"] = RunCommand

SLASH_GLOBALSTRINGFIND1 = "/gfind"
SlashCmdList["GLOBALSTRINGFIND"] = function(query)
	for Key, Value in pairs(_G) do
		if (Value and type(Value) == "string") then
			if Value:lower():find(query:lower()) then
				print(format("|cFFFFFF00%s|r |cFFFFFFFF= %s|r", Key, Value))
			end
		end
	end
end
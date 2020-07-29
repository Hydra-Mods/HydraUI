local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Commands = {}

Commands["move"] = function()
	vUI:ToggleMovers()
end

Commands["movereset"] = function()
	vUI:ResetAllMovers()
end

Commands["settings"] = function()
	GUI:Toggle()
end

Commands["keybind"] = function()
	vUI:GetModule("Key Binding"):Toggle()
end

Commands["kb"] = function()
	vUI:GetModule("Key Binding"):Toggle()
end

Commands["reset"] = function()
	vUI:Reset()
end

Commands["help"] = function()
	print(format(Language["|cFF%svUI|r Commands"], Settings["ui-widget-color"]))
	print(" ")
	print(format("|Hcommand:/vui|h|cFF%s/vui|r|h - Toggle the settings window", Settings["ui-widget-color"]))
	print(format("|Hcommand:/vui move|h|cFF%s/vui move|r|h - Drag UI elements around the screen", Settings["ui-widget-color"]))
	print(format("|Hcommand:/vui movereset|h|cFF%s/vui movereset|r|h - Reposition all movers to their default locations", Settings["ui-widget-color"]))
	print(format("|Hcommand:/vui keybind or /kb|h|cFF%s/vui keybind or /kb|r|h - Toggle mouseover keybinding", Settings["ui-widget-color"]))
	print(format("|Hcommand:/vui reset|h|cFF%s/vui reset|r|h - Reset all stored UI information and settings", Settings["ui-widget-color"]))
end

local RunCommand = function(arg)
	if Commands[arg] then
		Commands[arg]()
	else
		Commands["settings"]()
	end
end

local ToggleKeybind = function(arg)
    vUI:GetModule("Key Binding"):Toggle()
end


SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = RunCommand


SLASH_KB1 = "/kb"
SlashCmdList["KB"] = ToggleKeybind

SLASH_KEYBIND1 = "/keybind"
SlashCmdList["KEYBIND"] = ToggleKeybind

SLASH_RL1 = "/rl"
SlashCmdList["RL"] = ReloadUI


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
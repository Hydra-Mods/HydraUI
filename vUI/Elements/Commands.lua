local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Commands = {}

Commands["move"] = function()
	vUI:ToggleMovers()
end

Commands["settings"] = function()
	GUI:Toggle()
end

Commands["help"] = function()
	print(format(Language["|cFF%svUI|r Commands"], Settings["ui-widget-color"]))
	print(" ")
	print(format("|Hcommand:/vui|h|cFF%s/vui|r|h - Toggle the settings window", Settings["ui-widget-color"]))
	print(format("|Hcommand:/vui move|h|cFF%s/vui move|r|h - Drag UI elements around the screen", Settings["ui-widget-color"]))
end

local RunCommand = function(arg)
	if Commands[arg] then
		Commands[arg]()
	else
		Commands["settings"]()
	end
end

SLASH_VUI1 = "/vui"
SlashCmdList["VUI"] = RunCommand

SLASH_GLOBALSTRINGFIND1 = "/gfind"
SlashCmdList["GLOBALSTRINGFIND"] = function(query)
	for Key, Value in pairs(_G) do
		if (Value and type(Value) == "string") then
			if Value:find(query) then
				print(format("|cFFFFFF00%s|r |cFFFFFFFF= %s|r", Key, Value))
			end
		end
	end
end
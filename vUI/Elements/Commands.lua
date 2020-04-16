local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Commands = {}

Commands["move"] = function()
	vUI:GetModule("Move"):Toggle()
end

Commands["help"] = function()
	print("...")
end

Commands["settings"] = function()
	GUI:Toggle()
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
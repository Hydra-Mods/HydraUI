local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Throttle = vUI:GetModule("Throttle")

local HasPrinted = false
local DevTools = Language["|Hcommand:/reload|h|cFF%s[Reload UI]|r|h |Hcommand:/eventtrace|h|cFF%s[Event Trace]|r|h |Hplayer:%s|h|cFF%s[Whisper Self]|r|h |Hcommand:/framestack|h|cFF%s[Frame Stack]|r|h"]

local UpdateDisplayDevTools = function()
	if (not HasPrinted) then
		local Color = Settings["ui-widget-color"]
		local Name = UnitName("player")
		
		print(format(DevTools, Color, Color, Name, Color, Color))
		
		HasPrinted = true
	end
end

local Languages = {
	["English"] = "enUS",
	["German"] = "deDE",
	["Spanish (Spain)"] = "esES",
	["Spanish (Mexico)"] = "esMX",
	["French"] = "frFR",
	["Italian"] = "itIT",
	["Korean"] = "koKR",
	["Portuguese (Brazil)"] = "ptBR",
	["Russian"] = "ruRU",
	["Chinese (Simplified)"] = "zhCN",
	["Chinese (Traditional)"] = "zhTW",
}

local UpdateUIScale = function(value)
	vUI:SetScale(tonumber(value))
end

local GetDiscordLink = function()
	if (not Throttle:Exists("discord-request")) then
		Throttle:Create("discord-request", 10)
	end
	
	if (not Throttle:IsThrottled("discord-request")) then
		vUI:print("Join the Discord community for support and feedback https://discord.gg/wfCVkJe")
		
		Throttle:Start("discord-request")
	end
end

local ToggleMove = function()
	vUI:GetModule("Move"):Toggle()
end

local ResetMovers = function()
	vUI:GetModule("Move"):ResetAll()
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["General"], true)
	
	Left:CreateHeader(Language["Welcome"])
	Left:CreateSwitch("ui-display-welcome", Settings["ui-display-welcome"], Language["Display Welcome Message"], "Display a welcome message on|n login with UI information")
	--Left:CreateSwitch("ui-display-whats-new", Settings["ui-display-whats-new"], Language[ [[Display "What's New" Pop-ups]] ], "")
	Left:CreateSwitch("ui-display-dev-tools", Settings["ui-display-dev-tools"], Language["Display Developer Chat Tools"], "", UpdateDisplayDevTools)
	
	--[[Left:CreateHeader(Language["Language"])
	Left:CreateDropdown("ui-language", vUI.UserLocale, Languages, Language["UI Language"], "", ReloadUI):RequiresReload(true)
	Left:CreateButton(Language["Contribute"], Language["Help Localize"], Language["Contribute"], function() vUI:print("") end)]]
	
	Left:CreateHeader("Discord")
	Left:CreateButton("Get Link", "Join Discord", "Get a link to join the vUI Discord community", GetDiscordLink)
	
	Left:CreateHeader(Language["Move UI"])
	Left:CreateButton(Language["Toggle"], Language["Move UI"], "While toggled, you can drag some|nelements of vUI around the screen", ToggleMove)
	Left:CreateButton(Language["Restore"], Language["Restore To Defaults"], "Restore all vUI movable frames|nto their default locations", ResetMovers)
	
	if Settings["ui-display-welcome"] then
		local Color1 = Settings["ui-widget-color"]
		local Color2 = Settings["ui-header-font-color"]
		
		print(format(Language["Welcome to |cFF%svUI|r version |cFF%s%s|r."], Color1, Color2, vUI.UIVersion))
		print(format(Language["Type |cFF%s/vui|r to access the settings window, or click |cFF%s|Hcommand:/vui|h[here]|h|r."], Color1, Color1))
		
		-- May as well put this here for now too.
		if Settings["ui-display-dev-tools"] then
			local Name = UnitName("player")
			
			print(format(DevTools, Color1, Color1, Name, Color1, Color1))
			
			HasPrinted = true
		end
	end
end)
local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

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

local UpdateUIScale = function(value)
	vUI:SetScale(tonumber(value))
end

local GetDiscordLink = function()
	if (not Throttle:Exists("discord-request")) then
		Throttle:Create("discord-request", 10)
	end
	
	if (not Throttle:IsThrottled("discord-request")) then
		vUI:print(Language["Join the Discord community for support and feedback https://discord.gg/wfCVkJe"])
		
		Throttle:Start("discord-request")
	end
end

local ToggleMove = function()
	vUI:ToggleMovers()
end

local ResetMovers = function()
	vUI:ResetAllMovers()
end

local UpdateGUIEnableFade = function(value)
	if value then
		GUI:RegisterEvent("PLAYER_STARTED_MOVING")
		GUI:RegisterEvent("PLAYER_STOPPED_MOVING")
	else
		GUI:UnregisterEvent("PLAYER_STARTED_MOVING")
		GUI:UnregisterEvent("PLAYER_STOPPED_MOVING")
		GUI:SetAlpha(1)
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["General"], true)
	
	Left:CreateHeader(Language["Welcome"])
	Left:CreateSwitch("ui-display-welcome", Settings["ui-display-welcome"], Language["Display Welcome Message"], Language["Display a welcome message on login with UI information"])
	--Left:CreateSwitch("ui-display-whats-new", Settings["ui-display-whats-new"], Language[ [[Display "What's New" Pop-ups]] ], "")
	Left:CreateSwitch("ui-display-dev-tools", Settings["ui-display-dev-tools"], Language["Display Developer Chat Tools"], "", UpdateDisplayDevTools)
	
	Left:CreateHeader(Language["Discord"])
	Left:CreateButton(Language["Get Link"], Language["Join Discord"], Language["Get a link to join the vUI Discord community"], GetDiscordLink)
	
	Left:CreateHeader(Language["Move UI"])
	Left:CreateButton(Language["Toggle"], Language["Move UI"], Language["While toggled, you can drag someelements of vUI around the screen"], ToggleMove)
	Left:CreateButton(Language["Restore"], Language["Restore To Defaults"], Language["Restore all vUI movable framesto their default locations"], ResetMovers)
	
	Right:CreateHeader(Language["Settings Window"])
	Right:CreateSwitch("gui-hide-in-combat", Settings["gui-hide-in-combat"], Language["Hide In Combat"], Language["Hide the settings window when engaging in combat"])
	Right:CreateSwitch("gui-enable-fade", Settings["gui-enable-fade"], Language["Fade While Moving"], Language["Fade out the settings window while moving"], UpdateGUIEnableFade)
	Right:CreateSlider("gui-faded-alpha", Settings["gui-faded-alpha"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the settings window while faded"], nil, nil, "%")
	
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
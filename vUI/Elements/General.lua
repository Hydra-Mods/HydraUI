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

function vUI:WelcomeMessage()
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
end

local UpdateUIScale = function(value)
	vUI:SetScale(tonumber(value))
end

local GetDiscordLink = function()
	if (not Throttle:Exists("discord-request")) then
		Throttle:Create("discord-request", 10)
	end
	
	if (not Throttle:IsThrottled("discord-request")) then
		vUI:print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
		
		Throttle:Start("discord-request")
	end
end

local GetYouTubeLink = function()
	if (not Throttle:Exists("yt-request")) then
		Throttle:Create("yt-request", 10)
	end
	
	if (not Throttle:IsThrottled("yt-request")) then
		vUI:print(Language["Subscribe to YouTube to see new features https://www.youtube.com/c/HydraMods"])
		
		Throttle:Start("yt-request")
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
	Left:CreateButton(Language["Get Link"], Language["Join Discord"], Language["Get a link to join the vUI Discord community"], GetDiscordLink)
	Left:CreateButton(Language["Get Link"], Language["Watch YouTube"], Language["Get a link for the vUI YouTube channel"], GetYouTubeLink)
	
	Left:CreateHeader(Language["Move UI"])
	Left:CreateButton(Language["Toggle"], Language["Move UI"], Language["While toggled, you can drag some elements of vUI around the screen"], ToggleMove)
	Left:CreateButton(Language["Restore"], Language["Restore To Defaults"], Language["Restore all vUI movable frames to their default locations"], ResetMovers)
	
	Right:CreateHeader(Language["Settings Window"])
	Right:CreateSwitch("gui-hide-in-combat", Settings["gui-hide-in-combat"], Language["Hide In Combat"], Language["Hide the settings window when engaging in combat"])
	Right:CreateSwitch("gui-enable-fade", Settings["gui-enable-fade"], Language["Fade While Moving"], Language["Fade out the settings window while moving"], UpdateGUIEnableFade)
	Right:CreateSlider("gui-faded-alpha", Settings["gui-faded-alpha"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the settings window while faded"], nil, nil, "%")
	
	--Left:CreateHeader(Language["Developer"])
	--Left:CreateSwitch("ui-display-dev-tools", Settings["ui-display-dev-tools"], Language["Display Developer Chat Tools"], "", UpdateDisplayDevTools)
end)

-- Putting Styles here too
local AcceptNewStyle = function(value)
	Assets:ApplyStyle(value)
	
	ReloadUI()
end

local UpdateStyle = function(value)
	local Label = value
	
	if Assets.Styles[value]["ui-widget-color"] then
		Label = format("|cFF%s%s|r", Assets.Styles[value]["ui-widget-color"], value)
	end
	
	vUI:DisplayPopup(Language["Attention"], format(Language['Are you sure you would like to change to the current style to "%s"?'], Label), Language["Accept"], AcceptNewStyle, Language["Cancel"], nil, value)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Styles"])
	
	Left:CreateHeader(Language["Styles"])
	Left:CreateDropdown("ui-style", Settings["ui-style"], Assets:GetStyleList(), Language["Select Style"], Language["Select a style to load"], UpdateStyle)
	
	Left:CreateHeader(Language["Headers"])
	Left:CreateColorSelection("ui-header-font-color", Settings["ui-header-font-color"], Language["Text Color"], "")
	Left:CreateColorSelection("ui-header-texture-color", Settings["ui-header-texture-color"], Language["Texture Color"], "")
	Left:CreateDropdown("ui-header-texture", Settings["ui-header-texture"], Assets:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Left:CreateDropdown("ui-header-font", Settings["ui-header-font"], Assets:GetFontList(), Language["Header Font"], "", nil, "Font")
	
	Left:CreateHeader(Language["Widgets"])
	Left:CreateColorSelection("ui-widget-color", Settings["ui-widget-color"], Language["Color"], "")
	Left:CreateColorSelection("ui-widget-bright-color", Settings["ui-widget-bright-color"], Language["Bright Color"], "")
	Left:CreateColorSelection("ui-widget-bg-color", Settings["ui-widget-bg-color"], Language["Background Color"], "")
	Left:CreateColorSelection("ui-widget-font-color", Settings["ui-widget-font-color"], Language["Label Color"], "")
	Left:CreateDropdown("ui-widget-texture", Settings["ui-widget-texture"], Assets:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Left:CreateDropdown("ui-widget-font", Settings["ui-widget-font"], Assets:GetFontList(), Language["Font"], "", nil, "Font")
	
	Right:CreateHeader(Language["What is a style?"])
	Right:CreateMessage(Language["Styles store visual settings such as fonts, textures, and colors to create an overall theme."])
	
	Right:CreateHeader(Language["Console"])
	Right:CreateButton(Language["Reload"], Language["Reload UI"], Language["Reload the UI"], ReloadUI)
	Right:CreateButton(Language["Delete"], Language["Delete Saved Variables"], Language["Reset all saved variables"], vUI.Reset)
	
	Right:CreateHeader(Language["Windows"])
	Right:CreateColorSelection("ui-window-bg-color", Settings["ui-window-bg-color"], Language["Background Color"], "")
	Right:CreateColorSelection("ui-window-main-color", Settings["ui-window-main-color"], Language["Main Color"], "")
	
	Right:CreateHeader(Language["Buttons"])
	Right:CreateColorSelection("ui-button-texture-color", Settings["ui-button-texture-color"], Language["Texture Color"], "")
	Right:CreateColorSelection("ui-button-font-color", Settings["ui-button-font-color"], Language["Font Color"], "")
	Right:CreateDropdown("ui-button-texture", Settings["ui-button-texture"], Assets:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Right:CreateDropdown("ui-button-font", Settings["ui-button-font"], Assets:GetFontList(), Language["Font"], "", nil, "Font")
	
	Left:CreateHeader(Language["Font Sizes"])
	Left:CreateSlider("ui-font-size", Settings["ui-font-size"], 8, 32, 1, Language["General Font Size"], Language["Set the general font size of the UI"])
	Left:CreateSlider("ui-header-font-size", Settings["ui-header-font-size"], 8, 32, 1, Language["Header Font Size"], Language["Set the font size of header elements in the UI"])
	Left:CreateSlider("ui-title-font-size", Settings["ui-title-font-size"], 8, 32, 1, Language["Title Font Size"], Language["Set the font size of title elements in the UI"])
end)

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["Profiles"])
	
	Right:CreateHeader(Language["What is a profile?"])
	Right:CreateMessage(Language["Profiles store your settings so that you can quickly and easily change between configurations."])
	
	local Name = vUI:GetActiveProfileName()
	local Profile = vUI:GetProfile(Name)
	local MostUsed = vUI:GetMostUsedProfile()
	local NumServed, IsAll = vUI:GetNumServedByProfile(Name)
	local NumUnused = vUI:CountUnusedProfiles()
	local MostUsedServed = NumServed
	
	if IsAll then
		NumServed = format("%d (%s)", NumServed, Language["All"])
	end
	
	if (Profile ~= MostUsed) then
		MostUsedServed = vUI:GetNumServedByProfile(MostUsed)
	end
	
	Right:CreateHeader(Language["Info"])
	Right:CreateDoubleLine(Language["Current Profile:"], Name)
	Right:CreateDoubleLine(Language["Created By:"], Profile["profile-created-by"])
	Right:CreateDoubleLine(Language["Created On:"], vUI:IsToday(Profile["profile-created"]))
	Right:CreateDoubleLine(Language["Last Modified:"], vUI:IsToday(Profile["profile-last-modified"]))
	Right:CreateDoubleLine(Language["Modifications:"], vUI:CountChangedValues(Name))
	Right:CreateDoubleLine(Language["Serving Characters:"], NumServed)
	
	Right:CreateHeader(Language["General"])
	Right:CreateDoubleLine(Language["Popular Profile:"], format("%s (%d)", MostUsed, MostUsedServed))
	Right:CreateDoubleLine(Language["Stored Profiles:"], vUI:GetProfileCount())
	Right:CreateDoubleLine(Language["Unused Profiles:"], NumUnused)
end)
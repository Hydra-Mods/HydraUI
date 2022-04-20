local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Throttle = HydraUI:GetModule("Throttle")
local GUI = HydraUI:GetModule("GUI")

local HasPrinted = false
local DevTools = "|Hcommand:/reload|h|cFF%s[Reload UI]|r|h |Hcommand:/eventtrace|h|cFF%s[Event Trace]|r|h |Hplayer:%s|h|cFF%s[Whisper Self]|r|h |Hcommand:/framestack|h|cFF%s[Frame Stack]|r|h"

local UpdateDisplayDevTools = function()
	if (not HasPrinted) then
		local Color = Settings["ui-widget-color"]
		local Name = UnitName("player")
		
		print(format(DevTools, Color, Color, Name, Color, Color))
		
		HasPrinted = true
	end
end

local Expansion = {
	[0] = EXPANSION_NAME0,
	[1] = EXPANSION_NAME1,
	[2] = EXPANSION_NAME2,
	[8] = EXPANSION_NAME8,
}

function HydraUI:WelcomeMessage()
	if Settings["ui-display-welcome"] then
		local Color1 = Settings["ui-widget-color"]
		local Color2 = Settings["ui-header-font-color"]
		local Expansion = Expansion[GetServerExpansionLevel()]
		
		if Expansion then -- Trial accounts have different returns
			print(format(Language["Welcome to |cFF%sHydra|r|cFFEFFFFFUI|r version |cFF%s%s|r for %s - https://discord.gg/XefDFa6nJR"], Color1, Color2, HydraUI.UIVersion, Expansion))
		else
			print(format(Language["Welcome to |cFF%sHydra|r|cFFEFFFFFUI|r version |cFF%s%s|r - https://discord.gg/XefDFa6nJR"], Color1, Color2, HydraUI.UIVersion))
		end
		
		print(format(Language["Type |cFF%s/hui|r to access the settings window, or click |cFF%s|Hcommand:/hui|h[here]|h|r."], Color1, Color1))
		
		-- May as well put this here for now too.
		if Settings["ui-display-dev-tools"] then
			local Name = UnitName("player")
			
			print(format(DevTools, Color1, Color1, Name, Color1, Color1))
			
			HasPrinted = true
		end
	end
end

local UpdateUIScale = function(value)
	HydraUI:SetScale(tonumber(value))
end

local GetDiscordLink = function()
	if (not Throttle:IsThrottled("discord-request")) then
		HydraUI:print(Language["Join the Discord community for support and feedback https://discord.gg/XefDFa6nJR"])
		
		Throttle:Start("discord-request", 10)
	end
end

local GetYouTubeLink = function()
	if (not Throttle:IsThrottled("yt-request")) then
		HydraUI:print(Language["Subscribe to YouTube to see new features https://www.youtube.com/c/HydraMods"])
		
		Throttle:Start("yt-request", 10)
	end
end

local ToggleMove = function()
	HydraUI:ToggleMovers()
end

local ResetMovers = function()
	HydraUI:ResetAllMovers()
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

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	left:CreateHeader(Language["Welcome"])
	left:CreateSwitch("ui-display-welcome", Settings["ui-display-welcome"], Language["Display Welcome Message"], Language["Display a welcome message on login with UI information"])
	--left:CreateSwitch("ui-display-whats-new", Settings["ui-display-whats-new"], Language[ [[Display "What's New" Pop-ups]] ], "")
	left:CreateButton("", Language["Get Link"], Language["Join Discord"], Language["Get a link to join the HydraUI Discord community"], GetDiscordLink)
	left:CreateButton("", Language["Get Link"], Language["Watch YouTube"], Language["Get a link for the HydraUI YouTube channel"], GetYouTubeLink)
	
	left:CreateHeader(Language["Move UI"])
	left:CreateButton("", Language["Toggle"], Language["Move UI"], Language["While toggled, you can drag some elements of HydraUI around the screen"], ToggleMove)
	left:CreateButton("", Language["Restore"], Language["Restore To Defaults"], Language["Restore all HydraUI movable frames to their default locations"], ResetMovers)
	
	right:CreateHeader(Language["Settings Window"])
	right:CreateSwitch("gui-hide-in-combat", Settings["gui-hide-in-combat"], Language["Hide In Combat"], Language["Hide the settings window when engaging in combat"])
	right:CreateSwitch("gui-enable-fade", Settings["gui-enable-fade"], Language["Fade While Moving"], Language["Fade out the settings window while moving"], UpdateGUIEnableFade)
	right:CreateSlider("gui-faded-alpha", Settings["gui-faded-alpha"], 0, 100, 10, Language["Set Faded Opacity"], Language["Set the opacity of the settings window while faded"], nil, nil, "%")
	
	right:CreateHeader(Language["Border Thickness"])
	right:CreateSlider('ui-border-thickness', Settings['ui-border-thickness'], 0, 2, 1, Language["Border Thickness"], Language["Set how thick the border on UI elements is"], ReloadUI, nil, "px"):RequiresReload(true)
	
	--left:CreateHeader(Language["Developer"])
	--left:CreateSwitch("ui-display-dev-tools", Settings["ui-display-dev-tools"], Language["Display Developer Chat Tools"], "", UpdateDisplayDevTools)
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
	
	HydraUI:DisplayPopup(Language["Attention"], format(Language['Are you sure you would like to change to the current style to "%s"?'], Label), ACCEPT, AcceptNewStyle, CANCEL, nil, value)
end

GUI:AddWidgets(Language["General"], Language["Styles"], function(left, right)
	left:CreateHeader(Language["Styles"])
	left:CreateDropdown("ui-style", Settings["ui-style"], Assets:GetStyleList(), Language["Select Style"], Language["Select a style to load"], UpdateStyle)
	
	left:CreateHeader(Language["Headers"])
	left:CreateColorSelection("ui-header-font-color", Settings["ui-header-font-color"], Language["Text Color"], "")
	left:CreateColorSelection("ui-header-texture-color", Settings["ui-header-texture-color"], Language["Texture Color"], "")
	left:CreateDropdown("ui-header-texture", Settings["ui-header-texture"], Assets:GetTextureList(), Language["Texture"], "", nil, "Texture")
	left:CreateDropdown("ui-header-font", Settings["ui-header-font"], Assets:GetFontList(), Language["Header Font"], "", nil, "Font")
	
	left:CreateHeader(Language["Widgets"])
	left:CreateColorSelection("ui-widget-color", Settings["ui-widget-color"], Language["Color"], "")
	left:CreateColorSelection("ui-widget-bright-color", Settings["ui-widget-bright-color"], Language["Bright Color"], "")
	left:CreateColorSelection("ui-widget-bg-color", Settings["ui-widget-bg-color"], Language["Background Color"], "")
	left:CreateColorSelection("ui-widget-font-color", Settings["ui-widget-font-color"], Language["Label Color"], "")
	left:CreateDropdown("ui-widget-texture", Settings["ui-widget-texture"], Assets:GetTextureList(), Language["Texture"], "", nil, "Texture")
	left:CreateDropdown("ui-widget-font", Settings["ui-widget-font"], Assets:GetFontList(), Language["Font"], "", nil, "Font")
	
	right:CreateHeader(Language["What is a style?"])
	right:CreateMessage("", Language["Styles store visual settings such as fonts, textures, and colors to create an overall theme."])
	
	right:CreateHeader(Language["Console"])
	right:CreateButton("", Language["Reload"], Language["Reload UI"], Language["Reload the UI"], ReloadUI)
	--right:CreateButton("", Language["Delete"], Language["Delete Saved Variables"], Language["Reset all saved variables"], HydraUI.Reset)
	
	right:CreateHeader(Language["Windows"])
	right:CreateColorSelection("ui-window-bg-color", Settings["ui-window-bg-color"], Language["Background Color"], "")
	right:CreateColorSelection("ui-window-main-color", Settings["ui-window-main-color"], Language["Main Color"], "")
	
	right:CreateHeader(Language["Buttons"])
	right:CreateColorSelection("ui-button-texture-color", Settings["ui-button-texture-color"], Language["Texture Color"], "")
	right:CreateColorSelection("ui-button-font-color", Settings["ui-button-font-color"], Language["Font Color"], "")
	right:CreateDropdown("ui-button-texture", Settings["ui-button-texture"], Assets:GetTextureList(), Language["Texture"], "", nil, "Texture")
	right:CreateDropdown("ui-button-font", Settings["ui-button-font"], Assets:GetFontList(), Language["Font"], "", nil, "Font")
	
	left:CreateHeader(Language["Font Sizes"])
	left:CreateSlider("ui-font-size", Settings["ui-font-size"], 8, 32, 1, Language["General Font Size"], Language["Set the general font size of the UI"])
	left:CreateSlider("ui-header-font-size", Settings["ui-header-font-size"], 8, 32, 1, Language["Header Font Size"], Language["Set the font size of header elements in the UI"])
	left:CreateSlider("ui-title-font-size", Settings["ui-title-font-size"], 8, 32, 1, Language["Title Font Size"], Language["Set the font size of title elements in the UI"])
end)

local Durability = HydraUI:NewModule("Durability")

local SetDurabilityPosition = function(self, anchor, parent)
	if (parent ~= Durability) then
		self:ClearAllPoints()
		self:SetPoint("CENTER", Durability, 0, 0)
	end
end

function Durability:Load() -- Maybe a setting to hide the whole frame?
	self:SetSize(DurabilityFrame:GetSize())
	self:SetPoint("BOTTOM", HydraUIParent, -360, 10)
	
	DurabilityFrame:SetScript("OnShow", nil)
	DurabilityFrame:SetScript("OnHide", nil)
	hooksecurefunc(DurabilityFrame, "SetPoint", SetDurabilityPosition)
	
	HydraUI:CreateMover(self)
end
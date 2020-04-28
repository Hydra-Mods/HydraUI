if (1 == 1) then
	return
end

local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local MinimapButtons = vUI:NewModule("Minimap Buttons")

local strlower = string.lower
local strfind = string.find
local tinsert = table.insert

MinimapButtons.items = {}

local MinimapButtonsBlacklist = {
	-- Blizzard
	-- TODO: clean this list up
	["BattlefieldMinimap"] = true,
	["ButtonCollectFrame"] = true,
	["FeedbackUIButton"] = true,
	["GameTimeFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MiniMapLFGFrame"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapTracking"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MinimapBackdrop"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["QueueStatusMinimapButton"] = true,
	["TimeManagerClockButton"] = true,
	["MiniMapTrackingFrame"] = true,

	-- Naughty AddOns
	["QuestieFrameGroup"] = true,
	-- NOTE: this one is really tricky as it includes a flyout
	["ItemRackMinimapFrame"] = true,
}

local MinimapButtonTextureIdsToRemove = {
	[136430] = true,
	[136467] = true,
	[130924] = true,
}

local OnChange = function(direction, buttonSize, spacing)
	local lastButton, width, height
  local panelTotalPadding = 6
  local numButtons = #MinimapButtons.items
  local spacing = spacing or Settings["minimap-buttonbar-buttonspacing"]
  local buttonSize = buttonSize or Settings["minimap-buttonbar-buttonsize"]
  local direction = direction or Settings["minimap-buttonbar-direction"]

  if (direction == "UP" or direction == "DOWN") then
    width = buttonSize + panelTotalPadding
    height = (numButtons * buttonSize) + ((numButtons - 1) * spacing) + panelTotalPadding
  else
    width = (numButtons * buttonSize) + ((numButtons - 1) * spacing) + panelTotalPadding
    height = buttonSize + panelTotalPadding
  end

  MinimapButtons.Panel:SetSize(width, height)

	for _, Button in pairs(MinimapButtons.items) do
		if (Button:IsShown()) then
			Button:SetSize(buttonSize, buttonSize)
			Button:ClearAllPoints()

      if not lastButton then
        if (direction == "LEFT") then
          Button:SetPoint("TOPRIGHT", MinimapButtons.Panel, -3, -3)
        end

        if (direction == "RIGHT") then
          Button:SetPoint("TOPLEFT", MinimapButtons.Panel, 3, -3)
        end

        if (direction == "DOWN") then
          Button:SetPoint("TOPLEFT", MinimapButtons.Panel, 3, -3)
        end

        if (direction == "UP") then
          Button:SetPoint("BOTTOMRIGHT", MinimapButtons.Panel, -3, 3)
        end
      else
        if (direction == "LEFT") then
          Button:SetPoint("RIGHT", lastButton, "LEFT", -spacing, 0)
        end

        if (direction == "RIGHT") then
          Button:SetPoint("LEFT", lastButton, "RIGHT", spacing, 0)
        end

        if (direction == "DOWN") then
          Button:SetPoint("TOP", lastButton, "BOTTOM", 0, -spacing)
        end

        if (direction == "UP") then
          Button:SetPoint("BOTTOM", lastButton, "TOP", 0, spacing)
        end
			end

			lastButton = Button
		end
	end
end

function MinimapButtons:SkinButtons()
  for _, Child in ipairs({Minimap:GetChildren()}) do
		local name = Child:GetName()

		if (name and not MinimapButtonsBlacklist[name] and Child:IsShown()) then
			local objectType = Child:GetObjectType()

			Child:SetParent(self.Panel)

			if (Child:HasScript("OnDragStart")) then
				Child:SetScript("OnDragStart", nil)
			end

			if (Child:HasScript("OnDragStop")) then
				Child:SetScript("OnDragStop", nil)
			end

			for i = 1, Child:GetNumRegions() do
				local region = select(i, Child:GetRegions())
				
				if (region:GetObjectType() == "Texture") then
					local t = region:GetTexture() or ""
					local texture = strlower(t)
					local textureId = region:GetTextureFileID()

					if (textureId and MinimapButtonTextureIdsToRemove[textureId]) then
						region:SetTexture(nil)
					end

					if (
						strfind(texture, [[interface\characterframe]]) or
						strfind(texture, [[interface\minimap]]) or
						strfind(texture, 'border') or 
						strfind(texture, 'background') or 
						strfind(texture, 'alphamask') or
						strfind(texture, 'highlight')
					) then
						region:SetTexture(nil)
						region:SetAlpha(0)
					end
	
					region:ClearAllPoints()
					region:SetPoint("TOPLEFT", Child, 1, -1)
					region:SetPoint("BOTTOMRIGHT", Child, -1, 1)
					region:SetDrawLayer('ARTWORK')
					region:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				end
			end

			Child.Backdrop = CreateFrame("Frame", nil, Child)
			Child.Backdrop:SetPoint(TOPLEFT", Child, 0, 0)
			Child.Backdrop:SetPoint("BOTTOMRIGHT", Child, 0, 0)
			Child.Backdrop:SetBackdrop(vUI.Backdrop)
			Child.Backdrop:SetBackdropColor(0, 0, 0)
			Child.Backdrop:SetFrameLevel(Child:GetFrameLevel() - 1)
			
			Child.Backdrop.Texture = Child.Backdrop:CreateTexture(nil, "BACKDROP")
			Child.Backdrop.Texture:SetPoint("TOPLEFT", Child.Backdrop, 1, -1)
			Child.Backdrop.Texture:SetPoint("BOTTOMRIGHT", Child.Backdrop, -1, 1)
			Child.Backdrop.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
			Child.Backdrop.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))

			Child:SetFrameLevel(Minimap:GetFrameLevel() + 10)
			Child:SetFrameStrata(Minimap:GetFrameStrata())

			if (objectType == "Button" or objectType == "Frame") then
				if (Child.SetHighlightTexture) then
					local Highlight = Child:CreateTexture(nil, "ARTWORK", button)
					Highlight:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
					Highlight:SetVertexColor(1, 1, 1, 0.2)
					Highlight:SetPoint("TOPLEFT", Child, 1, -1)
					Highlight:SetPoint("BOTTOMRIGHT", Child, -1, 1)
					
					Child.Highlight = Highlight
					Child:SetHighlightTexture(Highlight)
				end

				if (Child.SetPushedTexture) then
					local Pushed = Child:CreateTexture(nil, "ARTWORK", button)
					Pushed:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
					Pushed:SetVertexColor(0.9, 0.8, 0.1, 0.3)
					Pushed:SetPoint("TOPLEFT", Child, 1, -1)
					Pushed:SetPoint("BOTTOMRIGHT", Child, -1, 1)
					
					Child.Pushed = Pushed
					Child:SetPushedTexture(Pushed)
				end
			end

      -- TODO: tooltip styling

			tinsert(self.items, Child)
		end
	end
end

function MinimapButtons:CreatePanel()
  local Frame = CreateFrame("Frame", "vUI Minimap Buttons", vUI.UIParent)
	Frame:SetBackdrop(vUI.BackdropAndBorder)
	Frame:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Frame:SetBackdropBorderColor(0, 0, 0)
	Frame:SetFrameStrata("LOW")

	-- NOTE: we are taking into account zone text panel
	local minimapHeight = Settings["minimap-size"] + 26
	
	if (Settings["minimap-show-time"]) then
		-- NOTE: here be unicorn numbers
		Frame:SetPoint("TOPRIGHT", vUI.UIParent, "TOPRIGHT", -12, -(minimapHeight + 26 + 13))
	else
		Frame:SetPoint("TOPRIGHT", vUI.UIParent, "TOPRIGHT", -12, -(minimapHeight + 6))
	end

  self.Panel = Frame
end

function MinimapButtons:Load()
  if (not Settings["minimap-buttonbar-enable"]) then
    return
  end

	self:CreatePanel()
  self:SkinButtons()	
  
  OnChange()

  vUI:CreateMover(self.Panel)
end

local DirectionOptions = { 
	["Up"] = "UP", 
	["Down"] = "DOWN", 
	["Left"] = "LEFT", 
	["Right"] = "RIGHT"
}

GUI:AddOptions(function(self)
	local _, Right = self:GetWindow(Language["Minimap"])

	Right:CreateHeader(Language["Minimap Buttons"])

	Right:CreateSwitch("minimap-buttonbar-enable", Settings["minimap-buttonbar-enable"], "Enable Minimap Button Bar", "", ReloadUI):RequiresReload(true)

	Right:CreateDropdown("minimap-buttonbar-direction", Settings["minimap-buttonbar-direction"], DirectionOptions, "Direction", "", function(value)
		OnChange(value, nil, nil)
	end)
	
	Right:CreateSlider("minimap-buttonbar-buttonsize", Settings["minimap-buttonbar-buttonsize"], 16, 44, 1, "Button Size", "", function(value)
		OnChange(nil, value, nil)
	end)
	
	Right:CreateSlider("minimap-buttonbar-buttonspacing", Settings["minimap-buttonbar-buttonspacing"], 1, 3, 1, "Button Spacing", "", function()
		OnChange(nil, nil, value)
	end)
	
end)
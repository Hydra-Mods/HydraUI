local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local MinimapButtons = vUI:NewModule("Minimap Buttons")

local strlower = string.lower
local strfind = string.find

MinimapButtons.items = {}

local Ignored = {
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

local RemoveByID = {
	[136430] = true,
	[136467] = true,
	[130924] = true,
}

function MinimapButtons:PositionButtons(perrow, size, spacing)
	local Total = #MinimapButtons.items

	if (Total < perrow) then
		perrow = Total
	end
	
	local Columns = ceil(Total / perrow)
	
	if (Columns < 1) then
		Columns = 1
	end
	
	-- Bar sizing
	MinimapButtons.Panel:SetWidth((size * perrow) + (spacing * (perrow - 1)) + 6)
	MinimapButtons.Panel:SetHeight((size * Columns) + (spacing * (Columns - 1)) + 6)
	
	-- Actual moving
	for i = 1, Total do
		local Button = MinimapButtons.items[i]
		
		Button:ClearAllPoints()
		Button:SetSize(size, size)
		
		if (i == 1) then
			Button:SetPoint("TOPLEFT", MinimapButtons.Panel, 3, -3)
		elseif ((i - 1) % perrow == 0) then
			Button:SetPoint("TOP", MinimapButtons.items[i - perrow], "BOTTOM", 0, -spacing)
		else
			Button:SetPoint("LEFT", MinimapButtons.items[i - 1], "RIGHT", spacing, 0)
		end
	end
end

function MinimapButtons:SkinButtons()
  for _, Child in pairs({Minimap:GetChildren()}) do
		local name = Child:GetName()

		if (name and not Ignored[name] and Child:IsShown()) then
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

					if (textureId and RemoveByID[textureId]) then
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
			Child.Backdrop:SetPoint("TOPLEFT", Child, 0, 0)
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
	Frame:SetPoint("TOPRIGHT", vUI:GetModule("Minimap"), "BOTTOMRIGHT", 0, -2)
	
	self.Panel = Frame
end

function MinimapButtons:Hide()
	self.Panel:Hide()
end

local UpdateBar = function()
	MinimapButtons:PositionButtons(Settings["minimap-buttons-perrow"], Settings["minimap-buttons-size"], Settings["minimap-buttons-spacing"])
end

function MinimapButtons:Load()
  if (not Settings["minimap-buttons-enable"]) then
    return
  end

	self:CreatePanel()
  self:SkinButtons()
	
	if (#self.items == 0) then
		self:Hide()
		
		return
	end
	
  UpdateBar()
  
   vUI:CreateMover(self.Panel)
end

GUI:AddOptions(function(self)
	local _, Right = self:GetWindow(Language["Mini Map"])

	Right:CreateHeader(Language["Minimap Buttons"])
	Right:CreateSwitch("minimap-buttons-enable", Settings["minimap-buttons-enable"], "Enable Minimap Button Bar", "", ReloadUI):RequiresReload(true)
	Right:CreateSlider("minimap-buttons-size", Settings["minimap-buttons-size"], 16, 44, 1, "Button Size", "", UpdateBar)
	Right:CreateSlider("minimap-buttons-spacing", Settings["minimap-buttons-spacing"], 1, 5, 1, "Button Spacing", "", UpdateBar)
	Right:CreateSlider("minimap-buttons-perrow", Settings["minimap-buttons-perrow"], 1, 20, 1, "Per Row", "", UpdateBar)
end)
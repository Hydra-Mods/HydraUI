local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local MinimapButtons = HydraUI:NewModule("Minimap Buttons")

local lower = string.lower
local find = string.find

MinimapButtons.Items = {}

local IgnoredBlizzard = {
	["BattlefieldMinimap"] = true,
	["ButtonCollectFrame"] = true,
	["FeedbackUIButton"] = true,
	["GameTimeFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["HelpOpenWebTicketButton"] = true,
	["MinimapBackdrop"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MiniMapLFGFrame"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapTracking"] = true,
	["MiniMapTrackingFrame"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["QueueStatusMinimapButton"] = true,
	["TimeManagerClockButton"] = true,
}

local IgnoredAddOns = {
	"archy",
	"bookoftracksframe",
	"cartographernotespoi",
	"cork",
	"da_minimap",
	"dugisarrowminimappoint",
	"enhancedframeminimapbutton",
	"fishingextravaganzamini",
	"flower",
	"fwgminimappoi",
	"gatherarchnote",
	"gathermatepin",
	"gathernote",
	"gfw_trackmenuframe",
	"gfw_trackmenubutton",
	"gpsarrow",
	"guildmap3mini",
	"guildinstance",
	"handynotespin",
	"librockconfig-1.0_minimapbutton",
	"mininotepoi",
	"nauticusminiicon",
	"poiminimap",
	"premadefilter_minimapbutton",
	"questieframe",
	"questpointerpoi",
	"reciperadarminimapicon",
	"spy_mapnotelist_mini",
	"tdial_trackingicon",
	"tdial_trackButton",
	"tuber",
	"westpointer",
	"zgvmarker",
}

local RemoveByID = {
	[136430] = true,
	[136467] = true,
	[130924] = true,
}

local IsIgnoredAddOn = function(name)
	name = lower(name)
	
	for i = 1, #IgnoredAddOns do
		if find(name, IgnoredAddOns[i]) then
			return true
		end
	end
end

function MinimapButtons:PositionButtons(perrow, size, spacing)
	local Total = #self.Items
	
	if (Total < perrow) then
		perrow = Total
	end
	
	local Columns = ceil(Total / perrow)
	
	if (Columns < 1) then
		Columns = 1
	end
	
	-- Panel sizing
	self.Panel:SetWidth((size * perrow) + (spacing * (perrow - 1)) + 6)
	self.Panel:SetHeight((size * Columns) + (spacing * (Columns - 1)) + 6)
	
	-- Positioning
	for i = 1, Total do
		local Button = self.Items[i]
		
		Button:ClearAllPoints()
		Button:SetSize(size, size)
		
		if (i == 1) then
			Button:SetPoint("TOPLEFT", self.Panel, 3, -3)
		elseif ((i - 1) % perrow == 0) then
			Button:SetPoint("TOP", self.Items[i - perrow], "BOTTOM", 0, -spacing)
		else
			Button:SetPoint("LEFT", self.Items[i - 1], "RIGHT", spacing, 0)
		end
	end
end

function MinimapButtons:SkinButtons()
	for _, Child in next, {Minimap:GetChildren()} do
		local Name = Child:GetName()
		local Type = Child:GetObjectType()
		
		if (Child:IsShown() and Type ~= "Frame") then
			local Valid = (Name and not IgnoredBlizzard[Name] and not IsIgnoredAddOn(Name)) or not Name
			
			if Valid then
				Child:SetParent(self.Panel)
				
				if (Child:HasScript("OnDragStart")) then
					Child:SetScript("OnDragStart", nil)
				end
				
				if (Child:HasScript("OnDragStop")) then
					Child:SetScript("OnDragStop", nil)
				end
				
				for i = 1, Child:GetNumRegions() do
					local Region = select(i, Child:GetRegions())
					
					if (Region:GetObjectType() == "Texture") then
						local ID = Region:GetTextureFileID()
						local Texture = Region:GetTexture() or ""
						Texture = lower(Texture)
						
						if (ID and RemoveByID[ID]) then
							Region:SetTexture(nil)
						end
						
						if (
							find(Texture, [[interface\characterframe]]) or
							find(Texture, [[interface\minimap]]) or
							find(Texture, "border") or 
							find(Texture, "background") or 
							find(Texture, "alphamask") or
							find(Texture, "highlight")
						) then
							Region:SetTexture(nil)
							Region:SetAlpha(0)
						end
						
						Region:ClearAllPoints()
						Region:SetPoint("TOPLEFT", Child, 1, -1)
						Region:SetPoint("BOTTOMRIGHT", Child, -1, 1)
						Region:SetDrawLayer('ARTWORK')
						Region:SetTexCoord(0.1, 0.9, 0.1, 0.9)
					end
				end
				
				Child.Backdrop = CreateFrame("Frame", nil, Child, "BackdropTemplate")
				Child.Backdrop:SetPoint("TOPLEFT", Child, 0, 0)
				Child.Backdrop:SetPoint("BOTTOMRIGHT", Child, 0, 0)
				Child.Backdrop:SetBackdrop(HydraUI.Backdrop)
				Child.Backdrop:SetBackdropColor(0, 0, 0)
				Child.Backdrop:SetFrameLevel(Child:GetFrameLevel() - 1)
				
				Child.Backdrop.Texture = Child.Backdrop:CreateTexture(nil, "BACKDROP")
				Child.Backdrop.Texture:SetPoint("TOPLEFT", Child.Backdrop, 1, -1)
				Child.Backdrop.Texture:SetPoint("BOTTOMRIGHT", Child.Backdrop, -1, 1)
				Child.Backdrop.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
				Child.Backdrop.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
				
				Child:SetFrameLevel(Minimap:GetFrameLevel() + 10)
				Child:SetFrameStrata(Minimap:GetFrameStrata())
				
				if (Type == "Button" or Type == "Frame") then
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
				
				tinsert(self.Items, Child)
			end
		end
	end
end

function MinimapButtons:CreatePanel()
	local Frame = CreateFrame("Frame", "HydraUI Minimap Buttons", HydraUI.UIParent, "BackdropTemplate")
	Frame:SetBackdrop(HydraUI.BackdropAndBorder)
	Frame:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Frame:SetBackdropBorderColor(0, 0, 0)
	Frame:SetFrameStrata("LOW")
	Frame:SetPoint("TOPRIGHT", HydraUI:GetModule("Minimap").BottomFrame, "BOTTOMRIGHT", 0, -2)
	
	self.Panel = Frame
end

function MinimapButtons:Hide()
	self.Panel:Hide()
end

local UpdateBar = function()
	MinimapButtons:PositionButtons(Settings["minimap-buttons-perrow"], Settings["minimap-buttons-size"], Settings["minimap-buttons-spacing"])
end

local DelayedLoad = function()
	MinimapButtons:CreatePanel()
	MinimapButtons:SkinButtons()
	
	if (#MinimapButtons.Items == 0) then
		MinimapButtons:Hide()
		
		return
	end
	
	UpdateBar()
	
	HydraUI:CreateMover(MinimapButtons.Panel)
end

function MinimapButtons:Load()
	if (not Settings["minimap-buttons-enable"]) then
		return
	end
	
	C_Timer.After(2, DelayedLoad)
end

GUI:AddWidgets(Language["General"], Language["Minimap"], function(left, right)
	right:CreateHeader(Language["Minimap Buttons"])
	right:CreateSwitch("minimap-buttons-enable", Settings["minimap-buttons-enable"], Language["Enable Minimap Button Bar"], "", ReloadUI):RequiresReload(true)
	right:CreateSlider("minimap-buttons-size", Settings["minimap-buttons-size"], 16, 44, 1, Language["Button Size"], "", UpdateBar)
	right:CreateSlider("minimap-buttons-spacing", Settings["minimap-buttons-spacing"], 1, 5, 1, Language["Button Spacing"], "", UpdateBar)
	right:CreateSlider("minimap-buttons-perrow", Settings["minimap-buttons-perrow"], 1, 20, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateBar)
end)
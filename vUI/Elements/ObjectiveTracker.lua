local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

if 1 == 1 then
	return
end

local Tracker = vUI:NewModule("Objective Tracker")

--[[
	SCENARIO_CONTENT_TRACKER_MODULE
	UI_WIDGET_TRACKER_MODULE
	AUTO_QUEST_POPUP_TRACKER_MODULE
	BONUS_OBJECTIVE_TRACKER_MODULE
	WORLD_QUEST_TRACKER_MODULE
	QUEST_TRACKER_MODULE
	ACHIEVEMENT_TRACKER_MODULE
--]]

function Tracker:Move()
	self:SetSize(235, 300)
	self:SetPoint("RIGHT", vUIParent, -120, 120)
	
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", self, 0, 0)
	
	vUI:CreateMover(self)
end

local AddObjective = function(self, block, objective)
	if (not block.HeaderText.Handled) then
		vUI:SetFontInfo(block.HeaderText, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
		block.HeaderText.Handled = true
	end
	
	local Line = block.lines[objective]
	
	if (Line and not Line.Handled) then
		vUI:SetFontInfo(Line.Text, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
		Line.Handled = true
		
		if (Line.Dash and not Line.Dash.Handled) then
			vUI:SetFontInfo(Line.Dash, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
			Line.Dash.Handled = true
		end
	end
end

local UpdateMinimizeButton = function()
	if ObjectiveTrackerFrame.collapsed then
		ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture:SetTexture(Assets:GetTexture("Arrow Down"))
	else
		ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
	end
end

function Tracker:StyleWindow()
	-- Header
	vUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	-- Quests
	ObjectiveTrackerBlocksFrame.QuestHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.QuestHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	-- Scenario
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.ScenarioHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	-- Achievement
	ObjectiveTrackerBlocksFrame.AchievementHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	-- Bonus
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Background:Hide()
	vUI:SetFontInfo(BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	--[[local Title = ObjectiveTrackerFrame:CreateFontString(nil, "OVERLAY")
	Title:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
	vUI:SetFontInfo(Title, Settings["ui-header-font"], 12)
	Title:SetJustifyH("LEFT")
	Title:SetText(QUESTS_LABEL)
	
	local TitleDiv = CreateFrame("Frame", nil, ObjectiveTrackerFrame)
	TitleDiv:SetSize(156, 4)
	TitleDiv:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, -6)
	TitleDiv:SetBackdrop(vUI.BackdropAndBorder)
	TitleDiv:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	TitleDiv:SetBackdropBorderColor(0, 0, 0)
	
	TitleDiv.Texture = TitleDiv:CreateTexture(nil, "OVERLAY")
	TitleDiv.Texture:SetPoint("TOPLEFT", TitleDiv, 1, -1)
	TitleDiv.Texture:SetPoint("BOTTOMRIGHT", TitleDiv, -1, 1)
	TitleDiv.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TitleDiv.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))]]
	
	-- Hide minimize button
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetNormalTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPushedTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetHighlightTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetDisabledTexture("")
	
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize = CreateFrame("Frame", nil, ObjectiveTrackerFrame)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetSize(20, 20)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetPoint("CENTER", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, 0, 0)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetBackdrop(vUI.BackdropAndBorder)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetBackdropBorderColor(0, 0, 0)
	
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture = ObjectiveTrackerFrame.HeaderMenu.NewMinimize:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture:SetSize(16, 16)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture:SetPoint("CENTER", ObjectiveTrackerFrame.HeaderMenu.NewMinimize, 0, 0)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
end

function Tracker:AddHooks()
	if (not ObjectiveTrackerFrame.initialized) then -- I'll move or hook this case later, but the tracker also loads on player entering world, so sometimes we need to start it
		ObjectiveTracker_Initialize(ObjectiveTrackerFrame)
		
		ObjectiveTracker_Update()
		
		if (not QuestSuperTracking_IsSuperTrackedQuestValid()) then
			QuestSuperTracking_ChooseClosestQuest()
		end
		
		ObjectiveTrackerFrame.lastMapID = C_Map.GetBestMapForUnit("player")
	end
	
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		hooksecurefunc(ObjectiveTrackerFrame.MODULES[i], "AddObjective", AddObjective)
	end
	
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddObjective", AddObjective)
	
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnClick", UpdateMinimizeButton)
end

function Tracker:Load()
	if (not Settings["tracker-enable"]) then
		return
	end
	
	self:Move()
	self:StyleWindow()
	self:AddHooks()
end

local UpdateFont = function()
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		for ID, Block in pairs(ObjectiveTrackerFrame.MODULES[i].usedBlocks) do
			for Key, Value in pairs(Block.lines) do
				vUI:SetFontInfo(Value.Text, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
				
				if Value.Dash then
					vUI:SetFontInfo(Value.Dash, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
				end
			end
		end
	end
end

local UpdateHeaderFont = function()
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		for ID, Block in pairs(ObjectiveTrackerFrame.MODULES[i].usedBlocks) do
			vUI:SetFontInfo(Block.HeaderText, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
		end
	end
	
	vUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.QuestHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.ScenarioHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	vUI:SetFontInfo(BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Objectives"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("tracker-enable", Settings["tracker-enable"], Language["Enable Tracker Module"], Language["Enable the vUI tracker module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Font"])
	Left:CreateDropdown("tracker-font", Settings["tracker-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the tracker lines"], UpdateFont, "Font")
	Left:CreateSlider("tracker-font-size", Settings["tracker-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the tracker lines"], UpdateFont)
	Left:CreateDropdown("tracker-font-flags", Settings["tracker-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the tracker lines"], UpdateFont)
	
	Left:CreateHeader(Language["Header Font"])
	Left:CreateDropdown("tracker-header-font", Settings["tracker-header-font"], Assets:GetFontList(), Language["Header Font"], Language["Set the font of the tracker header lines"], UpdateHeaderFont, "Font")
	Left:CreateSlider("tracker-header-font-size", Settings["tracker-header-font-size"], 8, 18, 1, Language["Header Font Size"], Language["Set the font size of the tracker header lines"], UpdateHeaderFont)
	Left:CreateDropdown("tracker-header-font-flags", Settings["tracker-header-font-flags"], Assets:GetFlagsList(), Language["Header Font Flags"], Language["Set the font flags of the tracker header lines"], UpdateHeaderFont)
end)
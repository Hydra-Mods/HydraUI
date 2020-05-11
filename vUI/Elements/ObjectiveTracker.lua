local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

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
	self:SetSize(235, 140)
	self:SetPoint("RIGHT", vUIParent, -120, 120)
	
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", self, 0, 0)
	
	vUI:CreateMover(self)
end

local AddObjective = function(self, block, objective)
	vUI:SetFontInfo(block.HeaderText, Assets:GetFont(Settings["ui-font"]), 14)
	
	local Line = block.lines[objective]
	
	if Line then
		vUI:SetFontInfo(Line.Text, Assets:GetFont(Settings["ui-font"]), 12)
		
		if Line.Dash then
			vUI:SetFontInfo(Line.Dash, Assets:GetFont(Settings["ui-font"]), 12)
		end
	end
end

function Tracker:StyleWindow()
	-- Header
	vUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Assets:GetFont(Settings["ui-header-font"]), 14)
	
	-- Quests
	ObjectiveTrackerBlocksFrame.QuestHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.QuestHeader.Text, Assets:GetFont(Settings["ui-header-font"]), 14)
	
	-- Scenario
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.ScenarioHeader.Text, Assets:GetFont(Settings["ui-header-font"]), 14)
	
	-- Achievement
	ObjectiveTrackerBlocksFrame.AchievementHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, Assets:GetFont(Settings["ui-header-font"]), 14)
	
	-- Bonus
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Background:Hide()
	vUI:SetFontInfo(BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text, Assets:GetFont(Settings["ui-header-font"]), 14)
end

function Tracker:AddHooks()
	if (not ObjectiveTrackerFrame.initialized) then -- I'll move or hook this case later, but the tracker also loads on player entering world, so sometimes we need to start it
		ObjectiveTracker_Initialize(ObjectiveTrackerFrame)
		
		ObjectiveTracker_Update()
		
		if not QuestSuperTracking_IsSuperTrackedQuestValid() then
			QuestSuperTracking_ChooseClosestQuest()
		end
		
		ObjectiveTrackerFrame.lastMapID = C_Map.GetBestMapForUnit("player")
	end
	
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		hooksecurefunc(ObjectiveTrackerFrame.MODULES[i], "AddObjective", AddObjective)
	end
	
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddObjective", AddObjective)
end

function Tracker:Load()
	self:Move()
	self:StyleWindow()
	self:AddHooks()
end
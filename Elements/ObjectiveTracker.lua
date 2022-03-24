local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Tracker = HydraUI:NewModule("Objective Tracker")

-- Default settings values
Defaults["tracker-enable"] = true
Defaults["tracker-enable-backdrop"] = false
Defaults["tracker-backdrop-opacity"] = 70
Defaults["tracker-height"] = 400
Defaults["tracker-font"] = "Roboto"
Defaults["tracker-font-size"] = 12
Defaults["tracker-font-flags"] = ""
Defaults["tracker-header-font"] = "Roboto"
Defaults["tracker-header-font-size"] = 12
Defaults["tracker-header-font-flags"] = ""
Defaults["tracker-module-font"] = "Roboto"
Defaults["tracker-module-font-size"] = 12
Defaults["tracker-module-font-flags"] = ""
Defaults["tracker-module-font-color"] = "FFE6C0"
Defaults["tracker-color-normal"] = "FAFAFA"
Defaults["tracker-color-normal-highlight"] = "FFFFFF"
Defaults["tracker-color-header"] = "FFB54F"
Defaults["tracker-color-header-highlight"] = "FFFFFF"
Defaults["tracker-color-failed"] = "D32F2F"
Defaults["tracker-color-failed-highlight"] = "F44336"
Defaults["tracker-color-timeleft"] = "D32F2F"
Defaults["tracker-color-timeleft-highlight"] = "F44336"
Defaults["tracker-color-complete"] = "A0A0A0"

function Tracker:MoveTrackerFrame()
	self:SetSize(253, Settings["tracker-height"] + 2)
	self:SetPoint("RIGHT", HydraUIParent, -120, 0)
	
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", self, 4, -1)
	ObjectiveTrackerFrame:SetHeight(Settings["tracker-height"])
	
	HydraUI:CreateMover(self)
end

local AddObjective = function(self, block, objective)
	if (block.HeaderText and not block.HeaderText.Handled) then
		HydraUI:SetFontInfo(block.HeaderText, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
		block.HeaderText:SetTextColor(HydraUI:HexToRGB(Settings["tracker-color-header"]))
		block.HeaderText.Handled = true
	end
	
	if (block.itemButton and not block.itemButton.Handled) then
		local ItemButton = block.itemButton
	
		ItemButton:ClearAllPoints()
		ItemButton:SetPoint("TOPRIGHT", block, "TOPRIGHT", 2, 0)
		ItemButton:SetSize(28, 28)
		ItemButton:SetNormalTexture("")
		
		if ItemButton.Border then
			ItemButton.Border:SetTexture(nil)
		end
		
		if ItemButton.icon then
			ItemButton.icon:ClearAllPoints()
			ItemButton.icon:SetPoint("TOPLEFT", ItemButton, 1, -1)
			ItemButton.icon:SetPoint("BOTTOMRIGHT", ItemButton, -1, 1)
			ItemButton.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		
		if ItemButton.Count then
			ItemButton.Count:ClearAllPoints()
			ItemButton.Count:SetPoint("TOPRIGHT", ItemButton, -2, -2)
			HydraUI:SetFontInfo(ItemButton.Count, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
			ItemButton.Count:SetJustifyH("RIGHT")
			ItemButton.Count:SetDrawLayer("OVERLAY")
			ItemButton.Count:SetTextColor(1, 1, 1)
		end
		
		ItemButton.Backdrop = CreateFrame("Frame", nil, ItemButton, "BackdropTemplate")
		ItemButton.Backdrop:SetPoint("TOPLEFT", ItemButton, 0, 0)
		ItemButton.Backdrop:SetPoint("BOTTOMRIGHT", ItemButton, 0, 0)
		ItemButton.Backdrop:SetBackdrop(HydraUI.Outline)
		ItemButton.Backdrop:SetBackdropBorderColor(0, 0, 0)
		ItemButton.Backdrop:SetFrameStrata("MEDIUM")
		
		if ItemButton:GetPushedTexture() then
			local Pushed = ItemButton:GetPushedTexture()
			Pushed:SetTexture(Assets:GetTexture("Blank"))
			Pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			Pushed:SetPoint("TOPLEFT", ItemButton, 1, -1)
			Pushed:SetPoint("BOTTOMRIGHT", ItemButton, -1, 1)
		end
		
		local Highlight = ItemButton:GetHighlightTexture()
		Highlight:SetTexture(Assets:GetTexture("Blank"))
		Highlight:SetColorTexture(1, 1, 1, 0.2)
		Highlight:SetPoint("TOPLEFT", ItemButton, 1, -1)
		Highlight:SetPoint("BOTTOMRIGHT", ItemButton, -1, 1)
		
		ItemButton.Handled = true
	end
	
	local Line = block.lines[objective]
	
	if (Line and not Line.Handled) then
		HydraUI:SetFontInfo(Line.Text, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
		Line.Handled = true
		
		if (Line.Dash and not Line.Dash.Handled) then
			HydraUI:SetFontInfo(Line.Dash, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
			Line.Dash.Handled = true
		end
	end
end

local HideWorldQuestPOI = function(self)
	self:SetAlpha(0)
end

local UpdateMinimizeButton = function()
	if ObjectiveTrackerFrame.collapsed then
		ObjectiveTrackerFrame.HeaderMenu.Texture:SetTexture(Assets:GetTexture("Arrow Down"))
		
		if Settings["tracker-enable-backdrop"] then
			ObjectiveTrackerFrame.BG:Hide()
		end
	else
		ObjectiveTrackerFrame.HeaderMenu.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
		
		if Settings["tracker-enable-backdrop"] then
			ObjectiveTrackerFrame.BG:Show()
		end
	end
end

function Tracker:ReplaceColor(key, value)
	local R, G, B = HydraUI:HexToRGB(value)
	
	OBJECTIVE_TRACKER_COLOR[key].r = R
	OBJECTIVE_TRACKER_COLOR[key].g = G
	OBJECTIVE_TRACKER_COLOR[key].b = B
end

local MinimizeHook = function(button, collapsed)
	if collapsed then
		button.Texture:SetTexture(Assets:GetTexture("Arrow Down"))
	else
		button.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
	end
	
	for i = 1, button:GetNumRegions() do
		local Region = select(i, button:GetRegions())
		
		if (Region and Region:GetObjectType() == "Texture") then
			Region:SetTexture(nil)
		end
	end
end

function Tracker:CreateCustomHeader(tracker)
	if tracker.Background then
		tracker.Background:Hide()
	end
	
	if tracker.Text then
		HydraUI:SetFontInfo(tracker.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
		tracker.Text:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
	end
	
	if tracker.MinimizeButton then
		tracker.MinimizeButton.Texture = ObjectiveTrackerFrame.HeaderMenu:CreateTexture(nil, "OVERLAY")
		tracker.MinimizeButton.Texture:SetSize(16, 16)
		tracker.MinimizeButton.Texture:SetPoint("CENTER", tracker.MinimizeButton, 0, -1)
		tracker.MinimizeButton.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
		tracker.MinimizeButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
		
		hooksecurefunc(tracker.MinimizeButton, "SetCollapsed", MinimizeHook)
		
		for i = 1, tracker.MinimizeButton:GetNumRegions() do
			local Region = select(i, tracker.MinimizeButton:GetRegions())
			
			if (Region and Region:GetObjectType() == "Texture") then
				Region:SetTexture(nil)
			end
		end
	end
	
	if (tracker and tracker.CreateTexture) then
		tracker.BG = tracker:CreateTexture(nil, "BORDER")
		tracker.BG:SetPoint("TOPLEFT", tracker, 0, -2)
		tracker.BG:SetPoint("BOTTOMRIGHT", tracker, 12, -1)
		tracker.BG:SetTexture(Assets:GetTexture("Blank"))
		tracker.BG:SetVertexColor(0, 0, 0)
		
		tracker.Texture = tracker:CreateTexture(nil, "ARTWORK")
		tracker.Texture:SetPoint("TOPLEFT", tracker, 1, -3)
		tracker.Texture:SetPoint("BOTTOMRIGHT", tracker, 11, 0)
		tracker.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
		tracker.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	end
end

function Tracker:StyleWindow()
	self:ReplaceColor("Normal", Settings["tracker-color-normal"])
	self:ReplaceColor("NormalHighlight", Settings["tracker-color-normal-highlight"])
	self:ReplaceColor("Failed", Settings["tracker-color-failed"])
	self:ReplaceColor("FailedHighlight", Settings["tracker-color-failed-highlight"])
	self:ReplaceColor("Header", Settings["tracker-color-header"])
	self:ReplaceColor("HeaderHighlight", Settings["tracker-color-header-highlight"])
	self:ReplaceColor("TimeLeft", Settings["tracker-color-timeleft"])
	self:ReplaceColor("TimeLeftHighlight", Settings["tracker-color-timeleft-highlight"])
	self:ReplaceColor("Complete", Settings["tracker-color-complete"])
	
	-- Header
	HydraUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	self:CreateCustomHeader(ObjectiveTrackerBlocksFrame.QuestHeader) -- Quests
	self:CreateCustomHeader(ObjectiveTrackerBlocksFrame.ScenarioHeader) -- Scenario
	self:CreateCustomHeader(ObjectiveTrackerBlocksFrame.AchievementHeader) -- Achievement
	self:CreateCustomHeader(CAMPAIGN_QUEST_TRACKER_MODULE.Header) -- Bonus
	self:CreateCustomHeader(BONUS_OBJECTIVE_TRACKER_MODULE.Header) -- Bonus
	self:CreateCustomHeader(WORLD_QUEST_TRACKER_MODULE.Header) -- World Quests
	self:CreateCustomHeader(ObjectiveTrackerFrame.BlocksFrame.CampaignQuestHeader) -- Campaign
	
	-- Backdrop
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	ObjectiveTrackerFrame.BG = CreateFrame("Frame", nil, ObjectiveTrackerFrame, "BackdropTemplate")
	ObjectiveTrackerFrame.BG:SetBackdrop(HydraUI.BackdropAndBorder)
	ObjectiveTrackerFrame.BG:SetPoint("TOPLEFT", ObjectiveTrackerFrame, -13, 1)
	ObjectiveTrackerFrame.BG:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame, 5, -1)
	ObjectiveTrackerFrame.BG:SetBackdropColor(R, G, B, Settings["tracker-backdrop-opacity"] / 100)
	ObjectiveTrackerFrame.BG:SetBackdropBorderColor(0, 0, 0)
	
	ObjectiveTrackerFrame.BG.Top = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Top:SetHeight(2)
	ObjectiveTrackerFrame.BG.Top:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Top:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Top:SetPoint("TOPLEFT", ObjectiveTrackerFrame.BG, 1, -1)
	ObjectiveTrackerFrame.BG.Top:SetPoint("TOPRIGHT", ObjectiveTrackerFrame.BG, -1, -1)
	
	ObjectiveTrackerFrame.BG.Bottom = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Bottom:SetHeight(2)
	ObjectiveTrackerFrame.BG.Bottom:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Bottom:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Bottom:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame.BG, 1, 1)
	ObjectiveTrackerFrame.BG.Bottom:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame.BG, -1, 1)
	
	ObjectiveTrackerFrame.BG.Left = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Left:SetWidth(2)
	ObjectiveTrackerFrame.BG.Left:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Left:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Left:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame.BG, 1, 1)
	ObjectiveTrackerFrame.BG.Left:SetPoint("TOPLEFT", ObjectiveTrackerFrame.BG, 1, -1)
	
	ObjectiveTrackerFrame.BG.Right = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Right:SetWidth(2)
	ObjectiveTrackerFrame.BG.Right:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Right:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Right:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame.BG, -1, 1)
	ObjectiveTrackerFrame.BG.Right:SetPoint("TOPRIGHT", ObjectiveTrackerFrame.BG, -1, -1)
	
	ObjectiveTrackerFrame.BG.InnerBorder = CreateFrame("Frame", nil, ObjectiveTrackerFrame.BG, "BackdropTemplate")
	ObjectiveTrackerFrame.BG.InnerBorder:SetPoint("TOPLEFT", ObjectiveTrackerFrame.BG, 3, -3)
	ObjectiveTrackerFrame.BG.InnerBorder:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame.BG, -3, 3)
	ObjectiveTrackerFrame.BG.InnerBorder:SetBackdrop(HydraUI.Outline)
	ObjectiveTrackerFrame.BG.InnerBorder:SetBackdropBorderColor(0, 0, 0)
	
	if (not Settings["tracker-enable-backdrop"]) then
		ObjectiveTrackerFrame.BG:Hide()
	end
	
	-- Hide minimize button
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetNormalTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPushedTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetHighlightTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetDisabledTexture("")
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:ClearAllPoints()
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, -4, -6)
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetAlpha(0)
	
	ObjectiveTrackerFrame.HeaderMenu.Texture = ObjectiveTrackerFrame.HeaderMenu:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetSize(16, 16)
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetPoint("RIGHT", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, 0, 0)
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetPoint("CENTER", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, 0, 0)
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
end

local AddProgressBar = function(self, block, line)
	if line.ProgressBar.Bar.Handled then
		return
	end
	
	line.ProgressBar.Bar:ClearAllPoints()
	line.ProgressBar.Bar:SetPoint("LEFT", block.currentLine, 22, 0)
	line.ProgressBar.Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	line.ProgressBar.Bar:SetSize(200, 18)
	
	if line.ProgressBar.Bar.BarBG then
		line.ProgressBar.Bar.BarBG:SetTexture()
	end
	
	line.ProgressBar.Bar.Backdrop = CreateFrame("Frame", nil, line.ProgressBar.Bar, "BackdropTemplate")
	line.ProgressBar.Bar.Backdrop:SetPoint("TOPLEFT", line.ProgressBar.Bar, -1, 1)
	line.ProgressBar.Bar.Backdrop:SetPoint("BOTTOMRIGHT", line.ProgressBar.Bar, 1, -1)
	line.ProgressBar.Bar.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	line.ProgressBar.Bar.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	line.ProgressBar.Bar.Backdrop:SetBackdropBorderColor(0, 0, 0)
	line.ProgressBar.Bar.Backdrop:SetFrameLevel(line.ProgressBar.Bar:GetFrameLevel() - 1)
	
	line.ProgressBar.Bar.BGTexture = line.ProgressBar.Bar.Backdrop:CreateTexture(nil, "BACKGROUND")
	line.ProgressBar.Bar.BGTexture:SetPoint("TOPLEFT", line.ProgressBar.Bar.Backdrop, 0, 0)
	line.ProgressBar.Bar.BGTexture:SetPoint("BOTTOMRIGHT", line.ProgressBar.Bar.Backdrop, 0, 0)
	line.ProgressBar.Bar.BGTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	line.ProgressBar.Bar.BGTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	
	if line.ProgressBar.Bar.Icon then
		line.ProgressBar.Bar.Icon:ClearAllPoints()
		line.ProgressBar.Bar.Icon:SetPoint("LEFT", line.ProgressBar.Bar, "RIGHT", 4, 0)
		line.ProgressBar.Bar.Icon:SetSize(18, 18)
		line.ProgressBar.Bar.Icon:SetMask("")
		line.ProgressBar.Bar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		
		line.ProgressBar.Bar.Icon.Backdrop = CreateFrame("Frame", nil, line.ProgressBar.Bar, "BackdropTemplate")
		line.ProgressBar.Bar.Icon.Backdrop:SetPoint("TOPLEFT", line.ProgressBar.Bar.Icon, -1, 1)
		line.ProgressBar.Bar.Icon.Backdrop:SetPoint("BOTTOMRIGHT", line.ProgressBar.Bar.Icon, 1, -1)
		line.ProgressBar.Bar.Icon.Backdrop:SetBackdrop(HydraUI.Outline)
		line.ProgressBar.Bar.Icon.Backdrop:SetBackdropBorderColor(0, 0, 0)
		line.ProgressBar.Bar.Icon.Backdrop:SetFrameStrata("BACKGROUND")
	end
	
	if line.ProgressBar.Bar.BarFrame then
		line.ProgressBar.Bar.BarFrame:Hide()
	end
	
	if line.ProgressBar.Bar.BarFrame2 then
		line.ProgressBar.Bar.BarFrame2:Hide()
	end
	
	if line.ProgressBar.Bar.BarFrame3 then
		line.ProgressBar.Bar.BarFrame3:Hide()
	end
	
	if line.ProgressBar.Bar.BarGlow then
		line.ProgressBar.Bar.BarGlow:Hide()
	end
	
	if line.ProgressBar.Bar.Sheen then
		line.ProgressBar.Bar.Sheen:Hide()
	end
	
	if line.ProgressBar.Bar.Label then
		line.ProgressBar.Bar.Label:ClearAllPoints()
		line.ProgressBar.Bar.Label:SetPoint("CENTER", line.ProgressBar.Bar)
		line.ProgressBar.Bar.Label:SetFont(Assets:GetFont(Settings["tracker-font"]), Settings["tracker-font-size"], Settings["tracker-font-flags"])
	end
	
	if line.ProgressBar.Bar.IconBG then
		line.ProgressBar.Bar.IconBG:SetTexture()
	end
	
	line.ProgressBar.Bar.Handled = true
end

local PopupOnEnter = function(self)
	self.Backdrop.Highlight:Show()
end

local PopupOnLeave = function(self)
	self.Backdrop.Highlight:Hide()
end

local SkinAutoQuestPopup = function()
	for i = 1, GetNumAutoQuestPopUps() do
		local QuestID, PopupType = GetAutoQuestPopUp(i)
		
		--[[if IsQuestBounty(QuestID) then
			return
		end]]
		
		local QuestTitle = C_QuestLog.GetTitleForQuestID(QuestID)
		
		if (QuestTitle and QuestTitle ~= "") then
			local Block = AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(QuestID)
			
			if Block then
				local BlockContents = Block.ScrollChild
				
				BlockContents:ClearAllPoints()
				BlockContents:SetPoint("LEFT", Block, 0, 2)
				BlockContents:GetParent():SetWidth(268)
				
				if (not BlockContents.Backdrop) then
					BlockContents.Backdrop = CreateFrame("Frame", nil, BlockContents, "BackdropTemplate")
					--BlockContents.Backdrop:SetPoint("TOPLEFT", BlockContents:GetParent(), 36, -1)
					--BlockContents.Backdrop:SetPoint("BOTTOMRIGHT", BlockContents:GetParent(), 40, 1)
					BlockContents.Backdrop:SetPoint("TOPLEFT", BlockContents:GetParent(), 38, 0)
					BlockContents.Backdrop:SetPoint("BOTTOMRIGHT", BlockContents:GetParent(), -1, 0)
					BlockContents.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
					BlockContents.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
					BlockContents.Backdrop:SetBackdropBorderColor(0, 0, 0)
					BlockContents.Backdrop:SetFrameLevel(BlockContents:GetFrameLevel() - 1)
					--BlockContents:HookScript("OnEnter", PopupOnEnter)
					--BlockContents:HookScript("OnLeave", PopupOnLeave)
					
					BlockContents.Backdrop.Highlight = BlockContents.Backdrop:CreateTexture(nil, "BACKGROUND")
					BlockContents.Backdrop.Highlight:SetPoint("TOPLEFT", BlockContents.Backdrop, 1, -1)
					BlockContents.Backdrop.Highlight:SetPoint("BOTTOMRIGHT", BlockContents.Backdrop, -1, 0)
					BlockContents.Backdrop.Highlight:SetTexture(Assets:GetTexture("Blank"))
					BlockContents.Backdrop.Highlight:SetVertexColor(1, 1, 1, 0.1)
					BlockContents.Backdrop.Highlight:Hide()
				end
				
				if (not BlockContents.Handled) then
					HydraUI:SetFontInfo(BlockContents.TopText, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
					HydraUI:SetFontInfo(BlockContents.BottomText, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
					HydraUI:SetFontInfo(BlockContents.QuestName, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
					
					BlockContents.Handled = true
				end
				
				if  (PopupType == "COMPLETE") then
					BlockContents.QuestionMark:ClearAllPoints()
					BlockContents.QuestionMark:SetPoint("LEFT", BlockContents.Backdrop, 18, 0)
				elseif (PopupType == "OFFER") then
					BlockContents.Exclamation:ClearAllPoints()
					BlockContents.Exclamation:SetPoint("LEFT", BlockContents.Backdrop, 18, 0)
				end
				
				BlockContents.Bg:Hide()
				BlockContents.QuestIconBg:Hide()
				BlockContents.QuestIconBadgeBorder:Hide()
				BlockContents.Shine:Hide()
				BlockContents.IconShine:Hide()
				BlockContents.FlashFrame:Hide()
				BlockContents.BorderTopLeft:Hide()
				BlockContents.BorderTopRight:Hide()
				BlockContents.BorderBotLeft:Hide()
				BlockContents.BorderBotRight:Hide()
				BlockContents.BorderLeft:Hide()
				BlockContents.BorderRight:Hide()
				BlockContents.BorderTop:Hide()
				BlockContents.BorderBottom:Hide()
			end
		end
	end
end

local UpdateScenarioBlock = function()
	local StageBlock = ScenarioStageBlock
	
	StageBlock.NormalBG:Hide()
	StageBlock.FinalBG:Hide()
	StageBlock.GlowTexture:Hide()
	HydraUI:SetFontInfo(StageBlock.Stage, Settings["tracker-font"], 18, Settings["tracker-font-flags"])
	HydraUI:SetFontInfo(StageBlock.CompleteLabel, Settings["tracker-font"], 18, Settings["tracker-font-flags"])
	HydraUI:SetFontInfo(StageBlock.Name, Settings["tracker-font"], 18, Settings["tracker-font-flags"])
	
	--[[if (not StageBlock.Backdrop) then
		StageBlock.Backdrop = CreateFrame("Frame", nil, StageBlock)
		StageBlock.Backdrop:SetPoint("TOPLEFT", StageBlock, 1, -1)
		StageBlock.Backdrop:SetPoint("BOTTOMRIGHT", StageBlock, -1, 1)
		StageBlock.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
		StageBlock.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
		StageBlock.Backdrop:SetBackdropBorderColor(0, 0, 0)
		StageBlock.Backdrop:SetFrameLevel(StageBlock:GetFrameLevel() - 1)
	end]]
	
	--[[StageBlock.Stage:ClearAllPoints()
	StageBlock.Stage:SetPoint("CENTER", StageBlock.Backdrop, 0, 0)
	HydraUI:SetFontInfo(StageBlock.Stage, Settings["tracker-font"], 18, Settings["tracker-font-flags"])]]
	
	--[[
	local ChallengeBlock = ScenarioChallengeModeBlock
	
	ChallengeBlock.TimerBGBack:Hide()
	ChallengeBlock.TimerBG:Hide()
	
	ChallengeBlock.StatusBar
	
	HydraUI:SetFontInfo(ChallengeBlock.Level, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
	HydraUI:SetFontInfo(ChallengeBlock.TimeLeft, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
	HydraUI:SetFontInfo(ChallengeBlock.DeathCount.Count, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
	--]]
end

function Tracker:AddHooks()
	if (not ObjectiveTrackerFrame.initialized) then -- I'll move or hook this case later, but the tracker also loads on player entering world, so sometimes we need to start it
		ObjectiveTracker_Initialize(ObjectiveTrackerFrame)
		
		--ObjectiveTracker_Update() -- Tainting in 9.1
		
		if (not QuestSuperTracking_IsSuperTrackedQuestValid()) then
			QuestSuperTracking_ChooseClosestQuest()
		end
		
		ObjectiveTrackerFrame.lastMapID = C_Map.GetBestMapForUnit("player")
	end
	
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		hooksecurefunc(ObjectiveTrackerFrame.MODULES[i], "AddObjective", AddObjective)
	end
	
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddObjective", AddObjective)
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", AddObjective)
	
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnClick", UpdateMinimizeButton)
	
	--hooksecurefunc("QuestPOI_GetButton", QuestPOI_HideAllButtons) -- Choosing to hide POI buttons, They're very ugly, and you can just click on the quest. I can always make this a setting if requested.
	--hooksecurefunc(QuestUtil, "SetupWorldQuestButton", HideWorldQuestPOI)
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	--hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	--hooksecurefunc(AUTO_QUEST_POPUP_TRACKER_MODULE, "Update", SkinAutoQuestPopup)
	hooksecurefunc("ScenarioBlocksFrame_OnLoad", UpdateScenarioBlock)
	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", UpdateScenarioBlock)
end

function Tracker:Load()
	if (not Settings["tracker-enable"]) then
		return
	end
	
	self:MoveTrackerFrame()
	self:StyleWindow()
	self:AddHooks()
	
	if ObjectiveTrackerUIWidgetFrame then
		
	end
end

local UpdateCategoryFont = function()
	HydraUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerFrame.HeaderMenu.Title:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	HydraUI:SetFontInfo(ObjectiveTrackerBlocksFrame.QuestHeader.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	HydraUI:SetFontInfo(ObjectiveTrackerBlocksFrame.ScenarioHeader.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	HydraUI:SetFontInfo(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	HydraUI:SetFontInfo(BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	HydraUI:SetFontInfo(WORLD_QUEST_TRACKER_MODULE.Header.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetTextColor(HydraUI:HexToRGB(Settings["tracker-module-font-color"]))
end

local UpdateHeaderFont = function()
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		for ID, Block in pairs(ObjectiveTrackerFrame.MODULES[i].usedBlocks) do
			if Block.HeaderText then
				HydraUI:SetFontInfo(Block.HeaderText, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
				Block.HeaderText:SetTextColor(HydraUI:HexToRGB(Settings["tracker-color-header"]))
			end
		end
	end
end

local UpdateLineFont = function()
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		for ID, Block in pairs(ObjectiveTrackerFrame.MODULES[i].usedBlocks) do
			for Key, Value in pairs(Block.lines) do
				HydraUI:SetFontInfo(Value.Text, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
				
				if Value.Dash then
					HydraUI:SetFontInfo(Value.Dash, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
				end
			end
		end
	end
end

local UpdateHeight = function(value)
	ObjectiveTrackerFrame:SetHeight(Settings["tracker-height"])
end

local UpdateBackdropOpacity = function(value)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	ObjectiveTrackerFrame.BG:SetBackdropColor(R, G, B, value / 100)
end

local UpdateEnableBackdrop = function(value)
	if (value and not ObjectiveTrackerFrame.collapsed) then
		ObjectiveTrackerFrame.BG:Show()
	else
		ObjectiveTrackerFrame.BG:Hide()
	end
end

GUI:AddWidgets(Language["General"], Language["Objectives"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("tracker-enable", Settings["tracker-enable"], Language["Enable Tracker Module"], Language["Enable the HydraUI objective tracker module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("tracker-enable-backdrop", Settings["tracker-enable-backdrop"], Language["Enable Backdrop"], Language["Enable a backdrop for the objective tracker"], UpdateEnableBackdrop)
	left:CreateSlider("tracker-backdrop-opacity", Settings["tracker-backdrop-opacity"], 0, 100, 5, Language["Backdrop Opacity"], Language["Set the backdrop opacity of the objective tracker"], UpdateBackdropOpacity)
	left:CreateSlider("tracker-height", Settings["tracker-height"], 100, 500, 1, Language["Set Height"], Language["Set the height of the objective tracker"], UpdateHeight)
	
	left:CreateHeader(Language["Colors"])
	left:CreateColorSelection("tracker-color-normal", Settings["tracker-color-normal"], Language["Line Normal"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-normal-highlight", Settings["tracker-color-normal-highlight"], Language["Line Highlight"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-header", Settings["tracker-color-header"], Language["Header"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-header-highlight", Settings["tracker-color-header-highlight"], Language["Header Highlight"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-failed", Settings["tracker-color-failed"], Language["Failed"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-failed-highlight", Settings["tracker-color-failed-highlight"], Language["Failed Highlight"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-timeleft", Settings["tracker-color-timeleft"], Language["Time left"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-timeleft-highlight", Settings["tracker-color-timeleft-highlight"], Language["Time left Highlight"], "", UpdateHeaderFont)
	left:CreateColorSelection("tracker-color-complete", Settings["tracker-color-complete"], Language["Complete"], "", UpdateHeaderFont)
	
	right:CreateHeader(Language["Category Font"])
	right:CreateDropdown("tracker-module-font", Settings["tracker-module-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker lines"], UpdateCategoryFont, "Font")
	right:CreateSlider("tracker-module-font-size", Settings["tracker-module-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker lines"], UpdateCategoryFont)
	right:CreateDropdown("tracker-module-font-flags", Settings["tracker-module-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker lines"], UpdateCategoryFont)
	right:CreateColorSelection("tracker-module-font-color", Settings["tracker-module-font-color"], Language["Font Color"], "", UpdateCategoryFont)
	
	right:CreateHeader(Language["Header Font"])
	right:CreateDropdown("tracker-header-font", Settings["tracker-header-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker header lines"], UpdateHeaderFont, "Font")
	right:CreateSlider("tracker-header-font-size", Settings["tracker-header-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker header lines"], UpdateHeaderFont)
	right:CreateDropdown("tracker-header-font-flags", Settings["tracker-header-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker header lines"], UpdateHeaderFont)
	
	right:CreateHeader(Language["Line Font"])
	right:CreateDropdown("tracker-font", Settings["tracker-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker lines"], UpdateLineFont, "Font")
	right:CreateSlider("tracker-font-size", Settings["tracker-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker lines"], UpdateLineFont)
	right:CreateDropdown("tracker-font-flags", Settings["tracker-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker lines"], UpdateLineFont)
end)
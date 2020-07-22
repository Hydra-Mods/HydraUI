local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Tracker = vUI:NewModule("Objective Tracker")

function Tracker:MoveTrackerFrame()
	self:SetSize(253, Settings["tracker-height"] + 2)
	self:SetPoint("RIGHT", vUIParent, -120, 0)
	
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", self, 4, -1)
	ObjectiveTrackerFrame:SetHeight(Settings["tracker-height"])
	
	vUI:CreateMover(self)
end

local AddObjective = function(self, block, objective)
	if (block.HeaderText and not block.HeaderText.Handled) then
		vUI:SetFontInfo(block.HeaderText, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
		block.HeaderText:SetTextColor(vUI:HexToRGB(Settings["tracker-color-header"]))
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
			vUI:SetFontInfo(ItemButton.Count, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
			ItemButton.Count:SetJustifyH("RIGHT")
			ItemButton.Count:SetDrawLayer("OVERLAY")
			ItemButton.Count:SetTextColor(1, 1, 1)
		end
		
		ItemButton.Backdrop = CreateFrame("Frame", nil, ItemButton)
		ItemButton.Backdrop:SetPoint("TOPLEFT", ItemButton, 0, 0)
		ItemButton.Backdrop:SetPoint("BOTTOMRIGHT", ItemButton, 0, 0)
		ItemButton.Backdrop:SetBackdrop(vUI.Outline)
		ItemButton.Backdrop:SetBackdropBorderColor(0, 0, 0)
		ItemButton.Backdrop:SetFrameStrata("BACKGROUND")
		
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
		vUI:SetFontInfo(Line.Text, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
		Line.Handled = true
		
		if (Line.Dash and not Line.Dash.Handled) then
			vUI:SetFontInfo(Line.Dash, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
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
	local R, G, B = vUI:HexToRGB(value)
	
	OBJECTIVE_TRACKER_COLOR[key].r = R
	OBJECTIVE_TRACKER_COLOR[key].g = G
	OBJECTIVE_TRACKER_COLOR[key].b = B
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
	vUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	
	-- Quests
	ObjectiveTrackerBlocksFrame.QuestHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.QuestHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	ObjectiveTrackerBlocksFrame.QuestHeader.BG = ObjectiveTrackerBlocksFrame.QuestHeader:CreateTexture(nil, "BORDER")
	ObjectiveTrackerBlocksFrame.QuestHeader.BG:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame.QuestHeader, 0, -2)
	ObjectiveTrackerBlocksFrame.QuestHeader.BG:SetPoint("BOTTOMRIGHT", ObjectiveTrackerBlocksFrame.QuestHeader, 12, -1)
	ObjectiveTrackerBlocksFrame.QuestHeader.BG:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerBlocksFrame.QuestHeader.BG:SetVertexColor(0, 0, 0)
	
	ObjectiveTrackerBlocksFrame.QuestHeader.Texture = ObjectiveTrackerBlocksFrame.QuestHeader:CreateTexture(nil, "ARTWORK")
	ObjectiveTrackerBlocksFrame.QuestHeader.Texture:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame.QuestHeader, 1, -3)
	ObjectiveTrackerBlocksFrame.QuestHeader.Texture:SetPoint("BOTTOMRIGHT", ObjectiveTrackerBlocksFrame.QuestHeader, 11, 0)
	ObjectiveTrackerBlocksFrame.QuestHeader.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ObjectiveTrackerBlocksFrame.QuestHeader.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- Scenario
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.ScenarioHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	ObjectiveTrackerBlocksFrame.ScenarioHeader.BG = ObjectiveTrackerBlocksFrame.ScenarioHeader:CreateTexture(nil, "BORDER")
	ObjectiveTrackerBlocksFrame.ScenarioHeader.BG:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame.ScenarioHeader, 0, -2)
	ObjectiveTrackerBlocksFrame.ScenarioHeader.BG:SetPoint("BOTTOMRIGHT", ObjectiveTrackerBlocksFrame.ScenarioHeader, 12, -1)
	ObjectiveTrackerBlocksFrame.ScenarioHeader.BG:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerBlocksFrame.ScenarioHeader.BG:SetVertexColor(0, 0, 0)
	
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Texture = ObjectiveTrackerBlocksFrame.ScenarioHeader:CreateTexture(nil, "ARTWORK")
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Texture:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame.ScenarioHeader, 1, -3)
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Texture:SetPoint("BOTTOMRIGHT", ObjectiveTrackerBlocksFrame.ScenarioHeader, 11, 0)
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- Achievement
	ObjectiveTrackerBlocksFrame.AchievementHeader.Background:Hide()
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	ObjectiveTrackerBlocksFrame.AchievementHeader.BG = ObjectiveTrackerBlocksFrame.AchievementHeader:CreateTexture(nil, "BORDER")
	ObjectiveTrackerBlocksFrame.AchievementHeader.BG:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame.AchievementHeader, 0, -2)
	ObjectiveTrackerBlocksFrame.AchievementHeader.BG:SetPoint("BOTTOMRIGHT", ObjectiveTrackerBlocksFrame.AchievementHeader, 12, -1)
	ObjectiveTrackerBlocksFrame.AchievementHeader.BG:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerBlocksFrame.AchievementHeader.BG:SetVertexColor(0, 0, 0)
	
	ObjectiveTrackerBlocksFrame.AchievementHeader.Texture = ObjectiveTrackerBlocksFrame.AchievementHeader:CreateTexture(nil, "ARTWORK")
	ObjectiveTrackerBlocksFrame.AchievementHeader.Texture:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame.AchievementHeader, 1, -3)
	ObjectiveTrackerBlocksFrame.AchievementHeader.Texture:SetPoint("BOTTOMRIGHT", ObjectiveTrackerBlocksFrame.AchievementHeader, 11, 0)
	ObjectiveTrackerBlocksFrame.AchievementHeader.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ObjectiveTrackerBlocksFrame.AchievementHeader.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- Bonus
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Background:Hide()
	vUI:SetFontInfo(BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.BG = BONUS_OBJECTIVE_TRACKER_MODULE.Header:CreateTexture(nil, "BORDER")
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.BG:SetPoint("TOPLEFT", BONUS_OBJECTIVE_TRACKER_MODULE.Header, 0, -2)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.BG:SetPoint("BOTTOMRIGHT", BONUS_OBJECTIVE_TRACKER_MODULE.Header, 12, -1)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.BG:SetTexture(Assets:GetTexture("Blank"))
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.BG:SetVertexColor(0, 0, 0)
	
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Texture = BONUS_OBJECTIVE_TRACKER_MODULE.Header:CreateTexture(nil, "ARTWORK")
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Texture:SetPoint("TOPLEFT", BONUS_OBJECTIVE_TRACKER_MODULE.Header, 1, -3)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Texture:SetPoint("BOTTOMRIGHT", BONUS_OBJECTIVE_TRACKER_MODULE.Header, 11, 0)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- World Quests
	WORLD_QUEST_TRACKER_MODULE.Header.Background:Hide()
	vUI:SetFontInfo(WORLD_QUEST_TRACKER_MODULE.Header.Text, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	WORLD_QUEST_TRACKER_MODULE.Header.BG = WORLD_QUEST_TRACKER_MODULE.Header:CreateTexture(nil, "BORDER")
	WORLD_QUEST_TRACKER_MODULE.Header.BG:SetPoint("TOPLEFT", WORLD_QUEST_TRACKER_MODULE.Header, 0, -2)
	WORLD_QUEST_TRACKER_MODULE.Header.BG:SetPoint("BOTTOMRIGHT", WORLD_QUEST_TRACKER_MODULE.Header, 12, -1)
	WORLD_QUEST_TRACKER_MODULE.Header.BG:SetTexture(Assets:GetTexture("Blank"))
	WORLD_QUEST_TRACKER_MODULE.Header.BG:SetVertexColor(0, 0, 0)
	
	WORLD_QUEST_TRACKER_MODULE.Header.Texture = WORLD_QUEST_TRACKER_MODULE.Header:CreateTexture(nil, "ARTWORK")
	WORLD_QUEST_TRACKER_MODULE.Header.Texture:SetPoint("TOPLEFT", WORLD_QUEST_TRACKER_MODULE.Header, 1, -3)
	WORLD_QUEST_TRACKER_MODULE.Header.Texture:SetPoint("BOTTOMRIGHT", WORLD_QUEST_TRACKER_MODULE.Header, 11, 0)
	WORLD_QUEST_TRACKER_MODULE.Header.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	WORLD_QUEST_TRACKER_MODULE.Header.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- Backdrop
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	ObjectiveTrackerFrame.BG = CreateFrame("Frame", nil, ObjectiveTrackerFrame)
	ObjectiveTrackerFrame.BG:SetBackdrop(vUI.BackdropAndBorder)
	ObjectiveTrackerFrame.BG:SetPoint("TOPLEFT", ObjectiveTrackerFrame, -13, 1)
	ObjectiveTrackerFrame.BG:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame, 5, -1)
	ObjectiveTrackerFrame.BG:SetBackdropColor(R, G, B, Settings["tracker-backdrop-opacity"] / 100)
	ObjectiveTrackerFrame.BG:SetBackdropBorderColor(0, 0, 0)
	
	ObjectiveTrackerFrame.BG.Top = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Top:SetHeight(2)
	ObjectiveTrackerFrame.BG.Top:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Top:SetVertexColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Top:SetPoint("TOPLEFT", ObjectiveTrackerFrame.BG, 1, -1)
	ObjectiveTrackerFrame.BG.Top:SetPoint("TOPRIGHT", ObjectiveTrackerFrame.BG, -1, -1)
	
	ObjectiveTrackerFrame.BG.Bottom = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Bottom:SetHeight(2)
	ObjectiveTrackerFrame.BG.Bottom:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Bottom:SetVertexColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Bottom:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame.BG, 1, 1)
	ObjectiveTrackerFrame.BG.Bottom:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame.BG, -1, 1)
	
	ObjectiveTrackerFrame.BG.Left = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Left:SetWidth(2)
	ObjectiveTrackerFrame.BG.Left:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Left:SetVertexColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Left:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame.BG, 1, 1)
	ObjectiveTrackerFrame.BG.Left:SetPoint("TOPLEFT", ObjectiveTrackerFrame.BG, 1, -1)
	
	ObjectiveTrackerFrame.BG.Right = ObjectiveTrackerFrame.BG:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.BG.Right:SetWidth(2)
	ObjectiveTrackerFrame.BG.Right:SetTexture(Assets:GetTexture("Blank"))
	ObjectiveTrackerFrame.BG.Right:SetVertexColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	ObjectiveTrackerFrame.BG.Right:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame.BG, -1, 1)
	ObjectiveTrackerFrame.BG.Right:SetPoint("TOPRIGHT", ObjectiveTrackerFrame.BG, -1, -1)
	
	ObjectiveTrackerFrame.BG.InnerBorder = CreateFrame("Frame", nil, ObjectiveTrackerFrame.BG)
	ObjectiveTrackerFrame.BG.InnerBorder:SetPoint("TOPLEFT", ObjectiveTrackerFrame.BG, 3, -3)
	ObjectiveTrackerFrame.BG.InnerBorder:SetPoint("BOTTOMRIGHT", ObjectiveTrackerFrame.BG, -3, 3)
	ObjectiveTrackerFrame.BG.InnerBorder:SetBackdrop(vUI.Outline)
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
	
	--[[ObjectiveTrackerFrame.HeaderMenu.NewMinimize = CreateFrame("Frame", nil, ObjectiveTrackerFrame)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetSize(20, 20)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetFrameLevel(20)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetPoint("CENTER", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, 0, 0)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetBackdrop(vUI.BackdropAndBorder)
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	ObjectiveTrackerFrame.HeaderMenu.NewMinimize:SetBackdropBorderColor(0, 0, 0)]]
	
	ObjectiveTrackerFrame.HeaderMenu.Texture = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:CreateTexture(nil, "OVERLAY")
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetSize(16, 16)
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetPoint("CENTER", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, 0, 0)
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetTexture(Assets:GetTexture("Arrow Up"))
	ObjectiveTrackerFrame.HeaderMenu.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
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
	
	line.ProgressBar.Bar.Backdrop = CreateFrame("Frame", nil, line.ProgressBar.Bar)
	line.ProgressBar.Bar.Backdrop:SetPoint("TOPLEFT", line.ProgressBar.Bar, -1, 1)
	line.ProgressBar.Bar.Backdrop:SetPoint("BOTTOMRIGHT", line.ProgressBar.Bar, 1, -1)
	line.ProgressBar.Bar.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	line.ProgressBar.Bar.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	line.ProgressBar.Bar.Backdrop:SetBackdropBorderColor(0, 0, 0)
	line.ProgressBar.Bar.Backdrop:SetFrameLevel(line.ProgressBar.Bar:GetFrameLevel() - 1)
	
	line.ProgressBar.Bar.BGTexture = line.ProgressBar.Bar.Backdrop:CreateTexture(nil, "BACKGROUND")
	line.ProgressBar.Bar.BGTexture:SetPoint("TOPLEFT", line.ProgressBar.Bar.Backdrop, 0, 0)
	line.ProgressBar.Bar.BGTexture:SetPoint("BOTTOMRIGHT", line.ProgressBar.Bar.Backdrop, 0, 0)
	line.ProgressBar.Bar.BGTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	line.ProgressBar.Bar.BGTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	
	if line.ProgressBar.Bar.Icon then
		line.ProgressBar.Bar.Icon:ClearAllPoints()
		line.ProgressBar.Bar.Icon:SetPoint("LEFT", line.ProgressBar.Bar, "RIGHT", 4, 0)
		line.ProgressBar.Bar.Icon:SetSize(18, 18)
		line.ProgressBar.Bar.Icon:SetMask("")
		line.ProgressBar.Bar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		
		line.ProgressBar.Bar.Icon.Backdrop = CreateFrame("Frame", nil, line.ProgressBar.Bar)
		line.ProgressBar.Bar.Icon.Backdrop:SetPoint("TOPLEFT", line.ProgressBar.Bar.Icon, -1, 1)
		line.ProgressBar.Bar.Icon.Backdrop:SetPoint("BOTTOMRIGHT", line.ProgressBar.Bar.Icon, 1, -1)
		line.ProgressBar.Bar.Icon.Backdrop:SetBackdrop(vUI.Outline)
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
		
		local QuestTitle = GetQuestLogTitle(GetQuestLogIndexByID(QuestID))
		
		if (QuestTitle and QuestTitle ~= "") then
			local Block = AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(QuestID)
			
			if Block then
				local BlockContents = Block.ScrollChild
				
				BlockContents:ClearAllPoints()
				BlockContents:SetPoint("LEFT", Block, 0, 2)
				BlockContents:GetParent():SetWidth(268)
				
				if (not BlockContents.Backdrop) then
					BlockContents.Backdrop = CreateFrame("Frame", nil, BlockContents)
					--BlockContents.Backdrop:SetPoint("TOPLEFT", BlockContents:GetParent(), 36, -1)
					--BlockContents.Backdrop:SetPoint("BOTTOMRIGHT", BlockContents:GetParent(), 40, 1)
					BlockContents.Backdrop:SetPoint("TOPLEFT", BlockContents:GetParent(), 38, 0)
					BlockContents.Backdrop:SetPoint("BOTTOMRIGHT", BlockContents:GetParent(), -1, 0)
					BlockContents.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
					BlockContents.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
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
					vUI:SetFontInfo(BlockContents.TopText, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
					vUI:SetFontInfo(BlockContents.BottomText, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
					vUI:SetFontInfo(BlockContents.QuestName, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
					
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
	vUI:SetFontInfo(StageBlock.Stage, Settings["tracker-font"], 18, Settings["tracker-font-flags"])
	vUI:SetFontInfo(StageBlock.CompleteLabel, Settings["tracker-font"], 18, Settings["tracker-font-flags"])
	vUI:SetFontInfo(StageBlock.Name, Settings["tracker-font"], 18, Settings["tracker-font-flags"])
	
	--[[if (not StageBlock.Backdrop) then
		StageBlock.Backdrop = CreateFrame("Frame", nil, StageBlock)
		StageBlock.Backdrop:SetPoint("TOPLEFT", StageBlock, 1, -1)
		StageBlock.Backdrop:SetPoint("BOTTOMRIGHT", StageBlock, -1, 1)
		StageBlock.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
		StageBlock.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
		StageBlock.Backdrop:SetBackdropBorderColor(0, 0, 0)
		StageBlock.Backdrop:SetFrameLevel(StageBlock:GetFrameLevel() - 1)
	end]]
	
	--[[StageBlock.Stage:ClearAllPoints()
	StageBlock.Stage:SetPoint("CENTER", StageBlock.Backdrop, 0, 0)
	vUI:SetFontInfo(StageBlock.Stage, Settings["tracker-font"], 18, Settings["tracker-font-flags"])]]
	
	--[[
	local ChallengeBlock = ScenarioChallengeModeBlock
	
	ChallengeBlock.TimerBGBack:Hide()
	ChallengeBlock.TimerBG:Hide()
	
	ChallengeBlock.StatusBar
	
	vUI:SetFontInfo(ChallengeBlock.Level, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
	vUI:SetFontInfo(ChallengeBlock.TimeLeft, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
	vUI:SetFontInfo(ChallengeBlock.DeathCount.Count, Settings["tracker-font"], Settings["tracker-font-size"], Settings["tracker-font-flags"])
	--]]
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
	
	hooksecurefunc("QuestPOI_GetButton", QuestPOI_HideAllButtons) -- Choosing to hide POI buttons, They're very ugly, and you can just click on the quest. I can always make this a setting if requested.
	hooksecurefunc(QuestUtil, "SetupWorldQuestButton", HideWorldQuestPOI)
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", AddProgressBar)
	hooksecurefunc(AUTO_QUEST_POPUP_TRACKER_MODULE, "Update", SkinAutoQuestPopup)
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
end

local UpdateCategoryFont = function()
	vUI:SetFontInfo(ObjectiveTrackerFrame.HeaderMenu.Title, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerFrame.HeaderMenu.Title:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.QuestHeader.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.ScenarioHeader.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	vUI:SetFontInfo(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	vUI:SetFontInfo(BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
	
	vUI:SetFontInfo(WORLD_QUEST_TRACKER_MODULE.Header.Text, Settings["tracker-module-font"], Settings["tracker-module-font-size"], Settings["tracker-module-font-flags"])
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetTextColor(vUI:HexToRGB(Settings["tracker-module-font-color"]))
end

local UpdateHeaderFont = function()
	for i = 1, #ObjectiveTrackerFrame.MODULES do
		for ID, Block in pairs(ObjectiveTrackerFrame.MODULES[i].usedBlocks) do
			if Block.HeaderText then
				vUI:SetFontInfo(Block.HeaderText, Settings["tracker-header-font"], Settings["tracker-header-font-size"], Settings["tracker-header-font-flags"])
				Block.HeaderText:SetTextColor(vUI:HexToRGB(Settings["tracker-color-header"]))
			end
		end
	end
end

local UpdateLineFont = function()
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

local UpdateHeight = function(value)
	ObjectiveTrackerFrame:SetHeight(Settings["tracker-height"])
end

local UpdateBackdropOpacity = function(value)
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	ObjectiveTrackerFrame.BG:SetBackdropColor(R, G, B, value / 100)
end

local UpdateEnableBackdrop = function(value)
	if (value and not ObjectiveTrackerFrame.collapsed) then
		ObjectiveTrackerFrame.BG:Show()
	else
		ObjectiveTrackerFrame.BG:Hide()
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Objectives"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("tracker-enable", Settings["tracker-enable"], Language["Enable Tracker Module"], Language["Enable the vUI objective tracker module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSwitch("tracker-enable-backdrop", Settings["tracker-enable-backdrop"], Language["Enable Backdrop"], Language["Enable a backdrop for the objective tracker"], UpdateEnableBackdrop)
	Left:CreateSlider("tracker-backdrop-opacity", Settings["tracker-backdrop-opacity"], 0, 100, 5, Language["Backdrop Opacity"], Language["Set the backdrop opacity of the objective tracker"], UpdateBackdropOpacity)
	Left:CreateSlider("tracker-height", Settings["tracker-height"], 100, 600, 1, Language["Set Height"], Language["Set the height of the objective tracker"], UpdateHeight)
	
	Left:CreateHeader(Language["Colors"])
	Left:CreateColorSelection("tracker-color-normal", Settings["tracker-color-normal"], Language["Line Normal"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-normal-highlight", Settings["tracker-color-normal-highlight"], Language["Line Highlight"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-header", Settings["tracker-color-header"], Language["Header"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-header-highlight", Settings["tracker-color-header-highlight"], Language["Header Highlight"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-failed", Settings["tracker-color-failed"], Language["Failed"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-failed-highlight", Settings["tracker-color-failed-highlight"], Language["Failed Highlight"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-timeleft", Settings["tracker-color-timeleft"], Language["Time Left"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-timeleft-highlight", Settings["tracker-color-timeleft-highlight"], Language["Time Left Highlight"], "", UpdateHeaderFont)
	Left:CreateColorSelection("tracker-color-complete", Settings["tracker-color-complete"], Language["Complete"], "", UpdateHeaderFont)
	
	Right:CreateHeader(Language["Category Font"])
	Right:CreateDropdown("tracker-module-font", Settings["tracker-module-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker lines"], UpdateCategoryFont, "Font")
	Right:CreateSlider("tracker-module-font-size", Settings["tracker-module-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker lines"], UpdateCategoryFont)
	Right:CreateDropdown("tracker-module-font-flags", Settings["tracker-module-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker lines"], UpdateCategoryFont)
	Right:CreateColorSelection("tracker-module-font-color", Settings["tracker-module-font-color"], Language["Font Color"], "", UpdateCategoryFont)
	
	Right:CreateHeader(Language["Header Font"])
	Right:CreateDropdown("tracker-header-font", Settings["tracker-header-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker header lines"], UpdateHeaderFont, "Font")
	Right:CreateSlider("tracker-header-font-size", Settings["tracker-header-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker header lines"], UpdateHeaderFont)
	Right:CreateDropdown("tracker-header-font-flags", Settings["tracker-header-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker header lines"], UpdateHeaderFont)
	
	Right:CreateHeader(Language["Line Font"])
	Right:CreateDropdown("tracker-font", Settings["tracker-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker lines"], UpdateLineFont, "Font")
	Right:CreateSlider("tracker-font-size", Settings["tracker-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker lines"], UpdateLineFont)
	Right:CreateDropdown("tracker-font-flags", Settings["tracker-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker lines"], UpdateLineFont)
end)
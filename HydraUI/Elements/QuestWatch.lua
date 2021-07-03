local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

-- QUESTS_LABEL = "Quests"
-- QUEST_OBJECTIVES = "Quest Objectives"
-- TRACKER_HEADER_QUESTS = "Quests"

local Quest = HydraUI:NewModule("Quest Watch")

function Quest:StyleFrame()
	self:SetSize(156, 40)
	self:SetPoint("TOPRIGHT", HydraUI.UIParent, "TOPRIGHT", -300, -400)
	
	local Title = QuestWatchFrame:CreateFontString(nil, "OVERLAY")
	Title:SetPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, 0)
	HydraUI:SetFontInfo(Title, Settings["ui-header-font"], 12)
	Title:SetJustifyH("LEFT")
	Title:SetText(QUESTS_LABEL)
	
	local TitleDiv = CreateFrame("Frame", nil, QuestWatchFrame, "BackdropTemplate")
	TitleDiv:SetSize(156, 4)
	TitleDiv:SetPoint("BOTTOMLEFT", QuestWatchFrame, "TOPLEFT", 0, -6)
	TitleDiv:SetBackdrop(HydraUI.BackdropAndBorder)
	TitleDiv:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	TitleDiv:SetBackdropBorderColor(0, 0, 0)
	
	TitleDiv.Texture = TitleDiv:CreateTexture(nil, "OVERLAY")
	TitleDiv.Texture:SetPoint("TOPLEFT", TitleDiv, 1, -1)
	TitleDiv.Texture:SetPoint("BOTTOMRIGHT", TitleDiv, -1, 1)
	TitleDiv.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TitleDiv.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	QuestWatchFrame:Show()
	
	local Region
	local Child
	
	for i = 1, QuestTimerFrame:GetNumRegions() do
		Region = select(i, QuestTimerFrame:GetRegions())
		
		if (Region:GetObjectType() == "Texture") then
			Region:SetTexture(nil)
		elseif (Region:GetObjectType() == "FontString") then
			HydraUI:SetFontInfo(Region, Settings["ui-header-font"], 12)
		end
	end
	
	for i = 1, 30 do
		HydraUI:SetFontInfo(_G["QuestWatchLine" .. i], Settings["ui-header-font"], 12)
	end
	
	for i = 1, 20 do
		HydraUI:SetFontInfo(_G["QuestTimer" .. i .. "Text"], Settings["ui-header-font"], 12)
	end
	
	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 60)
	QuestTimerFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 60)
	QuestTimerFrame:SetHeight(30)
	
	HydraUI:CreateMover(self)
end

function Quest:Load()
	self:StyleFrame()
end
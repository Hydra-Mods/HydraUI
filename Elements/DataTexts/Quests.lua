local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local select = select
local GetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept
local Label = QUESTS_LABEL

local GetNumQuests

if HydraUI.IsMainline then
	GetNumQuests = C_QuestLog.GetNumQuestLogEntries
else
	GetNumQuests = GetNumQuestLogEntries
end

local OnMouseUp = function()
	--[[if HydraUI.IsMainline then
		ToggleFrame(QuestMapFrame)
	else
		ToggleFrame(QuestLogFrame)
	end]]
	
	ToggleFrame(HydraUI.IsMainline and QuestMapFrame or QuestLogFrame)
end

local Update = function(self)
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s/%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], select(2, GetNumQuests()), GetMaxNumQuestsCanAccept())
end

local OnEnable = function(self)
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("QUEST_LOG_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Quests", OnEnable, OnDisable, Update)
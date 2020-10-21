local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local select = select
local Label = QUESTS_LABEL

local OnMouseUp = function()
	ToggleFrame(QuestMapFrame)
end

local Update = function(self)
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s/%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], select(2, C_QuestLog.GetNumQuestLogEntries()), C_QuestLog.GetMaxNumQuestsCanAccept())
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

vUI:AddDataText("Quests", OnEnable, OnDisable, Update)
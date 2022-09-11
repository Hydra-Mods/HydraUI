local HydraUI, Language, Assets, Settings = select(2, ...):get()

-- QUESTS_LABEL = "Quests"
-- QUEST_OBJECTIVES = "Quest Objectives"
-- TRACKER_HEADER_QUESTS = "Quests"

local Quest = HydraUI:NewModule("Quest Watch")

function Quest:StyleFrame()
	self:SetSize(203, 203) -- Not sure why, Blizzard did it.
	self:SetPoint("TOPRIGHT", HydraUI.UIParent, "TOPRIGHT", -300, -400)
	
	local Mover = HydraUI:CreateMover(self)
	
	WatchFrame:SetMovable(true)
	WatchFrame:SetUserPlaced(true)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPLEFT", Mover, "TOPLEFT", 0, 0)
	
	self.Mover = Mover
end

function Quest:Load()
	self:StyleFrame()
end
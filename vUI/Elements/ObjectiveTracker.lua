local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Tracker = vUI:NewModule("Objective Tracker")

function Tracker:Move()
	self:SetSize(235, 140)
	self:SetPoint("RIGHT", vUIParent, -120, 120)
	
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", self, 0, 0)
	
	vUI:CreateMover(self)
end

function Tracker:AddHooks()
	local Quests = ObjectiveTracker_GetModuleInfoTable()
	
	hooksecurefunc(Quests, "SetBlockHeader", function(block)
			vUI:SetFontInfo(block.HeaderText, Assets:GetFont(Settings["ui-header-font"]), 14)
	end)
end

function Tracker:Load()
	self:Move()
end
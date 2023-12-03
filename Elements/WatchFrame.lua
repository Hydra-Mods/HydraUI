local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Quest = HydraUI:NewModule("Quest Watch")

function Quest:StyleFrame()
	self:SetSize(204, 204) -- Not sure why, Blizzard did it.
	self:SetPoint("TOPRIGHT", HydraUI.UIParent, "TOPRIGHT", -300, -400)

	local Mover = HydraUI:CreateMover(self)

	WatchFrame:SetMovable(true)
	WatchFrame:SetUserPlaced(true)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOP", self, "TOP", 0, 0)
	WatchFrame:SetSize(204, 757)

	self.Mover = Mover
end

function Quest:Load()
	self:StyleFrame()
end
local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Objectives = HydraUI:NewModule("PVP Objectives")

local SetBelowMinimapPosition = function(self, a, p)
	if (p ~= Objectives.MinimapAnchor) then
		self:ClearAllPoints()
		self:SetParent(Objectives.MinimapAnchor)
		self:SetPoint("CENTER", Objectives.MinimapAnchor)
	end
end

function Objectives:Load()
	self.MinimapAnchor = CreateFrame("Frame", "PVP Objectives", HydraUI.UIParent)
	self.MinimapAnchor:SetSize(173, 26)
	self.MinimapAnchor:SetPoint("TOP", HydraUI.UIParent, 0, -70)
	
	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", SetBelowMinimapPosition)
	
	HydraUI:CreateMover(self.MinimapAnchor)
end
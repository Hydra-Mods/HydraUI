local HydraUI, Language, Assets, Settings = select(2, ...):get()

local ScaleOnAccept = function()
	C_CVar.SetCVar("uiScale", (768 / select(2, GetPhysicalScreenSize())))
end

local SetSuggestedScale = function()
	HydraUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to the suggested setting of %s?"], (768 / select(2, GetPhysicalScreenSize()))), ACCEPT, ScaleOnAccept, CANCEL)
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Scale"])
	right:CreateButton("", Language["Apply"], Language["Set Suggested Scale"], Language["Apply the scale recommended based on your resolution"], SetSuggestedScale)
end)
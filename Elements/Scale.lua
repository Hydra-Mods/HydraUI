local HydraUI, Language, Assets, Settings = select(2, ...):get()

local ScaleOnAccept = function()
	C_CVar.SetCVar("uiScale", (768 / select(2, GetPhysicalScreenSize())))
end

local SetSuggestedScale = function()
	HydraUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to %s?"], (768 / select(2, GetPhysicalScreenSize()))), ACCEPT, ScaleOnAccept, CANCEL)
end

local UpdateScaleCVar = function(value)
	C_CVar.SetCVar("uiScale", value)
end

local SetScaleFromSlider = function(value)
	HydraUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to %s?"], value), ACCEPT, UpdateScaleCVar, CANCEL, nil, value)
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Scale"])
	right:CreateButton("", Language["Apply"], Language["Set Suggested Scale"], Language["Apply the recommended scale based on your resolution"], SetSuggestedScale)
	right:CreateSlider("ui-scale", C_CVar.GetCVar("uiScale"), 0.4, 1.2, 0.01, Language["Set UI Scale"], Language["Adjust the UI scale"], SetScaleFromSlider)
end)
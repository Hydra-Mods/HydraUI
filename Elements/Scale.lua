local HydraUI, Language, Assets, Settings = select(2, ...):get()

local ScaleOnAccept = function()

	local Scale = (768 / select(2, GetPhysicalScreenSize()))

	C_CVar.SetCVar("uiScale", Scale)

	local Widget = HydraUI:GetModule("GUI"):GetWidget("ui-scale")
	Widget.Slider:SetValue(Scale)
	Widget.Slider.EditBox:SetText(Scale)
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

local UseUIScale = function(value)
	C_CVar.SetCVar("useUiScale", value == true and "1" or "0")
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Scale"])
	right:CreateSwitch("enable-scale", C_CVar.GetCVar("useUiScale") == "1" and true or false, USE_UISCALE, OPTION_TOOLTIP_USE_UISCALE, UseUIScale)
	right:CreateButton("", Language["Apply"], Language["Set Suggested Scale"], Language["Apply the recommended scale based on your resolution"], SetSuggestedScale)
	right:CreateSlider("ui-scale", tonumber(C_CVar.GetCVar("uiScale")), 0.4, 1.2, 0.01, Language["Set UI Scale"], Language["Adjust the UI scale"], SetScaleFromSlider)
end)
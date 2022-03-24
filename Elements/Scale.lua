local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local UpdateUIScale = function(value)
	value = tonumber(value)
	
	HydraUI:SetScale(value)
end

local RevertScaleChange = function()
	
end

local ScaleOnAccept = function()
	local Suggested = HydraUI:GetSuggestedScale()
	local Profile = HydraUI:GetProfile(HydraUI:GetActiveProfileName())
	
	if (Profile["ui-scale"] ~= Suggested) then
		Profile["ui-scale"] = Suggested
		
		HydraUI:SetScale(Suggested)
		
		GUI:GetWidget("ui-scale").Input.ButtonText:SetText(Suggested)
	end
end

local SetSuggestedScale = function()
	HydraUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to the suggested setting of %s?"], HydraUI:GetSuggestedScale()), ACCEPT, ScaleOnAccept, CANCEL)
end

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Scale"])
	right:CreateInput("ui-scale", Settings["ui-scale"], Language["Set UI Scale"], Language["Set the scale for the UI"], UpdateUIScale)
	right:CreateButton("", Language["Apply"], Language["Set Suggested Scale"], Language["Apply the scale recommended based on your resolution"], SetSuggestedScale)
end)
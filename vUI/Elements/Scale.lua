local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local UpdateUIScale = function(value)
	value = tonumber(value)
	
	vUI:SetScale(value)
end

local RevertScaleChange = function()
	
end

local ScaleOnAccept = function()
	local Suggested = vUI:GetSuggestedScale()
	local Profile = vUI:GetProfile(vUI:GetActiveProfileName())
	
	if (Profile["ui-scale"] ~= Suggested) then
		Profile["ui-scale"] = Suggested
		
		vUI:SetScale(Suggested)
		
		GUI:GetWidget(Language["General"], Language["General"], "ui-scale").Input.ButtonText:SetText(Suggested)
	end
end

local SetSuggestedScale = function()
	vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to the suggested setting of %s?"], vUI:GetSuggestedScale()), Language["Accept"], ScaleOnAccept, Language["Cancel"])
end

GUI:AddSettings(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Scale"])
	--right:CreateLine("|cFFE81123Do not use this to resize UI elements|r")
	right:CreateInput("ui-scale", Settings["ui-scale"], Language["Set UI Scale"], Language["Set the scale for the UI"], UpdateUIScale)
	right:CreateButton(Language["Apply"], Language["Set Suggested Scale"], Language["Apply the scale recommended based on your resolution"], SetSuggestedScale)
end)
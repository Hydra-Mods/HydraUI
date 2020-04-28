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
	end
	
	vUI:SetScale(Suggested)
	
	GUI:GetWidgetByWindow(Language["General"], "ui-scale").Input.ButtonText:SetText(Suggested)
end

local SetSuggestedScale = function()
	vUI:DisplayPopup(Language["Attention"], format(Language["Are you sure you would like to change your UI scale to the suggested setting of %s?"], vUI:GetSuggestedScale()), "Accept", ScaleOnAccept, "Cancel")
end

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["General"])
	
	Right:CreateHeader(Language["Scale"])
	--Right:CreateLine("|cFFE81123Do not use this to resize UI elements|r")
	Right:CreateInput("ui-scale", Settings["ui-scale"], Language["Set UI Scale"], "Set the scale for the UI", UpdateUIScale)
	Right:CreateButton(Language["Apply"], Language["Set Suggested Scale"], Language["Apply the scale recommended based on your resolution"], SetSuggestedScale)
end)
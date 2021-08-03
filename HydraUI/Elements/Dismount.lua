local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local AutoDismount = HydraUI:NewModule("Dismount")

AutoDismount.Mount = {
	[SPELL_FAILED_NOT_MOUNTED] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_NOT_WHILE_MOUNTED] = true,
	[ERR_TAXIPLAYERALREADYMOUNTED] = true,
}

AutoDismount.Shapeshift = {
    [ERR_CANT_INTERACT_SHAPESHIFTED] = true,
    [ERR_EMBLEMERROR_NOTABARDGEOSET] = true,
    [ERR_MOUNT_SHAPESHIFTED] = true,
    [ERR_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
    [ERR_NOT_WHILE_SHAPESHIFTED] = true,
    [ERR_TAXIPLAYERSHAPESHIFTED] = true,
    [SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
    [SPELL_FAILED_NOT_SHAPESHIFT] = true,
    [SPELL_NOT_SHAPESHIFTED] = true,
    [SPELL_NOT_SHAPESHIFTED_NOSPACE] = true,
}

AutoDismount.Stand = {
	[SPELL_FAILED_NOT_STANDING] = true
}

function AutoDismount:UI_ERROR_MESSAGE(id, message)
	if self.Mount[message] then
		Dismount()
		UIErrorsFrame:Clear()
	elseif self.Shapeshift[message] then
		for i = 1, 40 do
			local ID = select(10, UnitBuff("player", i))
			
			if (ID == 2645) then
				CancelUnitBuff("player", i)
				UIErrorsFrame:Clear()
				
				break
			end
		end
	elseif self.Stand[message] then
		DoEmote("STAND")
		UIErrorsFrame:Clear()
	end
end

function AutoDismount:TAXIMAP_OPENED()
	Dismount()
end

function AutoDismount:OnEvent(event, ...)
	self[event](self, ...)
end

function AutoDismount:Load()
	if Settings["dismount-enable"] then
		self:RegisterEvent("UI_ERROR_MESSAGE")
		self:RegisterEvent("TAXIMAP_OPENED")
	end
	
	self:SetScript("OnEvent", self.OnEvent)
end

local UpdateEnableDismount = function(value)
	if value then
		AutoDismount:RegisterEvent("UI_ERROR_MESSAGE")
		AutoDismount:RegisterEvent("TAXIMAP_OPENED")
	else
		AutoDismount:UnregisterEvent("UI_ERROR_MESSAGE")
		AutoDismount:UnregisterEvent("TAXIMAP_OPENED")
	end
end

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Auto Dismount"])
	right:CreateSwitch("dismount-enable", Settings["dismount-enable"], Language["Enable Auto Dismount"], Language["Automatically dismount during actions that can't be performed while mounted"], UpdateEnableDismount)
end)
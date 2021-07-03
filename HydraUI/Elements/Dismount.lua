local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

--[[
	ERR_NOT_WHILE_MOUNTED
	ERR_MOUNT_ALREADYMOUNTED
	SPELL_FAILED_NOT_STANDING - DoEmote("STAND")
--]]

local AutoDismount = HydraUI:NewModule("Dismount")

AutoDismount.Errors = {
	[50] = SPELL_FAILED_NOT_MOUNTED,
	[198] = ERR_ATTACK_MOUNTED,
	[213] = ERR_TAXIPLAYERALREADYMOUNTED,
}

function AutoDismount:UI_ERROR_MESSAGE(id)
	if self.Errors[id] then
		Dismount()
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
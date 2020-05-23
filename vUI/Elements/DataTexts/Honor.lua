local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local Label = Language["Honor"]

local OnEnter = function(self)
	self:SetTooltip()
	
	local Honor = UnitHonor("player")
	local MaxHonor = UnitHonorMax("player")
	local Percent = floor((Honor / MaxHonor * 100 + 0.05) * 10) / 10
	local Remaining = MaxHonor - Honor
	local RemainingPercent = floor((Remaining / MaxHonor * 100 + 0.05) * 10) / 10
	
	GameTooltip:AddLine(format(HONOR_LEVEL_TOOLTIP, UnitHonorLevel("player")))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Current honor"])
	GameTooltip:AddDoubleLine(format("%s / %s", vUI:Comma(Honor), vUI:Comma(MaxHonor)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining honor"])
	GameTooltip:AddDoubleLine(format("%s", vUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	PVEFrame_ToggleFrame("PVPUIFrame", "HonorFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s / %s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], UnitHonor("player"), UnitHonorMax("player"))
end

local OnEnable = function(self)
	self:RegisterUnitEvent("HONOR_XP_UPDATE", "player")
	self:RegisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("HONOR_XP_UPDATE")
	self:UnregisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

vUI:AddDataText("Honor", OnEnable, OnDisable, Update)
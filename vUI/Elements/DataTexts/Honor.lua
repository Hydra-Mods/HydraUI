local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local Label = Language["Honor"]

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local Honor = UnitHonor("player")
	local MaxHonor = UnitHonorMax("player")
	local Percent = floor((Honor / MaxHonor * 100 + 0.05) * 10) / 10
	local Remaining = MaxHonor - Honor
	local RemainingPercent = floor((Remaining / MaxHonor * 100 + 0.05) * 10) / 10
	
	GameTooltip:AddLine(LEVEL .. " " .. UnitHonorLevel("player"))
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

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Honor = UnitHonor("player")
	local MaxHonor = UnitHonorMax("player")
	
	self.Text:SetFormattedText("%s: %s / %s", Label, Honor, MaxHonor)
end

local OnEnable = function(self)
	self:RegisterUnitEvent("HONOR_XP_UPDATE", "player")
	self:RegisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("HONOR_XP_UPDATE")
	self:UnregisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

vUI:AddDataText(Label, OnEnable, OnDisable, Update)
local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Gold = HydraUI:NewModule("Gold")

local GetMoney = GetMoney
local tinsert = table.insert
local tremove = table.remove

local SessionChange = 0
local Sorted = {}
local TablePool = {}
local CurrentUser

local Sort = function(a, b)
	return a[2] > b[2]
end

function Gold:GetTable()
	local Table

	if TablePool[1] then
		Table = tremove(TablePool, 1)
	else
		Table = {}
	end

	return Table
end

function Gold:GetSessionStats()
	return SessionChange, GetMoney()
end

function Gold:GetServerInfo()
	if Sorted[1] then
		for i = 1, #Sorted do
			tinsert(TablePool, tremove(Sorted, 1))
		end
	end

	local Table
	local Total = 0

	for Name, Value in next, HydraUI.GoldData[HydraUI.UserRealm] do
		Table = self:GetTable()

		Table[1] = Name
		Table[2] = Value

		Total = Total + Value

		tinsert(Sorted, Table)
	end

	table.sort(Sorted, Sort)

	return Sorted, Total
end

function Gold:OnEvent()
	local CurrentValue = GetMoney()

	SessionChange = SessionChange + (CurrentValue - HydraUI.GoldData[HydraUI.UserRealm][CurrentUser])

	HydraUI.GoldData[HydraUI.UserRealm][CurrentUser] = CurrentValue
end

function Gold:Reset()
	HydraUIGold = nil
	HydraUI.GoldData = nil

	self:Load()
end

function Gold:Load()
	HydraUI:BindSavedVariable("HydraUIGold", "GoldData")

	if (not HydraUI.GoldData[HydraUI.UserRealm]) then
		HydraUI.GoldData[HydraUI.UserRealm] = {}
	end

	CurrentUser = string.format("|c%s%s|r", RAID_CLASS_COLORS[HydraUI.UserClass].colorStr, HydraUI.UserName)

	HydraUI.GoldData[HydraUI.UserRealm][CurrentUser] = GetMoney()

	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", self.OnEvent)
end
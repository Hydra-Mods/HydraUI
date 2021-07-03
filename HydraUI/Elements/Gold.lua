local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Gold = HydraUI:NewModule("Gold")

local GetMoney = GetMoney
local tinsert = table.insert
local tremove = table.remove

Gold.SessionChange = 0
Gold.Sorted = {}
Gold.TablePool = {}

function Gold:GetTable()
	local Table
	
	if self.TablePool[1] then
		Table = tremove(self.TablePool, 1)
	else
		Table = {}
	end
	
	return Table
end

function Gold:GetSessionStats()
	return self.SessionChange, GetMoney()
end

function Gold:GetServerInfo()
	if self.Sorted[1] then
		for i = 1, #self.Sorted do
			tinsert(self.TablePool, tremove(self.Sorted, 1))
		end
	end
	
	local Table
	local Total = 0
	
	for Name, Value in pairs(HydraUI.GoldData[HydraUI.UserRealm]) do
		Table = self:GetTable()
		
		Table[1] = Name
		Table[2] = Value
		
		Total = Total + Value
		
		tinsert(self.Sorted, Table)
	end
	
	table.sort(self.Sorted, function(a, b)
		return a[2] > b[2]
	end)
	
	return self.Sorted, Total
end

function Gold:OnEvent()
	local CurrentValue = GetMoney()
	
	self.SessionChange = self.SessionChange + (CurrentValue - HydraUI.GoldData[HydraUI.UserRealm][self.CurrentUser])
	
	HydraUI.GoldData[HydraUI.UserRealm][self.CurrentUser] = CurrentValue
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
	
	self.CurrentUser = string.format("|c%s%s|r", RAID_CLASS_COLORS[HydraUI.UserClass].colorStr, HydraUI.UserName)
	
	HydraUI.GoldData[HydraUI.UserRealm][self.CurrentUser] = GetMoney()
	
	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", self.OnEvent)
end
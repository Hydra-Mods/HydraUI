local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Gold = vUI:NewModule("Gold")

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
	
	for Name, Value in pairs(vUIGold[vUI.UserRealm]) do
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

function Gold:PLAYER_MONEY()
	local CurrentValue = GetMoney()
	local LastValue = vUIGold[vUI.UserRealm][self.CurrentUser]
	local Diff = CurrentValue - LastValue
	
	self.SessionChange = self.SessionChange + Diff
	
	vUIGold[vUI.UserRealm][self.CurrentUser] = CurrentValue
end

function Gold:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

function Gold:Reset()
	vUIGold = nil
	
	self:Load()
end

function Gold:Load()
	if (not vUIGold) then
		vUIGold = {}
	end
	
	if (not vUIGold[vUI.UserRealm]) then
		vUIGold[vUI.UserRealm] = {}
	end
	
	self.CurrentUser = string.format("|c%s%s|r", RAID_CLASS_COLORS[vUI.UserClass].colorStr, vUI.UserName)
	
	vUIGold[vUI.UserRealm][self.CurrentUser] = GetMoney()
	
	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", self.OnEvent)
end
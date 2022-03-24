local HydraUI = select(2, ...):get()

local tinsert = table.insert
local tremove = table.remove
local GetTime = GetTime

local Throttle = HydraUI:NewModule("Throttle")
Throttle.Active = {}
Throttle.Inactive = {}

function Throttle:IsThrottled(name)
	for i = 1, #self.Active do
		if (self.Active[i][1] == name) then
			local Throttle = self.Active[i]
			
			if (GetTime() - Throttle[2] >= Throttle[3]) then
				tinsert(self.Inactive, tremove(self.Active, i))
				
				return false
			end
			
			return true
		end
	end
end

function Throttle:Exists(name)
	for i = 1, #self.Active do
		if (self.Active[i][1] == name) then
			return true
		end
	end
	
	for i = 1, #self.Inactive do
		if (self.Inactive[i][1] == name) then
			return true
		end
	end
end

function Throttle:Start(name, duration)
	if (not self:Exists(name)) then
		tinsert(self.Inactive, {name, GetTime(), duration})
	end
	
	if (not self:IsThrottled(name)) then
		for i = 1, #self.Inactive do
			if (self.Inactive[i][1] == name) then
				self.Inactive[i][2] = GetTime()
				
				tinsert(self.Active, tremove(self.Inactive, i))
				
				break
			end
		end
	end
end
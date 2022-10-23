local HydraUI = select(2, ...):get()

local tinsert = table.insert
local tremove = table.remove
local GetTime = GetTime

local Throttle = HydraUI:NewModule("Throttle")
local Active = {}
local Inactive = {}

function Throttle:IsThrottled(name)
	for i = 1, #Active do
		if (Active[i][1] == name) then
			local Item = tremove(Active, i)

			if (GetTime() - Item[2] >= Item[3]) then
				tinsert(Inactive, Item)

				return false
			end

			return true
		end
	end
end

function Throttle:Exists(name)
	for i = 1, #Active do
		if (Active[i][1] == name) then
			return true
		end
	end

	for i = 1, #Inactive do
		if (Inactive[i][1] == name) then
			return true
		end
	end
end

function Throttle:Start(name, duration)
	if (not self:Exists(name)) then
		tinsert(Inactive, {name, GetTime(), duration})
	end

	if (not self:IsThrottled(name)) then
		for i = 1, #Inactive do
			if (Inactive[i][1] == name) then
				Inactive[i][2] = GetTime()

				tinsert(Active, tremove(Inactive, i))

				break
			end
		end
	end
end
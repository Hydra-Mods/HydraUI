local vUI, GUI, Language, Media, Settings, Defaults, Profiles = select(2, ...):get()

local Throttle = vUI:NewModule("Throttle")
Throttle.Inactive = {}
Throttle.Active = {}

local tinsert = table.insert
local tremove = table.remove

local OnUpdate = function(self, ela)
	for i = 1, #self.Active do
		self.Active[i].Time = self.Active[i].Time - ela
		
		if (self.Active[i].Time <= 0) then
			tinsert(self.Inactive, tremove(self.Active, i))
		end
	end
	
	if (#self.Active == 0) then
		self:SetScript("OnUpdate", nil)
	end
end

function Throttle:Create(name, duration)
	if self:Exists(name) then
		--vUI:print(format('A throttle already exists with the name "%s".', name))
		
		return
	end
	
	tinsert(self.Inactive, {Name = name, Time = duration, Duration = duration})
end

function Throttle:IsThrottled(name)
	for i = 1, #self.Active do
		if (self.Active[i].Name == name) then
			return true
		end
	end
	
	return false
end

function Throttle:GetRemaining(name)
	for i = 1, #self.Active do
		if (self.Active[i].Name == name) then
			return self.Active[i].Time
		end
	end
end

function Throttle:Exists(name)
	for i = 1, #self.Active do
		if (self.Active[i].Name == name) then
			return true
		end
	end
	
	for i = 1, #self.Inactive do
		if (self.Inactive[i].Name == name) then
			return true
		end
	end
	
	return false
end

function Throttle:Start(name)
	for i = 1, #self.Inactive do
		if (self.Inactive[i].Name == name) then
			local Throttle = tremove(self.Inactive, i)
			
			Throttle.Time = Throttle.Duration -- Reset the duration
			tinsert(self.Active, Throttle)
			
			if (not self:GetScript("OnUpdate")) then
				self:SetScript("OnUpdate", OnUpdate)
			end
			
			break
		end
	end
end

function Throttle:Stop(name)
	for i = 1, #self.Active do
		if (self.Active[i].Name == name) then
			tinsert(self.Inactive, tremove(self.Active, i))
			
			break
		end
	end
	
	if (#self.Active == 0) then
		self:SetScript("OnUpdate", nil)
	end
end
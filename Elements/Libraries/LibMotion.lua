-- LibMotion by Hydra
local Version = 1.00

if LibMotion and LibMotion.Version >= Version then -- An equal or higher version is already running
	return
end

_G.LibMotion = {Version = Version}

local pi = math.pi
local cos = math.cos
local sin = math.sin
local mod = math.fmod
local sqrt = math.sqrt
local ceil = math.ceil
local floor = math.floor
local format = string.format
local tinsert = table.insert
local tremove = table.remove

local Updater = CreateFrame("StatusBar")
local Initialize = {}
local Update = {}
local Easing = {}

local OnUpdate = function(self, elapsed)
	for i = #self, 1, -1 do
		local Anim = self[i]

		if (Anim and Anim:IsPlaying()) then
			Update[Anim.Type](Anim, elapsed)
		end
	end

	if (#self == 0) then
		self:SetScript("OnUpdate", nil)
	end
end

local Prototype = {
	Play = function(self)
		if self.Paused then
			self:FireEvent("OnResume")
		elseif Initialize[self.Type] then
			Initialize[self.Type](self)
			self:FireEvent("OnPlay")
		end

		self.Playing = true
		self.Paused = false
		self.Stopped = false
		self.Finished = false

		tinsert(Updater, self)

		if (not Updater:GetScript("OnUpdate")) then
			Updater:SetScript("OnUpdate", OnUpdate)
		end
	end,

	IsPlaying = function(self)
		return self.Playing
	end,

	Pause = function(self)
		for i = 1, #Updater do
			if (Updater[i] == self) then
				tremove(Updater, i)

				break
			end
		end

		self.Playing = false
		self.Paused = true
		self.Stopped = false
		self.Finished = false
		self:FireEvent("OnPause")
	end,

	IsPaused = function(self)
		return self.Paused
	end,

	Stop = function(self, reset)
		for i = 1, #Updater do
			if (Updater[i] == self) then
				tremove(Updater, i)

				break
			end
		end

		self.Playing = false
		self.Paused = false
		self.Stopped = true
		self.Finished = false
		self.Progress = 0

		if reset then
			self:Reset()
			self:FireEvent("OnReset")
		else
			self:FireEvent("OnStop")
		end
	end,

	IsStopped = function(self)
		return self.Stopped
	end,

	SetEasing = function(self, easing)
		easing = easing:lower()

		self.Easing = Easing[easing] and easing or "linear"
	end,

	GetEasing = function(self)
		return self.Easing
	end,

	SetDuration = function(self, duration)
		self.Duration = duration or 0
	end,

	GetDuration = function(self)
		return self.Duration
	end,

	SetProgress = function(self, progress)
		self.Progress = progress
	end,

	GetProgress = function(self)
		return self.Progress
	end,

	SetStartDelay = function(self, delay)
		self.StartDelaySetting = delay or 0
	end,

	GetStartDelay = function(self, delay)
		return self.StartDelaySetting
	end,

	SetEndDelay = function(self, delay)
		self.EndDelaySetting = delay or 0
	end,

	GetEndDelay = function(self, delay)
		return self.EndDelaySetting
	end,

	SetOrder = function(self, order)
		self.Order = order or 1

		if (self.Group and order > self.Group.MaxOrder) then
			self.Group.MaxOrder = order
		end
	end,

	GetOrder = function(self)
		return self.Order
	end,

	SetParent = function(self, parent)
		self.Parent = parent
	end,

	GetParent = function(self)
		return self.Parent
	end,

	SetGroup = function(self, group)
		if group then
			self.Order = 1
			self.Group = group

			tinsert(group.Animations, self)

			return self.Group
		elseif self.Group then
			for i = 1, #self.Group.Animations do
				if (self.Group.Animations[i] == self) then
					tremove(self.Group, i)
				end
			end

			self.Group = nil
		end
	end,

	GetGroup = function(self)
		return self.Group
	end,

	SetScript = function(self, event, func)
		event = event:lower()

		if (not self.Events) then
			self.Events = {}
		end

		self.Events[event] = func
	end,

	GetScript = function(self, event)
		if (not self.Events) then
			return
		end

		event = event:lower()

		if self.Events[event] then
			return self.Events[event]
		end
	end,

	FireEvent = function(self, event)
		if (not self.Events) then
			return
		end

		event = event:lower()

		if self.Events[event] then
			self.Events[event](self, event)
		end
	end,
}

local GroupPrototype = {
	Play = function(self)
		if self.Playing then
			return
		end

		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				self.Animations[i]:Play()
			end
		end

		self.Playing = true
		self.Paused = false
		self.Stopped = false

		self:FireEvent("OnPlay")
	end,

	IsPlaying = function(self)
		return self.Playing
	end,

	Pause = function(self)
		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				self.Animations[i]:Pause()
			end
		end

		self.Playing = false
		self.Paused = true
		self.Stopped = false

		self:FireEvent("OnPause")
	end,

	IsPaused = function(self)
		return self.Paused
	end,

	Stop = function(self)
		for i = 1, #self.Animations do
			self.Animations[i]:Stop()
		end

		self.Playing = false
		self.Paused = false
		self.Stopped = true
		self.Order = 1

		self:FireEvent("OnStop")
	end,

	IsStopped = function(self)
		return self.Stopped
	end,

	SetLooping = function(self, shouldLoop)
		self.Looping = shouldLoop
	end,

	GetLooping = function(self)
		return self.Looping
	end,

	SetScript = function(self, event, func)
		event = event:lower()

		if (not self.Events) then
			self.Events = {}
		end

		self.Events[event] = func
	end,

	GetScript = function(self, event)
		if (not self.Events) then
			return
		end

		event = event:lower()

		if self.Events[event] then
			return self.Events[event]
		end
	end,

	FireEvent = function(self, event)
		if (not self.Events) then
			return
		end

		event = event:lower()

		if self.Events[event] then
			self.Events[event](self, event)
		end
	end,

	CheckOrder = function(self)
		if (not self.Animations) then
			return
		end

		-- Check if we're done all animations at the current order, then proceed to the next order.
		local NumAtOrder = 0
		local NumDoneAtOrder = 0

		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				NumAtOrder = NumAtOrder + 1

				if (not self.Animations[i].Playing) then
					NumDoneAtOrder = NumDoneAtOrder + 1
				end
			end
		end

		-- All the animations at x order finished, go to next order
		if (NumAtOrder == NumDoneAtOrder) then
			self.Order = self.Order + 1

			-- We exceeded max order, reset to 1 and bail the function, or restart if we're looping
			if (self.Order > self.MaxOrder) then
				self.Order = 1

				self:FireEvent("OnFinished")

				if (self.Stopped or not self.Looping) then
					self.Playing = false

					return
				end
			end

			self:FireEvent("OnLoop")

			-- Play!
			for i = 1, #self.Animations do
				if (self.Animations[i].Order == self.Order) then
					self.Animations[i]:Play()
				end
			end
		end
	end,
}

local AnimMethods = {
	move = {
		SetOffset = function(self, x, y)
			self.XSetting = x or 0
			self.YSetting = y or 0
		end,

		GetOffset = function(self)
			return self.XSetting, self.YSetting
		end,

		SetSmoothPath = function(self, smooth)
			self.SmoothPathSetting = smooth
		end,

		GetSmoothPath = function(self)
			return self.SmoothPathSetting
		end,

		Reset = function(self)
			self.Progress = 0
			self.Parent:ClearAllPoints()
			self.Parent:SetPoint(self.A1, self.P, self.A2, self.StartX, self.StartY)
		end,

		Finish = function(self)
			self:Stop()

			self.Parent:ClearAllPoints()
			self.Parent:SetPoint(self.A1, self.P, self.A2, self.EndX, self.EndY)
		end,
	},

	fade = {
		SetChange = function(self, alpha)
			self.EndAlphaSetting = alpha or 0
		end,

		GetChange = function(self)
			return self.EndAlphaSetting
		end,

		Reset = function(self)
			self.Progress = 0
			self.Parent:SetAlpha(self.StartAlpha)
		end,

		Finish = function(self)
			self:Stop()
			self.Parent:SetAlpha(self.EndAlpha)
		end,
	},

	height = {
		SetChange = function(self, height)
			self.EndHeightSetting = height or 0
		end,

		GetChange = function(self)
			return self.EndHeightSetting
		end,

		Reset = function(self)
			self.Progress = 0
			self.Parent:SetHeight(self.StartHeight)
		end,

		Finish = function(self)
			self:Stop()
			self.Parent:SetHeight(self.EndHeight)
		end,
	},

	width = {
		SetChange = function(self, width)
			self.EndWidthSetting = width or 0
		end,

		GetChange = function(self)
			return self.EndWidthSetting
		end,

		Reset = function(self)
			self.Progress = 0
			self.Parent:SetWidth(self.StartWidth)
		end,

		Finish = function(self)
			self:Stop()
			self.Parent:SetWidth(self.EndWidth)
		end,
	},

	color = {
		SetChange = function(self, r, g, b)
			self.EndRSetting = r or 1
			self.EndGSetting = g or 1
			self.EndBSetting = b or 1
		end,

		GetChange = function(self)
			return self.EndRSetting, self.EndGSetting, self.EndBSetting
		end,

		SetColorType = function(self, region)
			region = region:lower()

			self.ColorType = ColorSet[region] and region or "border"
		end,

		GetColorType = function(self)
			return self.ColorType
		end,

		Reset = function(self)
			self.Progress = 0
			ColorSet[self.ColorType](self.Parent, self.StartR, self.StartG, self.StartB)
		end,

		Finish = function(self)
			self:Stop()
			ColorSet[self.ColorType](self.Parent, self.EndR, self.EndG, self.EndB)
		end,
	},

	progress = {
		SetChange = function(self, value)
			self.EndValueSetting = value or 0
		end,

		GetChange = function(self)
			return self.EndValueSetting
		end,

		Reset = function(self)
			self.Progress = 0
			self.Parent:SetValue(self.StartValue)
		end,

		Finish = function(self)
			self:Stop()
			self.Parent:SetValue(self.EndValue)
		end,
	},

	number = {
		SetChange = function(self, value)
			self.EndNumberSetting = value or 0
		end,

		GetChange = function(self)
			return self.EndNumberSetting
		end,

		SetStart = function(self, value)
			self.StartNumber = value
		end,

		GetStart = function(self)
			return self.StartNumber
		end,

		SetPrefix = function(self, text)
			self.Prefix = text or ""
		end,

		GetPrefix = function(self)
			return self.Prefix
		end,

		SetPostfix = function(self, text)
			self.Postfix = text or ""
		end,

		GetPostfix = function(self)
			return self.Postfix
		end,

		Reset = function(self)
			self.Progress = 0
			self.Parent:SetText(self.StartNumber)
		end,

		Finish = function(self)
			self:Stop()
			self.Parent:SetText(self.EndNumber)
		end,
	},

	scale = {
		SetChange = function(self, scale)
			self.EndScaleSetting = scale or 0
		end,

		GetChange = function(self)
			return self.EndScaleSetting
		end,

		Reset = function(self)
			self.Progress = 0
		end,

		Finish = function(self)
			self:Stop()
			self.Parent:SetScale(self.EndScale)
		end,
	},

	path = {
		SetPath = function(self, path)
			self.PathSetting = path
		end,
		
		GetPath = function(self)
			return self.PathSetting
		end,

		SetSmoothPath = function(self, smooth)
			self.SmoothPathSetting = smooth
		end,
		
		GetSmoothPath = function(self)
			return self.SmoothPathSetting
		end,
	},

	gif = {
		SetFrameDuration = function(self, duration)
			self.FrameDurationSetting = duration
		end,

		GetFrameDuration = function(self)
			return self.FrameDurationSetting
		end,

		SetFrames = function(self, list)
			self.TextureFramesSetting = list
		end,

		GetFrames = function(self)
			return self.TextureFramesSetting
		end,
	},

	typewriter = {

	},
}

-- Library functions

function LibMotion:CreateAnimationGroup()
	local Group = setmetatable({}, {__index = GroupPrototype})

	Group.Playing = false
	Group.Paused = false
	Group.Stopped = false
	Group.Order = 1
	Group.MaxOrder = 1
	Group.Animations = {}

	return Group
end

function LibMotion:CreateAnimation(parent, animtype)
	local Type = animtype:lower()
	local Methods = AnimMethods[Type]

	if (not Methods) then
		return
	end

	local Animation = setmetatable({}, {
		__index = function(self, key)
			local Method = Methods[key]

			if Method then
				return Method
			end

			return Prototype[key]
		end
	})

	Animation.Type = Type
	Animation.Parent = parent
	Animation.Paused = false
	Animation.Playing = false
	Animation.Stopped = false
	Animation.Finished = false
	Animation.Looping = false
	Animation.Duration = 0.3
	Animation.Easing = "linear"
	Animation.Order = 1
	Animation.StartDelay = 0
	Animation.EndDelay = 0

	return Animation
end

-- Easing types

-- Linear easing
Easing.linear = function(t, b, c, d)
	return c * t / d + b
end

-- Quadratic easing
Easing.inquadratic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 2) + b
end

Easing.outquadratic = function(t, b, c, d)
	t = t / d

	return -c * t * (t - 2) + b
end

Easing.inoutquadratic = function(t, b, c, d)
	t = t / d * 2

	if (t < 1) then
		return c / 2 * (t ^ 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

-- Cubic easing
Easing.incubic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 3) + b
end

Easing.outcubic = function(t, b, c, d)
	t = t / d - 1

	return c * (t ^ 3 + 1) + b
end

Easing.inoutcubic = function(t, b, c, d)
	t = t / d * 2

	if (t < 1) then
		return c / 2 * (t ^ 3) + b
	else
		t = t - 2

		return c / 2 * (t ^ 3 + 2) + b
	end
end

-- Quartic easing
Easing.inquartic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 4) + b
end

Easing.outquartic = function(t, b, c, d)
	t = t / d - 1

	return -c * (t ^ 4 - 1) + b
end

Easing.inoutquartic = function(t, b, c, d)
	t = t / d * 2

	if (t < 1) then
		return c / 2 * t ^ 4 + b
	else
		t = t - 2

		return -c / 2 * (t ^ 4 - 2) + b
	end
end

-- Quintic easing
Easing.inquintic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 5) + b
end

Easing.outquintic = function(t, b, c, d)
	t = t / d - 1

	return c * (t ^ 5 + 1) + b
end

Easing.inoutquintic = function(t, b, c, d)
	t = t / d * 2

	if (t < 1) then
		return c / 2 * t ^ 5 + b
	else
		t = t - 2

		return c / 2 * (t ^ 5 + 2) + b
	end
end

-- Sinusoidal easing
Easing.insinusoidal = function(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

Easing.outsinusoidal = function(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

Easing.inoutsinusoidal = function(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

-- Exponential easing
Easing.inexponential = function(t, b, c, d)
	if (t == 0) then
		return b
	else
		return c * (2 ^ (10 * (t / d - 1))) + b - c * 0.001
	end
end

Easing.outexponential = function(t, b, c, d)
	if (t == d) then
		return b + c
	else
		return c * 1.001 * (-(2 ^ (-10 * t / d)) + 1) + b
	end
end

Easing.inoutexponential = function(t, b, c, d)
	if (t == 0) then
		return b
	end

	if (t == d) then
		return b + c
	end

	t = t / d * 2

	if (t < 1) then
		return c / 2 * (2 ^ (10 * (t - 1))) + b - c * 0.0005
	else
		t = t - 1

		return c / 2 * 1.0005 * (-(2 ^ (-10 * t)) + 2) + b
	end
end

-- Circular easing
Easing.incircular = function(t, b, c, d)
	t = t / d

	return (-c * (sqrt(1 - t * t) - 1) + b)
end

Easing.outcircular = function(t, b, c, d)
	t = t / d - 1

	return (c * sqrt(1 - t * t) + b)
end

Easing.inoutcircular = function(t, b, c, d)
	t = t / d * 2

	if (t < 1) then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2

		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

-- Bounce easing
Easing.outbounce = function(t, b, c, d)
	t = t / d

	if (t < (1 / 2.75)) then
		return c * (7.5625 * t * t) + b
	elseif (t < (2 / 2.75)) then
		t = t - (1.5 / 2.75)

		return c * (7.5625 * t * t + 0.75) + b
	elseif (t < (2.5 / 2.75)) then
		t = t - (2.25 / 2.75)

		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)

		return c * (7.5625 * t * t + 0.984375) + b
	end
end

Easing.inbounce = function(t, b, c, d)
	return c - Easing.outbounce(d - t, 0, c, d) + b
end

Easing.inoutbounce = function(t, b, c, d)
	if (t < d / 2) then
		return Easing.inbounce(t * 2, 0, c, d) * 0.5 + b
	else
		return Easing.outbounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
	end
end

-- Elastic easing
Easing.inelastic = function(t, b, c, d)
	if (t == 0) then
		return b
	end

	t = t / d

	if (t == 1) then
		return b + c
	end

	local a = c
	local p = d * 0.3
	local s = p / 4

	t = t - 1

	return -(a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

Easing.outelastic = function(t, b, c, d)
	if (t == 0) then
		return b
	end

	t = t / d

	if (t == 1) then
		return b + c
	end

	local a = c
	local p = d * 0.3
	local s = p / 4

	return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

Easing.inoutelastic = function(t, b, c, d)
	if (t == 0) then
		return b
	end

	t = t / d * 2

	if (t == 2) then
		return b + c
	end

	local a = c
	local p = d * (0.3 * 1.5)
	local s = p / 4

	if (t < 1) then
		t = t - 1

		return -0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1

		return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	end
end

-- Simple options
Easing['in'] = Easing.inquadratic
Easing.out = Easing.outquadratic
Easing.inout = Easing.inoutquadratic

-- Animation types

-- Movement
Initialize.move = function(self)
	if self:IsPlaying() then
		return
	end

	local A1, P, A2, X, Y = self.Parent:GetPoint()

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.A1 = A1
	self.P = P
	self.A2 = A2
	self.StartX = X
	self.EndX = X + self.XSetting or 0
	self.StartY = Y
	self.EndY = Y + self.YSetting or 0
	self.XChange = self.EndX - self.StartX
	self.YChange = self.EndY - self.StartY

	if self.SmoothPathSetting then
		if (self.XChange == 0 or self.YChange == 0) then -- check if we're valid to be rounded
			self.SmoothPathSetting = false
		end
	end
end

Update.move = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetPoint(self.A1, self.P, self.A2, self.EndX, self.EndY)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
    else
        local EasingValue = Easing[self.Easing](self.Progress, 0, 1, 1)

        if self.SmoothPathSetting then
            self.XOffset = self.StartX + self.XChange * EasingValue
            self.YOffset = self.StartY + self.YChange * EasingValue + (self.Duration / pi) * sin(EasingValue * pi)
        else
            self.XOffset = self.StartX + self.XChange * EasingValue
            self.YOffset = self.StartY + self.YChange * EasingValue
        end

        self.Parent:SetPoint(self.A1, self.P, self.A2, (self.EndX ~= 0 and self.XOffset or self.StartX), (self.EndY ~= 0 and self.YOffset or self.StartY))
    end
end

-- Fade
Initialize.fade = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.StartAlpha = self.Parent:GetAlpha() or 1
	self.EndAlpha = self.EndAlphaSetting or 0
	self.Change = self.EndAlpha - self.StartAlpha
end

Update.fade = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

            self.Parent:SetAlpha(self.EndAlpha)
            self.Playing = false
            self.Finished = true
            self:FireEvent("OnFinished")

            if self.Group then
                self.Group:CheckOrder()
            end
        end
    else
        self.Parent:SetAlpha(Easing[self.Easing](self.Progress, self.StartAlpha, self.Change, 1))
    end
end

-- Height
Initialize.height = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.StartHeight = self.Parent:GetHeight() or 0
	self.EndHeight = self.EndHeightSetting or 0
	self.HeightChange = self.EndHeight - self.StartHeight
end

Update.height = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetHeight(self.EndHeight)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
    else
        self.Parent:SetHeight(Easing[self.Easing](self.Progress, self.StartHeight, self.HeightChange, 1))
    end
end

-- Width
Initialize.width = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.StartWidth = self.Parent:GetWidth() or 0
	self.EndWidth = self.EndWidthSetting or 0
	self.WidthChange = self.EndWidth - self.StartWidth
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
end

Update.width = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetWidth(self.EndWidth)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
	else
		self.Parent:SetWidth(Easing[self.Easing](self.Progress, self.StartWidth, self.WidthChange, 1))
	end
end

-- Color
local InterpolateRGB = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local Texture = Updater:CreateTexture()
local FontString = Updater:CreateFontString()

local ColorSet = {
	backdrop = Updater.SetBackdropColor,
	border = Updater.SetBackdropBorderColor,
	statusbar = Updater.SetStatusBarColor,
	text = FontString.SetTextColor,
	texture = Texture.SetTexture,
	vertex = Texture.SetVertexColor,
}

local ColorGet = {
	backdrop = Updater.GetBackdropColor,
	border = Updater.GetBackdropBorderColor,
	statusbar = Updater.GetStatusBarColor,
	text = FontString.GetTextColor,
	texture = Texture.GetVertexColor,
	vertex = Texture.GetVertexColor,
}

Initialize.color = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.ColorType = self.ColorType or "backdrop"
	self.StartR, self.StartG, self.StartB = ColorGet[self.ColorType](self.Parent)
	self.EndR = self.EndRSetting or 1
	self.EndG = self.EndGSetting or 1
	self.EndB = self.EndBSetting or 1
end

Update.color = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

	if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			ColorSet[self.ColorType](self.Parent, self.EndR, self.EndG, self.EndB)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
	else
		ColorSet[self.ColorType](self.Parent, InterpolateRGB(Easing[self.Easing](self.Progress, 0, 1, 1), self.StartR, self.StartG, self.StartB, self.EndR, self.EndG, self.EndB))
	end
end

-- Progress
Initialize.progress = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.StartValue = self.Parent:GetValue() or 0
	self.EndValue = self.EndValueSetting or 0
	self.ProgressChange = self.EndValue - self.StartValue
end

Update.progress = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

	if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetValue(self.EndValue)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
	else
		self.Parent:SetValue(Easing[self.Easing](self.Progress, self.StartValue, self.ProgressChange, 1))
	end
end

-- Number
Initialize.number = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0

	if (not self.StartNumber) then
		self.StartNumber = tonumber(self.Parent:GetText()) or 0
	end

	self.EndNumber = self.EndNumberSetting or 0
	self.NumberChange = self.EndNumberSetting - self.StartNumber
	self.Prefix = self.Prefix or ""
	self.Postfix = self.Postfix or ""
end

Update.number = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

	if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetText(format("%s%d%s", self.Prefix, floor(self.EndNumber), self.Postfix))
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
	else
		self.Parent:SetText(format("%s%d%s", self.Prefix, floor(Easing[self.Easing](self.Progress, self.StartNumber, self.NumberChange, 1)), self.Postfix))
	end
end

-- Scale
Initialize.scale = function(self)
	if self:IsPlaying() then
		return
	end

	self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
	self.StartScale = self.Parent:GetScale() or 1
	self.EndScale = self.EndScaleSetting or 1
	self.ScaleChange = self.EndScale - self.StartScale
end

Update.scale = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

	if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetScale(self.EndScale)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
	else
		self.Parent:SetScale(Easing[self.Easing](self.Progress, self.StartScale, self.ScaleChange, 1))
	end
end

-- Path
local GenerateSmoothPath = function(path) -- Cubic spline interpolation for buttery paths
    local SmoothPath = {}

    for i = 1, #path - 1 do
        local P0 = path[i - 1] or path[i]
        local P1 = path[i]
        local P2 = path[i + 1]
        local P3 = path[i + 2] or P2

        for t = 0, 1, 0.1 do -- Lowering 0.1 will increase how many points are generated
            local t2 = t * t
            local t3 = t2 * t
            local factor1 = 2 * P1
            local factor2 = P2 - P0
            local factor3 = 2 * P0 - 5 * P1 + 4 * P2 - P3
            local factor4 = -P0 + 3 * P1 - 3 * P2 + P3

            local X = 0.5 * (factor1 + (factor2 * t) + (factor3 * t2) + (factor4 * t3))
            local Y = 0.5 * (factor1 + (factor2 * t) + (factor3 * t2) + (factor4 * t3))

            tinsert(SmoothPath, {X, Y})
        end
    end

    return SmoothPath
end

Initialize.path = function(self)
	if self:IsPlaying() then
		return
	end

    local A1, P, A2, X, Y = self.Parent:GetPoint()

    self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
    self.A1 = A1
    self.P = P
    self.A2 = A2
    self.StartX = X
    self.StartY = Y
    self.Path = self.PathSetting or {}
    self.SmoothPath = self.SmoothPathSetting and GenerateSmoothPath(self.Path) or self.Path
    self.PathLength = #self.SmoothPath - 1
    self.SegmentDurations = {}

    local TotalDuration = self.Duration

    for i = 1, self.PathLength do
        local SegmentDuration = TotalDuration / self.PathLength
        self.SegmentDurations[i] = SegmentDuration
        TotalDuration = TotalDuration - SegmentDuration
    end
end

Update.path = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetPoint(self.A1, self.P, self.A2, self.StartX + self.SmoothPath[#self.SmoothPath][1], self.StartY + self.SmoothPath[#self.SmoothPath][2])
			self.Playing = false
			self.Finished = false
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
    else
        local CurrPathLength = self.PathLength * Easing[self.Easing](self.Progress, 0, 1, 1)
        local SegmentIndex = floor(CurrPathLength) + 1
        local SegmentTime = CurrPathLength - floor(CurrPathLength)

        local CurrPoint = self.SmoothPath[SegmentIndex]
        local NextPoint = self.SmoothPath[SegmentIndex + 1]

        local OffsetX = self.StartX + CurrPoint[1] + (NextPoint[1] - CurrPoint[1]) * SegmentTime
        local OffsetY = self.StartY + CurrPoint[2] + (NextPoint[2] - CurrPoint[2]) * SegmentTime

        self.Parent:SetPoint(self.A1, self.P, self.A2, OffsetX, OffsetY)
    end
end

-- GIF
Initialize.gif = function(self)
	if self:IsPlaying() then
		return
	end

    self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
    self.FrameDuration = self.FrameDurationSetting or 0.1
    self.TextureFrames = self.TextureFramesSetting or {}
    self.TotalFrames = #self.TextureFrames
end

Update.gif = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.FrameDuration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
    else
        local Texture = self.TextureFrames[floor(self.Progress * self.TotalFrames) + 1]

        if Texture then
            self.Parent:SetTexture(Texture)
        end
    end
end

-- Typewriter
Initialize.typewriter = function(self)
	if self:IsPlaying() then
		return
	end

    self.Progress = 0
	self.StartDelay = self.StartDelaySetting or 0
	self.EndDelay = self.EndDelaySetting or 0
    self.Text = self.Parent:GetText() or ""
    self.Length = self.Text:len()
    self.Index = 0
end

Update.typewriter = function(self, elapsed)
	if (self.StartDelay > 0) then
		self.StartDelay = self.StartDelay - elapsed

		return
	end

    self.Progress = self.Progress + (elapsed / self.Duration)

    if (self.Progress >= 1) then
		if (self.EndDelay > 0) then
			self.EndDelay = self.EndDelay - elapsed

			return
		end

        if (not self.Finished) then
			for i = #Updater, 1, -1 do
				if (Updater[i] == self) then
					tremove(Updater, i)
					break
				end
			end

			self.Parent:SetText(self.Text)
			self.Playing = false
			self.Finished = true
			self:FireEvent("OnFinished")

			if self.Group then
				self.Group:CheckOrder()
			end
		end
    else
        local CharToShow = floor(Easing[self.Easing](self.Progress, 0, 1, 1) * self.Length) - self.Index

        if (CharToShow > 0) then
            self.Index = self.Index + CharToShow
            self.Parent:SetText(self.Text:sub(1, self.Index))
        end
    end
end
local AddOn, Namespace = ...
local tonumber = tonumber
local tostring = tostring
local select = select
local sub = string.sub
local len = string.len
local format = string.format
local floor = math.floor
local match = string.match
local reverse = string.reverse
local min = math.min
local max = math.max
local gsub = gsub
local type = type
local UnitLevel = UnitLevel
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME

local Resolution = GetCurrentResolution()
local ScreenHeight
local Scale = 1

-- Data storage
local Assets = {}
local Settings = {}
local Defaults = {}

-- GUI
local GUI = CreateFrame("Frame", nil, UIParent)

GUI.Queue = {}

function GUI:AddOptions(func)
	if (type(func) == "function") then
		tinsert(self.Queue, func)
	end
end

-- Language
local Language = {}

local Index = function(self, key)
	return key
end

setmetatable(Language, {__index = Index})

-- Core functions and data
local vUI = CreateFrame("Frame", nil, UIParent)

vUI.Modules = {}
vUI.Plugins = {}

-- Some constants
vUI.UIVersion = GetAddOnMetadata("vUI", "Version")
vUI.UserName = UnitName("player")
vUI.UserClass = select(2, UnitClass("player"))
vUI.UserRace = UnitRace("player")
vUI.UserRealm = GetRealmName()
vUI.UserLocale = GetLocale()
vUI.UserProfileKey = format("%s:%s", vUI.UserName, vUI.UserRealm)

if (vUI.UserLocale == "enGB") then
	vUI.UserLocale = "enUS"
end

local Hook = function(self, global, hook)
	if _G[global] then
		local Func
	
		if self[global] then
			Func = self[global]
		elseif (hook and self[hook]) then
			Func = self[hook]
		end
		
		if Func then
			hooksecurefunc(global, Func)
		end
	end
end

function vUI:NewModule(name)
	if self.Modules[name] then
		return self.Modules[name]
	end
	
	local Module = CreateFrame("Frame", "vUI " .. name, UIParent)
	
	Module.Name = name
	Module.Loaded = false
	Module.Hook = Hook
	
	self.Modules[name] = Module
	self.Modules[#self.Modules + 1] = Module
	
	return Module
end

function vUI:GetModule(name)
	if self.Modules[name] then
		return self.Modules[name]
	end
end

function vUI:LoadModule(name)
	if (not self.Modules[name]) then
		return
	end
	
	local Module = self.Modules[name]
	
	if ((not Module.Loaded) and Module.Load) then
		Module:Load()
		Module.Loaded = true
	end
end

function vUI:LoadModules()
	for i = 1, #self.Modules do
		if self.Modules[i].Load then
			self.Modules[i]:Load()
		end
	end
end

function vUI:NewPlugin(name)
	if self.Plugins[name] then
		return self.Plugins[name]
	end
	
	local Plugin = CreateFrame("Frame", name, UIParent)
	local Name, Title, Notes = GetAddOnInfo(name)
	local Author = GetAddOnMetadata(name, "Author")
	local Version = GetAddOnMetadata(name, "Version")
	
	Plugin.Name = Name
	Plugin.Title = Title
	Plugin.Notes = Notes
	Plugin.Author = Author
	Plugin.Version = Version
	Plugin.Loaded = false
	Plugin.Hook = Hook
	
	self.Plugins[name] = Plugin
	self.Plugins[#self.Plugins + 1] = Plugin
	
	return Plugin
end

function vUI:GetPlugin(name)
	if self.Plugins[name] then
		return self.Plugins[name]
	end
end

function vUI:LoadPlugin(name)
	if (not self.Plugins[name]) then
		return
	end
	
	local Plugin = self.Plugins[name]
	
	if ((not Plugin.Loaded) and Plugin.Load) then
		Plugin:Load()
		Plugin.Loaded = true
	end
end

function vUI:LoadPlugins()
	for i = 1, #self.Plugins do
		if self.Plugins[i].Load then
			self.Plugins[i]:Load()
		end
	end
end

function vUI:AddPluginInfo()
	if (#self.Plugins == 0) then
		return
	end
	
	local Left, Right = GUI:CreateWindow("Plugins")
	local Anchor
	
	for i = 1, #self.Plugins do
		if ((i % 2) == 0) then
			Anchor = Right
		else
			Anchor = Left
		end
		
		Anchor:CreateHeader(self.Plugins[i].Title)
		
		Anchor:CreateDoubleLine(Language["Author"], self.Plugins[i].Author)
		Anchor:CreateDoubleLine(Language["Version"], self.Plugins[i].Version)
		Anchor:CreateLine(" ")
		Anchor:CreateMessage(self.Plugins[i].Notes)
	end
	
	Left:CreateFooter()
	Right:CreateFooter()
end

-- NYI, Concept list for my preferred CVars, and those important to the UI
function vUI:SetCVars()
	C_CVar.SetCVar("countdownForCooldowns", 1)
end

--[[
	Scale comprehension references:
	https://wow.gamepedia.com/UI_Scale
	https://www.reddit.com/r/WowUI/comments/95o7qc/other_how_to_pixel_perfect_ui_xpost_rwow/
	https://www.wowinterface.com/forums/showthread.php?t=31813
--]]

function vUI:UpdateScreenHeight()
	if (C_CVar.GetCVar("gxMaximize") == "1") then -- A fullscreen resolution
		self.ScreenResolution = C_CVar.GetCVar("gxFullscreenResolution")
	else -- Windowed
		self.ScreenResolution = C_CVar.GetCVar("gxWindowedResolution")
	end
	
	ScreenHeight = tonumber(match(self.ScreenResolution, "%d+x(%d+)"))
end

vUI:UpdateScreenHeight()

local GetScale = function(x)
	return floor(Scale * x + 0.5)
end

function vUI:GetScale(x)
	return GetScale(x)
end

function vUI:SetScale(x)
	x = min(1.2, max(0.4, x))
	
	C_CVar.SetCVar("uiScale", x)
	
	self:UpdateScreenHeight()
	
	Scale = (768 / ScreenHeight) / x
	
	self.BackdropAndBorder.edgeSize = GetScale(x)
	self.Outline.edgeSize = GetScale(x)
end

function vUI:SetSuggestedScale()
	self:SetScale(self:GetSuggestedScale())
end

function vUI:GetSuggestedScale()
	return (768 / ScreenHeight)
end

function vUI:ShortValue(num)
	if (num >= 1000000) then
		return format("%.2fm", num / 1000000)
	elseif (num >= 1000) then
		return format("%dk", num / 1000)
	else
		return num
	end
end

function vUI:Comma(number)
	if (not number) then
		return
	end
	
	local Number = format("%.0f", floor(number + 0.5))
   	local Left, Number, Right = match(Number, "^([^%d]*%d)(%d+)(.-)$")
	
	return Left and Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) or number
end

vUI.Backdrop = {
	bgFile = "Interface\\AddOns\\vUI\\Assets\\Textures\\Blank.tga",
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

vUI.BackdropAndBorder = {
	bgFile = "Interface\\AddOns\\vUI\\Assets\\Textures\\Blank.tga",
	edgeFile = "Interface\\AddOns\\vUI\\Assets\\Textures\\Blank.tga",
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

vUI.Outline = {
	edgeFile = "Interface\\AddOns\\vUI\\Assets\\Textures\\Blank.tga",
	edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

vUI.TimerPool = {}

local TimerOnFinished = function(self)
	self.Hook(self.Arg)
	tinsert(vUI.TimerPool, self)
end

function vUI:StartTimer(seconds, callback, arg)
	local Timer
	
	if (not self.TimerParent) then
		self.TimerParent = CreateAnimationGroup(self)
	end
	
	if self.TimerPool[1] then
		Timer = tremove(self.TimerPool, 1)
	else
		Timer = self.TimerParent:CreateAnimation("sleep")
	end
	
	Timer.Hook = callback
	Timer.Arg = arg
	Timer:SetDuration(seconds)
	Timer:SetScript("OnFinished", TimerOnFinished)
	Timer:Play()
end

function vUI:HexToRGB(hex)
	if (not hex) then
		return
	end
	
	if (len(hex) == 8) then
		return tonumber("0x"..sub(hex, 1, 2)) / 255, tonumber("0x"..sub(hex, 3, 4)) / 255, tonumber("0x"..sub(hex, 5, 6)) / 255, tonumber("0x"..sub(hex, 7, 8)) / 255
	else
		return tonumber("0x"..sub(hex, 1, 2)) / 255, tonumber("0x"..sub(hex, 3, 4)) / 255, tonumber("0x"..sub(hex, 5, 6)) / 255
	end
end

function vUI:RGBToHex(r, g, b)
	return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function vUI:FormatTime(seconds)
	if (seconds >= 86400) then
		return format("%dd", floor(seconds / 86400 + 0.5))
	elseif (seconds >= 3600) then
		return format("%dh", floor(seconds / 3600 + 0.5))
	elseif (seconds >= 60) then
		return format("%dm", floor(seconds / 60 + 0.5))
	elseif (seconds >= 6) then
		return format("%ds", floor(seconds))
	end
	
	return format("%.1fs", seconds)
end

function vUI:Reset()
	-- Create a prompt
	--vUIData = nil
	vUIProfiles = nil
	vUIProfileData = nil
	
	ReloadUI()
end

local NewPrint = function(...)
	local NumArgs = select("#", ...)
	local String = ""
	
	if (NumArgs == 0) then
		return
	elseif (NumArgs > 1) then
		for i = 1, NumArgs do
			if (i == 1) then
				String = tostring(select(i, ...))
			else
				String = String .. " " .. tostring(select(i, ...))
			end
		end
		
		if vUI.FormatLinks then
			String = vUI.FormatLinks(String)
		end
		
		DEFAULT_CHAT_FRAME:AddMessage(String)
	else
		if vUI.FormatLinks then
			String = vUI.FormatLinks(tostring(...))
			
			DEFAULT_CHAT_FRAME:AddMessage(String)
		else
			DEFAULT_CHAT_FRAME:AddMessage(...)
		end
	end
end

setprinthandler(NewPrint)

function vUI:print(...)
	if Settings["ui-widget-color"] then
		print("|cFF" .. Settings["ui-widget-color"] .. "vUI|r:", ...)
	else
		print("|cFF" .. Defaults["ui-widget-color"] .. "vUI|r:", ...)
	end
end

function vUI:SetHeight(object, height)
	object:SetHeight(GetScale(height))
end

function vUI:SetWidth(object, width)
	object:SetWidth(GetScale(width))
end

function vUI:SetSize(object, width, height)
	object:SetSize(GetScale(width), GetScale(height or width))
end

function vUI:SetPoint(object, anchor1, parent, anchor2, x, y)
	if (type(parent) == "number") then
		parent = GetScale(parent)
	end
	
	if (type(anchor2) == "number") then
		anchor2 = GetScale(anchor2)
	end
	
	if (type(x) == "number") then
		x = GetScale(x)
	end
	
	if (type(y) == "number") then
		y = GetScale(y)
	end
	
	object:SetPoint(anchor1, parent, anchor2, x, y)
end


function vUI:SetFontInfo(object, font, size, flags)
	local Font, IsPixel = Assets:GetFont(font)
	
	if IsPixel then
		object:SetFont(Font, size, "MONOCHROME, OUTLINE")
		object:SetShadowColor(0, 0, 0, 0)
	else
		object:SetFont(Font, size, flags)
		object:SetShadowColor(0, 0, 0)
		object:SetShadowOffset(1, -1)
	end
end

function vUI:VARIABLES_LOADED(event)
	if (not C_CVar.GetCVar("useUIScale")) then
		C_CVar.SetCVar("useUIScale", 1)
	end
	
	Defaults["ui-scale"] = self:GetSuggestedScale()
	
	-- Import profile data and load a profile
	self:CreateProfileData()
	self:UpdateProfileList()
	self:ApplyProfile(self:GetActiveProfileName())
	
	self:SetScale(Settings["ui-scale"])
	self:UpdateoUFColors()
	
	-- Load the GUI
	GUI:Create()
	GUI:RunQueue()
	
	-- Show the default window
	if GUI.DefaultWindow then
		GUI:ShowWindow(GUI.DefaultWindow)
	end
	
	self:UnregisterEvent(event)
end

function vUI:PLAYER_ENTERING_WORLD(event)
	self:LoadModules()
	self:LoadPlugins()
	self:AddPluginInfo()
	
	self:UnregisterEvent(event)
end

function vUI:OnEvent(event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end

vUI:RegisterEvent("VARIABLES_LOADED")
vUI:RegisterEvent("PLAYER_ENTERING_WORLD")
vUI:SetScript("OnEvent", vUI.OnEvent)

-- Aura wrappers for lookup by name
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

local Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3

UnitAuraByName = function(unit, name, filter)
	for i = 1, 40 do
		Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3 = UnitAura(unit, i, filter)
		
		if (Name == name) then
			return Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3
		end
	end
end

UnitBuffByName = function(unit, name, filter)
	for i = 1, 40 do
		Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3 = UnitBuff(unit, i, filter)
		
		if (Name == name) then
			return Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3
		end
	end
end

UnitDebuffByName = function(unit, name, filter)
	for i = 1, 40 do
		Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3 = UnitDebuff(unit, i, filter)
		
		if (Name == name) then
			return Name, Texture, Count, DebuffType, Duration, Expiration, Caster, IsStealable, NameplateShowSelf, SpellID, CanApply, IsBossDebuff, CasterIsPlayer, NameplateShowAll, TimeMod, Effect1, Effect2, Effect3
		end
	end
end

-- Access data tables
function Namespace:get()
	return vUI, GUI, Language, Assets, Settings, Defaults
end

-- Global access
_G["vUIGlobal"] = Namespace
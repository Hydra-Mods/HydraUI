local AddOn, Namespace = ... -- HydraUI was created on May 22, 2019

-- Data storage
local Assets = {}
local Settings = {}
local Defaults = {}
local Modules = {}
local Plugins = {}
local ModuleQueue = {}
local PluginQueue = {}

-- Core functions and data
local HydraUI = CreateFrame("Frame", nil, UIParent)
HydraUI.Modules = Modules
HydraUI.Plugins = Plugins

HydraUI.UIParent = CreateFrame("Frame", "HydraUIParent", UIParent, "SecureHandlerStateTemplate")
HydraUI.UIParent:SetAllPoints(UIParent)
HydraUI.UIParent:SetFrameLevel(UIParent:GetFrameLevel())

-- Constants
HydraUI.UIVersion = GetAddOnMetadata("HydraUI", "Version")
HydraUI.UserName = UnitName("player")
HydraUI.UserClass = select(2, UnitClass("player"))
HydraUI.UserRace = UnitRace("player")
HydraUI.UserRealm = GetRealmName()
HydraUI.UserLocale = GetLocale()
HydraUI.UserProfileKey = format("%s:%s", HydraUI.UserName, HydraUI.UserRealm)
HydraUI.ClientVersion = select(4, GetBuildInfo())
HydraUI.IsClassic = HydraUI.ClientVersion > 10000 and HydraUI.ClientVersion < 20000
HydraUI.IsTBC = HydraUI.ClientVersion > 20000 and HydraUI.ClientVersion < 30000
HydraUI.IsWrath = HydraUI.ClientVersion > 30000 and HydraUI.ClientVersion < 40000
HydraUI.IsMainline = HydraUI.ClientVersion > 90000

if (HydraUI.UserLocale == "enGB") then
	HydraUI.UserLocale = "enUS"
end

-- Language
local Language = {}

local Index = function(self, key)
	return key
end

setmetatable(Language, {__index = Index})

-- Modules and plugins
function HydraUI:NewModule(name)
	local Module = self:GetModule(name)

	if Module then
		return Module
	end

	Module = CreateFrame("Frame", "HydraUI " .. name, self.UIParent, "BackdropTemplate")
	Module.Name = name

	Modules[name] = Module
	ModuleQueue[#ModuleQueue + 1] = Module

	return Module
end

function HydraUI:GetModule(name)
	if Modules[name] then
		return Modules[name]
	end
end

function HydraUI:LoadModules()
	for i = 1, #ModuleQueue do
		if (ModuleQueue[i].Load and not ModuleQueue[i].Loaded) then
			ModuleQueue[i]:Load()
			ModuleQueue[i].Loaded = true
		end
	end

	-- Wipe the queue
end

function HydraUI:NewPlugin(name)
	local Plugin = self:GetPlugin(name)

	if Plugin then
		return
	end

	local Name, Title, Notes = GetAddOnInfo(name)
	local Author = GetAddOnMetadata(name, "Author")
	local Version = GetAddOnMetadata(name, "Version")

	Plugin = CreateFrame("Frame", name, self.UIParent, "BackdropTemplate")
	Plugin.Name = Name
	Plugin.Title = Title
	Plugin.Notes = Notes
	Plugin.Author = Author
	Plugin.Version = Version

	Plugins[name] = Plugin
	PluginQueue[#PluginQueue + 1] = Plugin

	return Plugin
end

function HydraUI:GetPlugin(name)
	if Plugins[name] then
		return Plugins[name]
	end
end

function HydraUI:LoadPlugins()
	if (#PluginQueue == 0) then
		return
	end

	for i = 1, #PluginQueue do
		if PluginQueue[i].Load then
			PluginQueue[i]:Load()
		end
	end

	self:GetModule("GUI"):AddWidgets(Language["Info"], Language["Plugins"], function(left, right)
		local Anchor

		for i = 1, #PluginQueue do
			if ((i % 2) == 0) then
				Anchor = right
			else
				Anchor = left
			end

			Anchor:CreateHeader(PluginQueue[i].Title)
			Anchor:CreateDoubleLine("", Language["Author"], PluginQueue[i].Author)
			Anchor:CreateDoubleLine("", Language["Version"], PluginQueue[i].Version)
			Anchor:CreateMessage("", PluginQueue[i].Notes)
		end
	end)
end

-- Events
function HydraUI:OnEvent(event)
	-- Import profile data and load a profile
	self:CreateProfileData()
	self:UpdateProfileList()
	self:ApplyProfile(self:GetActiveProfileName())

	self:UpdateColors()
	self:UpdateoUFColors()

	self:WelcomeMessage()

	self:LoadModules()
	self:LoadPlugins()

	self:UnregisterEvent(event)
end

HydraUI:RegisterEvent("PLAYER_ENTERING_WORLD")
HydraUI:SetScript("OnEvent", HydraUI.OnEvent)

-- Access data tables
function Namespace:get()
	return HydraUI, Language, Assets, Settings, Defaults
end

-- Global access
_G.HydraUIGlobal = Namespace
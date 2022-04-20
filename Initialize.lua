local AddOn, Namespace = ...

-- Data storage
local Assets = {}
local Settings = {}
local Defaults = {}
local Modules = {}
local Plugins = {}

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
HydraUI.IsMainline = HydraUI.ClientVersion > 90000 and HydraUI.ClientVersion < 100000

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
	
	Modules[#Modules + 1] = Module
	
	return Module
end

function HydraUI:GetModule(name)
	for i = 1, #Modules do
		if (Modules[i].Name == name) then
			return Modules[i]
		end
	end
end

function HydraUI:LoadModules()
	for i = 1, #Modules do
		if (Modules[i].Load and not Modules[i].Loaded) then
			Modules[i]:Load()
			Modules[i].Loaded = true
		end
	end
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
	
	Plugins[#Plugins + 1] = Plugin
	
	return Plugin
end

function HydraUI:GetPlugin(name)
	for i = 1, #Plugins do
		if (Plugins[i].Name == name) then
			return Plugins[i]
		end
	end
end

function HydraUI:LoadPlugins()
	if (#Plugins == 0) then
		return
	end
	
	for i = 1, #Plugins do
		if Plugins[i].Load then
			Plugins[i]:Load()
		end
	end
	
	self:CreatePluginWindow()
end

function HydraUI:NewDB(name) -- for profiles, languages, settings, assets, etc. instead of creating a module which doesn't fit the bare minimum needs of these
	if self.DBs[name] then
		return self.DBs[name]
	end
	
	local DB = {}
	
	self.DBs[name] = DB
	
	return DB
end

function HydraUI:GetDB(name)
	if self.DBs[name] then
		return self.DBs[name]
	end
end

function HydraUI:CreatePluginWindow()
	self:GetModule("GUI"):AddWidgets(Language["Info"], Language["Plugins"], function(left, right)
		local Anchor
		
		for i = 1, #Plugins do
			if ((i % 2) == 0) then
				Anchor = right
			else
				Anchor = left
			end
			
			Anchor:CreateHeader(Plugins[i].Title)
			Anchor:CreateDoubleLine("", Language["Author"], Plugins[i].Author)
			Anchor:CreateDoubleLine("", Language["Version"], Plugins[i].Version)
			Anchor:CreateMessage("", Plugins[i].Notes)
		end
	end)
end

-- Events
function HydraUI:OnEvent(event)
	Defaults["ui-scale"] = self:GetSuggestedScale()
	
	-- Import profile data and load a profile
	self:CreateProfileData()
	self:UpdateProfileList()
	self:ApplyProfile(self:GetActiveProfileName())
	
	self:SetScale(Settings["ui-scale"])
	
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
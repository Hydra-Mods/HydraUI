local AddOn, Namespace = ...

-- Data storage
local Assets = {}
local Settings = {}
local Defaults = {}

-- Core functions and data
local HydraUI = CreateFrame("Frame", nil, UIParent)
HydraUI.Modules = {}
HydraUI.Plugins = {}
HydraUI.DBs = {}

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

if (HydraUI.UserLocale == "enGB") then
	HydraUI.UserLocale = "enUS"
end

-- Backdrops
HydraUI.Backdrop = {
	bgFile = "Interface\\AddOns\\HydraUI\\Assets\\Textures\\HydraUIBlank.tga",
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

HydraUI.BackdropAndBorder = {
	bgFile = "Interface\\AddOns\\HydraUI\\Assets\\Textures\\HydraUIBlank.tga",
	edgeFile = "Interface\\AddOns\\HydraUI\\Assets\\Textures\\HydraUIBlank.tga",
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

HydraUI.Outline = {
	edgeFile = "Interface\\AddOns\\HydraUI\\Assets\\Textures\\HydraUIBlank.tga",
	edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

-- GUI
local GUI = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")

-- Language
local Language = {}

local Index = function(self, key)
	return key
end

setmetatable(Language, {__index = Index})

-- Modules and plugins
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

function HydraUI:NewModule(name)
	if self.Modules[name] then
		return self.Modules[name]
	end
	
	local Module = CreateFrame("Frame", "HydraUI " .. name, self.UIParent, "BackdropTemplate")
	
	Module.Name = name
	Module.Loaded = false
	Module.Hook = Hook
	
	self.Modules[name] = Module
	self.Modules[#self.Modules + 1] = Module
	
	return Module
end

function HydraUI:GetModule(name)
	if self.Modules[name] then
		return self.Modules[name]
	end
end

function HydraUI:LoadModule(name)
	if (not self.Modules[name]) then
		return
	end
	
	local Module = self.Modules[name]
	
	if ((not Module.Loaded) and Module.Load) then
		Module:Load()
		Module.Loaded = true
	end
end

function HydraUI:LoadModules()
	for i = 1, #self.Modules do
		if (self.Modules[i].Load and not self.Modules[i].Loaded) then
			self.Modules[i]:Load()
			self.Modules[i].Loaded = true
		end
	end
end

function HydraUI:NewPlugin(name)
	if self.Plugins[name] then
		return self.Plugins[name]
	end
	
	local Plugin = CreateFrame("Frame", name, self.UIParent, "BackdropTemplate")
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

function HydraUI:GetPlugin(name)
	if self.Plugins[name] then
		return self.Plugins[name]
	end
end

function HydraUI:LoadPlugin(name)
	if (not self.Plugins[name]) then
		return
	end
	
	local Plugin = self.Plugins[name]
	
	if ((not Plugin.Loaded) and Plugin.Load) then
		Plugin:Load()
		Plugin.Loaded = true
	end
end

function HydraUI:LoadPlugins()
	if (#self.Plugins > 0) then
		for i = 1, #self.Plugins do
			if self.Plugins[i].Load then
				self.Plugins[i]:Load()
			end
		end
		
		self:CreatePluginWindow()
	end
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

-- Events
function HydraUI:CreatePluginWindow()
	GUI:AddWidgets(Language["Info"], Language["Plugins"], function(left, right)
		local Anchor
		
		for i = 1, #self.Plugins do
			if ((i % 2) == 0) then
				Anchor = right
			else
				Anchor = left
			end
			
			--[[Anchor:CreateHeader(self.Plugins[i].Title)
			Anchor:CreateDoubleLine("", Language["Author"], self.Plugins[i].Author)
			Anchor:CreateDoubleLine("", Language["Version"], self.Plugins[i].Version)
			Anchor:CreateMessage("", "|cff" .. Settings["ui-header-font-color"] .. self.Plugins[i].Notes .. "|r")]]
			
			Anchor:CreateHeader(self.Plugins[i].Title)
			Anchor:CreateDoubleLine("", Language["Author"], self.Plugins[i].Author)
			Anchor:CreateDoubleLine("", Language["Version"], self.Plugins[i].Version)
			Anchor:CreateMessage("", self.Plugins[i].Notes)
		end
	end)
end

function HydraUI:OnEvent(event)
	Defaults["ui-scale"] = self:GetSuggestedScale()
	
	-- Import profile data and load a profile
	--self:MigrateData()
	self:CreateProfileData()
	--self:MigrateMoverData()
	self:UpdateProfileList()
	self:ApplyProfile(self:GetActiveProfileName())
	
	self:SetScale(Settings["ui-scale"])
	
	self:UpdateoUFColors()
	self:UpdateColors()
	
	self:WelcomeMessage()

	self:LoadModules()
	self:LoadPlugins()
	
	self:UnregisterEvent(event)
end

HydraUI:RegisterEvent("PLAYER_ENTERING_WORLD")
HydraUI:SetScript("OnEvent", HydraUI.OnEvent)

-- Access data tables
function Namespace:get()
	return HydraUI, GUI, Language, Assets, Settings, Defaults
end

-- Global access
_G["HydraUIGlobal"] = Namespace
_G["vUIGlobal"] = Namespace -- Temporary, from May 2021
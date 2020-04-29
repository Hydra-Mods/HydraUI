local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local DeflateLevel = {level = 9}

local DefaultKey = "%s-%s"
local pairs = pairs
local format = format
local match = string.match

vUI.ProfileList = {}

vUI.ProfileMetadata = {
	["profile-name"] = true,
	["profile-created"] = true,
	["profile-created-by"] = true,
	["profile-last-modified"] = true,
}

-- Some settings shouldn't be sent to others
vUI.PreserveSettings = {
	["ui-scale"] = true,
}

function vUI:UpdateProfileList()
	if vUIProfiles then
		for Name in pairs(vUIProfiles) do
			self.ProfileList[Name] = Name
		end
	end
end

function vUI:UpdateProfileLastModified(name)
	local Profile = self:GetProfile(name)
	
	Profile["profile-last-modified"] = self:GetCurrentDate()
end

function vUI:GetProfileCount()
	local Count = 0
	
	for Name in pairs(self.ProfileList) do
		Count = Count + 1
	end
	
	return Count
end

function vUI:GetDefaultProfileKey()
	return format(DefaultKey, self.UserName, self.UserRealm)
end

function vUI:GetActiveProfileName()
	if (vUIProfileData and vUIProfileData[self.UserProfileKey]) then
		return vUIProfileData[self.UserProfileKey]
	end
end

function vUI:GetActiveProfile()
	if (vUIProfileData and vUIProfileData[self.UserProfileKey]) then
		return self:GetProfile(vUIProfileData[self.UserProfileKey])
	end
end

function vUI:SetActiveProfile(name)
	if (vUIProfileData and vUIProfileData[self.UserProfileKey]) then
		vUIProfileData[self.UserProfileKey] = name
	end
end

function vUI:CountChangedValues(name)
	local Profile = self:GetProfile(name)
	local Count = 0
	
	for ID in pairs(Profile) do
		if (not self.ProfileMetadata[ID]) then
			Count = Count + 1
		end
	end
	
	return Count
end

function vUI:CreateProfileData()
	if (not vUIProfileData) then -- No profile data exists, create a default
		self:CreateProfile(Language["Default"])
	end
	
	if (not vUIProfileData[self.UserProfileKey]) then
		vUIProfileData[self.UserProfileKey] = self:GetMostUsedProfile()
	end
end

function vUI:AddProfile(profile)
	if (type(profile) ~= "table") then
		return
	end
	
	local Name = profile["profile-name"]
	
	-- Do I overwrite the imported profile's metadata with new stuff for the player?
	
	if (Name and not vUIProfiles[Name]) then
		vUIProfiles[Name] = profile
		self.ProfileList[Name] = Name
		
		local Widget = GUI:GetWidgetByWindow(Language["Profiles"], "ui-profile")
		Widget.Dropdown:CreateSelection(Name, Name)
		Widget.Dropdown:Sort()
		
		self:print(format(Language['Added profile: "%s."'], Name))
	else
		self:print(format(Language['A profile already exists with the name "%s."'], Name))
	end
end

function vUI:CreateProfile(name)
	if (not vUIProfileData) then
		vUIProfileData = {}
	end
	
	if (not vUIProfiles) then
		vUIProfiles = {}
	end
	
	if (not name) then
		name = self:GetDefaultProfileKey()
	end
	
	if (not vUIProfileData[self.UserProfileKey]) then
		vUIProfileData[self.UserProfileKey] = name
	end
	
	if vUIProfiles[name] then
		self.ProfileList[name] = name
		
		return vUIProfiles[name]
	end
	
	vUIProfiles[name] = {}
	
	-- Some metadata just for additional information
	vUIProfiles[name]["profile-name"] = name
	vUIProfiles[name]["profile-created"] = self:GetCurrentDate()
	vUIProfiles[name]["profile-created-by"] = self:GetDefaultProfileKey()
	vUIProfiles[name]["profile-last-modified"] = self:GetCurrentDate()
	
	--vUIProfileData[self.UserProfileKey] = name
	
	self.ProfileList[name] = name
	
	return vUIProfiles[name]
end

function vUI:RestoreToDefault(name)
	if (not vUIProfiles[name]) then
		return
	end
	
	for ID in pairs(vUIProfiles[name]) do
		if (not self.ProfileMetadata[ID]) then
			vUIProfiles[name][ID] = nil
		end
	end
	
	self:print(format('Restored profile "%s" to default.', name))
end

function vUI:GetProfile(name)
	if vUIProfiles[name] then
		return vUIProfiles[name]
	else
		local Default = self:GetMostUsedProfile()
		
		if (not Default) then
			return self:CreateProfile(Language["Default"])
		elseif (Default and vUIProfiles[Default]) then
			return vUIProfiles[Default]
		end
	end
end

function vUI:GetProfileList()
	return self.ProfileList
end

function vUI:IsUsedBy(name)
	
end

function vUI:GetMostUsedProfile() -- Return most used profile as a fallback instead of "Default" which may not even exist if the user deletes it
	local Temp = {}
	local HighestValue = 0
	local HighestName
	
	for Key, ProfileName in pairs(vUIProfileData) do
		if (not Temp[ProfileName]) then -- In case we renamed something
			Temp[ProfileName] = 0
		end
		
		Temp[ProfileName] = (Temp[ProfileName] or 0) + 1
	end
	
	for Name, Value in pairs(Temp) do
		if (Value > HighestValue) then
			HighestValue = Value
			HighestName = Name
		end
	end
	
	return HighestName, vUIProfileData[HighestName]
end

function vUI:GetNumServedByProfile(name)
	local Count = 0
	local Total = 0
	
	for Key, ProfileName in pairs(vUIProfileData) do
		if (ProfileName == name) then
			Count = Count + 1
		end
		
		Total = Total + 1
	end
	
	return Count, (Count == Total)
end

function vUI:DeleteProfile(name)
	if vUIProfiles[name] then
		vUIProfiles[name] = nil
		self.ProfileList[name] = nil
		
		local Default = self:GetMostUsedProfile()
		
		-- If we just wiped out a profile that characters were using, reroute them to an existing profile.
		for Key, ProfileName in pairs(vUIProfileData) do
			if (ProfileName == name) then
				vUIProfileData[Key] = Default
			end
		end
		
		self:print(format('Deleted profile "%s".', name))
	else
		self:print(format('No profile exists with the name "%s".', name))
	end
	
	if (self:GetProfileCount() == 0) then
		self:CreateProfile(Language["Default"]) -- If we just deleted our last profile, make a new default.
		
		for Key in pairs(vUIProfileData) do
			vUIProfileData[Key] = Language["Default"]
		end
	end
end

function vUI:MergeWithDefaults(name)
	local Profile = self:GetProfile(name)
	local Values = {}
	
	-- Collect default values
	for ID, Value in pairs(Defaults) do
		Values[ID] = Value
	end
	
	-- And apply stored values
	if Profile then
		for ID, Value in pairs(Profile) do
			Values[ID] = Value
		end
	end
	
	return Values
end

function vUI:ApplyProfile(name)
	local Values = self:MergeWithDefaults(name)
	
	for ID, Value in pairs(Values) do
		Settings[ID] = Value
	end
	
	vUIProfileData[self.UserProfileKey] = name
	
	Values = nil
end

function vUI:DeleteEmptyProfiles()
	local Count = 0
	local Deleted = 0
	
	for Name, Value in pairs(vUIProfiles) do
		Count = 0
		
		for ID in pairs(Value) do
			if (not self.ProfileMetadata[ID]) then
				Count = Count + 1
			end
		end
		
		if (Count == 0) then
			self:DeleteProfile(Name)
			
			Deleted = Deleted + 1
		end
	end
	
	self:print(format("Deleted %s empty profiles.", Deleted))
end

function vUI:CountEmptyProfiles()
	local Count = 0
	local Total = 0
	
	for Name, Value in pairs(vUIProfiles) do
		Count = 0
		
		for ID in pairs(Value) do
			if (not self.ProfileMetadata[ID]) then
				Count = Count + 1
			end
		end
		
		if (Count == 0) then
			Total = Total + 1
		end
	end
	
	return Total
end

function vUI:DeleteUnusedProfiles()
	local Counts = {}
	local Deleted = 0
	
	self:UpdateProfileList()
	
	for Name in pairs(self.ProfileList) do
		Counts[Name] = 0
	end
	
	for Key, ProfileName in pairs(vUIProfileData) do
		if (not Counts[ProfileName]) then -- In case we renamed something
			Counts[ProfileName] = 0
		end
		
		Counts[ProfileName] = Counts[ProfileName] + 1
	end
	
	for Name, Total in pairs(Counts) do
		if (Total == 0) then
			self:DeleteProfile(Name)
			
			Deleted = Deleted + 1
		end
	end
	
	Counts = nil
	
	self:print(format("Deleted %s unused profiles.", Deleted))
end

function vUI:CountUnusedProfiles()
	local Counts = {}
	local Unused = 0
	
	self:UpdateProfileList()
	
	for Name in pairs(self.ProfileList) do
		Counts[Name] = 0
	end
	
	for Key, ProfileName in pairs(vUIProfileData) do
		if (not Counts[ProfileName]) then -- In case we renamed something
			Counts[ProfileName] = 0
		end
	
		Counts[ProfileName] = Counts[ProfileName] + 1
	end
	
	for Name, Total in pairs(Counts) do
		if (Total == 0) then
			Unused = Unused + 1
		end
	end
	
	Counts = nil
	
	return Unused
end

function vUI:RenameProfile(from, to)
	if (not vUIProfiles[from]) then
		return
	elseif vUIProfiles[to] then
		self:print(format('A profile already exists with the name "%s".', to))
		
		return
	end
	
	vUIProfiles[to] = vUIProfiles[from]
	vUIProfiles[to]["profile-name"] = to
	
	vUIProfiles[from] = nil
	self.ProfileList[from] = nil
	self.ProfileList[to] = to
	
	-- Reroute characters who used this profile
	for Key, ProfileName in pairs(vUIProfileData) do
		if (ProfileName == from) then
			vUIProfileData[Key] = to
		end
	end
	
	-- Update dropdown menu if needed
	
	self:print(format('Profile "%s" has been renamed to "%s".', from, to))
end

function vUI:CopyProfile(from, to)
	if (not vUIProfiles[from]) or (not vUIProfiles[to]) then
		return
	end
	
	local ToProfile = vUIProfiles[to]
	
	for Name, Value in pairs(vUIProfiles[from]) do
		for ID in pairs(Value) do
			if (not self.ProfileMetadata[ID]) then
				ToProfile[ID] = Value
			end
		end
	end
	
	self:print(format('Profile "%s" has been copied from "%s".', to, from))
end

function vUI:SetProfileMetadata(name, meta, value) -- /run vUI:get(1):SetProfileMetadata("ProfileName", "profile-created-by", "Hydra")
	if (vUIProfiles[name] and self.ProfileMetadata[meta]) then
		vUIProfiles[name][meta] = value
	end
end

function vUI:UpdateProfileInfo()
	local Name = self:GetActiveProfileName()
	local Profile = self:GetProfile(Name)
	local MostUsed = self:GetMostUsedProfile()
	local NumServed, IsAll = self:GetNumServedByProfile(Name)
	local MostUsedServed = NumServed
	
	if IsAll then
		NumServed = format("%d (%s)", NumServed, Language["All"])
	end
	
	if (Profile ~= MostUsed) then
		MostUsedServed = self:GetNumServedByProfile(MostUsed)
	end
	
	GUI:GetWidgetByWindow(Language["Profiles"], "current-profile").Right:SetText(Name)
	GUI:GetWidgetByWindow(Language["Profiles"], "created-by").Right:SetText(Profile["profile-created-by"])
	GUI:GetWidgetByWindow(Language["Profiles"], "created-on").Right:SetText(vUI:IsToday(Profile["profile-created"]))
	GUI:GetWidgetByWindow(Language["Profiles"], "last-modified").Right:SetText(vUI:IsToday(Profile["profile-last-modified"]))
	GUI:GetWidgetByWindow(Language["Profiles"], "modifications").Right:SetText(self:CountChangedValues(Name))
	GUI:GetWidgetByWindow(Language["Profiles"], "serving-characters").Right:SetText(NumServed)
	
	GUI:GetWidgetByWindow(Language["Profiles"], "popular-profile").Right:SetText(format("%s (%d)", MostUsed, MostUsedServed))
	GUI:GetWidgetByWindow(Language["Profiles"], "stored-profiles").Right:SetText(self:GetProfileCount())
	GUI:GetWidgetByWindow(Language["Profiles"], "empty-profiles").Right:SetText(self:CountEmptyProfiles())
	GUI:GetWidgetByWindow(Language["Profiles"], "unused-profiles").Right:SetText(self:CountUnusedProfiles())
end

local AcceptNewProfile = function(value)
	vUI:SetActiveProfile(value)
	
	ReloadUI()
end

local UpdateActiveProfile = function(value)
	if (value ~= vUI:GetActiveProfileName()) then
		vUI:DisplayPopup(Language["Attention"], format(Language['Are you sure you would like to change to the current profile to "|cFF%s%s|r"?'], Settings["ui-widget-color"], value), Language["Accept"], AcceptNewProfile, Language["Cancel"], nil, value)
	end
end

local CreateProfile = function(value)
	vUI:CreateProfile(value)
	vUI:UpdateProfileInfo()
	
	local Widget = GUI:GetWidgetByWindow(Language["Profiles"], "ui-profile")
	Widget.Dropdown:CreateSelection(value, value)
	Widget.Dropdown:Sort()
end

local DeleteProfile = function(value)
	vUI:DeleteProfile(value)
	vUI:UpdateProfileInfo()
	
	local Widget = GUI:GetWidgetByWindow(Language["Profiles"], "ui-profile")
	Widget.Dropdown:RemoveSelection(value)
	Widget.Dropdown.Current:SetText(vUI:GetActiveProfileName())
end

function vUI:GetEncodedProfile()
	local Profile = vUI:GetActiveProfile()
	local Serialized = AceSerializer:Serialize(Profile)
	local Compressed = LibDeflate:CompressDeflate(Serialized, DeflateLevel)
	local Encoded = LibDeflate:EncodeForPrint(Compressed)
	
	return Encoded
end

function vUI:DecodeProfile(encoded)
	local Decoded = LibDeflate:DecodeForPrint(encoded)
	
	if (not Decoded) then
		return self:print("Failure decoding")
	end
	
	local Decompressed = LibDeflate:DecompressDeflate(Decoded)
	
	if (not Decompressed) then
		return self:print("Failure decompressing")
	end
	
	local Success, Deserialized = AceSerializer:Deserialize(Decompressed)
	
	if (not Success) then
		return self:print("Failure deserializing")
	end
	
	return Deserialized
end

local ShowExportWindow = function()
	local Encoded = vUI:GetEncodedProfile()
	
	GUI:CreateExportWindow()
	GUI:SetExportWindowText(Encoded)
	GUI:ToggleExportWindow()
end

local ShowImportWindow = function()
	GUI:CreateImportWindow()
	GUI:ToggleImportWindow()
end

local DeleteEmpty = function()
	vUI:DeleteEmptyProfiles()
	vUI:UpdateProfileInfo()
end

local DeleteUnused = function()
	vUI:DeleteUnusedProfiles()
	vUI:UpdateProfileInfo()
end

local RenameProfile = function(value)
	if (value and match(value, "%S+")) then
		vUI:RenameProfile(vUI:GetActiveProfileName(), value)
		vUI:UpdateProfileInfo()
	end
end

local UpdateProfileInfo = function()
	vUI:UpdateProfileInfo()
end

local RestoreToDefault = function()
	vUI:RestoreToDefault(vUI:GetActiveProfileName())
	
	ReloadUI() -- Temp
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Profiles"])
	
	Left:DisableScrolling()
	
	Left:CreateHeader(Language["Profiles"])
	Left:CreateDropdown("ui-profile", vUI:GetActiveProfileName(), vUI:GetProfileList(), Language["Select Profile"], Language["Select a profile to load"], UpdateActiveProfile)
	--Left:CreateButton("Apply", "Apply Current Profile", "", UpdateActiveProfile)
	
	Left:CreateHeader(Language["Modify"])
	Left:CreateInput("profile-key", vUI:GetDefaultProfileKey(), Language["Create New Profile"], Language["Create a new profile to store a different collection of settings"], CreateProfile):DisableSaving()
	Left:CreateInput("profile-delete", vUI:GetDefaultProfileKey(), Language["Delete Profile"], Language["Delete a profile"], DeleteProfile):DisableSaving()
	Left:CreateInput("profile-rename", "", Language["Rename Profile"], Language["Rename the currently selected profile"], RenameProfile):DisableSaving()
	Left:CreateButton(Language["Restore"], Language["Restore To Default"], Language["Restore the currently selected profile to default settings"], RestoreToDefault):RequiresReload(true)
	Left:CreateButton(Language["Delete"], Language["Delete Empty Profiles"], Language["Delete any profiles that have no settings that vary from default"], DeleteEmpty)
	Left:CreateButton(Language["Delete"], Language["Delete Unused Profiles"], Language["Delete any profiles that are not currently in use by any characters"], DeleteUnused)
	
	Left:CreateHeader(Language["Sharing is caring"])
	Left:CreateButton(Language["Import"], Language["Import A Profile"], "", ShowImportWindow)
	Left:CreateButton(Language["Export"], Language["Export Current Profile"], "", ShowExportWindow)
end)
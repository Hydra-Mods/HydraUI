local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

local DefaultKey = "%s-%s"
local date = date
local pairs = pairs
local format = format
local match = string.match

vUI.ProfileList = {}

--[[
	To do:
	
	vUI:CopyProfile(from, to)
--]]

vUI.ProfileMetadata = {
	["profile-name"] = true,
	["profile-created"] = true,
	["profile-created-by"] = true,
	["profile-last-modified"] = true,
}

-- Some settings shouldn't be sent to others
vUI.PreserveSettings = {
	["ui-scale"] = true,
	["ui-language"] = true,
}

function vUI:GetCurrentDate()
	return date("%Y-%m-%d %I:%M %p")
end

-- If the date given is today, change "2019-07-24 2:06 PM" to "Today 2:06 PM"
local IsToday = function(s)
	local Date, Time = match(s, "(%d+%-%d+%-%d+)%s(.+)")
	
	if (not Date or not Time) then
		return s
	end
	
	if (Date == date("%Y-%m-%d")) then
		s = format("%s %s", Language["Today"], Time)
	end
	
	return s
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
	GUI:GetWidgetByWindow(Language["Profiles"], "created-on").Right:SetText(IsToday(Profile["profile-created"]))
	GUI:GetWidgetByWindow(Language["Profiles"], "last-modified").Right:SetText(IsToday(Profile["profile-last-modified"]))
	GUI:GetWidgetByWindow(Language["Profiles"], "modifications").Right:SetText(self:CountChangedValues(Name))
	GUI:GetWidgetByWindow(Language["Profiles"], "serving-characters").Right:SetText(NumServed)
	
	GUI:GetWidgetByWindow(Language["Profiles"], "popular-profile").Right:SetText(format("%s (%d)", MostUsed, MostUsedServed))
	GUI:GetWidgetByWindow(Language["Profiles"], "stored-profiles").Right:SetText(self:GetProfileCount())
	GUI:GetWidgetByWindow(Language["Profiles"], "empty-profiles").Right:SetText(self:CountEmptyProfiles())
	GUI:GetWidgetByWindow(Language["Profiles"], "unused-profiles").Right:SetText(self:CountUnusedProfiles())
end

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
		
		self:SendAlert(Language["Import successful"], format(Language["New profile: %s"], Name))
	else
		self:print(format('A profile already exists with the name "%s."', Name))
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
		
		-- If we just wiped out a profile that characters were using, reroute them to a different profile for the time being.
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
	local FromProfile = vUIProfiles[from]
	local ToProfile = vUIProfiles[to]
	
	if (not FromProfile) then
		return
	elseif ToProfile then
		self:print(format('A profile already exists with the name "%s".', to))
		
		return
	end
	
	vUIProfiles[to] = FromProfile
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

function vUI:SetProfileMetadata(name, meta, value) -- /run vUI:get(7):SetProfileMetadata("ProfileName", "profile-created-by", "Hydra")
	if (vUIProfiles[name] and self.ProfileMetadata[meta]) then
		vUIProfiles[name][meta] = value
	end
end

local UpdateActiveProfile = function(value)
	if (value ~= vUI:GetActiveProfileName()) then
		vUI:SetActiveProfile(value)
		
		ReloadUI()
		--vUI:UpdateProfileInfo()
	end
end

local CreateProfile = function(value)
	vUI:CreateProfile(value)
	vUI:UpdateProfileInfo()
	
	local Widget = GUI:GetWidgetByWindow(Language["Profiles"], "ui-profile")
	Widget.Dropdown:CreateSelection(value, value)
	Widget.Dropdown:Sort()
	
	--ReloadUI() -- Temp
end

local DeleteProfile = function(value)
	vUI:DeleteProfile(value)
	vUI:UpdateProfileInfo()
	
	local Widget = GUI:GetWidgetByWindow(Language["Profiles"], "ui-profile")
	Widget.Dropdown:RemoveSelection(value)
	Widget.Dropdown.Current:SetText(vUI:GetActiveProfileName())
	--ReloadUI() -- Temp
end

local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local Encoder = LibCompress:GetAddonEncodeTable()

function vUI:GetEncoded()
	local Profile = self:GetActiveProfile()
	local Serialized = AceSerializer:Serialize(Profile)
	local Compressed = LibCompress:Compress(Serialized)
	local Encoded = Encoder:Encode(Compressed)
	
	return Encoded
end

function vUI:GetDecoded(encoded)
	local Decoded = Encoder:Decode(encoded)
	local Decompressed = LibCompress:Decompress(Decoded)
	local Message, Deserialized = AceSerializer:Deserialize(Decompressed)
	
	if (not Message) then
		self:print("Failure deserializing.")
	else
		return Deserialized
	end
end

-- Test
local TestvUItring = function()
	local Profile = vUI:GetActiveProfile()
	
	local Result = AceSerializer:Serialize(Profile)
	local Compressed = LibCompress:Compress(Result)
	local Encoded = Encoder:Encode(Compressed)
	
	local Decoded = Encoder:Decode(Encoded)
	local Decompressed = LibCompress:Decompress(Decoded)
	local Success, Value = AceSerializer:Deserialize(Decompressed)
	
	if Success then
		print("Success", Value["ui-display-dev-tools"])
		
		-- Merge values into settings
	else
		print(Value) -- Error
	end
end

__testSerialize = function() -- /run __testSerialize()
	TestvUItring()
end

local ShowExportWindow = function()
	local Encoded = vUI:GetEncoded()
	
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
	
	ReloadUI() -- Temp
end

local DeleteUnused = function()
	vUI:DeleteUnusedProfiles()
	vUI:UpdateProfileInfo()
	
	ReloadUI() -- Temp
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
	Left:CreateInput("profile-key", vUI:GetDefaultProfileKey(), Language["Create New Profile"], "", CreateProfile):DisableSaving()
	Left:CreateInput("profile-delete", vUI:GetDefaultProfileKey(), Language["Delete Profile"], "", DeleteProfile):DisableSaving()
	Left:CreateInput("profile-rename", "", Language["Rename Profile"], "", RenameProfile):DisableSaving()
	Left:CreateButton(Language["Restore"], Language["Restore To Default"], "", RestoreToDefault):RequiresReload(true)
	Left:CreateButton(Language["Delete"], Language["Delete Empty Profiles"], "", DeleteEmpty):RequiresReload(true)
	Left:CreateButton(Language["Delete"], Language["Delete Unused Profiles"], "", DeleteUnused):RequiresReload(true)
	
	--[[Left:CreateHeader("Sharing is caring")
	Left:CreateButton("Import", "Import A Profile", "", ShowImportWindow)
	Left:CreateButton("Export", "Export Current Profile", "", ShowExportWindow)]]
	
	Right:CreateHeader(Language["What is a profile?"])
	Right:CreateLine(Language["Profiles store your settings so that you can quickly"])
	Right:CreateLine(Language["and easily change between configurations."])
	--Right:CreateMessage(Language["Profiles store your settings so that you can quickly and easily change between configurations."])
	
	local Name = vUI:GetActiveProfileName()
	local Profile = vUI:GetProfile(Name)
	local MostUsed = vUI:GetMostUsedProfile()
	local NumServed, IsAll = vUI:GetNumServedByProfile(Name)
	local NumEmpty = vUI:CountEmptyProfiles()
	local NumUnused = vUI:CountUnusedProfiles()
	local MostUsedServed = NumServed
	
	if IsAll then
		NumServed = format("%d (%s)", NumServed, Language["All"])
	end
	
	if (Profile ~= MostUsed) then
		MostUsedServed = vUI:GetNumServedByProfile(MostUsed)
	end
	
	Right:CreateHeader(Language["Info"])
	Right:CreateDoubleLine(Language["Current Profile:"], Name)
	Right:CreateDoubleLine(Language["Created By:"], Profile["profile-created-by"])
	Right:CreateDoubleLine(Language["Created On:"], IsToday(Profile["profile-created"]))
	Right:CreateDoubleLine(Language["Last Modified:"], IsToday(Profile["profile-last-modified"]))
	Right:CreateDoubleLine(Language["Modifications:"], vUI:CountChangedValues(Name))
	Right:CreateDoubleLine(Language["Serving Characters:"], NumServed)
	
	Right:CreateHeader(Language["General"])
	Right:CreateDoubleLine(Language["Popular Profile:"], format("%s (%d)", MostUsed, MostUsedServed))
	Right:CreateDoubleLine(Language["Stored Profiles:"], vUI:GetProfileCount())
	Right:CreateDoubleLine(Language["Empty Profiles:"], NumEmpty)
	Right:CreateDoubleLine(Language["Unused Profiles:"], NumUnused)
end)
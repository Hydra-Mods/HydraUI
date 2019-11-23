local vUI, GUI, Language, Media, Settings = select(2, ...):get()
local rawget = rawget
local rawset = rawset
local type = type
local Locale
local Updated

local Index = function(self, key)
	if (not Updated) then
		if (Settings and Settings["ui-language"]) then
			Locale = Settings["ui-language"]
			Updated = true
		else
			Locale = vUI.UserLocale
		end
	end
	
	local Result = rawget(self, Locale)
	
	if (Result and Result[key]) then
		return Result[key]
	else
		return key
	end
end

local NewIndex = function(self, key, value)
	if (type(key) == "string" and type(value) == "table") then
		rawset(self, key, value)
	end
end

setmetatable(Language, {__index = Index, __newindex = NewIndex})
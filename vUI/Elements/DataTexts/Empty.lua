local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Update = function()

end

local OnEnable = function(self)
	self.Text:SetText("")
end

local OnDisable = function()

end

vUI:AddDataText("Empty", OnEnable, OnDisable, Update)